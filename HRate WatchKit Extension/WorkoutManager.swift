//
//  WorkoutManager.swift
//  hrate WatchKit Extension
//
//  Created by Anselm Joseph on 31/01/21.
//

import Foundation
import HealthKit
import Combine

class WorkoutManager: NSObject, ObservableObject {
    
    /// - Tag: DeclareSessionBuilder
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession!
    var builder: HKLiveWorkoutBuilder!
    
    /// - Tag: Published
    @Published var heartRate: Int = 0 {
        didSet {
            self.heartRateCallback?("\(self.heartRate)")
        }
    }
    @Published var activeCalories: Double = 0
    @Published var distance: Double = 0
    @Published var timeString: String = "0 mins"
    @Published var elapsedSeconds: Int = 0 {
        didSet {
            let h = Int(floor(Double(elapsedSeconds) / 3600));
            let m = Int(floor(Double(elapsedSeconds % 3600) / 60));
            let hString = h > 0 ? "\(h)" + (h == 1 ? " hour " : " hours ") : ""
            let mString = "\(m)" + (m == 1 ? " min" : " mins")
            timeString = hString + mString
        }
    }
    
    // The app's workout state.
    @Published var running: Bool = false
    
    /// - Tag: TimerSetup
    // The cancellable holds the timer publisher.
    var start: Date = Date()
    var cancellable: Cancellable?
    var accumulatedTime: Int = 0

    var heartRateCallback: ((String) -> Void)?

    
    // Set up and start the timer.
    func setUpTimer() {
        start = Date()
        cancellable = Timer.publish(every: 60, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.elapsedSeconds = self.incrementElapsedTime()
            }
    }
    
    // Calculate the elapsed time.
    func incrementElapsedTime() -> Int {
        let runningTime: Int = Int(-1 * (self.start.timeIntervalSinceNow))
        return self.accumulatedTime + runningTime
    }
    
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // Requesting authorization.
        /// - Tag: RequestAuthorization
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        
        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error.
        }
    }
    
    // Provide the workout configuration.
    func workoutConfiguration() -> HKWorkoutConfiguration {
        /// - Tag: WorkoutConfiguration
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        
        return configuration
    }
    
    // Start the workout.
    func startWorkout() {
        // Start the timer.
        setUpTimer()
        
        self.running = true
        
        // Create the session and obtain the workout builder.
        /// - Tag: CreateWorkout
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: self.workoutConfiguration())
            builder = session.associatedWorkoutBuilder()
        } catch {
            // Handle any exceptions.
            return
        }
        
        // Setup session and builder.
        session.delegate = self
        builder.delegate = self
        
        // Set the workout builder's data source.
        /// - Tag: SetDataSource
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                     workoutConfiguration: workoutConfiguration())
        
        // Start the workout session and begin data collection.
        /// - Tag: StartSession
        session.startActivity(with: Date())
        builder.beginCollection(withStart: Date()) { (success, error) in
            // The workout has started.
        }
    }
    
    // MARK: - State Control
    func togglePause() {
        // If you have a timer, then the workout is in progress, so pause it.
        if running == true {
            self.pauseWorkout()
        } else {// if session.state == .paused { // Otherwise, resume the workout.
            resumeWorkout()
        }
    }
    
    func pauseWorkout() {
        // Pause the workout.
        session.pause()
        // Stop the timer.
        cancellable?.cancel()
        // Save the elapsed time.
        accumulatedTime = elapsedSeconds
        running = false
    }
    
    func resumeWorkout() {
        // Resume the workout.
        session.resume()
        // Start the timer.
        setUpTimer()
        running = true
    }
    
    func endWorkout() {
        // End the workout session.
        session.end()
        cancellable?.cancel()
        
        self.running = false
    }
    
    func resetWorkout() {
        // Reset the published values.
        DispatchQueue.main.async {
            self.elapsedSeconds = 0
            self.activeCalories = 0
            self.heartRate = 0
            self.distance = 0
        }
    }
    
    // MARK: - Update the UI
    // Update the published values.
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                /// - Tag: SetLabel
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                let roundedValue = Int( round( 1 * value! ) / 1 )
                self.heartRate = roundedValue
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                let value = statistics.sumQuantity()?.doubleValue(for: energyUnit)
                self.activeCalories = Double( round( 1 * value! ) / 1 )
                return
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                let meterUnit = HKUnit.meter()
                let value = statistics.sumQuantity()?.doubleValue(for: meterUnit)
                let roundedValue = Double( round( 1 * value! ) / 1 )
                self.distance = roundedValue
                return
            default:
                return
            }
        }
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        // Wait for the session to transition states before ending the builder.
        /// - Tag: SaveWorkout
        if toState == .ended {
            print("The workout has now ended.")
            builder.endCollection(withEnd: Date()) { (success, error) in
                self.builder.finishWorkout { (workout, error) in
                    // Optionally display a workout summary to the user.
                    self.resetWorkout()
                }
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }
            
            /// - Tag: GetStatistics
            let statistics = workoutBuilder.statistics(for: quantityType)
            
            // Update the published values.
            updateForStatistics(statistics)
        }
    }
}
