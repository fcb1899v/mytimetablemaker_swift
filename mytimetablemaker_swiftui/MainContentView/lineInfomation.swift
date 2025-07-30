//
//  mainAlertPlusLabel.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/03/04.
//

import SwiftUI

// MARK: - Line Information View
// Displays line information with ride time, name, and color editing capabilities
struct lineInfomation: View {
    
    @State private var isShowingRideTimeAlert = false
    @State private var isShowingTimetableAlert = false
    @State private var isShowingLineNameAlert = false
    @State private var isShowingLineColorAlert = false
    @State private var inputText = ""
    @State private var label: String
    @State private var color : Color

    private let goorback: String
    private let weekflag: Bool
    private let num: Int
    
    // MARK: - Initialization
    // Initialize with route identifier, weekday flag, and line number
    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ num: Int
    ){
        self.goorback = goorback
        self.weekflag = weekflag
        self.num = num
        self.label = goorback.lineNameArray[num]
        self.color = goorback.lineColorArray[num]
    }

    var body: some View {
        HStack {
            // MARK: - Ride Time Button
            Button (action: {
                self.isShowingRideTimeAlert = true
                inputText = ""
            }) {
                lineTimeImage(color: color)
                    .sheet(isPresented: $isShowingTimetableAlert) {
                        TimetableContentView(goorback, num)
                    }
            }
            // MARK: - Ride Time Edit Alert
            .alert(rideTimeAlertTitle, isPresented: $isShowingRideTimeAlert) {
                TextField(numberPlaceHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .lineLimit(1)
                // OK button
                Button(textOk, role: .none) {
                    if (inputText.intText(min: 1, max: 99) > 0) {
                        UserDefaults.standard.set(inputText, forKey: goorback.rideTimeKey(num))
                    }
                    isShowingRideTimeAlert = false
                }
                // Cancel button
                Button(textCancel, role: .cancel){
                    isShowingRideTimeAlert = false
                }
                // Change Timetable button
                Button(timetableAlertTitle, role: .destructive) {
                    isShowingTimetableAlert = true
                    isShowingRideTimeAlert = false
                }
            } message: {
                Text(goorback.rideTimeAlertMessage(num))
            }
            
            // MARK: - Line Name Button
            Button (action: {
                isShowingLineNameAlert = true
                inputText = ""
            }) {
                Text(label)
                    .font(.system(size: routeLineFontSize))
                    .foregroundColor(color)
                    .lineLimit(1)
                    .onChange(of: goorback.lineNameArray[num]) {
                        newValue in label = newValue
                    }
                    .onChange(of: goorback.lineColorArray[num]) {
                        newColor in color = newColor
                    }
            }
            // MARK: - Line Name Edit Alert
            .alert(lineNameAlertTitle, isPresented: $isShowingLineNameAlert) {
                TextField(placeHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                // OK button
                Button(textOk, role: .none){
                    if (inputText != "") {
                        UserDefaults.standard.set(inputText, forKey: goorback.lineNameKey(num))
                    }
                    isShowingLineNameAlert = false
                }
                // Cancel button
                Button(textCancel, role: .cancel){
                    isShowingLineNameAlert = false
                }
                // Setting line color button
                Button(lineColorAlertTitle, role: .destructive){
                    if (inputText != "") {
                        UserDefaults.standard.set(inputText, forKey: goorback.lineNameKey(num))
                    }
                    isShowingLineColorAlert = true
                    isShowingLineNameAlert = false
                }
            } message: {
                Text(lineNameAlertMessage(num))
            }
            .padding(.leading, routeLineImageLeftPadding)
            
            // MARK: - Line Color Action Sheet
            .actionSheet(isPresented: $isShowingLineColorAlert) {
                ActionSheet(
                    title: Text(lineColorAlertTitle),
                    message: Text(goorback.lineNameArray[num]),
                    buttons: CustomColor.allCases.map{$0.rawValue.localized}.indices.map { i in
                        .default(Text(CustomColor.allCases.map{$0.rawValue.localized}[i])) {
                            UserDefaults.standard.set(
                                CustomColor.allCases.map{$0.RGB}[i],
                                forKey: goorback.lineColorKey(num)
                            )
                        }
                    } + [.cancel()]
                )
            }
            Spacer()
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct lineInfomation_Previews: PreviewProvider {
    static var previews: some View {
        lineInfomation("back1", true, 0)
    }
}
