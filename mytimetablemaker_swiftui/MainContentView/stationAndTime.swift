//
//  stationAndTime.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/05/01.
//

import SwiftUI
import Foundation
import Combine

// MARK: - Station and Time View
// Displays station name and departure time with editing capability
struct stationAndTime: View {
    
    private var cancellable: AnyCancellable?
    
    @State private var isShowingAlert = false
    @State private var inputText = ""
    @State private var label: String

    private let goorback: String
    private let num: Int
    private let time: String

    // MARK: - Initialization
    // Initialize with route identifier, station number, and time
    init(
        _ goorback: String,
        _ num: Int,
        _ time: String
    ){
        self.goorback = goorback
        self.num = num
        self.time = time
        self.label = goorback.stationArray[num]
    }

    var body: some View {
        HStack {
            // MARK: - Station Name Button
            Button (action: {
                self.isShowingAlert = true
                inputText = ""
            }) {
                Text(label)
                    .font(.system(size: routeStationFontSize))
                    .lineLimit(1)
                    .onChange(of: goorback.stationArray[num]) {
                        newValue in label = newValue
                    }
            }
            // MARK: - Station Name Edit Alert
            .alert(stationAlertTitleArray[num], isPresented: $isShowingAlert) {
                TextField(placeHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                // OK button
                Button(textOk, role: .none){
                    if (inputText != "") {
                        UserDefaults.standard.set(inputText, forKey: goorback.stationKeyArray[num])
                    }
                    isShowingAlert = false
                }
                // Cancel button
                Button(textCancel, role: .cancel){
                    isShowingAlert = false
                }
            } message: {
                Text(stationAlertMessageArray[num])
            }
            Spacer()
            // MARK: - Time Display
            Text(time)
                .font(.custom("GenEiGothicN-Regular", size: routeTimeFontSize))
        }.foregroundColor(Color.primaryColor)
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct stationAndTime_Previews: PreviewProvider {
    static var previews: some View {
        stationAndTime("back1", 0, "0800")
    }
}
