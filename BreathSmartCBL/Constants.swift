//
//  CBLKeys.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 1/25/25.
//

import Foundation

enum CBState {
    case notAvailable
    case resetting
    case poweredOff
    case goodToGo
    case mockOnly
    
    var errorType: ErrorType? {
        switch self {
        case .notAvailable, .poweredOff:
            return .notAvailable
        case .mockOnly:
            return nil
        default:
            return nil
        }
    }
}

enum ErrorType: String, Error {
    case deviceDisconnected = "Device disconnected."
    case failedToConnect = "Failed to connect to device."
    case peripheralMissing = "Asked to connect to device that wasn't in the discovered list."
    case notAvailable = "Bluetooth is not available."
    case notAuthorized = "Bluetooth is not authorized."
    case unknown = "Something went wrong."
}

enum CBLKeys: String {
    
    case advDataManufacturerDataKey = "CBAdvertisementDataManufacturerDataKey"
    case advDataServiceDataKey = "CBAdvertisementDataServiceDataKey"
    case advDataServiceUUIDsKey = "CBAdvertisementDataServiceUUIDsKey"
    case advDataOverflowServiceUUIDsKey = "CBAdvertisementDataOverflowServiceUUIDsKey"
    case advDataTxPowerLevelKey = "CBAdvertisementDataTxPowerLevelKey"
    case advDataIsConnectableKey = "CBAdvertisementDataIsConnectable"
    case advDataSolicitedServiceKey = "CBAdvertisementDataSolicitedServiceUUIDsKey"
}

// Used for mocking the details view only
struct Constants {
    struct UUID {
        struct Service {
            static let heartRateService = "0000180D-0000-1000-8000-00805F9B34FB"
            static let heartRateMeasurement = "00002A37-0000-1000-8000-00805F9B34FB"
            static let bodySensorLocation = "00002A38-0000-1000-8000-00805F9B34FB"
        }
        
        struct Characteristic {
            static let batteryCharacteristic = "0x2A19"
            static let deviceInfoCharacteristic = "0x2A00"
            static let heartRateCharacteristic = "0x2A37"
        }
    }
    
    struct HM10 {
        struct Service {
            static let data = "FFE0"
        }
        
        struct Characteristic {
            static let data = "FFE1"
        }
    }
}

