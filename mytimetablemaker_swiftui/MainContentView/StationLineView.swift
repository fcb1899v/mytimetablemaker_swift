//
//  StationLineView.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2025/08/16.
//

import SwiftUI

// MARK: - Line Information View
// Displays line information with ride time, name, and color editing capabilities
struct StationLineView: View {
    
    @State private var isShowingTimetableAlert = false
    @State private var isShowingLineSelection = false

    private let goorback: String
    private let weekflag: Bool
    private let num: Int
    private let departureTime: String
    private let arrivalTime: String
    private let lineNameArray: [String]
    private let lineColorArray: [Color]
    private let lineCodeArray: [String]
    private let lineKindArray: [TransportationLine.Kind]
    private var stationArray: [String]
    
    // MARK: - Initialization
    // Initialize with route identifier, weekday flag, and line number
    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ num: Int,
        _ departureTime: String,
        _ arrivalTime: String
    ){
        self.goorback = goorback
        self.weekflag = weekflag
        self.num = num
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.lineNameArray = goorback.lineNameArray
        self.lineColorArray = goorback.lineColorArray
        self.lineCodeArray = goorback.lineCodeArray
        self.lineKindArray = goorback.lineKindArray
        self.stationArray = goorback.stationArray
    }

    var body: some View {
        VStack(alignment: .leading) {

            HStack {
                Text(stationArray[2 * num])
                    .font(.system(size: screen.stationFontSize))
                    .lineLimit(1)
                Spacer()
                // MARK: - Time Display
                Text(departureTime)
                    .font(.custom("GenEiGothicN-Regular", size: screen.timeFontSize))
            }
            .foregroundColor(.primary)

            // MARK: - Setting Button
            Button (action: {
                isShowingLineSelection = true
            }) {
                HStack {
                    LineTimeImage(
                        lineColor: lineColorArray[num],
                        lineCode: lineCodeArray[num],
                        isTransfer: false,
                        transportation: "",
                        transportationKind: lineKindArray[num]
                    )
                    
                    Text(lineNameArray[num])
                        .font(.system(size: screen.lineFontSize))
                        .foregroundColor(lineColorArray[num])
                        .lineLimit(2)
                }
                .sheet(isPresented: $isShowingTimetableAlert) {
                    TimetableContentView(goorback, num)
                }
            }
            .frame(height: screen.lineNameHeight)
            .sheet(isPresented: $isShowingLineSelection) {
                NavigationStack {
                    SettingsLineSheet(goorback: goorback, lineIndex: num)
                }
            }

            
            HStack {
                Text(stationArray[2 * num + 1])
                    .font(.system(size: screen.stationFontSize))
                    .lineLimit(1)
                Spacer()
                // MARK: - Time Display
                Text(arrivalTime)
                    .font(.custom("GenEiGothicN-Regular", size: screen.timeFontSize))
            }
            .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct StationAndLine_Previews: PreviewProvider {
    static var previews: some View {
        StationLineView("back1", true, 0, "0800", "0830")
    }
}
