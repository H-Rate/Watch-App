//
//  hrateApp.swift
//  hrate WatchKit Extension
//
//  Created by Anselm Joseph on 05/12/20.
//

import SwiftUI

@main
struct hrateApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(viewModel: ContentViewModel())
            }
        }
    }
}
