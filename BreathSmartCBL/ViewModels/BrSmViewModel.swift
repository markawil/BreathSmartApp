//
//  BrSmViewModel.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 2/21/25.
//

import Combine
import Foundation

class BrSmViewModel: ObservableObject {
    
    @Published var availableDevices: [Device] = []
    @Published var selectedDevice: Device? // only used by the BLEDevicesView
    @Published var isScanning: Bool = false
    @Published var isConnected: Bool = false
    @Published var errorThrown: Bool = false
    @Published var state: CBState = .notAvailable
    @Published var sensorValues: [SensorValueItem] = []
    
    var connectToHM10 = false
    
    private var cancellables: Set<AnyCancellable> = []
    private var hasInitialized = false
    
    var lastError: ErrorType? {
        didSet {
            if lastError != nil {
                errorThrown = true
            }
        }
    }
    
    var connectedDevice: Device? {
        guard let peripheral = bleManager?.connectedPeripheral else { return nil }
        guard !availableDevices.isEmpty else { return nil }
        
        return availableDevices.first { $0.id == peripheral.identifier }
    }
    
    private(set) var bleManager: BLEProvider?
    
    // sensorValues needed to show mocked preview
    init(with sensorValues: [SensorValueItem] = emptySensorValues,
         devices: [Device] = [], // just used for mocking
         bleManager: BLEProvider? = nil) {
        self.availableDevices = devices
        self.sensorValues = sensorValues
        self.bleManager = bleManager
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables = []
    }
    
    func startScan(clearDevices: Bool) {
        if clearDevices {
            self.availableDevices.removeAll()
        }
        bleManager?.clearDiscoveries(completion: { [weak self] in
            self?.bleManager?.startScan()
        })
    }
    
    func connect() {
        guard let selectedDevice = selectedDevice else { return }
        
        bleManager?.connect(to: selectedDevice.id)
    }
    
    func reconnectToHM10() {
        guard let device = availableDevices.first(where: { $0.name.lowercased().hasPrefix("HMSoft".lowercased()) }) else {
            return
        }
        
        self.bleManager?.connect(to: device.id)
    }
    
    func sendOn() {
        bleManager?.send(message: "YES")
    }
    
    func sendOff() {
        bleManager?.send(message: "NO")
    }
    
    func setupAndStart() {
        guard let bleManager = bleManager else { return }
        guard !hasInitialized else {
            if connectToHM10 {
                reconnectToHM10() // just try and reconnect to HM10
            }
            return
        }
        
        hasInitialized = true
          
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
                
                // add the new devices to the list of available devices
                guard !self.availableDevices.contains(where: { $0.id == device.id }) else { return }
                self.availableDevices.append(device)
                
                if self.connectToHM10 {
                    // if not connected and we found the BLE Adapter, connect
                    if device.name.lowercased().hasPrefix("HMSoft".lowercased()) {
                        self.bleManager?.connect(to: device.id)
                    }
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
                    if connectToHM10 {
                        self.startScan(clearDevices: false)
                    }
                }
            }
            .store(in: &cancellables)
        
        bleManager.cbStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
        
        bleManager.sensorDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sensorValue in
                guard let self = self else { return }
                guard let sensorValueItem = sensorValues.first(where: { $0.type == sensorValue.type }) else {
                    return
                }
                sensorValueItem.value = sensorValue.value
                sensorValueItem.timestamp = Date()
                // cheap way to tell the view to reload it's observed values.
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        bleManager.startCB()
    }
}
