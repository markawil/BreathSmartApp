//
//  ContentView.swift
//  BreathSmartCBL
//
//  Created by MarkWilkinson on 12/13/24.
//

import SwiftUI

@MainActor
struct BLEDevicesView: View {
    
    @Environment(\.presentationMode) private var mode
    @EnvironmentObject var viewModel: BrSmViewModel
    
    @State private var showBLENotAvailableAlert = false
    @State private var showDeviceDetails = false
    @State private var showConnectionPopUp = false
    @State private var refreshView = false
    
    let isMock: Bool
    
    var body: some View {
            ZStack {
                if viewModel.state == .notAvailable && !isMock {
                    Text("BLE is not available!")
                        .padding()
                        .background(.white)
                } else if viewModel.availableDevices.isEmpty {
                    Button {
                        viewModel.startScan(clearDevices: false)
                    } label: {
                        Text("Scan for BLE Devices")
                            .font(.headline)
                            .background(.white)
                    }
                } else {
                    deviceList
                }
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("BLE Devices")
                            .bold()
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(Color(.blue), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)            
            .navigationBarBackButtonHidden(true)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear() {
                viewModel.connectToHM10 = false
                if viewModel.isConnected {
                    viewModel.bleManager?.disconnect()
                }
                self.viewModel.selectedDevice = nil
            }
            .fullScreenCover(isPresented: $showConnectionPopUp,
                             onDismiss: {
                self.showDeviceDetails = viewModel.isConnected
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
    
    private var deviceList: some View {
        List(viewModel.availableDevices, id: \.id) {
            device in
            Button {
                self.viewModel.selectedDevice = device
                self.viewModel.connect()
                self.showConnectionPopUp.toggle()
            } label: {
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
            .tint(.black)
            .cornerRadius(15)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .background(Color(uiColor: UIColor.systemGroupedBackground))
        .padding([.leading, .trailing], -20)
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

let mockDevices: [Device] = [
    Device(id: UUID(), name: "device 1", advertisementData: [:], rssi: -30),
    Device(id: UUID(), name: "device 2", advertisementData: [:], rssi: -60),
    Device(id: UUID(), name: "device 3", advertisementData: [:], rssi: -80),
    Device(id: UUID(), name: "device 4", advertisementData: [:], rssi: -80),
    Device(id: UUID(), name: "device 5", advertisementData: [:], rssi: -80),
    Device(id: UUID(), name: "device 6", advertisementData: [:], rssi: -80),
]

let mockCBViewModel = BrSmViewModel(with: mockSensorValues,
                                    devices: mockDevices,
                                    bleManager: BLEManager(state: .mockOnly))

#Preview {
    NavigationStack {
        BLEDevicesView(isMock: true)
            .environmentObject(mockCBViewModel)
    }
}
