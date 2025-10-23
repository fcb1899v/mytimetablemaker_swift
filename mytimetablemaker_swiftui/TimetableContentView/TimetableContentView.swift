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
    
    @State private var selectedCalendarType = Date().odpTCalendarType
    @State private var availableCalendarTypes: [ODPTCalendarType] = []
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

                    Text("\(goorback.stationArray[2 * num])\(" > ".localized)\(goorback.stationArray[2 * num + 1])")
                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.leading, screen.timetableHorizontalSpacing)

                    // Show color legend only when there are 2 or more train types
                    if loadTrainTypeList().count > 1 {
                        colorLegendView(trainTypes: loadTrainTypeList())
                    }
                                        
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
                                    Text(selectedCalendarType.displayName)
                                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
                                        .foregroundColor(selectedCalendarType.calendarColor)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
                                        .foregroundColor(selectedCalendarType.calendarColor)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.clear)
                            }
                            Spacer()
                            Color.white.frame(width: 1)
                        }
                        .onAppear {
                            print("🔍 TimetableContentView: selectedCalendarType=\(selectedCalendarType.displayName), calendarTag=\(selectedCalendarType.calendarTag)")
                        }
                        .background(Color.black.opacity(0.5))
                        .frame(width: screen.customWidth, height: screen.timetableGridHeight)
    
                        Color.white.frame(width: screen.customWidth, height: 1)
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(validHourRange(), id: \.self) { hour in
                                    TimetableGridView(goorback, $selectedCalendarType, num, hour)
                                    Color.white.frame(width: screen.customWidth, height: 1)
                                }
                            }
                        }
                        .frame(minHeight: 0.0, maxHeight: screen.timetableMaxHeight)
                    }
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
                // Load available calendar types from cache or use default
                availableCalendarTypes = loadAvailableCalendarTypes()
                
                // Set selectedCalendarType based on current date with fallback to available types
                selectedCalendarType = Date().odpTCalendarType(fallbackTo: availableCalendarTypes)
                
                // Check if data exists for the selected calendar type, if not, try other available types
                if !hasTimetableDataForSelectedType() {
                    print("📱 No data found for \(selectedCalendarType.debugDisplayName), trying other calendar types...")
                    for calendarType in availableCalendarTypes {
                        if hasTimetableDataForType(calendarType) {
                            selectedCalendarType = calendarType
                            print("📱 Found data for \(calendarType.debugDisplayName), switching to it")
                            break
                        }
                    }
                }
                
                print("📱 TimetableContentView loaded: selectedCalendarType=\(selectedCalendarType.debugDisplayName)")
                print("📱 Selected calendar type raw value: \(selectedCalendarType.rawValue)")
                print("📱 Selected calendar type tag: \(selectedCalendarType.calendarTag)")
                print("📱 Available calendar types: \(availableCalendarTypes.map { $0.debugDisplayName })")
                
                // Debug: Check if timetable data exists for the selected calendar type
                let sampleKey = goorback.timetableKey(selectedCalendarType, num, 7)
                print("📱 Looking for timetable data with key: \(sampleKey)")
                if let timetableString = UserDefaults.standard.string(forKey: sampleKey) {
                    print("📱 Sample timetable data found for hour 7: \(timetableString)")
                } else {
                    print("📱 No timetable data found for hour 7 with key: \(sampleKey)")
                    
                    // Debug: Check all UserDefaults keys that contain timetable data
                    let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
                    let timetableKeys = allKeys.filter { $0.contains("timetable") && $0.contains("\(num)") && $0.contains("07") }
                    print("📱 All timetable keys for hour 7: \(timetableKeys)")
                    
                    // Debug: Check all UserDefaults keys that contain this route
                    let routeKeys = allKeys.filter { $0.contains("\(goorback)") && $0.contains("\(num)") }
                    print("📱 All keys for route \(goorback) and num \(num): \(routeKeys)")
                    
                    // Debug: Check all UserDefaults keys that contain calendar tags
                    let calendarKeys = allKeys.filter { $0.contains("holiday") || $0.contains("weekday") || $0.contains("saturday") }
                    print("📱 All keys with calendar tags: \(calendarKeys)")
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CalendarTypeChanged"))) { notification in
                if let userInfo = notification.userInfo,
                   let calendarTypeRawValue = userInfo["calendarType"] as? String,
                   let calendarType = ODPTCalendarType(rawValue: calendarTypeRawValue) {
                    selectedCalendarType = calendarType
                    print("🔄 Calendar type changed from SettingsTimetableSheet: \(selectedCalendarType.displayName)")
                }
            }
            .sheet(isPresented: $showWeekdaySheet) {
                WeekdaySelectionSheet(
                    selectedCalendarType: $selectedCalendarType,
                    availableCalendarTypes: availableCalendarTypes
                )
                .onAppear {
                    print("📱 WeekdaySelectionSheet opened with availableCalendarTypes: \(availableCalendarTypes.map { $0.debugDisplayName })")
                    print("📱 WeekdaySelectionSheet availableCalendarTypes raw values: \(availableCalendarTypes.map { $0.rawValue })")
                }
            }
        }
    }
    
    // MARK: - Available Calendar Types Loading
    /// Load available calendar types from cache or use default
    private func loadAvailableCalendarTypes() -> [ODPTCalendarType] {
        // Always try to detect from actual data first to ensure we have the most up-to-date information
        let detectedTypes = detectAvailableCalendarTypesFromData()
        if !detectedTypes.isEmpty {
            print("📅 Detected calendar types from data: \(detectedTypes.map { $0.debugDisplayName })")
            return detectedTypes
        }
        
        // Try to get cached calendar types for the current line
        // Check multiple possible cache keys
        
        // First, try the route-specific cache key
        let routeCacheKey = "\(goorback)_calendarTypes"
        if let cachedTypes = UserDefaults.standard.stringArray(forKey: routeCacheKey),
           !cachedTypes.isEmpty {
            let cachedCalendarTypes = cachedTypes.compactMap { ODPTCalendarType(rawValue: $0) }
            if !cachedCalendarTypes.isEmpty {
                print("📅 Using cached calendar types for \(goorback): \(cachedCalendarTypes.map { $0.debugDisplayName })")
                return cachedCalendarTypes
            }
        }
        
        // Try to find any cached calendar types by searching all keys
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in allKeys {
            if key.contains("calendarTypes") {
                if let cachedTypes = UserDefaults.standard.stringArray(forKey: key),
                   !cachedTypes.isEmpty {
                    print("🔍 Found cached types: \(cachedTypes)")
                    let cachedCalendarTypes = cachedTypes.compactMap { ODPTCalendarType(rawValue: $0) }
                    if !cachedCalendarTypes.isEmpty {
                        print("📅 Using cached calendar types from key '\(key)': \(cachedCalendarTypes.map { $0.debugDisplayName })")
                        print("📅 Raw values: \(cachedCalendarTypes.map { $0.rawValue })")
                        return cachedCalendarTypes
                    } else {
                        print("❌ Failed to convert cached types to ODPTCalendarType: \(cachedTypes)")
                    }
                }
            }
        }
        
        // Final fallback to default calendar types
        print("📅 Using default calendar types for \(goorback)")
        return [.weekday, .saturdayHoliday]
    }
    
    // MARK: - Calendar Type Detection from Data
    /// Detect available calendar types by checking actual timetable data
    private func detectAvailableCalendarTypesFromData() -> [ODPTCalendarType] {
        var detectedTypes: Set<ODPTCalendarType> = []
        
        print("📱 Detecting calendar types from data for goorback=\(goorback), num=\(num)")
        
        // Check all possible calendar types
        for calendarType in ODPTCalendarType.allCases {
            if hasTimetableDataForType(calendarType) {
                detectedTypes.insert(calendarType)
            }
        }
        
        print("📱 Detected calendar types: \(detectedTypes.map { $0.debugDisplayName })")
        return Array(detectedTypes).sorted { $0.rawValue < $1.rawValue }
    }
    
    // MARK: - Timetable Data Existence Check
    /// Check if timetable data exists for the currently selected calendar type
    private func hasTimetableDataForSelectedType() -> Bool {
        return hasTimetableDataForType(selectedCalendarType)
    }
    
    /// Check if timetable data exists for the specified calendar type
    private func hasTimetableDataForType(_ calendarType: ODPTCalendarType) -> Bool {
        // Check all hours (4-25) to see if data exists
        for hour in 4...25 {
            let key = goorback.timetableKey(calendarType, num, hour)
            if UserDefaults.standard.string(forKey: key) != nil {
                print("📱 Found timetable data for \(calendarType.debugDisplayName) at hour \(hour) with key: \(key)")
                return true
            }
        }
        print("📱 No timetable data found for \(calendarType.debugDisplayName) with num=\(num)")
        return false
    }
    
    // MARK: - Valid Hour Range Calculation
    // Calculate the range of hours with data, including gaps
    private func validHourRange() -> [Int] {
        let allHours = Array(4...25)
        
        // Find hours with train times
        let hoursWithData = allHours.filter { hour in
            !goorback.loadTransportationTimes(selectedCalendarType, num, hour).isEmpty
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
            let transportationTimes = goorback.loadTransportationTimes(selectedCalendarType, num, hour)
            counts.append(transportationTimes.count)
        }
        return counts
    }
    
    // MARK: - Load Train Type List
    // Load unique train types list for the current line and direction
    private func loadTrainTypeList() -> [String] {
        let trainTypeListKey = goorback.trainTypeListKey(selectedCalendarType, num)

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
                                    .font(.system(size: screen.settingsSheetInputFontSize, weight: .bold))
                                    .foregroundColor(colorGroup.color)
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
// Custom sheet for calendar type selection with responsive sizing
struct WeekdaySelectionSheet: View {
    @Binding var selectedCalendarType: ODPTCalendarType
    let availableCalendarTypes: [ODPTCalendarType]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: screen.settingsSheetVerticalSpacing) {
                // Selection buttons
                ScrollView {
                    VStack(spacing: screen.settingsSheetVerticalSpacing) {
                        ForEach(availableCalendarTypes, id: \.rawValue) { calendarType in
                            Button(action: {
                                selectedCalendarType = calendarType
                                dismiss()
                                print("✅ Calendar type selected: \(calendarType.displayName)")
                                
                                // Notify other views about calendar type change
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("CalendarTypeChanged"),
                                    object: nil,
                                    userInfo: ["calendarType": calendarType.rawValue]
                                )
                            }) {
                                HStack {
                                    Image(systemName: selectedCalendarType == calendarType ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: screen.settingsSheetInputFontSize))
                                    Text(calendarType.displayName)
                                        .foregroundColor(Color.white)
                                        .font(.system(size: screen.settingsSheetInputFontSize, weight: .medium))
                                    Spacer()
                                }
                                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                                .padding(.vertical, screen.settingsSheetVerticalSpacing)
                                .background(selectedCalendarType == calendarType ? Color.accent : Color.gray)
                                .cornerRadius(screen.settingsSheetVerticalSpacing)
                            }
                        }
                    }
                    .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                }
                
                Spacer()
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white.opacity(0.8), for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Select Schedule Type".localized)
                        .font(.system(size: screen.settingsTitleFontSize, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CustomBackButton(
                        foregroundColor: .black,
                        action: { dismiss() }
                    )
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct TimetableContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableContentView("back1", 0)
    }
}

