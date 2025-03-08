//
//  BreathSmartHomeView.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 2/17/25.
//

import SwiftUI

struct BreathSmartHomeView: View {
    
    @EnvironmentObject var viewModel: BrSmViewModel
    
    @State private var showBLEDevices: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TileView()
                        .environmentObject(viewModel)
                        .navigationDestination(isPresented: $showBLEDevices) {
                            BLEDevicesView(isMock: false)
                                .environmentObject(viewModel)
                        }
                }
                .background(Color(uiColor: UIColor.systemGroupedBackground))
                .toolbarBackground(Color(.blue), for: .navigationBar)
                .navigationTitle("BreathSmart")
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    if !viewModel.isScanning {
                        ToolbarItem(placement: .status) {
                            Button {
                                showBLEDevices.toggle()
                            } label: {
                                Image(viewModel.isConnected ? "bluetooth" : "bluetooth_off")
                                    .renderingMode(.template)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .onAppear {
                    viewModel.connectToHM10 = true
                    if viewModel.isConnected {
                        viewModel.bleManager?.disconnect()
                    }
                    viewModel.setupAndStart()
                }
                if viewModel.isScanning {
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
}


struct LightStatusBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                UIApplication.shared.statusBarStyle = .lightContent
            }
            .onDisappear {
                UIApplication.shared.statusBarStyle = .default
            }
    }
}

extension View {
    func enableLightStatusBar() -> some View {
        self.modifier(LightStatusBarModifier())
    }
}
