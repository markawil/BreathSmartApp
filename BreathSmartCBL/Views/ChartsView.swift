//
//  ChartsView.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/9/25.
//

import Charts
import SwiftUI

struct ChartsView: View {
    
    @Environment(\.presentationMode) private var mode
    @EnvironmentObject var viewModel: ChartsViewModel
    
    var body: some View {
        ZStack {
            ScrollView {
                Text("7 day average")
                    .font(.headline)
                    .bold()
                    .padding()
                ForEach(SensorValueType.allCases, id: \.rawValue) { sensorType in
                    if sensorType != .battery {
                        let chartValues = viewModel.buildChartValues(for: sensorType)
                        LineChartView(values: chartValues, sensorType: sensorType)
                            .padding()
                    }
                }
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Sensor Data")
                            .bold()
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(Color(.blue), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    NavigationStack {
        ChartsView()
            .environmentObject(ChartsViewModel(realmManager: RealmManager(useInMemory: true)))
    }
}
