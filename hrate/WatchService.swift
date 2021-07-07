//
//  WatchService.swift
//  hrate
//
//  Created by Anselm Joseph on 16/06/21.
//

import Foundation
import WatchConnectivity

class WatchService: NSObject, ObservableObject {
    @Published var isAppInstalled: Bool!
    @Published var isConnectivitySupported: Bool!
    @Published var isAppActive: Bool!
    @Published var isWorkoutRunning = false
    
    var requestIP: (() -> String?)? = nil
    
    func startSession() {
        isConnectivitySupported = WCSession.isSupported()
        
        if (isConnectivitySupported) {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendUpdatedIP() {
        if let ip = requestIP?() {
            sendMessage(message: ["updated_ip": ip])
        } else {
            sendMessage(message: ["server_stopped": true])
        }
    }
    
    func sendMessage(message: [String: Any]) {
        func errorHandler(error: Error) {
            print("error", error)
        }
        
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: errorHandler)
    }
    
    func sendMessage(message: String) {
        sendMessage(message: ["message": message])
    }
}


extension WatchService: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        DispatchQueue.main.async {
            self.isAppInstalled = WCSession.default.isWatchAppInstalled
            self.isAppActive = activationState == .activated
        }
        
        if let ip = requestIP?() {
            sendMessage(message: ip)
        }
        
        if (error != nil) { print("err", error ?? "ERROR") }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isAppActive = false
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isAppActive = false
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
   
        if (message.keys.contains("start_workout")) {
            DispatchQueue.main.async {
                self.isWorkoutRunning = true
            }
        } else if (message.keys.contains("end_workout")) {
            DispatchQueue.main.async {
                self.isWorkoutRunning = false
            }
        } else if (message.keys.contains("request_ip")) {
            if let ip = requestIP?() {
                sendMessage(message: ["updated_ip": ip])
            }
        }
    }
}
