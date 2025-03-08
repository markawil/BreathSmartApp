//
//  TileView.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/7/25.
//

import SwiftUI

struct TileView: View {
    
    @EnvironmentObject var viewModel: BrSmViewModel
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns,
                      alignment: .leading,
                      spacing: 20) {
                ForEach(viewModel.sensorValues) { value in
                    CardItemView(valueItem: value, color: value.type.backgroundColor)
                }
            }.padding()
        }
    }
}

let mockSensorValues: [SensorValueItem] = [
    .init(value: 0.15, timestamp: Date(), type: .tvoc),
    .init(value: 101, timestamp: Date(), type: .aqi),
    .init(value: 75.6, timestamp: Date(), type: .temperature),
    .init(value: 50, timestamp: Date(), type: .humidity),
    .init(value: 29.75, timestamp: Date(), type: .pressure),
    .init(value: 85, timestamp: Date(), type: .battery)
    ]

let mockBrSmViewModel = BrSmViewModel(with: mockSensorValues,
                                      bleManager: BLEManager(state: .mockOnly))

#Preview {
    TileView()
        .environmentObject(mockBrSmViewModel)
}
