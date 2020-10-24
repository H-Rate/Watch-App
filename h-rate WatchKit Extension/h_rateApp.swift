//
//  h_rateApp.swift
//  h-rate WatchKit Extension
//
//  Created by Anselm Joseph on 25/10/20.
//

import SwiftUI

@main
struct h_rateApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
