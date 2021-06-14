//
//  Device.swift
//  hrate
//
//  Created by Anselm Joseph on 12/01/21.
//

import Foundation

struct Session: Codable {
    private(set) var id: String
    private(set) var deviceId: String
    private(set) var connected: Bool
    private(set) var address: String
    private(set) var registedAt: Date
    private(set) var updatedAt: Date
}
