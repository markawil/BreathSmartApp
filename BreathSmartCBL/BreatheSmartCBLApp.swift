//
//  BreatheSmartCBLApp.swift
//  BreathSmartCBL
//
//  Created by MarkWilkinson on 12/13/24.
//

import SwiftUI

@main
struct BreatheSmartCBLApp: App {
    
    let bleManager = BLEManager()
    
//    init() {
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]        
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//    }
    
    var body: some Scene {
        WindowGroup {
            BreatheSmartHomeView()
                .environmentObject(BrSmViewModel(bleManager: bleManager))
        }
    }
}
