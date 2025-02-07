//
//  ContentView.swift
//  BreathSmartCBL
//
//  Created by MarkWilkinson on 12/13/24.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: CBViewModel
    
    @State private var showBLENotAvailableAlert = false
    
    @State private var selectedDevice: Device?
    @State private var showConnectedScreen = false
    @State private var showConnectionPopUp = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.state == .notAvailable {
                    Text("BLE is not available!")
                        .padding()
                        .background(.white)
                } else if viewModel.devices.isEmpty {
                    Button {
                        Task {
                            await viewModel.startScan()
                        }
                    } label: {
                        Text("Scan for BLE Devices")
                            .font(.headline)
                            .background(.white)
                    }
                } else {
                    List(viewModel.devices, id: \.id) {
                        device in
                        Button {
                            self.selectedDevice = device
                            self.viewModel.connect(to: device)
                            self.showConnectionPopUp = true
                        } label: {
                            VStack {
                                HStack {
                                    Text(device.name)
                                        .font(.title2)
                                        .padding(10)
                                    Spacer()
                                    Image("wifi_strength_4")
                                        .renderingMode(.template)
                                        .foregroundColor(.blue)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 35, height: 35)
                                        .padding(10)
                                }
                                .padding()
                                .background(Color(uiColor: .white))
                            }
                        }
                        .tint(.black)
                        .cornerRadius(15)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .background(Color(uiColor: UIColor.systemGroupedBackground))
                    .padding([.leading, .trailing], -20)
                    .refreshable {
                        await viewModel.startScan()
                    }
                    .navigationDestination(isPresented: $viewModel.isConnected) {
                        DeviceDetailsView()
                            .environmentObject(viewModel)
                    }
                }
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .navigationTitle("CoreBluetooth")
            .toolbarBackground(Color(.blue), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear() {
                self.showConnectionPopUp = false
                viewModel.startCB()
            }
            .fullScreenCover(isPresented: $showConnectionPopUp) {
                FullScreenConnectingView(deviceName: selectedDevice?.name ?? "??")
            }
        }
    }
}

let mockDevices: [Device] = [
    Device(id: UUID(), name: "device 1", advertisementData: [:], rsi: 4),
    Device(id: UUID(), name: "device 2", advertisementData: [:], rsi: 2),
    Device(id: UUID(), name: "device 3", advertisementData: [:], rsi: 1),
]

let mockViewModel = CBViewModel(with: [],
                                state: .mockOnly)

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(viewModel: mockViewModel)
    }
}
