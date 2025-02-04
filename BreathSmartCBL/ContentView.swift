//
//  ContentView.swift
//  BreathSmartCBL
//
//  Created by MarkWilkinson on 12/13/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel: CBViewModel
    
    @State private var showBLENotAvailableAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.state == .notAvailable {
                    Text("BLE is not available!")
                        .padding()
                        .background(.white)
                } else {
                    List {
                        ForEach(viewModel.devices, id: \.id) {
                            device in
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
                            .cornerRadius(15)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .background(Color(uiColor: UIColor.systemGroupedBackground))
                    .padding([.leading, .trailing], -20)
                    .refreshable {
                        await viewModel.startScan()
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

struct ConttentView_Previews: PreviewProvider {
    
    static let devices: [Device] = [
        Device(id: UUID(), name: "device 1", advertisementData: [:], rsi: 4),
        Device(id: UUID(), name: "device 2", advertisementData: [:], rsi: 2),
        Device(id: UUID(), name: "device 3", advertisementData: [:], rsi: 1),
    ]
    static var previews: some View {
        ContentView(viewModel: CBViewModel(with: devices,
                                           state: .goodToGo))
    }
    
}
