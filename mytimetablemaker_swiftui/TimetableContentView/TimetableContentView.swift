//
//  TimetableContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2021/03/02.
//

import SwiftUI
import GoogleMobileAds

// MARK: - Timetable Content View
// Main timetable editing screen with grid view and image picker
struct TimetableContentView: View {
    
    @State private var weekflag = Date().isWeekday
    @State private var image = UIImage()
    @State private var isShowImagePicker = false
    @State private var scrollViewHeight: CGFloat = 0
    @State private var showWeekdaySheet = false
    @Environment(\.dismiss) private var dismiss

    private let goorback: String
    private let num: Int

    init(
        _ goorback: String,
        _ num: Int
    ) {
        self.goorback = goorback
        self.num = num
    }
    
    // MARK: - Action Variables
    /// Action to dismiss timetable view and return to homepage
    private var backToHomepageAction: () -> Void {
        return {
            dismiss()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.primary
                VStack(alignment: .leading, spacing: screen.timetableVerticalSpacing) {

                    // MARK: - Header Section
                    Text(goorback.lineNameArray[num])
                        .font(.system(size: screen.settingsSheetInputFontSize, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.leading, screen.timetableHorizontalSpacing)

                    Text("\(goorback.stationArray[2 * num])\(" >".localized)\(goorback.stationArray[2 * num + 1])")
                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.leading, screen.timetableHorizontalSpacing)
        
                    // MARK: - Timetable Grid
                    VStack(spacing: 0) {
                        Color.white.frame(width: screen.customWidth, height: 1)

                        HStack {
                            Color.white.frame(width: 1)
                            Spacer()
                            // Weekday/Weekend Dropdown Button for Header
                            Button(action: {
                                showWeekdaySheet = true
                            }) {
                                HStack {
                                    Text(weekflag ? "Weekdays".localized : "Sat/Sun/PH".localized)
                                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
                                        .foregroundColor(weekflag.weekLabelColor)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
                                        .foregroundColor(weekflag.weekLabelColor)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.clear)
                            }
                            Spacer()
                            Color.white.frame(width: 1)
                        }
                        .onAppear {
                            print("🔍 TimetableContentView: weekflag=\(weekflag), weekdayLabel='\(weekflag.weekdayLabel)', weekLabelColor=\(weekflag.weekLabelColor)")
                        }
                        .background(Color.black.opacity(0.5))
                        .frame(width: screen.customWidth, height: screen.timetableGridHeight)
    
                        Color.white.frame(width: screen.customWidth, height: 1)
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(validHourRange(), id: \.self) { hour in
                                    TimetableGridView(goorback, $weekflag, num, hour)
                                    Color.white.frame(width: screen.customWidth, height: 1)
                                }
                            }
                        }
                        .frame(height: screen.calculateScrollViewHeight(trainTimesCounts: getTrainTimesCounts()))
                    }
                    
                    colorLegendView(trainTypes: loadTrainTypeList())
                }
            }
            .navigationBarColor(
                backgroundColor: UIColor(.primary),
                titleColor: .white,
            )
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.bottom)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Timetable (Riding Time)".localized)
                        .font(.system(size: screen.settingsTitleFontSize, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .navigationBarLeading) {
                        // iOS 26+ specific back button styling
                        CustomBackButton(action: backToHomepageAction)
                    }
                    .sharedBackgroundVisibility(.hidden)
                } else {
                    ToolbarItem(placement: .navigationBarLeading) {
                        // iOS 16-25 back button styling
                        CustomBackButton(action: backToHomepageAction)
                    }
                }
            }
            .onAppear {
                // Set weekflag based on current date
                weekflag = Date().isWeekday
                print("📱 TimetableContentView loaded: weekflag=\(weekflag) (\(weekflag ? "Weekdays" : "Weekend")), label='\(weekflag.weekdayLabel)'")
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WeekdayChanged"))) { notification in
                if let userInfo = notification.userInfo,
                   let isWeekday = userInfo["isWeekday"] as? Bool {
                    weekflag = isWeekday
                    print("🔄 Weekday changed from SettingsTimetableSheet: weekflag=\(weekflag)")
                }
            }
            .sheet(isPresented: $showWeekdaySheet) {
                WeekdaySelectionSheet(weekflag: $weekflag)
            }
        }
    }
    
    // MARK: - Valid Hour Range Calculation
    // Calculate the range of hours with data, including gaps
    private func validHourRange() -> [Int] {
        let allHours = Array(4...25)
        
        // Find hours with train times
        let hoursWithData = allHours.filter { hour in
            !goorback.loadTransportationTimes(weekflag, num, hour).isEmpty
        }
        
        // Return range from first to last hour with data
        guard let firstHour = hoursWithData.min(),
              let lastHour = hoursWithData.max() else {
            return [] // No data found
        }
        
        return Array(firstHour...lastHour)
    }
    
    // MARK: - Get Train Times Counts
    // Get train times count for each hour in the valid range
    private func getTrainTimesCounts() -> [Int] {
        let hours = validHourRange()
        var counts: [Int] = []
        for hour in hours {
            let transportationTimes = goorback.loadTransportationTimes(weekflag, num, hour)
            counts.append(transportationTimes.count)
        }
        return counts
    }
    
    // MARK: - Load Train Type List
    // Load unique train types list for the current line and direction
    private func loadTrainTypeList() -> [String] {
        let trainTypeListKey = goorback.trainTypeListKey(weekflag, num)

        if let trainTypeListString = UserDefaults.standard.string(forKey: trainTypeListKey),
           !trainTypeListString.isEmpty {
            let trainTypes = Array(Set(trainTypeListString.components(separatedBy: " ")
                .filter { !$0.isEmpty }))
                .sorted { trainType1, trainType2 in
                    let color1 = Color.colorForTrainType(trainType1)
                    let color2 = Color.colorForTrainType(trainType2)
                    
                    // Define color priority: white, yellow-green, orange, red, pink
                    let colorPriority: [Color: Int] = [
                        .white: 0,
                        .yelwgre: 1,
                        .yellow: 2,
                        .orange: 3,
                        .pink: 4,
                        .ligblue: 5
                    ]
                    
                    let priority1 = colorPriority[color1] ?? 999
                    let priority2 = colorPriority[color2] ?? 999
                    
                    if priority1 != priority2 {
                        return priority1 < priority2
                    } else {
                        return trainType1 < trainType2
                    }
                }
            return trainTypes
        } else {
            print("🔍 loadTrainTypeList: No train type list found for key='\(trainTypeListKey)'")
            return []
        }
    }
    
    // MARK: - Color Legend View Function
    // Displays color legend for train types based on saved train type list
    @ViewBuilder
    private func colorLegendView(trainTypes: [String]) -> some View {
        // Filter out nil and empty train types
        let validTrainTypes = trainTypes.filter { !$0.isEmpty }
        
        // Group train types by color
        let groupedByColor = Dictionary(grouping: validTrainTypes) { trainType in
            Color.colorForTrainType(trainType)
        }
        
        // Convert to array of (color, trainTypes) tuples
        let colorGroups = groupedByColor.map { (color, types) in
            (color: color, trainTypes: types)
        }.sorted { group1, group2 in
            // Sort by color priority
            let colorPriority: [Color: Int] = [
                .white: 0,
                .yelwgre: 1,
                .yellow: 2,
                .orange: 3,
                .pink: 4,
                .ligblue: 5
            ]
            let priority1 = colorPriority[group1.color] ?? 999
            let priority2 = colorPriority[group2.color] ?? 999
            return priority1 < priority2
        }
        
        HStack {
            Spacer()
            VStack(spacing: screen.timetableVerticalSpacing) {
                ForEach(0..<((colorGroups.count + 1) / 2), id: \.self) { rowIndex in
                    HStack(spacing: screen.timetableHorizontalSpacing) {
                        ForEach(0..<min(2, colorGroups.count - rowIndex * 2), id: \.self) { colIndex in
                            let groupIndex = rowIndex * 2 + colIndex
                            let colorGroup = colorGroups[groupIndex]
                            
                            // Create combined display text
                            let displayTexts = colorGroup.trainTypes.map { trainType in
                                trainType.components(separatedBy: ".").last ?? trainType
                            }.map { $0.localized }
                            
                            let separator = Locale.current.language.languageCode?.identifier == "ja" ? "・" : ", "
                            let combinedText = displayTexts.joined(separator: separator)
                            
                            HStack {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(colorGroup.color)
                                    .font(.system(size: screen.settingsSheetInputFontSize))
                                Text(combinedText)
                                    .font(.system(size: screen.settingsSheetInputFontSize, weight: .medium))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .scaledToFit()
                            }
                            .padding(.horizontal, screen.timetableHorizontalSpacing)
                        }
                    }
                }
            }
            .padding(.horizontal, screen.timetableHorizontalSpacing)
            Spacer()
        }
    }
}

// MARK: - Weekday Selection Sheet
// Custom sheet for weekday/weekend selection with responsive sizing
struct WeekdaySelectionSheet: View {
    @Binding var weekflag: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: screen.settingsSheetVerticalSpacing) {
                // Selection buttons
                VStack(spacing: screen.settingsSheetVerticalSpacing) {
                    Button(action: {
                        weekflag = true
                        dismiss()
                        print("✅ Weekday selected: weekflag=\(weekflag)")
                    }) {
                        HStack {
                            Image(systemName: weekflag ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(Color.white)
                                .font(.system(size: screen.settingsSheetInputFontSize))
                            Text("Weekdays")
                                .foregroundColor(Color.white)
                                .font(.system(size: screen.settingsSheetInputFontSize, weight: .medium))
                            Spacer()
                        }
                        .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                        .padding(.vertical, screen.settingsSheetVerticalSpacing)
                        .background(weekflag ? Color.accent : Color.gray)
                        .cornerRadius(screen.settingsSheetVerticalSpacing)
                    }
                    
                    Button(action: {
                        weekflag = false
                        dismiss()
                        print("✅ Weekend selected: weekflag=\(weekflag)")
                    }) {
                        HStack {
                            Image(systemName: !weekflag ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(Color.white)
                                .font(.system(size: screen.settingsSheetInputFontSize))
                            Text("Sat/Sun/PH")
                                .foregroundColor(Color.white)
                                .font(.system(size: screen.settingsSheetInputFontSize, weight: .medium))
                            Spacer()
                        }
                        .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                        .padding(.vertical, screen.settingsSheetVerticalSpacing)
                        .background(!weekflag ? Color.accent : Color.gray)
                        .cornerRadius(screen.settingsSheetVerticalSpacing)
                    }
                }
                .padding(.horizontal, screen.settingsSheetHorizontalPadding)
                .padding(.top, screen.settingsSheetVerticalSpacing)
                .padding(.bottom, screen.settingsSheetVerticalSpacing)
                
                Spacer()
            }
            .background(.white)
            .navigationBarColor(
                backgroundColor: UIColor(.white),
                titleColor: .black,
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CustomBackButton(foregroundColor: .black, action: { dismiss() })
                }
            }
        }
        .presentationDetents([.medium, .large]) // コンテンツに応じて動的に調整
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct TimetableContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableContentView("back1", 0)
    }
}

