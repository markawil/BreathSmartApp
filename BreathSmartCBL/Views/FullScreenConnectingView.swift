//
//  FullScreenConnectingView.swift
//  BreathSmartCBL
//
//  Created by MarkWilkinson on 2/6/25.
//

import SwiftUI

struct FullScreenConnectingView: View {
    
    @EnvironmentObject var viewModel: CBViewModel
    @Environment(\.presentationMode) private var mode
    
    @State var deviceName: String = "Unknown device"

        var body: some View {
            Color.black.opacity(0.5)
                .overlay {
                    VStack {
                        Spacer()
                        Text("Connecting to \(deviceName)...")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.white)
                        ProgressView()
                            .tint(Color.white)
                            .controlSize(.large)
                            .padding()
                        Spacer()
                        Button {
                            // will cancel the pending connection
                            viewModel.bleManager?.disconnect()
                            mode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.white)
                        }
                        .padding(.bottom, 40)
                    }
                }
                .ignoresSafeArea()
        }
}

#Preview {
    FullScreenConnectingView()
        .environmentObject(mockViewModel)
}
