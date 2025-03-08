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

struct SensorValueItem: Identifiable {
    var id: UUID = UUID()
    var value: Double?
    var timestamp: Date?
    var type: SensorValueType
}
