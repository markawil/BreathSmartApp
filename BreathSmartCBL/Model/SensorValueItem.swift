//
//  SensorValueItem.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/7/25.
//

import SwiftUI
import Foundation

enum SensorValueType {
    case temperature
    case humidity
    case pressure
    case tvoc
    case battery
    case aqi
    
    var unit: String {
        switch self {
        case .temperature:
            return "°F"
        case .humidity:
            return "%"
        case .pressure:
            return "inHg"
        case .tvoc:
            return "ppb"
        case .battery:
            return "%"
        case .aqi:
            return "AQI"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .temperature:
                .orange
        case .humidity:
                .green
        case .pressure:
                .blue
        case .tvoc:
                .red
        case .battery:
                .purple
        case .aqi:
                .teal
        }
    }
    
    var name: String {
        switch self {
        case .temperature:
            return "Temperature"
        case .humidity:
            return "Humidity"
        case .pressure:
            return "Pressure"
        case .tvoc:
            return "TVOC"
        case .battery:
            return "Battery"
        case .aqi:
            return "AQI"
        }
    }
    
    var imageName: String {
        switch self {
        case .temperature:
            return "thermometer.variable"
        case .humidity:
            return "humidity"
        case .pressure:
            return "barometer"
        case .tvoc:
            return "allergens"
        case .battery:
            return "bolt.batteryblock"
        case .aqi:
            return "sun.haze"
        }
    }
}

// mutable data holder for the cards on the Home screen
class SensorValueItem: Identifiable {
    var id: UUID = UUID()
    var value: Double?
    var timestamp: Date?
    var type: SensorValueType
    
    init(value: Double? = nil, timestamp: Date? = nil, type: SensorValueType) {
        self.value = value
        self.timestamp = timestamp
        self.type = type
    }
}

// immutable to hold values coming back from the Device
struct SensorValue {
    let value: Double
    let type: SensorValueType
    
    init?(from dataString: String) {
        let parts = dataString.split(separator: ":")
        guard parts.count == 2 else {
            return nil
        }
        guard let code = Int(parts[0]),
              let value = Double(parts[1]) else {
            return nil
        }
        
        switch code {
        case 0:
            self.type = .temperature
        case 1:
            self.type = .humidity
        case 2:
            self.type = .pressure
        case 3:
            self.type = .tvoc
        case 4:
            self.type = .battery
        case 5:
            self.type = .aqi
        default:
            return nil
        }
        
        self.value = value
    }
}

let emptySensorValues: [SensorValueItem] = [
    .init(type: .tvoc),
    .init(type: .aqi),
    .init(type: .temperature),
    .init(type: .humidity),
    .init(type: .pressure),
    .init(type: .battery)
    ]

