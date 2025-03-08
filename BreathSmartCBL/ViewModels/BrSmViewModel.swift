//
//  BrSmViewModel.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 2/21/25.
//

import Combine
import Foundation

let emptySensorValues: [SensorValueItem] = [
    .init(value: nil, timestamp: Date(), type: .tvoc),
    .init(value: nil, timestamp: Date(), type: .aqi),
    .init(value: nil, timestamp: Date(), type: .temperature),
    .init(value: nil, timestamp: Date(), type: .humidity),
    .init(value: nil, timestamp: Date(), type: .pressure),
    .init(value: nil, timestamp: Date(), type: .battery)
    ]

class BrSmViewModel: ObservableObject {
    
    @Published var isScanning: Bool = false
    @Published var isConnected: Bool = false
    @Published var errorThrown: Bool = false
    @Published var state: CBState = .notAvailable
    
    @Published var sensorValues: [SensorValueItem] = []
    
    private var cancellables: Set<AnyCancellable> = []
    private var hasInitialized = false
    
    var lastError: ErrorType? {
        didSet {
            if lastError != nil {
                errorThrown = true
            }
        }
    }
    
    var connectedDevice: Device?
    
    private(set) var bleManager: BLEProvider?
    
    // sensorValues needed to show mocked preview
    init(with sensorValues: [SensorValueItem] = emptySensorValues,
         bleManager: BLEProvider? = nil) {
        self.sensorValues = sensorValues
        self.bleManager = bleManager
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables = []
    }
    
    func scanAndConnectToHM10() {
        bleManager?.clearDiscoveries()
        bleManager?.startScan()
    }
    
    func setupAndStart() {
        guard let bleManager = bleManager else { return }
        guard !hasInitialized else {
            return
        }
        
        hasInitialized = true
        isScanning = true
        
        bleManager.lastErrorPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.lastError, on: self)
            .store(in: &cancellables)
        
        bleManager.discoveredPeripheralPublisher
            .receive(on: DispatchQueue.main)
            .map { (peripheral, advertisementData, rssi) in
                return Device(id: peripheral.identifier,
                                    name: peripheral.name ?? "Unknown",
                                    advertisementData: advertisementData,
                                    rssi: rssi.intValue)
            }
            .sink { [weak self] device in
                guard let self = self else { return }
                guard !self.isConnected else { return }
                // if not connected and we found the BLE Adapter, connect
                if device.name.lowercased().hasPrefix("HMSoft".lowercased()) {
                    self.bleManager?.connect(to: device.id)
                }
            }
            .store(in: &cancellables)
        
        bleManager.connectionStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                guard let self = self else { return }
                self.isConnected = connected
                if connected {
                    // show a noticeable delay in connecting
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                        self?.isScanning = false
                    }
                } else {
                    // disconnected, continue to scan and try to connect
                    self.sensorValues = emptySensorValues
                    self.isScanning = true
                    self.scanAndConnectToHM10()
                }
            }
            .store(in: &cancellables)
        
        bleManager.cbStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
        
        bleManager.startCB()
    }
}
