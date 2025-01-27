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

struct Device: Identifiable {
    let id: UUID
    let name: String
    let advertisementData: [String : Any]
    let rsi: Int
}

class CBViewModel: NSObject, ObservableObject {
    
    // should just be devices we want to connec to
    @Published var devices: [Device] = []
    
    // temp to show all devices
    @Published var discoveredPeripherals = [CBPeripheral]()
    @Published var state: CBState = .notAvailable
    @Published var isConnected: Bool = false
    
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral? {
        didSet {
            isConnected = connectedPeripheral != nil
        }
    }
    
    // needed to show mocked preview
    init(with devices: [Device] = [],
         state: CBState = .notAvailable) {
        self.devices = devices
        self.state = state
    }
    
    func startCB() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        centralManager.scanForPeripherals(withServices: nil)
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
            startScan()
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
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
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
    
    func disconect() {
        guard let peripheral = self.connectedPeripheral else { return }
        guard let central = self.centralManager else { return }
        
        central.cancelPeripheralConnection(peripheral)
    }
}

extension CBViewModel: CBPeripheralDelegate {
    
}
