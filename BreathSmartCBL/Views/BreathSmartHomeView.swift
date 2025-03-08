//
//  BreathSmartHomeView.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 2/17/25.
//

import SwiftUI

struct BreathSmartHomeView: View {
    
    @EnvironmentObject var brSmViewModel: BrSmViewModel
    @EnvironmentObject var cbViewModel: CBViewModel
    
    @State private var showBLEDevices: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TileView()
                        .environmentObject(brSmViewModel)
                        .navigationDestination(isPresented: $showBLEDevices) {
                            BLEDevicesView()
                                .environmentObject(cbViewModel)
                        }
                }
                .background(Color(uiColor: UIColor.systemGroupedBackground))
                .navigationTitle("BreathSmart")
                .toolbarBackground(Color(.blue), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    if !brSmViewModel.isScanning {
                        ToolbarItem(placement: .status) {
                            Button {
                                showBLEDevices.toggle()
                            } label: {
                                Image(brSmViewModel.isConnected ? "bluetooth" : "bluetooth_off")
                                    .renderingMode(.template)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .onAppear {
                    if brSmViewModel.isConnected {
                        brSmViewModel.bleManager?.disconnect()
                    }
                    brSmViewModel.setupAndStart()
                }
                .toolbarColorScheme(.dark, for: .navigationBar)
                .preferredColorScheme(.light)
                if brSmViewModel.isScanning {
                    Color(uiColor: UIColor.systemGroupedBackground).opacity(0.85)
                        .ignoresSafeArea()
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(2.0, anchor: .center) // Makes the spinner larger
                        Text("Connecting to device...")
                            .font(.headline)
                            .foregroundStyle(Color.blue)
                            .padding()
                    }
                }
            }
        }
    }
}

#Preview {
    BreathSmartHomeView()
        .environmentObject(mockBrSmViewModel)
        .environmentObject(mockCBViewModel)
}
