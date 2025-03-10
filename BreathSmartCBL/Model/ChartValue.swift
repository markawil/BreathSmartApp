//
//  ChartValue.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/10/25.
//

import Charts
import Foundation

struct ChartValue: Identifiable {
    let id = UUID()
    let xValue: PlottableValue<String>
    let yValue: PlottableValue<Double>
}

struct MockChartValues {
    
    static func generateValues() -> [ChartValue] {
        let xValues = ["Fri", "Sat", "Sun", "Mon", "Tue", "Wed", "Thu"]
        let yValues = [10.5, 24.2, 15.2, 17.2, 11.3, 8.1, 12.4]
        let xPlotValues = xValues.map { PlottableValue.value("Day", $0) }
        let yPlotValues = yValues.map { PlottableValue.value("Values", $0) }
        
        return zip(xPlotValues, yPlotValues).map(ChartValue.init)
    }
}
