//
//  ContentView.swift
//  h-rate WatchKit Extension
//
//  Created by Anselm Joseph on 25/10/20.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
    private var healthStore = HKHealthStore()
    private let heartRateQuantity = HKUnit(from: "count/min")
    
    @State private var heartRate = 0
    
    func authorizeHeartRate() {
        let healthKitTypes: Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]

        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
    }
    
    func start() {
        authorizeHeartRate()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
        
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            
            process(samples, type: quantityTypeIdentifier)
        }
        
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        query.updateHandler = updateHandler

        healthStore.execute(query)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0
      
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = Int(sample.quantity.doubleValue(for: heartRateQuantity))
            }
            
            print(lastHeartRate)
            
            DispatchQueue.main.async {
                self.heartRate = lastHeartRate
            }
        }
    }
    
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Spacer()
                Text("HRate")
                    .font(.title3)
                    .fontWeight(.black)
            }
            Spacer()
            VStack {
                Text("\(self.heartRate)")
                    .font(Font.system(size: 60))
                    .fontWeight(.black)
                    .kerning(1)
                Text("BPM")
                    .fontWeight(.bold)
            }
            Spacer()
        }.onAppear(perform: start)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
