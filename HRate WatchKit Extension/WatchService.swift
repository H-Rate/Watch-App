//
//  iPhoneService.swift
//  HRate WatchKit Extension
//
//  Created by Anselm Joseph on 16/06/21.
//

import Foundation

import WatchConnectivity

enum WatchServiceConnectionStatus {
    case Loading, Disconnected, Connected, Failed
}

class WatchService: NSObject, ObservableObject {
    
    var ipDidUpdate: (String) -> Void = { _ in }
    var didServerStop: () -> Void = {}
    
    @Published private(set) var connectionStatus: WatchServiceConnectionStatus = .Disconnected
    
    override init() {
        super.init()
        startSession()
    }
    
    func startSession() {
        DispatchQueue.main.async {
            self.connectionStatus = .Loading
        }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    func sendMessage(message: String) {
        let data = ["message": message]
        sendMessage(data: data)
    }
    
    func sendMessage(data: [String : Any]) {
        func errorHandler(error: Error) {
            print("error", error)
        }
        
        WCSession.default.sendMessage(data, replyHandler: nil, errorHandler: errorHandler)
    }
}


extension WatchService: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard error == nil else {
            print("error", error ?? "-")
            DispatchQueue.main.async {
                self.connectionStatus = .Failed
            }
            return
        }
        
        print("Activation state", activationState == .activated)
        
        DispatchQueue.main.async {
            self.connectionStatus = .Connected
        }
        
        sendMessage(data: ["request_ip": true])
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        processMessage(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        processMessage(message)
        replyHandler(["ok dude": "cool"])
    }
    
    func processMessage(_ message: [String : Any]) {
        print(message)
        if (message.keys.contains("updated_ip")) {
            ipDidUpdate(message["updated_ip"] as! String)
        } else if (message.keys.contains("server_stopped")) {
            
        }
    }
}
