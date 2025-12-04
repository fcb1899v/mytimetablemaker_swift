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
    // Valid hours for current calendar type (cached to prevent sheet dismissal on first data add)
    @State private var validHours: [Int] = []
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
    
    // MARK: - Helper Functions
    /// Get display name (split by ":" and return first component for ODPT format)
    private func getDisplayName(from name: String) -> String {
        let components = name.components(separatedBy: ":")
        return components.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? name
    }
    
    /// Update valid hours for current calendar type
    /// This is called when calendar type changes or timetable data is updated
    private func updateValidHours() {
        validHours = goorback.validHourRange(calendarType: selectedCalendarType, num: num)
    }
    
    /// Rebuild train type list from existing timetable data if not exists
    /// This ensures the train type list is always up to date
    private func rebuildTrainTypeListIfNeeded() {
        // Check if train type list already exists
        let existingTrainTypes = goorback.loadTrainTypeList(selectedCalendarType, num)
        if !existingTrainTypes.isEmpty {
            return
        }
        
        let validHours = goorback.validHourRange(calendarType: selectedCalendarType, num: num)
        var allTransportationTimes: [any TransportationTime] = []
        
        // Collect all transportation times from all valid hours
        for hour in validHours {
            let times = goorback.loadTransportationTimes(selectedCalendarType, num, hour)
            allTransportationTimes.append(contentsOf: times)
        }
        
        // Save train type list if we have data
        if !allTransportationTimes.isEmpty {
            goorback.saveTrainTypeList(allTransportationTimes, selectedCalendarType, num)
        }
    }
    
    /// Sort calendar types according to enum definition order
    /// Order: weekday, holiday, saturdayHoliday, sunday, monday, tuesday, wednesday, thursday, friday, saturday, specific(String)
    private func sortCalendarTypesByEnumOrder(_ types: [ODPTCalendarType]) -> [ODPTCalendarType] {
        // Define enum order (excluding specific which has associated value)
        let enumOrder: [ODPTCalendarType] = [
            .weekday,
            .holiday,
            .saturdayHoliday,
            .sunday,
            .monday,
            .tuesday,
            .wednesday,
            .thursday,
            .friday,
            .saturday
        ]
        
        // Separate specific types and regular types
        let specificTypes = types.filter {
            if case .specific = $0 { return true }
            return false
        }
        let regularTypes = types.filter {
            if case .specific = $0 { return false }
            return true
        }
        
        // Sort regular types by enum order
        let sortedRegularTypes = regularTypes.sorted { type1, type2 in
            let index1 = enumOrder.firstIndex(of: type1) ?? Int.max
            let index2 = enumOrder.firstIndex(of: type2) ?? Int.max
            return index1 < index2
        }
        
        // Append specific types at the end (sorted alphabetically by rawValue)
        let sortedSpecificTypes = specificTypes.sorted { type1, type2 in
            let rawValue1 = type1.rawValue
            let rawValue2 = type2.rawValue
            return rawValue1 < rawValue2
        }
        
        return sortedRegularTypes + sortedSpecificTypes
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.primary
                VStack(alignment: .leading, spacing: screen.timetableVerticalSpacing) {

                    // MARK: - Header Section
                    // MARK: - Operator & Line Name Display
                    Text("\(goorback.operatorNameArray[num]) : \(goorback.lineNameArray[num])")
                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.leading, screen.timetableHorizontalSpacing)

                    Text("\(getDisplayName(from: goorback.stationArray[2 * num]))\(" > ".localized)\(getDisplayName(from: goorback.stationArray[2 * num + 1]))")
                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.leading, screen.timetableHorizontalSpacing)

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
                                ForEach(validHours, id: \.self) { hour in
                                    timetableGridView(hour: hour)
                                    Color.white.frame(width: screen.customWidth, height: 1)
                                }
                            }
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            scrollViewHeight = geometry.size.height
                                        }
                                        .onChange(of: geometry.size.height) { newHeight in
                                            scrollViewHeight = newHeight
                                        }
                                }
                            )
                        }
                        .frame(height: scrollViewHeight > 0 ? min(scrollViewHeight, screen.timetableMaxHeight) : screen.timetableMaxHeight)
                        
                        // Show color legend only when there are 2 or more train types
                        let trainTypes = goorback.loadTrainTypeList(selectedCalendarType, num)
                        if trainTypes.count > 1 {
                            colorLegendView(trainTypes: trainTypes)
                        }
 
                        // Check if timetable data exists
                        if validHours.isEmpty {
                            // Show register button when no timetable data exists
                            registerTimetableButton
                        }
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
                let loadedTypes = goorback.loadAvailableCalendarTypes(num: num)
                // Sort calendar types according to enum definition order
                availableCalendarTypes = sortCalendarTypesByEnumOrder(loadedTypes)
                
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
                
                // Initialize valid hours
                updateValidHours()
                
                // Rebuild train type list from existing data if not exists
                rebuildTrainTypeListIfNeeded()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CalendarTypeChanged"))) { notification in
                if let userInfo = notification.userInfo,
                   let calendarTypeRawValue = userInfo["calendarType"] as? String,
                   let calendarType = ODPTCalendarType(rawValue: calendarTypeRawValue) {
                    selectedCalendarType = calendarType
                    updateValidHours()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TimetableDataUpdated"))) { _ in
                // Update valid hours when timetable data changes
                // This ensures the view updates but doesn't close the sheet
                updateValidHours()
                // Rebuild train type list from existing data
                rebuildTrainTypeListIfNeeded()
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
    
    // MARK: - Register Timetable Button
    // Button to register timetable when no data exists
    @ViewBuilder
    private var registerTimetableButton: some View {
        // Initialize state for first hour (4:00) if not exists
        let hour = 18
        let binding = Binding(
            get: { showingTimetableSheet[hour] ?? false },
            set: { showingTimetableSheet[hour] = $0 }
        )
        
        HStack(alignment: .top) {
            Spacer()
            
            CustomButton(
                title: "Register Timetable".localized,
                icon: "plus.circle.fill",
                backgroundColor: .accent,
                textColor: .white,
                action: {
                    binding.wrappedValue = true
                }
            )

            Spacer()
        }
        .frame(width: screen.loginButtonWidth)
        .adaptiveSheet(isPresented: binding) {
            SettingsTimetableSheet(
                goorback: goorback,
                selectedCalendarType: selectedCalendarType,
                num: num,
                hour: hour
            )
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
            return group1.color.priorityValue < group2.color.priorityValue
        }
        
        GeometryReader { geometry in

            // Create rows by grouping colorGroups that fit in each row
            let rows = createRows(
                colorGroups: colorGroups,
                availableWidth: geometry.size.width - screen.timetableHorizontalSpacing * 2,
                itemSpacing: screen.timetableHorizontalSpacing
            )
        
            VStack(alignment: .center, spacing: screen.timetableVerticalSpacing) {
                ForEach(0..<rows.count, id: \.self) { rowIndex in
                    HStack(spacing: screen.timetableHorizontalSpacing) {
                        Spacer()
                        ForEach(rows[rowIndex], id: \.index) { groupInfo in
                            let colorGroup = groupInfo.group
                            
                            // Create combined display text
                            let displayTexts = colorGroup.trainTypes.map { trainType in
                                trainType.components(separatedBy: ".").last ?? trainType
                            }.map { $0.localized }
                            
                            let separator = Locale.current.language.languageCode?.identifier == "ja" ? "・" : ", "
                            let combinedText = displayTexts.joined(separator: separator)
                            
                            HStack(spacing: screen.timetableHorizontalSpacing) {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(colorGroup.color)
                                    .font(.system(size: screen.settingsSheetInputFontSize))
                                Text(combinedText)
                                    .font(.system(size: screen.settingsSheetInputFontSize, weight: .bold))
                                    .foregroundColor(colorGroup.color)
                                    .lineLimit(1)
                                    .fixedSize()
                            }
                        }
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, screen.timetableHorizontalSpacing)
            .padding(.top, screen.timetableVerticalSpacing)
        }
        .frame(height: estimateHeight(colorGroups: colorGroups, availableWidth: screen.customWidth - screen.timetableHorizontalSpacing * 2))
    }
    
    // Helper function to create rows of colorGroups that fit within available width
    private func createRows(
        colorGroups: [(color: Color, trainTypes: [String])],
        availableWidth: CGFloat,
        itemSpacing: CGFloat
    ) -> [[(index: Int, group: (color: Color, trainTypes: [String]))]] {
        var rows: [[(index: Int, group: (color: Color, trainTypes: [String]))]] = []
        var currentRow: [(index: Int, group: (color: Color, trainTypes: [String]))] = []
        var currentRowWidth: CGFloat = 0
        
        for (index, colorGroup) in colorGroups.enumerated() {
            // Create combined display text
            let displayTexts = colorGroup.trainTypes.map { trainType in
                trainType.components(separatedBy: ".").last ?? trainType
            }.map { $0.localized }
            
            let separator = Locale.current.language.languageCode?.identifier == "ja" ? "・" : ", "
            let combinedText = displayTexts.joined(separator: separator)
            
            // Estimate width: icon + spacing + text + padding
            let iconWidth: CGFloat = screen.settingsSheetInputFontSize
            let textWidth = estimateTextWidth(
                text: combinedText,
                fontSize: screen.settingsSheetInputFontSize,
                fontWeight: .bold
            )
            let horizontalPadding = screen.timetableHorizontalSpacing * 2
            let itemWidth = iconWidth + 4 + textWidth + horizontalPadding
            
            // Check if this item fits in current row
            let spacingNeeded = currentRow.isEmpty ? 0 : itemSpacing
            let totalWidth = currentRowWidth + spacingNeeded + itemWidth
            
            if totalWidth <= availableWidth || currentRow.isEmpty {
                // Add to current row
                currentRow.append((index: index, group: colorGroup))
                currentRowWidth = totalWidth
            } else {
                // Start new row
                rows.append(currentRow)
                currentRow = [(index: index, group: colorGroup)]
                currentRowWidth = itemWidth
            }
        }
        
        // Add last row if not empty
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    // Estimate text width
    private func estimateTextWidth(text: String, fontSize: CGFloat, fontWeight: Font.Weight) -> CGFloat {
        let uiFontWeight: UIFont.Weight
        switch fontWeight {
        case .bold:
            uiFontWeight = .bold
        case .semibold:
            uiFontWeight = .semibold
        case .medium:
            uiFontWeight = .medium
        case .regular:
            uiFontWeight = .regular
        default:
            uiFontWeight = .bold
        }
        let font = UIFont.systemFont(ofSize: fontSize, weight: uiFontWeight)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width
    }
    
    // Estimate total height needed
    private func estimateHeight(colorGroups: [(color: Color, trainTypes: [String])], availableWidth: CGFloat) -> CGFloat {
        let rows = createRows(
            colorGroups: colorGroups,
            availableWidth: availableWidth,
            itemSpacing: screen.timetableHorizontalSpacing
        )
        let rowHeight = screen.settingsSheetInputFontSize + screen.timetableVerticalSpacing
        let verticalSpacing = screen.timetableVerticalSpacing * CGFloat(max(0, rows.count - 1))
        return CGFloat(rows.count) * rowHeight + verticalSpacing + screen.timetableVerticalSpacing
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
        .adaptiveSheet(isPresented: binding) {
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

