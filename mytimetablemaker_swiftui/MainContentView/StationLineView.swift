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
    @State private var departureStation: String
    @State private var arrivalStation: String
    @State private var color : Color

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
        self.departureStation = goorback.stationArray[2 * num + 2]
        self.arrivalStation = goorback.stationArray[2 * num + 3]
        self.color = goorback.lineColorArray[num]
    }

    var body: some View {
        VStack(alignment: .leading) {

            HStack {
                Text(departureStation)
                    .font(.system(size: routeStationFontSize))
                    .lineLimit(1)
                    .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                        // UserDefaultsが変更された時に色を更新
                        departureStation = goorback.stationArray[2 * num + 2]
                    }
                Spacer()
                // MARK: - Time Display
                Text(departureTime)
                    .font(.custom("GenEiGothicN-Regular", size: routeTimeFontSize))

            }.foregroundColor(Color.primaryColor)

            HStack {
                // MARK: - Setting Button
                Button (action: {
                    isShowingLineSelection = true
                }) {
                    lineTimeImage(color: color)
                        .sheet(isPresented: $isShowingTimetableAlert) {
                            TimetableContentView(goorback, num)
                        }
                }
                .sheet(isPresented: $isShowingLineSelection) {
                    NavigationStack {
                        SelectLineView(goorback: goorback, lineIndex: num)
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
                .padding(.leading, routeLineImageLeftPadding)

                Text(lineName)
                    .font(.system(size: routeLineFontSize))
                    .foregroundColor(color)
                    .lineLimit(1)
                    .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                        // UserDefaultsが変更された時に色を更新
                        lineName = goorback.lineName(num)
                        color = goorback.lineColorArray[num]
                    }
            }
            
            HStack {
                Text(arrivalStation)
                    .font(.system(size: routeStationFontSize))
                    .lineLimit(1)
                    .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                        // UserDefaultsが変更された時に色を更新
                        arrivalStation = goorback.stationArray[2 * num + 3]
                    }
                Spacer()
                // MARK: - Time Display
                Text(arrivalTime)
                    .font(.custom("GenEiGothicN-Regular", size: routeTimeFontSize))
            }.foregroundColor(Color.primaryColor)
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct StationAndLine_Previews: PreviewProvider {
    static var previews: some View {
        LineAndStation("back1", true, 0, "0800", "0830")
            .onAppear {
                // プレビュー用のテストデータを設定
                UserDefaults.standard.set("東京駅", forKey: "station_2")
                UserDefaults.standard.set("新宿駅", forKey: "station_3")
                UserDefaults.standard.set("テスト路線", forKey: "lineName_0")
                UserDefaults.standard.set("#FF0000", forKey: "lineColor_0")
            }
    }
}
