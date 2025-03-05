//
//  BSViewModel.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 2/21/25.
//

import Combine
import Foundation

class BSViewModel: ObservableObject {
    
    @Published var isScanning: Bool = false
    @Published var isConnected: Bool = false
    @Published var errorThrown: Bool = false
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
    
    var connectedDevice: Device?
    
    private(set) var bleManager: BLEProvider?
    
    // devices needed to show mocked preview
    init(bleManager: BLEManager? = nil) {
        self.bleManager = bleManager
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables = []
    }
    
    func scanAndConnectToHM10() {
        bleManager?.clearDiscoveries()
        bleManager?.startScan()
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
                
                if device.name.hasPrefix("HMSoft") {
                    
                }
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
        
        bleManager.startCB()
    }
}
