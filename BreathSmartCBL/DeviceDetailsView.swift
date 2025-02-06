//
//  DeviceDetailsView.swift
//  BreathSmartCBL
//
//  Created by MarkWilkinson on 1/24/25.
//

import SwiftUI

struct DeviceDetailsView: View {
    
    @EnvironmentObject var viewModel: CBViewModel
    
    var body: some View {
        VStack {
            Text("Connected...").font(.title)
                .padding()
            Spacer()
            HStack {
                Button("ON  ") {
                    viewModel.sendOn()
                }
                .padding()
                .background(.green)
                .foregroundColor(.white)
                .font(.largeTitle)
                .cornerRadius(15)
                Button("OFF") {
                    viewModel.sendOff()
                }
                .padding()
                .background(.red)
                .foregroundColor(.white)
                .font(.largeTitle)
                .cornerRadius(15)
            }
            Spacer()
            Button("Disconnect") {
                viewModel.disconect()
            }
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .font(.largeTitle)
            .cornerRadius(15)
        }
    }
}

#Preview {
    DeviceDetailsView()
        .environmentObject(CBViewModel(with: mockDevices, state: .goodToGo))
}
