//
//  ContentView.swift
//  hrate WatchKit Extension
//
//  Created by Anselm Joseph on 05/12/20.
//

import SwiftUI
import os

struct ContentView: View {
    
    @ObservedObject var watchService = WatchService()
    @ObservedObject var viewModel: ContentViewModel
    @ObservedObject var workoutManager = WorkoutManager()
    
    func viewLoaded() {
        watchService.ipDidUpdate = { urlString in viewModel.openConnection(withURL: urlString) }
        watchService.didServerStop = { viewModel.disconnect() }
        workoutManager.heartRateCallback = viewModel.emitSocketMessage
    }
    
    var body: some View {
        TabView {
            TabAView(viewModel: viewModel).tag("TabA")
            TabBView().tag("TabB")
        }
        .navigationTitle("HRate")
        .overlay(StartView())
        .overlay(ConnectionStatusView(watchService: watchService, contentViewModel: viewModel))
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
