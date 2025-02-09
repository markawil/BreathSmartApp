//
//  DeviceDetailsView.swift
//  BreathSmartCBL
//
//  Created by MarkWilkinson on 1/24/25.
//

import CoreBluetooth
import SwiftUI

struct DeviceDetailsView: View {
    
    @EnvironmentObject var viewModel: CBViewModel
    
    let mockServices: [CBUUID] = [CBUUID(string: Constants.UUID.Service.heartRateService),
                                  CBUUID(string: Constants.UUID.Service.bodySensorLocation),
                                  CBUUID(string: Constants.UUID.Service.heartRateMeasurement)]
    
    let mockCharacteristics: [CBUUID] = [CBUUID(string: Constants.UUID.Characteristic.heartRateCharacteristic),
                                         CBUUID(string: Constants.UUID.Characteristic.batteryCharacteristic),
                                         CBUUID(string: Constants.UUID.Characteristic.deviceInfoCharacteristic)]
    
    var useMockServices: Bool = false
    
    @State private var showHM10View: Bool = false
    @State private var selectedService: CBUUID? = nil
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if let name = viewModel.connectedDevice?.name {
                    if name.starts(with: "HM") {
                        Button {
                            showHM10View.toggle()
                        } label: {
                            Text("HM10")
                        }
                    }
                } else {
                    Text("\(viewModel.connectedDevice?.name ?? "Device 1")")
                        .font(.title2)
                        .padding()
                }
                Spacer()
            }
            
            if useMockServices {
                List {
                    Section(header: Text("Advertised Services")) {
                        ForEach(mockServices, id: \.uuidString) { service in
                            Text(service.uuidString)
                        }
                    }
                    Section(header: Text("Characteristics")) {
                        ForEach(mockCharacteristics, id: \.uuidString) { characteristic in
                            Text(characteristic.uuidString)
                        }
                    }
                }
            } else {
                List(viewModel.discoveredServices, id: \.uuid) { service in
                    Section(header: Text("Advertised Services")) {
                        ForEach(viewModel.discoveredServices.map { $0.uuid }, id: \.uuidString) { service in
                            Text(service.uuidString)
                        }
                    }
                    Section(header: Text("Characteristics")) {
                        ForEach(viewModel.characteristics.map { $0.value.uuid }, id: \.uuidString) { characteristic in
                            Text(characteristic.uuidString)
                        }
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showHM10View) {
            HM10ConnectView()
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    DeviceDetailsView(useMockServices: true)
        .environmentObject(mockViewModel)
}
