//
//  StationLineView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/08/16.
//

import SwiftUI

// MARK: - Line Information View
// Displays line information with ride time, name, and color editing capabilities
struct LineAndStation: View {
    
    @State private var isShowingTimetableAlert = false
    @State private var isShowingLineSelection = false
    @State private var inputText = ""
    @State private var lineName: String
    @State private var lineColor : Color
    @State private var lineCode: String
    @State private var departureStation: String
    @State private var arrivalStation: String

    private let goorback: String
    private let weekflag: Bool
    private let num: Int
    private let departureTime: String
    private let arrivalTime: String

    
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
        self.lineName = goorback.lineNameArray[num]
        self.lineColor = goorback.lineColorArray[num]
        self.lineCode = goorback.lineCodeArray[num]
        self.departureStation = goorback.stationArray[2 * num + 2]
        self.arrivalStation = goorback.stationArray[2 * num + 3]
    }

    var body: some View {
        VStack(alignment: .leading) {

            HStack {
                Text(departureStation)
                    .font(.system(size: stationFontSize))
                    .lineLimit(1)
                Spacer()
                // MARK: - Time Display
                Text(departureTime)
                    .font(.custom("GenEiGothicN-Regular", size: timeFontSize))
            }.foregroundColor(Color.primaryColor)

            HStack {
                // MARK: - Setting Button
                Button (action: {
                    isShowingLineSelection = true
                }) {
                    lineTimeImage(
                        lineColor: lineColor,
                        lineCode: lineCode,
                        isTransit: false,
                        transportation: ""
                    )
                    .sheet(isPresented: $isShowingTimetableAlert) {
                        TimetableContentView(goorback, num)
                    }
                }
                .sheet(isPresented: $isShowingLineSelection) {
                    NavigationStack {
                        SettingsLineSheet(goorback: goorback, lineIndex: num)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Cancel".localized) {
                                        isShowingLineSelection = false
                                    }
                                    .foregroundColor(Color.black)
                                }
                            }
                    }
                }

                Text(lineName)
                    .font(.system(size: lineFontSize))
                    .foregroundColor(lineColor)
                    .lineLimit(1)
            }
            
            HStack {
                Text(arrivalStation)
                    .font(.system(size: stationFontSize))
                    .lineLimit(1)
                Spacer()
                // MARK: - Time Display
                Text(arrivalTime)
                    .font(.custom("GenEiGothicN-Regular", size: timeFontSize))
            }.foregroundColor(Color.primaryColor)
        }
        .onChange(of: isShowingLineSelection) { isPresented in
            if !isPresented {
                updateLineData()
            }
        }
        // UserDefaultsが変更された時にデータを更新
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            updateLineData()
        }
        // 初期データの読み込み
        .onAppear {
            updateLineData()
        }

    }
    
    
    // MARK: - Helper Methods
    // Update line data from UserDefaults
    private func updateLineData() {
        departureStation = goorback.stationArray[2 * num + 2]
        arrivalStation = goorback.stationArray[2 * num + 3]
        lineName = goorback.lineName(num)
        lineColor = goorback.lineColorArray[num]
        lineCode = goorback.lineCodeArray[num]
        print("Updated line data: lineName: \(lineName), color: \(lineColor), lineCode: \(lineCode), departureStation: \(departureStation), arrivalStation: \(arrivalStation)")
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct StationAndLine_Previews: PreviewProvider {
    static var previews: some View {
        LineAndStation("back1", true, 0, "0800", "0830")
    }
}
