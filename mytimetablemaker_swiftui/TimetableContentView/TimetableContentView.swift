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
    
    // Selected calendar type for filtering timetable data (weekday/holiday/etc.)
    @State private var selectedCalendarType = ODPTCalendarType.weekday
    // Available calendar types loaded from cache or detected from data
    @State private var availableCalendarTypes: [ODPTCalendarType] = []
    @State private var image = UIImage()
    @State private var isShowImagePicker = false
    @State private var scrollViewHeight: CGFloat = 0
    // Controls visibility of calendar type dropdown menu
    @State private var isCalendarTypeDropdownOpen = false
    // State for timetable grid views (hour-based sheet presentation)
    @State private var showingTimetableSheet: [Int: Bool] = [:]
    @Environment(\.dismiss) private var dismiss

    private let goorback: String
    private let num: Int

    // MARK: - Initialization
    // Initialize with route identifier and line number
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
                    let trainTypes = goorback.loadTrainTypeList(selectedCalendarType, num)
                    if trainTypes.count > 1 {
                        colorLegendView(trainTypes: trainTypes)
                    }
                                        
                    // MARK: - Timetable Grid
                    VStack(spacing: 0) {
                        Color.white.frame(width: screen.customWidth, height: 1)

                        HStack {
                            Color.white.frame(width: 1)
                            Spacer()
                            Button(action: {
                                isCalendarTypeDropdownOpen.toggle()
                            }) {
                                HStack {
                                    Text(selectedCalendarType.displayName)
                                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
                                        .foregroundColor(selectedCalendarType.calendarColor)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
                                        .foregroundColor(selectedCalendarType.calendarColor)
                                        .rotationEffect(.degrees(isCalendarTypeDropdownOpen ? 180 : 0))
                                }
                                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(screen.settingsSheetCornerRadius)
                            }
                            .buttonStyle(.plain)

                            Spacer()
                            Color.white.frame(width: 1)
                        }
                        .frame(width: screen.customWidth, height: screen.timetableGridHeight)
                        .background(Color.black.opacity(0.5))
    
                        Color.white.frame(width: screen.customWidth, height: 1)
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(goorback.validHourRange(calendarType: selectedCalendarType, num: num), id: \.self) { hour in
                                    timetableGridView(hour: hour)
                                    Color.white.frame(width: screen.customWidth, height: 1)
                                }
                            }
                        }
                        .frame(minHeight: 0.0, maxHeight: screen.timetableMaxHeight)
                    }
                }
                
                // Dropdown options overlay
                if isCalendarTypeDropdownOpen {
                    calendarTypeDropdownView
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
                availableCalendarTypes = goorback.loadAvailableCalendarTypes(num: num)
                
                // Set selectedCalendarType based on current date with fallback to available types
                selectedCalendarType = Date().odpTCalendarType(fallbackTo: availableCalendarTypes)
                
                // Check if data exists for the selected calendar type, if not, try other available types
                if !goorback.hasTimetableDataForType(selectedCalendarType, num: num) {
                    for calendarType in availableCalendarTypes {
                        if goorback.hasTimetableDataForType(calendarType, num: num) {
                            selectedCalendarType = calendarType
                            break
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CalendarTypeChanged"))) { notification in
                if let userInfo = notification.userInfo,
                   let calendarTypeRawValue = userInfo["calendarType"] as? String,
                   let calendarType = ODPTCalendarType(rawValue: calendarTypeRawValue) {
                    selectedCalendarType = calendarType
                }
            }
        }
    }
    
    // MARK: - Calendar Type Dropdown View
    // Dropdown menu for selecting calendar type (weekday/holiday/etc.)
    private var calendarTypeDropdownView: some View {
        VStack(spacing: 0) {
            ForEach(availableCalendarTypes, id: \.self) { calendarType in
                Button(action: {
                    selectedCalendarType = calendarType
                    isCalendarTypeDropdownOpen = false
                    NotificationCenter.default.post(
                        name: NSNotification.Name("CalendarTypeChanged"),
                        object: nil,
                        userInfo: ["calendarType": calendarType.rawValue]
                    )
                }) {
                    HStack {
                        Text(calendarType.displayName)
                            .font(.system(size: screen.settingsSheetInputFontSize))
                            .fontWeight(.semibold)
                            .foregroundColor(calendarType.calendarSubColor)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                    .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                    .background(Color.clear)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if calendarType != availableCalendarTypes.last {
                    Divider()
                        .frame(height: 1)
                        .background(.gray)
                }
            }
        }
        .frame(width: screen.timetableTypeMenuWidth)
        .background(CustomBackground(backgroundColor: Color.white))
        .overlay(CustomBorder(borderColor: .gray))
        .offset(
            x: screen.timetableTypeMenuOffsetX,
            y: screen.timetableContentViewMenuOffsetY,
        )
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
            return group1.color.priorityValue < group2.color.priorityValue
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
    
    // MARK: - Timetable Grid View
    // Individual grid cell for editing timetable times with add/delete/copy functionality
    @ViewBuilder
    private func timetableGridView(hour: Int) -> some View {
        // Initialize state for this hour if not exists
        let binding = Binding(
            get: { showingTimetableSheet[hour] ?? false },
            set: { showingTimetableSheet[hour] = $0 }
        )
        
        // Load transportation times for this hour
        let transportationTimes = goorback.loadTransportationTimes(selectedCalendarType, num, hour)
        
        // MARK: - Time Edit Button
        HStack(spacing: 0) {
            // MARK: - Hour Display
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Color.white.frame(width: 1)
                    Spacer()
                    Text(hour.addZeroTime)
                        .font(.system(size: screen.timetableHourFontSize, weight: .semibold))
                        .foregroundColor(.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .scaledToFit()
                    Spacer()
                    Color.white.frame(width: 1)
                }
                .frame(width: screen.timetableHourFrameWidth, height: screen.calculateContentHeight(transportationTimes.count))
                .background(Color.black.opacity(0.25))
            }
            
            Button(action: {
                binding.wrappedValue = true
            }) {
                timetableGridContent(transportationTimes: transportationTimes)
                    .contentShape(Rectangle())
            }
            .frame(width: screen.timetableMinuteFrameWidth)
            
            Color.white
                .frame(width: 1, height: screen.calculateContentHeight(transportationTimes.count))
        }
        .frame(width: screen.customWidth)
        .sheet(isPresented: binding) {
            SettingsTimetableSheet(
                goorback: goorback,
                selectedCalendarType: selectedCalendarType,
                num: num,
                hour: hour
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TimetableDataUpdated"))) { _ in
            // Trigger view update when timetable data changes
        }
    }
    
    // MARK: - Grid Content View
    // Train times display grid with proper wrapping
    @ViewBuilder
    private func timetableGridContent(transportationTimes: [any TransportationTime]) -> some View {
        // Calculate grid layout: 10 items per row with fixed width
        let availableWidth = screen.timetableMinuteFrameWidth - (screen.timetableMinuteSpacing * 2)
        let itemsPerRow = 10
        let itemWidth = availableWidth / CGFloat(itemsPerRow)
        let columns = Array(repeating: GridItem(.fixed(itemWidth), spacing: 0), count: itemsPerRow)
        
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(transportationTimes.indices, id: \.self) { index in
                HStack(spacing: 0) {
                    Text(transportationTimes[index].departureTime.minutesOnly)
                        .font(.system(size: screen.timetableMinuteFontSize, weight: .semibold))
                        .foregroundColor(Color.colorForTrainType((transportationTimes[index] as? TrainTime)?.trainType))
                    
                    Text("(\(String(transportationTimes[index].rideTime)))")
                        .font(.system(size: screen.timetableRideTimeFontSize, weight: .semibold))
                        .foregroundColor(Color.white)
                }
                .frame(width: itemWidth, height: screen.timetableNumberHeight)
                .minimumScaleFactor(0.8)
            }
        }
        .frame(width: screen.timetableMinuteFrameWidth, alignment: .leading)
        .padding(.horizontal, screen.timetableMinuteSpacing)
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct TimetableContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableContentView("back1", 0)
    }
}

