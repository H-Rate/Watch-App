//
//  StartView.swift
//  HRate WatchKit Extension
//
//  Created by Anselm Joseph on 05/02/21.
//

import SwiftUI

struct StartView: View {
    
    @EnvironmentObject var workoutManager: WorkoutManager
    
    private let screenHeight = WKInterfaceDevice.current().screenBounds.size.height
    
    func startAction() {
        workoutManager.startWorkout()
    }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            RunButton(action: startAction)
            .onAppear(perform: {
                self.workoutManager.requestAuthorization()
            })
        }
        .offset(CGSize(width: 0, height: self.workoutManager.running ? self.screenHeight : 0))
        .animation(.easeInOut(duration: 0.3))
    }
}


struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}

