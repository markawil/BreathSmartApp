//
//  ChartsViewModel.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/9/25.
//

import Charts
import RealmSwift
import Foundation

class ChartsViewModel: ObservableObject {
    
    private let realmManager: RealmManager
    
    // DI in case we want to setup a unit-testable realm manager
    init (realmManager: RealmManager) {
        self.realmManager = realmManager
        setupMockData()
    }
    
    private func setupMockData() {
        
//        if mockDataExists() {
//            realmManager.realm.deleteAll()
//        }
        
        buildMockData()
    }
    
    private func mockDataExists() -> Bool {
        let realm = realmManager.realm
        return !realm.objects(SensorData.self).isEmpty
    }
    
    private func buildMockData(count: Int = 7) {
        
        // build random values to plot
        for _ in 0..<count {
            
            let realm = realmManager
            
            // add a day forward to each value
            var components = DateComponents()
            components.day = count
            let now = Date()
            let date = Calendar.current.date(byAdding: components, to: now) ?? Date()
            
            let tempData = SensorData()
            tempData.timestamp = date
            tempData.value = Double.random(in: 65...90)
            tempData.type = SensorValueType.temperature.rawValue
            realm.add(object: tempData)
            
            let humidData = SensorData()
            humidData.timestamp = date
            humidData.value = Double.random(in: 30...60)
            humidData.type = SensorValueType.humidity.rawValue
            realm.add(object: humidData)
            
            let pressureData = SensorData()
            pressureData.timestamp = date
            pressureData.value = Double.random(in: 27...32)
            pressureData.type = SensorValueType.pressure.rawValue
            realm.add(object: pressureData)
            
            let tvocData = SensorData()
            tvocData.timestamp = date
            tvocData.value = Double.random(in: 100...500)
            tvocData.type = SensorValueType.tvoc.rawValue
            realm.add(object: tvocData)            
            
            let co2Data = SensorData()
            co2Data.timestamp = date
            co2Data.value = Double.random(in: 200...500)
            co2Data.type = SensorValueType.co2.rawValue
            realm.add(object: co2Data)
        }
    }
    
    func buildChartValues(for type: SensorValueType) -> [ChartValue] {
        
        let weekXValues = ["Fri", "Sat", "Sun", "Mon", "Tue", "Wed", "Thu"]
        
        let sensorValues = realmManager.realm.objects(SensorData.self).where {
            $0.type == type.rawValue
        }.prefix(7).map { $0.value }
        
        let xValues = weekXValues.map { PlottableValue.value("Day", $0) }
        let yValues = sensorValues.map { PlottableValue.value("\(type.unit)", $0) }
        
        let chartValues = zip(xValues, yValues).map(ChartValue.init)
        
        return chartValues
    }
}
