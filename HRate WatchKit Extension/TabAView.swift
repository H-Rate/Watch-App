//
//  TabAView.swift
//  HRate WatchKit Extension
//
//  Created by Anselm Joseph on 10/06/21.
//

import SwiftUI

struct TabAView: View {
    @ObservedObject var viewModel: ContentViewModel
    @EnvironmentObject var workoutManager: WorkoutManager
    
    func stopStreaming() {
        workoutManager.endWorkout()
    }
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Device Token").font(.system(size: 13));
            
            Text(viewModel.deviceToken ?? "Loading")
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .kerning(2);
            
            Spacer()
            
            Button(action: stopStreaming) {
                Text("STOP").font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .padding()
            .foregroundColor(.white)
            .buttonStyle(BorderedButtonStyle(tint: .red.opacity(5)))
        }
    }
}

struct TabAView_Previews: PreviewProvider {
    static var previews: some View {
        TabAView(viewModel: ContentViewModel())
    }
}
