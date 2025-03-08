//
//  DeviceDetailsView.swift
//  BreathSmartCBL
//
//  Created by MarkWilkinson on 1/24/25.
//

import CoreBluetooth
import SwiftUI

struct DeviceDetailsView: View {
    
    @Environment(\.presentationMode) private var mode
    @EnvironmentObject var viewModel: BrSmViewModel
    
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
            if let name = viewModel.connectedDevice?.name {
                if name.starts(with: "HM") {
                    Button {
                        showHM10View.toggle()
                    } label: {
                        Text("Control HM10 Device")
                    }
                    .padding()
                }
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
                List {
                    Section(header: Text("Advertised Services")) {
                        ForEach(viewModel.bleManager?.discoveredServices.map { $0.uuid } ?? [], id: \.uuidString) { service in
                            Text(service.uuidString)
                        }
                    }
                    Section(header: Text("Characteristics")) {
                        ForEach(viewModel.bleManager?.characteristics.map { $0.value.uuid } ?? [], id: \.uuidString) { characteristic in
                            Text(characteristic.uuidString)
                        }
                    }
                }
            }
            Spacer()
        }
        .background(Color(uiColor: UIColor.systemGroupedBackground))
        .navigationTitle("\(viewModel.connectedDevice?.name ?? "Device 1")")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(.blue), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(.white)
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
    NavigationStack {
        DeviceDetailsView(useMockServices: true)
            .environmentObject(mockCBViewModel)
    }
}
