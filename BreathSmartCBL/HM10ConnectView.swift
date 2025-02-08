//
//  HM10ConnectView.swift
//  BreathSmartCBL
//
//  Created by MarkWilkinson on 2/6/25.
//

import SwiftUI

struct HM10ConnectView: View {
    
    @EnvironmentObject var viewModel: CBViewModel
    
    @Environment(\.presentationMode) private var mode
    
    var body: some View {
        VStack {
            Text("HM10 Connected...").font(.title)
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
                viewModel.disconnect()
                mode.wrappedValue.dismiss()
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
    HM10ConnectView()
        .environmentObject(mockViewModel)
}
