//
//  ContentViewModel.swift
//  hrate WatchKit Extension
//
//  Created by Anselm Joseph on 07/01/21.
//

import SwiftUI
import SocketIO
import os

class ContentViewModel: ObservableObject {
    
    private let socketManager: SocketManager
    private let deviceId: String
    private let serverURL: URL
    
    @Published private(set) var error: String?
    
    init() {
        print(Environment.rootURL)
        serverURL = URL(string: "http://localhost:3000")!
        deviceId = WKInterfaceDevice.current().identifierForVendor!.uuidString
        socketManager = SocketManager(socketURL: serverURL, config: [.log(false), .connectParams(["deviceId": deviceId])])
        openConnection()
    }
    
    func openConnection() {
        let socket = socketManager.socket(forNamespace: "/device")
        
        socket.on(clientEvent: .connect) { (data, ack) in
            print("Connection Opened")
        }
        
        socket.on(clientEvent: .disconnect) { (data, ack) in
            print("Disconnected")
        }
        
        socket.on(clientEvent: .error) { (err, ack) in
            print("Error")
            self.error = err[0] as? String
        }
        
        socket.on("deviceRegister") { (response, ack) in
            print("registered")
            print(response)
        }
        
        socket.on("deviceToken") { (response, ack) in
            print("device token")
            print(response)
        }
        
        socket.on("subscriberList") { (response, ack) in
            print("subl")
            print(response)
        }
        
        os_log(.info, "Starting SocketIO")
        socket.connect()
    }
    
    
    
}
