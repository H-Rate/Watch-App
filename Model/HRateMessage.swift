//
//  HRateMessage.swift
//  HRate WatchKit Extension
//
//  Created by Anselm Joseph on 12/06/21.
//

import Foundation
import SocketIO

struct HRateMessage : SocketData {
    let payload: String
    
    func socketRepresentation() -> SocketData {
        return ["payload": payload]
    }
}
