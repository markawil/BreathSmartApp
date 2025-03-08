//
//  CardItemView.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/7/25.
//

import SwiftUI

struct CardItemView: View {
    
    private var valueItem: SensorValueItem
    private var color: Color
    
    init(valueItem: SensorValueItem, color: Color) {
        self.valueItem = valueItem
        self.color = color
    }
    
    var body: some View {
        ZStack {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(color)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(titleSubTitleOverlay, alignment: .bottom)
            }
        }
    }
    
    private var titleSubTitleOverlay: some View {
        VStack {
            Image(systemName: valueItem.type.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.white)
                .padding()
            Text(valueItem.type.name)
                .font(.title2) // will need to change to match Figma font
                .fontWeight(.medium)
                .foregroundStyle(.white)
            Text((valueItem.value?.description ?? "---") + " \(valueItem.type.unit)")
                .font(.headline)
                .foregroundStyle(.white)
                
        }
        .padding()
    }
}

#Preview {
    VStack {
        CardItemView(valueItem: SensorValueItem(value: nil,
                                                timestamp: Date(),
                                                type: .temperature),
                     color: Color.blue)
        CardItemView(valueItem: SensorValueItem(value: nil,
                                                timestamp: Date(),
                                                type: .battery),
                     color: Color.blue)
    }
}
