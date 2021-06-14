//
//  ContentView.swift
//  hrate WatchKit Extension
//
//  Created by Anselm Joseph on 05/12/20.
//

import SwiftUI
import os

struct ContentView: View {
    
    @ObservedObject var viewModel: ContentViewModel
    @ObservedObject var workoutManager = WorkoutManager()
    
    func viewLoaded() {
        os_log("set func")
        workoutManager.heartRateCallback = viewModel.emitSocketMessage
    }
    
    var body: some View {
        TabView {
            TabAView(viewModel: viewModel).tag("TabA")
            TabBView().tag("TabB")
        }
        .navigationTitle("HRate")
        .overlay(StartView())
        .environmentObject(workoutManager)
        .onAppear(perform: viewLoaded)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel())
            .environmentObject(WorkoutManager())
    }
}
