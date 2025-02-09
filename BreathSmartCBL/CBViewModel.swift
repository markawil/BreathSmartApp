//
//
//  Created by MarkWilkinson on 12/6/24.
//

import Foundation
import CoreBluetooth

struct Device: Identifiable, Hashable {
    
    let id: UUID
    let name: String
    let advertisementData: [String : Any]
    let rssi: Int
    let description: String = ""
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
    
    var rssiLevel: Int {
        if rssi < 30 && rssi >= -30 {
            return 4
        }
        else if rssi < -30 && rssi >= -50 {
            return 3
        }
        else if rssi < -50 && rssi >= -70 {
            return 2
        }
        else if rssi < -70 && rssi > -100 {
            return 1
        }
        else {
            return 0
        }
    }
    
    var rssiImageName: String {
        switch rssiLevel {
        case 1:
            return "wifi_strength_1"
        case 2:
            return "wifi_strength_2"
        case 3:
            return "wifi_strength_3"
        case 4:
            return "wifi_strength_4"
        default:
            return "wifi_strength_0"
        }
    }
}

class CBViewModel: NSObject, ObservableObject {
    
    // should just be devices we want to connect to
    @Published var devices: [Device] = []
    
    // temp to show all devices
    @Published var discoveredPeripherals = [CBPeripheral]()
    @Published var discoveredServices: [CBService] = []
    @Published var state: CBState = .notAvailable
    @Published var isConnected: Bool = false
    @Published var servicesAvailable: Bool = false
    @Published var isScanning: Bool = false
    @Published var errorThrown: Bool = false
    @Published var selectedDevice: Device? // only used by the ContentView
    
    var lastError: ErrorType? {
        didSet {
            if lastError != nil {
                errorThrown = true
            }
        }
    }
    
    var connectedDevice: Device? {
        guard let connectedPeripheral else { return nil }
        guard !devices.isEmpty else { return nil }
        
        return devices.first { $0.id == connectedPeripheral.identifier }
    }
    
    private var centralManager: CBCentralManager!
    private(set) var connectedPeripheral: CBPeripheral? {
        didSet {
            isConnected = connectedPeripheral != nil
            connectingPeripheral = nil
        }
    }
    private(set) var connectingPeripheral: CBPeripheral?
    
    // Keep track of characteristics that were found for the connectedPeripheral
    @Published var characteristics: [String: CBCharacteristic] = [:]
    
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
    
    func startScan() {
        guard state != .mockOnly else { return }
        guard !centralManager.isScanning else { return }
        
        clearDiscoveries()
        
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ]
        self.centralManager.scanForPeripherals(withServices: nil, options: options)
        
        // only need to scan for 3 seconds at most
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.centralManager?.stopScan()
        }
    }
    
    func connect(to device: Device) {
        guard state != .mockOnly else { return }
        guard let peripheral = discoveredPeripherals.first(where: { $0.identifier == device.id }) else {
            // show error message that periph wasn't in the discovered list
            self.lastError = .peripheralMissing
            return
        }
        
        self.connectingPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        guard state != .mockOnly else { return }
        guard let peripheral = self.connectedPeripheral else {
            clearDiscoveries() // go ahead and clear if periph was already nil
            return
        }
       
        centralManager.cancelPeripheralConnection(peripheral)
        clearDiscoveries()
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
    
    private func clearDiscoveries() {
        DispatchQueue.main.async {
            self.discoveredPeripherals.removeAll()
            self.discoveredServices.removeAll()
            self.devices.removeAll()
            self.characteristics.removeAll()
        }
    }
    
    func sendOn() {
        send(message: "YES")
    }
    
    func sendOff() {
        send(message: "NO")
    }
    
    private func send(message: String) {
        guard let peripheral = connectedPeripheral else { return }
        guard let name = peripheral.name, name.starts(with: "HM") else { return } // only dealing with the HM10 right now.
        guard let characteristic = characteristics[Constants.HM10.Characteristic.data] else { return }
                
        guard let data = message.data(using: .utf8) else { return }
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
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
                startScan()
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
            
            // now show an alert that anything other than poweredOn was found
            self.lastError = state.errorType
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
        let device = Device(id: peripheral.identifier,
                            name: peripheral.name ?? "Unknown",
                            advertisementData: advertisementData,
                            rssi: RSSI.intValue)
        self.devices.append(device)
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
        self.lastError = .failedToConnect
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
