//
//  VariousSettingsContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/02/14.
//

import SwiftUI

// MARK: - Various Settings Content View
// Comprehensive settings screen for configuring route details including stations, lines, and times
struct VariousSettingsContentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    private let goorback: String
    private let weekflag = Date().isWeekday

    init(
        _ goorback: String
    ){
        self.goorback = goorback
    }

    var body: some View {
        Form {
            // MARK: - Station Settings Section
            Section(
                header: Text(stationAlertTitle).fontWeight(.bold)
            ) {
                ForEach(1...2 * goorback.changeLineInt + 3, id: \.self) { num in settingsStations(goorback, num) }
                settingsStations(goorback, 0)
            }
            
            // MARK: - Line Name Settings Section
            Section(
                header: Text(lineNameAlertTitle).fontWeight(.bold)
            ) {
                ForEach(0...goorback.changeLineInt, id: \.self) { num in settingsLineName(goorback, num) }
            }
            
            // MARK: - Ride Time Settings Section
            Section(
                header: Text(rideTimeAlertTitle).fontWeight(.bold)
            ) {
                ForEach(0...goorback.changeLineInt, id: \.self) { num in settingsRideTime(goorback, num) }
            }
            
            // MARK: - Transportation Settings Section
            Section(
                header: Text(transportationAlertTitle).fontWeight(.bold)
            ) {
                ForEach(1...goorback.changeLineInt + 1, id: \.self) { num in settingsTransportation(goorback, num) }
                settingsTransportation(goorback, 0)
            }
            
            // MARK: - Transit Time Settings Section
            Section(
                header: Text(transitTimeAlertTitle).fontWeight(.bold)
            ) {
                ForEach(1...goorback.changeLineInt + 1, id: \.self) { num in settingsTransitTime(goorback, num) }
                settingsTransitTime(goorback, 0)
            }
        }.navigationBarHidden(true)
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct VariousSettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        VariousSettingsContentView("back1")
    }
}
