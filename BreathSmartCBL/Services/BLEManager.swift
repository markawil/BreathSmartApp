//
//  BLEManager.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 2/17/25.
//

import Combine
import CoreBluetooth
import Foundation

protocol BLEProvider {
    
    /* Combine Publishers for BLE states */
    var connectionStatePublisher: AnyPublisher<Bool, Never> { get }
    var discoveredPeripheralPublisher: AnyPublisher<(CBPeripheral, [String : Any], NSNumber), Never> { get }
    var cbStatePublisher: AnyPublisher<CBState, Never> { get }
    var lastErrorPublisher: AnyPublisher<ErrorType?, Never> { get }
    
    /* Properties for the connected device */
    var discoveredServices: [CBService] { get }
    var characteristics: [String: CBCharacteristic] { get }
    var isConnected: Bool { get }
    var connectedPeripheral: CBPeripheral? { get }
    
    func startCB()
    func startScan()
    func connect(to: UUID)
    func disconnect()
    func send(message: String)
    func clearDiscoveries()
}

class BLEManager: NSObject, BLEProvider {
    
    // private publisher subjects
    private(set) var connectionStateSubject = CurrentValueSubject<Bool, Never>(false)
    private(set) var discoveredPeripheralSubject = PassthroughSubject<(CBPeripheral, [String : Any], NSNumber), Never>()
    private(set) var cbStateSubject = CurrentValueSubject<CBState, Never>(.notAvailable)
    private(set) var lastErrorSubject = CurrentValueSubject<ErrorType?, Never>(nil)
    
    // public publishers hiding the private subjects
    var connectionStatePublisher: AnyPublisher<Bool, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }
    
    var discoveredPeripheralPublisher: AnyPublisher<(CBPeripheral, [String : Any], NSNumber), Never> {
        discoveredPeripheralSubject.eraseToAnyPublisher()
    }
    
    var cbStatePublisher: AnyPublisher<CBState, Never> {
        cbStateSubject.eraseToAnyPublisher()
    }
    
    var lastErrorPublisher: AnyPublisher<ErrorType?, Never> {
        lastErrorSubject.eraseToAnyPublisher()
    }
    
    var isConnected: Bool {
        connectionStateSubject.value
    }
    
    private var isScanning: Bool = false
    private var centralManager: CBCentralManager!
    private(set) var connectedPeripheral: CBPeripheral? {
        didSet {
            connectionStateSubject.send(connectedPeripheral != nil)
        }
    }
    
    private var discoveredPeripherals: [CBPeripheral] = []
    // Keep track of services and characteristics that were found for the connectedPeripheral
    private(set) var discoveredServices: [CBService] = []
    private(set) var characteristics: [String: CBCharacteristic] = [:]
    
    init(state: CBState = .notAvailable) {
        self.cbStateSubject.send(state)
    }
    
    func startCB() {
        guard cbStateSubject.value != .mockOnly else { return }
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        guard cbStateSubject.value != .mockOnly else { return }
        guard !centralManager.isScanning else { return }
        
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ]
        self.centralManager.scanForPeripherals(withServices: nil, options: options)
        
        // only need to scan for 3 seconds at most
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.centralManager?.stopScan()
        }
    }
    
    func send(message: String) {
        guard let peripheral = connectedPeripheral else { return }
        guard let name = peripheral.name, name.starts(with: "HM") else { return } // only dealing with the HM10 right now.
        guard let characteristic = characteristics[Constants.HM10.Characteristic.data] else { return }
                
        guard let data = message.data(using: .utf8) else { return }
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
    }
        
    func connect(to uuid: UUID) {
        guard cbStateSubject.value != .mockOnly else { return }
        guard let peripheral = discoveredPeripherals.first(where: { $0.identifier == uuid }) else { return }
        
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        guard cbStateSubject.value != .mockOnly else { return }
        guard let peripheral = self.connectedPeripheral else {
            clearConnectedPeripheralDiscoveries() // go ahead and clear if periph was already nil
            return
        }
       
        centralManager.cancelPeripheralConnection(peripheral)
        clearConnectedPeripheralDiscoveries()
        self.connectedPeripheral = nil
    }
    
    func discoverServices() {
        guard let connectedPeripheral = self.connectedPeripheral else { return }
        connectedPeripheral.discoverServices([])
    }
    
    private func initialReadCharacteristics() {
        guard let peripheral = self.connectedPeripheral else { return }
        
        // read specific characteristics here if needed.
    }
    
    func clearDiscoveries() {
        DispatchQueue.main.async {
            self.discoveredPeripherals.removeAll()
            self.clearConnectedPeripheralDiscoveries()
        }
    }
    
    func clearConnectedPeripheralDiscoveries() {
        DispatchQueue.main.async {
            self.discoveredServices.removeAll()
            self.characteristics.removeAll()
        }
    }
}

extension BLEManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            //  The state of the manager and the app’s connection to the Bluetooth service is unknown.
            print("Unknown state")
            cbStateSubject.send(.notAvailable)
        case .resetting:
            // The connection with the Bluetooth service was interrupted.
            print("Resetting state")
            cbStateSubject.send(.resetting)
        case .unsupported:
            // The iOS device does not support Bluetooth.
            print("Unsupported state")
            cbStateSubject.send(.notAvailable)
        case .unauthorized:
            // The user has refused the app permission to use Bluetooth. The user must re-enable it from the app’s Settings menu.
            print("Unauthorized state")
            cbStateSubject.send(.notAvailable)
        case .poweredOff:
            // The user has toggled Bluetooth off and will need to turn it back on from Settings or the Control Center.
            print("Powered off state")
            cbStateSubject.send(.poweredOff)
        case .poweredOn:
            // Bluetooth is enabled, authorized, and ready for app use.
            print("Powered on state")
            cbStateSubject.send(.goodToGo)
            Task {
                startScan()
            }
        @unknown default:
            print("default state")
            cbStateSubject.send(.notAvailable)
        }
        
        // per Kirill Sidorov's guide/project, you should disconnect if currently connected and
        // one state changes to anything but poweredOn.
        if central.state != .poweredOn {
            disconnect()
            if central.isScanning {
                central.stopScan()
            }
            
            // now show an alert that anything other than poweredOn was found
            self.lastErrorSubject.send(cbStateSubject.value.errorType)
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        guard central == self.centralManager else { return }
        guard !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) else { return }
        // ignore peripherals that aren't cool enough to reveal their names
        guard let name = peripheral.name else { return }
        
        // it's new add it
        self.discoveredPeripherals.append(peripheral)
        self.discoveredPeripheralSubject.send((peripheral, advertisementData, RSSI))
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
        
        discoverServices()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.send(message: "$$iPhone15!!")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        self.lastErrorSubject.send(.failedToConnect)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: (any Error)?) {
        guard self.connectedPeripheral?.identifier == peripheral.identifier else { return }
        
        disconnect()
    }
}

extension BLEManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: (any Error)?) {
        
        self.discoveredServices.removeAll()
        self.discoveredServices.append(contentsOf: peripheral.services ?? [])
        // peripheral responded it has services, get the available characteristics
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: (any Error)?) {
        guard let _ = self.connectedPeripheral else { return }
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            let key = characteristic.uuid
            self.characteristics[key.uuidString] = characteristic
        }
        
        initialReadCharacteristics()
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: (any Error)?) {
        // implement if you want to know when a value was updated.
    }
}
