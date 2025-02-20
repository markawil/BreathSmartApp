//
//
//  Created by MarkWilkinson on 12/6/24.
//

import Foundation
import CoreBluetooth
import Combine

class CBViewModel: NSObject, ObservableObject {
    
    // should just be devices we want to connect to
    @Published var devices: [Device] = []
    
    // temp to show all devices
    
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
         bleManager: BLEManager? = nil) {
        self.devices = devices
        self.bleManager = bleManager
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables = []
    }
    
    func startScan() {
        self.devices.removeAll()
        bleManager?.clearDiscoveries()
        bleManager?.startScan()
    }
    
    func connect() {
        guard let connectedDevice = connectedDevice else { return }
        
        bleManager?.connect(to: connectedDevice)
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
        
        bleManager.lastErrorSubject
            .receive(on: DispatchQueue.main)
            .sink { value in
                self.lastError = value
            }
            .store(in: &cancellables)
        
        bleManager.discoveredPeripheralSubject
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
        
        bleManager.connectionStateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.isConnected = value
            }
            .store(in: &cancellables)
        
        bleManager.cbStateSubject
            .receive(on: DispatchQueue.main)
            .sink { state in
                self.state = state
            }
            .store(in: &cancellables)
        
        bleManager.startCB()
    }
}

