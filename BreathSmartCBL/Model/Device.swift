//
//  Device.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 2/19/25.
//

import Foundation

struct Device: Identifiable, Hashable {
    
    let id: UUID
    let name: String
    let advertisementData: [String : Any]
    let rssi: Int
    let description: String = ""
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
    
    var rssiLevel: Int {
        if rssi < 30 && rssi >= -30 {
            return 4
        }
        else if rssi < -30 && rssi >= -60 {
            return 3
        }
        else if rssi < -60 && rssi >= -80 {
            return 2
        }
        else if rssi < -80 && rssi > -100 {
            return 1
        }
        else {
            return 0
        }
    }
    
    var rssiImageName: String {
        switch rssiLevel {
        case 1:
            return "wifi_strength_1"
        case 2:
            return "wifi_strength_2"
        case 3:
            return "wifi_strength_3"
        case 4:
            return "wifi_strength_4"
        default:
            return "wifi_strength_0"
        }
    }
}
