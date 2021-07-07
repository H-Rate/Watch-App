//
//  ContentView.swift
//  hrate
//
//  Created by Anselm Joseph on 15/06/21.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var bonjourService = BonjourService()
    @ObservedObject var watchService = WatchService()
    
    private var bonjourStatus: String {
        bonjourService.foundService ? "Disconnect" : bonjourService.searching ? "Searching" : "Search"
    }
    
    private var watchStatus: String {
        var s = ""
        guard watchService.isAppInstalled != nil && watchService.isConnectivitySupported != nil else {
            return "Loading"
        }
        if (!watchService.isAppInstalled) { s = "Install watchOS app" }
        else if (!watchService.isConnectivitySupported) { s = "Watch not supported" }
        else if (!watchService.isAppActive) { s = "Open watch app" }
        else if (watchService.isWorkoutRunning) { s = "Workout Running" }
        else { s = "Workout Stopped" }
        
        return s
    }
    
    func viewDidLoad() {
        bonjourService.serviceUrlDidChange = { _ in watchService.sendUpdatedIP() }
        watchService.requestIP = { bonjourService.serviceURL }
        
        watchService.startSession()
        bonjourService.start()
    }
    
    func sm() {
        watchService.sendMessage(message: "hello watch")
    }
    
    var body: some View {
        VStack {
            Text("HRate")
                .font(Font.system(.largeTitle, design: .rounded).weight(.bold))
                .padding()
            VStack {
                Spacer()
                Text("Server Connection Status")
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.orange))
                        .frame(width: 250, height: 100)
                        .clipped()
                        .animation(.easeIn)
                    Text(bonjourStatus)
                        .foregroundColor(Color(.systemBackground))
                        .font(.title)
                }
                Text("Watch Connection Status")
                    .padding(.top, 50)
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.orange))
                        .frame(width: 250, height: 100)
                        .clipped()
                        .animation(.easeIn)
                    Text(watchStatus)
                        .foregroundColor(Color(.systemBackground))
                        .font(.title)
                }
                Spacer()
            }
        }.onAppear(perform: viewDidLoad)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
