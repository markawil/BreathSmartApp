//
//
//  Created by MarkWilkinson on 12/6/24.
//

import Foundation
import CoreBluetooth

public enum CBState {
    case notAvailable
    case resetting
    case poweredOff
    case goodToGo
    case mockOnly
}

struct Device: Identifiable, Hashable {
    
    let id: UUID
    let name: String
    let advertisementData: [String : Any]
    let rsi: Int
    let description: String = ""
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}

class CBViewModel: NSObject, ObservableObject {
    
    // should just be devices we want to connect to
    @Published var devices: [Device] = []
    
    // temp to show all devices
    @Published var discoveredPeripherals = [CBPeripheral]()
    @Published var state: CBState = .notAvailable
    @Published var isConnected: Bool = false
    @Published var servicesAvailable: Bool = false
    @Published var isScanning: Bool = false
    
    private var centralManager: CBCentralManager!
    private(set) var connectedPeripheral: CBPeripheral? {
        didSet {
            isConnected = connectedPeripheral != nil
            connectingPeripheral = nil
        }
    }
    private(set) var connectingPeripheral: CBPeripheral?
    
    private var scanContinuation: CheckedContinuation<Void, Never>?
    
    // Keep track of characteristics that were found for the connectedPeripheral
    private var characteristics: [String: CBCharacteristic] = [:]
    
    // needed to show mocked preview
    init(with devices: [Device] = [],
         state: CBState = .notAvailable) {
        self.devices = devices
        self.state = state
    }
    
    func startCB() {
        guard state != .mockOnly else { return }
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() async {
        guard state != .mockOnly else { return }
        guard !centralManager.isScanning else { return }
        
        devices = []
        discoveredPeripherals = []
        
        await withCheckedContinuation { [weak self] continuation in
            self?.scanContinuation = continuation
            let options: [String: Any] = [
                CBCentralManagerScanOptionAllowDuplicatesKey: false
            ]
            self?.centralManager.scanForPeripherals(withServices: nil, options: options)
        }
    }
    
    func connect(to device: Device) {
        guard state != .mockOnly else { return }
        guard let peripheral = discoveredPeripherals.first(where: { $0.identifier == device.id }) else {
            // show error message that periph wasn't in the discovered list
            return
        }
        
        self.connectingPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func cancelConnection() {
        guard let peripheral = self.connectingPeripheral else { return }
        
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func disconnect() {
        guard let peripheral = self.connectedPeripheral else { return }
        guard let manager = self.centralManager else { return }
        
        manager.cancelPeripheralConnection(peripheral)
        self.connectedPeripheral = nil
        self.characteristics = [:]
    }
    
    func discoverServices() {
        guard let connectedPeripheral = self.connectedPeripheral else { return }
        connectedPeripheral.discoverServices([])
    }
    
    private func initialReadCharacteristics() {
        guard let peripheral = self.connectedPeripheral else { return }
        
        // read specific characteristics here if needed.
    }
    
    func sendOn() {
        send(message: "YES")
    }
    
    func sendOff() {
        send(message: "NO")
    }
    
    private func send(message: String) {
        guard let peripheral = connectedPeripheral else { return }
        
        guard let data = message.data(using: .utf8) else { return }
//        peripheral.writeValue(data, for: <#T##CBDescriptor#>)
    }
}

extension CBViewModel: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            //  The state of the manager and the app’s connection to the Bluetooth service is unknown.
            print("Unknown state")
            state = .notAvailable
        case .resetting:
            // The connection with the Bluetooth service was interrupted.
            print("Resetting state")
            state = .resetting
        case .unsupported:
            // The iOS device does not support Bluetooth.
            print("Unsupported state")
            state = .notAvailable
        case .unauthorized:
            // The user has refused the app permission to use Bluetooth. The user must re-enable it from the app’s Settings menu.
            print("Unauthorized state")
            state = .notAvailable
        case .poweredOff:
            // The user has toggled Bluetooth off and will need to turn it back on from Settings or the Control Center.
            print("Powered off state")
            state = .poweredOff
        case .poweredOn:
            // Bluetooth is enabled, authorized, and ready for app use.
            print("Powered on state")
            state = .goodToGo
            Task {
                await startScan()
            }
        @unknown default:
            print("default state")
            state = .notAvailable
        }
        
        // per Kirill Sidorov's guide/project, you should disconnect if currently connected and
        // one state changes to anything but poweredOn.
        if central.state != .poweredOn {
            disconnect()
            if central.isScanning {
                central.stopScan()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        guard central == self.centralManager else { return }
        guard !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) else { return }
        
        // it's new add it
        self.discoveredPeripherals.append(peripheral)
        let periphDevices = self.discoveredPeripherals.map { cbperiph in
            Device(id: peripheral.identifier,
                   name: cbperiph.name ?? "Unknown",
                   advertisementData: advertisementData,
                   rsi: RSSI.intValue)
        }
        self.devices.append(contentsOf: periphDevices)
        
        // tell the refreshable continuation to end and stop scanning
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.centralManager?.stopScan()
            self?.scanContinuation?.resume()
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
        discoverServices()
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        // show an error dialog.
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: (any Error)?) {
        guard self.connectedPeripheral?.identifier == peripheral.identifier else { return }
        
        disconnect()
    }
}

extension CBViewModel: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: (any Error)?) {
        self.servicesAvailable = true
        
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
    
}
