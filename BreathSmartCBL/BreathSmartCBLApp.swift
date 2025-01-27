//
//  BreathSmartCBLApp.swift
//  BreathSmartCBL
//
//  Created by MarkWilkinson on 12/13/24.
//

import SwiftUI

@main
struct BreathSmartCBLApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: CBViewModel())
        }
    }
}
