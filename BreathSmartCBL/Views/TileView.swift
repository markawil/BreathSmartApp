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

let mockBrSmViewModel = BrSmViewModel(with: emptySensorValues,
                                      bleManager: BLEManager(state: .mockOnly))

#Preview {
    TileView()
        .environmentObject(mockBrSmViewModel)
}
