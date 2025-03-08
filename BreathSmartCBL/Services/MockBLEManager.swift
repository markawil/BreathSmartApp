//
//  MockBLEManager.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/7/25.
//

import Combine
import CoreBluetooth
import Foundation

class MockBLEManager: BLEProvider {
    
    // private publisher subjects
    private(set) var connectionStateSubject = CurrentValueSubject<Bool, Never>(false)
    private(set) var discoveredPeripheralSubject = PassthroughSubject<(CBPeripheral, [String : Any], NSNumber), Never>()
    private(set) var cbStateSubject = CurrentValueSubject<CBState, Never>(.notAvailable)
    private(set) var lastErrorSubject = CurrentValueSubject<ErrorType?, Never>(nil)
    private(set) var sensorValueSubject = PassthroughSubject<SensorValue, Never>()
    
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
    
    var sensorDataPublisher: AnyPublisher<SensorValue, Never> {
        sensorValueSubject.eraseToAnyPublisher()
    }
    
    var isConnected: Bool {
        connectionStateSubject.value
    }
    
    private(set) var connectedPeripheral: CBPeripheral? {
        didSet {
            connectionStateSubject.send(connectedPeripheral != nil)
        }
    }
    
    // Keep track of services and characteristics that were found for the connectedPeripheral
    private(set) var discoveredServices: [CBService] = []
    private(set) var characteristics: [String: CBCharacteristic] = [:]
    
    init(state: CBState = .notAvailable) {
        self.cbStateSubject.send(state)
    }
    
    func startCB() {
       
    }
    
    func startScan() {
        // put in mock behavior here
    }
    
    func send(message: String) {
        
    }
        
    func connect(to uuid: UUID) {
        
    }
    
    func disconnect() {        
        self.connectedPeripheral = nil
    }
    
    func discoverServices() {
        
    }
    
    private func initialReadCharacteristics() {
        
    }
    
    func clearDiscoveries(completion: @escaping () -> Void) {
        
    }
    
}
