//
//  BreatheSmartCBLApp.swift
//  BreathSmartCBL
//
//  Created by MarkWilkinson on 12/13/24.
//

import SwiftUI

@main
struct BreatheSmartCBLApp: App {
    
    init() {
        Bootstrap().registerDependencies()
        bleMgr = DependencyResolver.shared.resolve()
    }
        
    private var bleMgr: BLEProvider?
    
    var body: some Scene {
        WindowGroup {
            BreatheSmartHomeView()
                .environmentObject(BrSmViewModel(bleManager: bleMgr ?? BLEManager()))
        }
    }
}
