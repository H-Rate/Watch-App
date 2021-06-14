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

class ContentViewModel: NSObject, ObservableObject {

    private let deviceId: String = WKInterfaceDevice.current().identifierForVendor!.uuidString
    private let serverURL: URL = Environment.rootURL
    private var socketManager: SocketManager!
    private var socket: SocketIOClient!
    
    @Published private(set) var loading: Bool = true
    @Published private(set) var session: Session!
    @Published private(set) var error: String?
    @Published private(set) var deviceToken: String?
    
    override init() {
        super.init()
        self.openConnection()
    }
 
    func openConnection() {
        socketManager = SocketManager(socketURL: serverURL, config: [.log(false), .connectParams(["deviceId": deviceId])])
        socket = socketManager.socket(forNamespace: "/device")
        
        socket.on(clientEvent: .connect) { (data, ack) in
            os_log("Connection Opened")
        }
        
        socket.on(clientEvent: .disconnect) { (data, ack) in
            os_log("Disconnected")
        }
        
        socket.on(clientEvent: .error) { (err, ack) in
            os_log("Error")
            self.error = err[0] as? String
        }
        
        socket.on("deviceRegister") { (data, ack) in
            os_log("Registered")
            print(data)
            do {
                let json = try JSONSerialization.data(withJSONObject: data[0])
                let decoder = JSONDecoder()
                
                let dF = DateFormatter()
                dF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
                decoder.dateDecodingStrategy = .formatted(dF)
                
                self.session = try decoder.decode(Session.self, from: json)
                
                self.socket.emit("generateToken", ["id": self.session.id]) {() in
                    print("Comp")
                }
                
            } catch let parsingError {
                print("Error", parsingError)
                self.error = parsingError.localizedDescription
            }
           
            self.loading = false
        }
        
        socket.on("deviceToken") { (response, ack) in
            print("Device Token", response)
            self.deviceToken = response[0] as? String
        }
        
        socket.on("subscriberList") { (response, ack) in
            print("subl")
            print(response)
        }
        
        os_log(.info, "Starting SocketIO")
        socket.connect()
    }
    
    func emitSocketMessage(heartRate: String) {
        guard self.session != nil else {
            return
        }
        
        os_log("emit hrate \(heartRate)")
        
        let data = HRateMessage(id: self.session.id, payload: heartRate)
        socket.emit("message", data)
    }
}
