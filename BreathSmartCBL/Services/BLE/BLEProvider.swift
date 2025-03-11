//
//  BLEProvider.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/9/25.
//

import CoreBluetooth
import Combine
import Foundation

/*
 A combine Publisher interface for using CoreBluetooth
 */
protocol BLEProvider {
    
    /* Combine Publishers for BLE states */
    var connectionStatePublisher: AnyPublisher<Bool, Never> { get }
    var discoveredPeripheralPublisher: AnyPublisher<(CBPeripheral, [String : Any], NSNumber), Never> { get }
    var cbStatePublisher: AnyPublisher<CBState, Never> { get }
    var lastErrorPublisher: AnyPublisher<ErrorType?, Never> { get }
    var sensorDataPublisher: AnyPublisher<SensorValue, Never> { get }
    
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
    func clearDiscoveries(completion: @escaping () -> Void)
}
