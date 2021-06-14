//
//  TabBView.swift
//  HRate WatchKit Extension
//
//  Created by Anselm Joseph on 10/06/21.
//

import SwiftUI

struct TabBView: View {
    
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("\(workoutManager.heartRate)")
                .font(.system(size: 50))
                .fontWeight(.black).kerning(2);
            
            Text("BPM")
                .font(.system(size: 13))
                .fontWeight(.bold);
            
            Spacer();
            
            Text(workoutManager.timeString)
        }
    }
}

struct TabBView_Previews: PreviewProvider {
    static var previews: some View {
        TabBView()
    }
}
