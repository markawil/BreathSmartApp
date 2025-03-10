//
//  BreatheSmartHomeView.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 2/17/25.
//

import SwiftUI

struct BreatheSmartHomeView: View {
    
    @EnvironmentObject var viewModel: BrSmViewModel
    
    @State private var showBLEDevices: Bool = false
    @State private var showCharts: Bool = false
    @State private var showBio: Bool = false
    
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
                        .navigationDestination(isPresented: $showCharts) {
                            ChartsView()
                                .environmentObject(ChartsViewModel(realmManager: RealmManager(useInMemory: true)))
                        }
                }
                .background(Color(uiColor: UIColor.systemGroupedBackground))
                .toolbarBackground(Color(.blue), for: .navigationBar)
                .navigationTitle("BreatheSmart")
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    if !viewModel.isScanning {
                        ToolbarItem(placement: .status) {
                            Button {
                                showBLEDevices.toggle()
                            } label: {
                                Image(viewModel.isConnected ? "bluetooth" : "bluetooth_off")                            .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        ToolbarItem(placement: .status) {
                            Button {
                                showCharts.toggle()
                            } label: {
                                Image(systemName: "chart.xyaxis.line")
                                    .renderingMode(.template)
                                    .foregroundColor(.blue)
                            }
                        }
                        ToolbarItem(placement: .status) {
                            Button {
                                showBio.toggle()
                            } label: {
                                Image(systemName: "info.circle")
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
                .fullScreenCover(isPresented: $showBio) {
                    GithubUserView()
                        .environmentObject(GithubUserViewModel(username: "markawil"))
                }
                
                if viewModel.isScanning {
                    spinnerOverlay
                }
            }
        }
    }
    
    private var spinnerOverlay: some View {
        ZStack {
            Color(uiColor: UIColor.systemGroupedBackground).opacity(0.75)
                .ignoresSafeArea(edges: [.leading, .trailing])
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

#Preview {
    BreatheSmartHomeView()
        .environmentObject(mockBrSmViewModel)
}
