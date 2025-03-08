//
//
//  Created by MarkWilkinson on 12/6/24.
//

import Foundation
import CoreBluetooth
import Combine

class CBViewModel: ObservableObject {
    
    // should just be devices we want to connect to
    @Published var devices: [Device] = []
    @Published var selectedDevice: Device? // only used by the ContentView
    @Published var errorThrown: Bool = false
    @Published var isConnected: Bool = false
    @Published var state: CBState = .notAvailable
    
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
        guard !devices.isEmpty else { return nil }
        
        return devices.first { $0.id == peripheral.identifier }
    }
    
    private(set) var bleManager: BLEProvider?
    
    // devices needed to show mocked preview
    init(with devices: [Device] = [],
         bleManager: BLEProvider? = nil) {
        self.devices = devices
        self.bleManager = bleManager
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables = []
    }
    
    func startScan(removeDiscoveredDevices: Bool) {
        if removeDiscoveredDevices {
            self.devices.removeAll()
        }
        bleManager?.clearDiscoveries()
        bleManager?.startScan()
    }
    
    func connect() {
        guard let selectedDevice = selectedDevice else { return }
        
        bleManager?.connect(to: selectedDevice.id)
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
                guard !self.devices.contains(where: { $0.id == device.id }) else { return }
                self.devices.append(device)
            }
            .store(in: &cancellables)
        
        bleManager.connectionStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
        
        bleManager.cbStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }
}

