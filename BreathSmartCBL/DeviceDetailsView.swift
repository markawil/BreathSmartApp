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
    
    @State private var selectedService: CBUUID? = nil
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("\(viewModel.connectedPeripheral?.name ?? "Device 1")")
                    .font(.title2)
                    .padding()
                Spacer()
                if let name = viewModel.connectedPeripheral?.name {
                    if name.starts(with: "HM") {
                        Button {
                            
                        } label: {
                            Text("Control")
                        }
                    }
                }
            }
            if useMockServices {
                List {
                    Section(header: Text("Advertised Services")) {
                        ForEach(mockServices, id: \.uuidString) { service in
                            Button {
                                
                            } label: {
                                Text(service.uuidString)
                            }
                            .tint(.black)
                        }
                    }
                    Section(header: Text("Attributes")) {
                        ForEach(mockCharacteristics, id: \.uuidString) { characteristic in
                            Text(characteristic.uuidString)
                        }
                    }
                }
                
            } else if let servicesAvailable = viewModel.connectedPeripheral?.services {
                List(servicesAvailable, id: \.uuid) { service in
                    VStack {
                        Text(service.uuid.uuidString)
                            .font(.headline)
                            .padding()
                    }
                }
            }
        }
    }
}

#Preview {
    DeviceDetailsView(useMockServices: true)
        .environmentObject(mockViewModel)
}
