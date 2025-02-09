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
    
    @State private var showDeviceDetails = false
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
                            self.viewModel.selectedDevice = device
                            self.viewModel.connect(to: device)
                            self.showConnectionPopUp.toggle()
                        } label: {
                            VStack {
                                HStack {
                                    Text(device.name)
                                        .font(.title2)
                                        .padding(10)
                                    Spacer()
                                    Image(device.rssiImageName)
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
                    .navigationDestination(isPresented: $showDeviceDetails) {
                        DeviceDetailsView()
                            .environmentObject(viewModel)
                    }
                    .alert("Error", isPresented: $viewModel.errorThrown) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(viewModel.lastError?.rawValue ?? "An error occurred.")
                    }
                }
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .navigationTitle("CoreBluetooth")
            .toolbarBackground(Color(.blue), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear() {
                self.viewModel.selectedDevice = nil
                viewModel.startCB()
            }
            .fullScreenCover(isPresented: $showConnectionPopUp,
                             onDismiss: {
                if viewModel.isConnected {
                    self.showDeviceDetails = true
                }
            }, content: {
                FullScreenConnectingView(deviceName: viewModel.selectedDevice?.name ?? "")
                    .environmentObject(viewModel)
            })
            .onReceive(viewModel.$isConnected
                .compactMap({$0})) { isConnected in
                    if isConnected {
                        self.showConnectionPopUp = false // if it was being displayed
                    }
            }
        }
    }
}

let mockDevices: [Device] = [
    Device(id: UUID(), name: "device 1", advertisementData: [:], rssi: -30),
    Device(id: UUID(), name: "device 2", advertisementData: [:], rssi: -50),
    Device(id: UUID(), name: "device 3", advertisementData: [:], rssi: -70),
]

let mockViewModel = CBViewModel(with: mockDevices,
                                state: .mockOnly)

#Preview {
    ContentView(viewModel: mockViewModel)
}
