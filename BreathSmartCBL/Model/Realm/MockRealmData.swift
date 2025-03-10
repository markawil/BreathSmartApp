////
////  MockRealmData.swift
////  BreathSmartCBL
////
////  Created by Mark Wilkinson on 3/9/25.
////
//
//import RealmSwift
//import Foundation
//
//struct MockRealmData {
//    
//    static func buildMockData(count: Int = 10) {
//        let realm = RealmManager.shared
//        
//        // build random values to plot
//        for _ in 0..<count {
//            
//            // add a day forward to each value
//            var components = DateComponents()
//            components.day = count
//            let now = Date()
//            let date = Calendar.current.date(byAdding: components, to: now) ?? Date()
//            
//            let tempData = SensorData()
//            tempData.timestamp = date
//            tempData.value = Double.random(in: 65...90)
//            tempData.type = SensorValueType.temperature.rawValue
//            realm.add(object: tempData)
//            
//            let humidData = SensorData()
//            humidData.timestamp = date
//            humidData.value = Double.random(in: 20...100)
//            humidData.type = SensorValueType.humidity.rawValue
//            realm.add(object: humidData)
//            
//            let pressureData = SensorData()
//            pressureData.timestamp = date
//            pressureData.value = Double.random(in: 27...32)
//            pressureData.type = SensorValueType.pressure.rawValue
//            realm.add(object: pressureData)
//            
//            let tvocData = SensorData()
//            tvocData.timestamp = date
//            tvocData.value = Double.random(in: 0...1000)
//            tvocData.type = SensorValueType.tvoc.rawValue
//            realm.add(object: tvocData)
//            
//            let batteryData = SensorData()
//            batteryData.timestamp = date
//            batteryData.value = Double.random(in: 1...3)
//            batteryData.type = SensorValueType.battery.rawValue
//            realm.add(object: batteryData)
//            
//            let co2Data = SensorData()
//            co2Data.timestamp = date
//            co2Data.value = Double.random(in: 100...1000)
//            co2Data.type = SensorValueType.co2.rawValue
//            realm.add(object: co2Data)
//        }
//    }
//}
