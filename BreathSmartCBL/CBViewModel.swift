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
    private var connectedPeripheral: CBPeripheral? {
        didSet {
            isConnected = connectedPeripheral != nil
        }
    }
    
    private var scanContinuation: CheckedContinuation<Void, Never>?
    
    // needed to show mocked preview
    init(with devices: [Device] = [],
         state: CBState = .notAvailable) {
        self.devices = devices
        self.state = state
    }
    
    func startCB() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() async {
        guard !centralManager.isScanning else { return }
        
        devices = []
        discoveredPeripherals = []
        
        await withCheckedContinuation { [weak self] continuation in
            self?.scanContinuation = continuation
            self?.centralManager.scanForPeripherals(withServices: nil)
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconect() {
        guard let peripheral = self.connectedPeripheral else { return }
        guard let central = self.centralManager else { return }
        
        central.cancelPeripheralConnection(peripheral)
    }
    
    func discoverService() {
        guard let connectedPeripheral = self.connectedPeripheral else { return }
        connectedPeripheral.discoverServices([])
    }
    
    func discoverCharacteristics(for service: CBService) {
        guard let connectedPeripheral = self.connectedPeripheral else { return }
        connectedPeripheral.discoverCharacteristics([], for: service)
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
        
        // tell the refreshable continuation to end
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.scanContinuation?.resume()
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
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
        self.connectedPeripheral = nil
    }
}

extension CBViewModel: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: (any Error)?) {
        self.servicesAvailable = true
        
        // use connectedPeripheral.services to see the values
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: (any Error)?) {
        
        // use
    }
    
}
