//
//  BreathSmartHomeView.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 2/17/25.
//

import SwiftUI

struct BreathSmartHomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .navigationTitle("BreathSmart")
            .toolbarBackground(Color(.blue), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                
            }
        }
    }
}

#Preview {
    BreathSmartHomeView()
}
