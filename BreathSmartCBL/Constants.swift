//
//  CBLKeys.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 1/25/25.
//

import Foundation

public enum CBLKeys: String {
    
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

}

