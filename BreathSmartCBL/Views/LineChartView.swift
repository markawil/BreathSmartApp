//
//  LineChartView.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/10/25.
//

import Charts
import SwiftUI

struct LineChartView: View {
    
    let linearGradient: LinearGradient
    
    let values: [ChartValue]
    let sensorType: SensorValueType
    
    init(values: [ChartValue], sensorType: SensorValueType) {
        self.values = values
        self.sensorType = sensorType
        linearGradient = LinearGradient(gradient: Gradient(colors: [sensorType.backgroundColor.opacity(0.5), sensorType.backgroundColor.opacity(0.1)]),
                                        startPoint: .top,
                                        endPoint: .bottom)
    }
    
    var body: some View {
        Chart {
            ForEach(values) { value in
                LineMark(x: value.xValue,
                         y: value.yValue)
                .foregroundStyle(sensorType.backgroundColor)
                .symbol(by: .value("Sensor Type", sensorType.name))
            }
            .interpolationMethod(.cardinal)
            
            // if we want to show a gradient underneath
//            ForEach(values) { value in
//                AreaMark(x: value.xValue,
//                         y: value.yValue)
//            }
//            .interpolationMethod(.cardinal)
//            .foregroundStyle(linearGradient)
            
        }
        .chartYAxisLabel { Text("\(sensorType.unit)") }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
//        .aspectRatio(1, contentMode: .fit)
        .padding()
        .frame(width: .infinity, height: 200)
    }
}

#Preview {
    LineChartView(values: MockChartValues.generateValues(), sensorType: .temperature)
}
