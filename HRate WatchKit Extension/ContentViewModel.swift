//
//  ContentViewModel.swift
//  hrate WatchKit Extension
//
//  Created by Anselm Joseph on 07/01/21.
//

import SwiftUI
import SocketIO
import HealthKit
import os

enum SocketConnectionStatus {
    case Loading, Connected, Disconnected, Failed
}

class ContentViewModel: NSObject, ObservableObject {

    private var socketManager: SocketManager!
    private var socket: SocketIOClient!
    
    @Published private(set) var socketConnection: SocketConnectionStatus = .Disconnected
    @Published private(set) var error: String?
    
    func openConnection(withURL urlString: String) {
        print("Open connection")
        
        guard let url = URL(string: "ws://\(urlString)") else {
            print("Invalid URL string")
            return
        }
                
        if socket != nil {
            disconnect()
        }
        
        DispatchQueue.main.async {
            self.socketConnection = .Loading
        }
        
        socketManager = SocketManager(socketURL: url, config: [.log(false), .reconnects(false)])
        socket = socketManager.defaultSocket

        socket.on(clientEvent: .connect) { (data, ack) in
            os_log("Connection Opened")
            DispatchQueue.main.async {
                self.socketConnection = .Connected
            }
        }

        socket.on(clientEvent: .disconnect) { (data, ack) in
            os_log("Disconnected")
            self.disconnect()
            DispatchQueue.main.async {
                self.socketConnection = .Disconnected
            }
        }

        socket.on(clientEvent: .error) { (err, ack) in
            os_log("Error", err)
            print(err)
            self.error = err[0] as? String
            self.disconnect()
            DispatchQueue.main.async {
                self.socketConnection = .Failed
            }
        }

        os_log(.info, "Starting SocketIO")
        socket.connect()
    }
    
    func emitSocketMessage(heartRate: String) {
        guard socket != nil else {
            print("SocketIO connection not opened")
            return
        }
        
        os_log("emit hrate \(heartRate)")

        let data = HRateMessage(payload: heartRate)
        socket.emit("update", data)
    }
    
    func disconnect() {
        if socket != nil {
            self.socket.disconnect()
        }
        self.socket = nil
    }
}
