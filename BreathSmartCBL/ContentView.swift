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
    
    @State var selectedDevice: Device?
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.state == .notAvailable {
                    Text("BLE is not available!")
                        .padding()
                        .background(.white)
                } else {
                    List(viewModel.devices, id: \.id) {
                        device in
                        Button {
                            self.selectedDevice = device
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
                    .navigationDestination(item: $selectedDevice) { device in
                        DeviceDetailsView()
                            .environmentObject(viewModel)
                    }
                }
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .navigationTitle("Breath Smart")
            .toolbarBackground(Color(.blue), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear() {
            //    viewModel.startCB()
            }
        }
    }
}

let mockDevices: [Device] = [
    Device(id: UUID(), name: "device 1", advertisementData: [:], rsi: 4),
    Device(id: UUID(), name: "device 2", advertisementData: [:], rsi: 2),
    Device(id: UUID(), name: "device 3", advertisementData: [:], rsi: 1),
]

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(viewModel: CBViewModel(with: mockDevices,
                                           state: .goodToGo))
    }
    
}
