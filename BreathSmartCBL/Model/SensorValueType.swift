//
//  SensorValueType.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/9/25.
//

import Foundation
import SwiftUI

/*
 The possible sensor value types that the device can send out.
 */
enum SensorValueType: Int, CaseIterable {
    case temperature
    case humidity
    case pressure
    case tvoc
    case battery
    case co2
    
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
            return "V"
        case .co2:
            return "ppm"
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
            Color.theme.redColor
        case .battery:
                .purple
        case .co2:
            Color.theme.tealColor
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
        case .co2:
            return "CO2"
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
        case .co2:
            return "sun.haze"
        }
    }
}
