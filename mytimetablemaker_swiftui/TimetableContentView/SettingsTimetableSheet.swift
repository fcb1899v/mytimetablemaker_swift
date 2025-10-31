//
//  SettingsTimetableSheet.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2025/09/17.
//

import SwiftUI

// MARK: - Timetable Edit Sheet
// Sheet for editing timetable times with add/delete/copy functionality
struct SettingsTimetableSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var departureTime: Int? = nil
    @State private var rideTime: Int = 0
    @State private var selectedTrainType: String?
    // Controls visibility of train type dropdown menu
    @State private var isTrainTypeDropdownOpen = false
    // Controls visibility of calendar type dropdown menu
    @State private var isCalendarTypeDropdownOpen = false
    // Controls visibility of copy time dropdown menu
    @State private var isCopyTimeDropdownOpen = false
    @State private var transportationTimes: [any TransportationTime] = []
    @State private var hour: Int
    // Selected calendar type for filtering timetable data
    @State private var selectedCalendarType: ODPTCalendarType
    // Available calendar types loaded from cache or detected from data
    @State private var availableOdptCalendar: [ODPTCalendarType] = [.weekday, .saturdayHoliday]
    
    private let goorback: String
    private let num: Int
    
    // MARK: - Initialization
    // Initialize with route identifier, calendar type, line number, and hour
    init(
        goorback: String,
        selectedCalendarType: ODPTCalendarType,
        num: Int,
        hour: Int
    ) {
        self.goorback = goorback
        self.num = num
        self._hour = State(initialValue: hour)
        self._selectedCalendarType = State(initialValue: selectedCalendarType)
        self._selectedTrainType = State(initialValue: nil)
        self._transportationTimes = State(initialValue: goorback.loadTransportationTimes(selectedCalendarType, num, hour))
        
        // Load saved ride time as default value (using route-level key without hour)
        let rideTimeKey = goorback.rideTimeKey(num)
        let savedRideTime = UserDefaults.standard.integer(forKey: rideTimeKey)
        print("🔍 SettingsTimetableSheet init: rideTimeKey='\(rideTimeKey)', savedRideTime=\(savedRideTime)")
        self._rideTime = State(initialValue: savedRideTime)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                VStack(spacing: screen.settingsSheetVerticalSpacing) {
                    calendarDropDownSection
                    hourControlSection
                    timetableDisplaySection
                    HStack {
                        departureTimeSelectSection
                        Spacer()
                        rideTimeSelectSection
                    }.padding(.top, screen.settingsSheetVerticalSpacing)
                    
                    if goorback.lineKind(num) == .railway {
                        trainTypeSelectSection
                    }
                    addDeleteButtonSection
                    copyTimeButtonSection
                    Spacer()
                }
                .frame(width: screen.timetableDisplayWidth)
                
                // Dropdown options overlay
                if isCalendarTypeDropdownOpen {
                    calendarTypeDropdownView
                }
                if isTrainTypeDropdownOpen {
                    trainTypeDropdownView
                }
                if isCopyTimeDropdownOpen {
                    copyTimeDropdownView
                }
            }
            .navigationBarColor(
                backgroundColor: UIColor(.white),
                titleColor: .black,
            )
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white.opacity(0.8), for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Timetable".localized)
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
        .presentationDetents([.height(screen.settingsTimetableSheetHeight)])
        .presentationDragIndicator(.hidden)
    }

    
    
    // MARK: - View Components
    // Calendar type dropdown section for selecting weekday/holiday/etc.
    @ViewBuilder
    private var calendarDropDownSection: some View {
        HStack {
            Spacer()            
            Button(action: {
                isCalendarTypeDropdownOpen.toggle()
            }) {
                HStack {
                    Text(selectedCalendarType.displayName)
                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
                        .foregroundColor(selectedCalendarType.calendarSubColor)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
                        .foregroundColor(selectedCalendarType.calendarSubColor)
                        .rotationEffect(.degrees(isCalendarTypeDropdownOpen ? 180 : 0))
                }
                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(screen.settingsSheetCornerRadius)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .onAppear {
            availableOdptCalendar = goorback.loadAvailableCalendarTypes(num: num)
        }
    }
    
    // Calendar type dropdown menu for selecting weekday/holiday/etc.
    private var calendarTypeDropdownView: some View {
        VStack(spacing: 0) {
            ForEach(availableOdptCalendar, id: \.self) { calendarType in
                Button(action: {
                    selectedCalendarType = calendarType
                    transportationTimes = goorback.loadTransportationTimes(calendarType, num, hour)
                    NotificationCenter.default.post(
                        name: NSNotification.Name("CalendarTypeChanged"),
                        object: nil,
                        userInfo: ["calendarType": calendarType.rawValue]
                    )
                    isCalendarTypeDropdownOpen = false
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
                
                if calendarType != availableOdptCalendar.last {
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
            y: screen.timetableCalendarMenuOffsetY,
        )
    }
    
    // Hour control section with decrease/increase buttons (4-24 range)
    @ViewBuilder
    private var hourControlSection: some View {
        HStack {
            // Decrease hour button
            Button(action: {
                if hour > 4 {
                    hour -= 1
                    transportationTimes = goorback.loadTransportationTimes(selectedCalendarType, num, hour)
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: screen.settingsSheetTitleFontSize, weight: .bold))
                    .foregroundColor(hour > 4 ? .primary : .gray)
            }
            .disabled(hour <= 4)
            
            Text("\(hour)\("Hour".localized)")
                .font(.system(size: screen.settingsSheetTitleFontSize, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .frame(width: screen.timetableEditButtonWidth)
            
            // Increase hour button
            Button(action: {
                if hour < 24 {
                    hour += 1
                    transportationTimes = goorback.loadTransportationTimes(selectedCalendarType, num, hour)
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: screen.settingsSheetTitleFontSize, weight: .bold))
                    .foregroundColor(hour < 24 ? .primary : .gray)
            }
            .disabled(hour >= 24)
        }
        .padding(.top, screen.settingsSheetVerticalSpacing)
    }
        
    // MARK: - Current Timetable Display
    // Display current timetable times in grid format (10 items per row)
    @ViewBuilder
    private var timetableDisplaySection: some View {
        if transportationTimes.count > 0 {
            let availableWidth = screen.timetableDisplayWidth - (screen.timetableMinuteSpacing * 2)
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
            .frame(width: screen.timetableDisplayWidth, height: screen.timetableDisplayHeight)
            .background(Color.primary)
            .padding(.horizontal, screen.timetableMinuteSpacing)
        } else {
            Color.primary
                .frame(width: screen.timetableDisplayWidth, height: screen.timetableDisplayHeight)
                .padding(.horizontal, screen.timetableHorizontalSpacing)
        }
    }
    
    // Train type selection section (only for railway lines)
    private var trainTypeSelectSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {

            Text("Select Type".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)
            
            // Custom dropdown for train type selection
            Button(action: {
                isTrainTypeDropdownOpen.toggle()
            }) {
                HStack {
                    // Display icon for selected train type
                    if (selectedTrainType != nil) {
                        Image(systemName: "train.side.front.car")
                            .frame(height: screen.settingsSheetIconSize)
                            .foregroundColor(Color.colorForTrainType(selectedTrainType))
                    }
                    Text(selectedTrainType?.localized ?? "-".localized)
                        .font(.system(size: screen.settingsSheetInputFontSize))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .scaledToFit()
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: screen.settingsSheetInputFontSize, weight: .medium))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isTrainTypeDropdownOpen ? 180 : 0))
                }
                .frame(height: screen.settingsSheetPickerDisplayHeight)
                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                .background(CustomBackground(backgroundColor: Color.primary))
                .overlay(CustomBorder(borderColor: Color(.separator)))
            }
            .buttonStyle(.plain)

            // Checkmark indicator
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(
                    (selectedTrainType != nil && !isTimeExistsForDeletion()) ? .accent:
                    (selectedTrainType != nil && isTimeExistsForDeletion()) ? .primary:
                    .red
                )
        }
    }
    
    // MARK: - Computed Properties
    // Train type dropdown menu for overlay selection
    private var trainTypeDropdownView: some View {
        VStack(spacing: 0) {
            ForEach(getAvailableTrainTypes(), id: \.self) { trainType in
                Button(action: {
                    selectedTrainType = trainType
                    isTrainTypeDropdownOpen = false
                }) {
                    HStack {
                        Image(systemName: "train.side.front.car")
                            .foregroundColor(Color.colorForTrainType(trainType))
                            .frame(height: screen.settingsSheetIconSize)
                        Text(trainType.localized)
                            .font(.system(size: screen.settingsSheetInputFontSize))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                    .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                    .background(Color.clear)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if trainType != getAvailableTrainTypes().last {
                    Divider()
                        .frame(height: 1)
                        .background(.white)
                }
            }
        }
        .frame(width: screen.timetableTypeMenuWidth)
        .background(CustomBackground(backgroundColor: Color.primary))
        .overlay(CustomBorder(borderColor: .white))
        .offset(
            x: screen.timetableTypeMenuOffsetX,
            y: screen.timetableTypeMenuOffsetY,
        )
    }
    
    // Departure time selection section with picker (0-59 minutes)
    private var departureTimeSelectSection: some View {
        VStack(alignment: .leading, spacing: screen.settingsSheetVerticalSpacing) {
            HStack {
                Text("Departure Time".localized)
                    .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                    .foregroundColor(.primary)
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(
                        departureTime == nil ? .gray: 
                        goorback.lineKind(num) != .railway && !isTimeExistsForDeletion() ? .accent: 
                        goorback.lineKind(num) != .railway && isTimeExistsForDeletion() ? .primary: 
                        selectedTrainType != nil && !isTimeExistsForDeletion() ? .accent: 
                        selectedTrainType != nil && isTimeExistsForDeletion() ? .primary: 
                        isTimeExistsForDeletion() ? .red:
                        .gray
                    )
            }

            // Departure time picker (0-59 minutes)
            ZStack {
                HStack {
                    Text(departureTime == nil ? "-": "\(String(departureTime!))\(" min".localized)")
                        .font(.system(size: screen.settingsSheetInputFontSize))
                        .foregroundColor(.black)
                    Spacer()
                }
                .frame(height: screen.settingsSheetPickerDisplayHeight)
                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                .background(CustomBackground())
                .overlay(CustomBorder())
                
                HStack {
                    Spacer()
                    Custom2DigitPicker(
                        value: Binding(
                            get: { departureTime ?? 0 },
                            set: {
                                departureTime = $0
                                isTrainTypeDropdownOpen = false
                            }
                        ),
                        isZeroToFive: true
                    )
                }
            }
            .padding(.top, screen.timetablePickerTopPadding)
            .padding(.bottom, screen.timetablePickerBottomPadding)
        }
        .frame(width: screen.timetablePickerWidth)
    }
    
    // Ride time selection section with picker (0-99 minutes)
    var rideTimeSelectSection: some View {
        VStack(alignment: .leading, spacing: screen.settingsSheetVerticalSpacing) {
            HStack {
                Text("Ride Time".localized)
                    .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                    .foregroundColor(.primary)
                                                    // Checkmark indicator
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(
                        (rideTime != 0 && !isTimeExistsForDeletion()) ? .accent:
                        (rideTime != 0 && isTimeExistsForDeletion()) ? .primary:
                        .red
                    )
            }
            
            // Ride time picker (0-99 minutes)
            ZStack {
                HStack {
                    Text(rideTime == 0 ? "-" : "\(rideTime)\(" min".localized)")
                        .font(.system(size: screen.settingsSheetInputFontSize))
                        .foregroundColor(.black)
                    Spacer()
                }
                .frame(height: screen.settingsSheetPickerDisplayHeight)
                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                .background(CustomBackground())
                .overlay(CustomBorder())
                
                HStack {
                    Spacer()
                    Custom2DigitPicker(
                        value: Binding(
                            get: { rideTime },
                            set: {
                                rideTime = $0
                                isTrainTypeDropdownOpen = false
                            }
                        ),
                        isZeroToFive: false
                    )
                }
            }
            .padding(.top, screen.timetablePickerTopPadding)
            .padding(.bottom, screen.timetablePickerBottomPadding)
        }
        .frame(width: screen.timetablePickerWidth)
    }
    
    // Add/Update and Delete buttons section for timetable editing
    @ViewBuilder
    private var addDeleteButtonSection: some View {
        HStack {
            CustomButton(
                title: isTimeExistsForDeletion() ? "Update".localized: "Add".localized,
                icon: isTimeExistsForDeletion() ? "arrow.clockwise.circle.fill" : "plus.circle.fill",
                backgroundColor: (
                    departureTime == nil ? Color.gray: 
                    goorback.lineKind(num) != .railway && !isTimeExistsForDeletion() ? Color.accent: 
                    goorback.lineKind(num) != .railway && isTimeExistsForDeletion() ? Color.primary: 
                    selectedTrainType != nil && !isTimeExistsForDeletion() ? Color.accent: 
                    selectedTrainType != nil && isTimeExistsForDeletion() ? Color.primary: 
                    Color.gray
                ),
                isEnabled: 
                    rideTime != 0 &&
                    departureTime != nil &&
                    (goorback.lineKind(num) == .railway && selectedTrainType != nil || goorback.lineKind(num) == .bus) &&
                    !isTimeExistsForDeletion(),
                action: {
                    addTime()
                }
            )
            .frame(width: screen.timetableEditButtonWidth)
            
            Spacer()
            
            CustomButton(
                title: "Delete".localized,
                icon: "minus.circle.fill",
                backgroundColor: (departureTime != nil && isTimeExistsForDeletion()) ? Color.red : Color.gray,
                isEnabled: departureTime != nil && isTimeExistsForDeletion(),
                action: {
                    deleteTime()
                }
            )
            .frame(width: screen.timetableEditButtonWidth)
        }
        .padding(.top, screen.settingsSheetVerticalSpacing)
    }
    
    // Copy time button section for copying timetable from other hours or routes
    @ViewBuilder
    private var copyTimeButtonSection: some View {
        Button(action: {
            isTrainTypeDropdownOpen = false
            isCalendarTypeDropdownOpen = false
            isCopyTimeDropdownOpen.toggle()
        }) {
            HStack(spacing: screen.settingsSheetIconSpacing) {
                Image(systemName: "doc.on.doc.fill")
                    .font(.system(size: screen.settingsSheetButtonFontSize, weight: .medium))
                    .foregroundColor(.white)
                Text("Copying your timetable".localized)
                    .font(.system(size: screen.settingsSheetButtonFontSize, weight: .bold))
                    .foregroundColor(.white)
                Image(systemName: "chevron.down")
                    .font(.system(size: screen.settingsSheetInputFontSize, weight: .medium))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isCopyTimeDropdownOpen ? 180 : 0))
            }
            .foregroundColor(.white)
            .frame(height: screen.settingsSheetButtonHeight)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: screen.settingsSheetButtonCornerRadius)
                    .fill(Color.accent)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, screen.settingsSheetVerticalSpacing)
    }

    // MARK: - Copy Time Sheet
    // Sheet for copying timetable times from other hours
    @ViewBuilder
    private var copyTimeDropdownView: some View {
        let startIndex = (hour == 4) ? 1 : 0
        let items = hour.choiceCopyTimeList
        
        VStack(spacing: 0) {
            ForEach(Array(startIndex..<items.count), id: \.self) { index in
                if !(hour == 25 && index == 1) {
                    Button(action: {
                        copyTime(from: index)
                        isCopyTimeDropdownOpen = false
                    }) {
                        HStack {
                            Text(items[index])
                                .font(.system(size: screen.settingsSheetInputFontSize))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                        .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                        .background(Color.clear)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    if index != items.count - 1 {
                        Divider()
                            .frame(height: 1)
                            .background(.white)
                    }
                }
            }
        }
        .frame(width: screen.timetableTypeMenuWidth)
        .background(CustomBackground(backgroundColor: Color.accent))
        .overlay(CustomBorder(borderColor: .white))
        .offset(
            x: screen.timetableTypeMenuOffsetX,
            y: screen.timetableCopyMenuOffsetY,
        )
    }
    
    // MARK: - Time Management
    // Add or update time entry in timetable with train type and ride time, then notify view update
    private func addTime() {
        guard let departureTime = departureTime else { return }
        
        // Add time, train type, and ride time as a triplet, then sort all together
        addTimeAndTrainTypePair(departureTime: departureTime, trainType: selectedTrainType, rideTime: rideTime)
        
        // Update trainTimes array with fresh data from UserDefaults
        transportationTimes = goorback.loadTransportationTimes(selectedCalendarType, num, hour)
        
        // Notify TimetableGridView to update
        NotificationCenter.default.post(name: NSNotification.Name("TimetableDataUpdated"), object: nil)
        
        self.departureTime = nil
        // Keep ride time and train type unchanged
    }
    
    // Delete time entry from timetable along with train type and ride time, then notify view update
    private func deleteTime() {
        guard let departureTime = departureTime else { return }
        
        deleteTimeAndTrainTypePair(departureTime: departureTime)
        
        // Update trainTimes array with fresh data from UserDefaults
        transportationTimes = goorback.loadTransportationTimes(selectedCalendarType, num, hour)
        
        // Notify TimetableGridView to update
        NotificationCenter.default.post(name: NSNotification.Name("TimetableDataUpdated"), object: nil)
        
        self.departureTime = nil
        // Keep ride time and train type unchanged
    }
    
    // MARK: - Time Validation
    /// Checks if the selected departure time exists in the timetable (for deletion)
    private func isTimeExistsForDeletion() -> Bool {
        guard let departureTime = departureTime else { return false }
        
        let timetableKey = goorback.timetableKey(selectedCalendarType, num, hour)
        guard let timetableString = UserDefaults.standard.string(forKey: timetableKey) else { return false }
        
        return timetableString.containsTimeInAnyFormat(departureTime)
    }
    
    // Get available train types for selection (default types or custom types from line)
    private func getAvailableTrainTypes() -> [String] {
        
        let defaultTypeList = [
            DisplayTrainType.defaultLocal.rawValue,
            DisplayTrainType.defaultExpress.rawValue,
            DisplayTrainType.defaultRapid.rawValue,
            DisplayTrainType.defaultSpecialRapid.rawValue,
            DisplayTrainType.defaultLimitedExpress.rawValue,
        ]
        
        // First, try to get existing train types from the current line
        let existingTrainTypes = goorback.loadTrainTypeList(selectedCalendarType, num)
        
        // If no existing train types are found, return default list
        if existingTrainTypes.isEmpty {
            return defaultTypeList
        }
        
        // Check if existingTrainTypes contains only default types
        let hasOnlyDefaultTypes = existingTrainTypes.allSatisfy { trainType in
            defaultTypeList.contains(trainType)
        }
        
        // If existingTrainTypes has only default types, return defaultTypeList
        // Otherwise, return existingTrainTypes (which includes custom types)
        return hasOnlyDefaultTypes ? defaultTypeList : existingTrainTypes
    }
    
    // Update train type list for the line by adding new type if not exists
    private func updateTrainTypeList(_ trainType: String) {
        let trainTypeListKey = goorback.trainTypeListKey(selectedCalendarType, num)
        let existingList = UserDefaults.standard.string(forKey: trainTypeListKey)?.timetableComponents ?? []
        
        // Add new train type if not already in the list
        if !existingList.contains(trainType) {
            var updatedList = existingList
            updatedList.append(trainType)
            UserDefaults.standard.set(updatedList.joined(separator: " "), forKey: trainTypeListKey)
        }
    }
    
    // MARK: - Time and Train Type Pair Management
    // Adds a new time, train type, and ride time triplet, then sorts by departure time
    // If the same time exists, it will be overwritten with new train type and ride time
    private func addTimeAndTrainTypePair(departureTime: Int, trainType: String?, rideTime: Int) {
        let timetableKey = goorback.timetableKey(selectedCalendarType, num, hour)
        let timetableTrainTypeKey = goorback.timetableTrainTypeKey(selectedCalendarType, num, hour)
        let timetableRideTimeKey = goorback.timetableRideTimeKey(selectedCalendarType, num, hour)
        let routeRideTimeKey = goorback.rideTimeKey(num)
        
        // Get current data
        let currentTimetableString = UserDefaults.standard.string(forKey: timetableKey) ?? ""
        let currentTrainTypeString = UserDefaults.standard.string(forKey: timetableTrainTypeKey) ?? ""
        let currentRideTimeString = UserDefaults.standard.string(forKey: timetableRideTimeKey) ?? ""
        let defaultRideTime = UserDefaults.standard.integer(forKey: routeRideTimeKey)
        
        // Convert to arrays
        var departureTimes = currentTimetableString.timetableComponents
        var trainTypes = currentTrainTypeString.timetableComponents
        var rideTimes = currentRideTimeString.timetableComponents
        
        let newTimeString = departureTime.addZeroTime
        let newTrainType = trainType ?? ""
        let newRideTimeString = rideTime.addZeroTime
        
        // Check if the same time already exists
        var existingIndex: Int?
        for (index, time) in departureTimes.enumerated() {
            if time == newTimeString || time == String(departureTime) {
                existingIndex = index
                break
            }
        }
        
        if let index = existingIndex {
            // Overwrite existing time with new train type and ride time
            trainTypes[index] = newTrainType
            rideTimes[index] = newRideTimeString
        } else {
            // Add new time, train type, and ride time
            departureTimes.append(newTimeString)
            trainTypes.append(newTrainType)
            rideTimes.append(newRideTimeString)
        }
        
        // Create triplets and sort by departure time
        var timeTypeRidePairs: [(time: String, type: String, rideTime: String)] = []
        for i in 0..<departureTimes.count {
            let type = i < trainTypes.count ? trainTypes[i] : "Local"
            let rideTime = i < rideTimes.count ? rideTimes[i] : defaultRideTime.addZeroTime
            timeTypeRidePairs.append((time: departureTimes[i], type: type, rideTime: rideTime))
        }
        
        // Sort triplets by time (convert to Int for proper sorting)
        timeTypeRidePairs.sort { (pair1, pair2) in
            pair1.time.isTimeLessThan(pair2.time)
        }
        
        // Extract sorted arrays
        let sortedTimes = timeTypeRidePairs.map { $0.time }
        let sortedTypes = timeTypeRidePairs.map { $0.type }
        let sortedRideTimes = timeTypeRidePairs.map { $0.rideTime }
        
        // Save to UserDefaults
        UserDefaults.standard.set(sortedTimes.joined(separator: " "), forKey: timetableKey)
        UserDefaults.standard.set(sortedTypes.joined(separator: " "), forKey: timetableTrainTypeKey)
        UserDefaults.standard.set(sortedRideTimes.joined(separator: " "), forKey: timetableRideTimeKey)
        
        // Update train type list if new type was added
        if let trainType = trainType {
            updateTrainTypeList(trainType)
        }
    }
    
    // Deletes a time entry along with its train type and ride time, then sorts remaining pairs
    private func deleteTimeAndTrainTypePair(departureTime: Int) {
        let timetableKey = goorback.timetableKey(selectedCalendarType, num, hour)
        let timetableTrainTypeKey = goorback.timetableTrainTypeKey(selectedCalendarType, num, hour)
        let timetableRideTimeKey = goorback.timetableRideTimeKey(selectedCalendarType, num, hour)
        let routeRideTimeKey = goorback.rideTimeKey(num)
        
        // Get current data
        let currentTimetableString = UserDefaults.standard.string(forKey: timetableKey) ?? ""
        let currentTrainTypeString = UserDefaults.standard.string(forKey: timetableTrainTypeKey) ?? ""
        let currentRideTimeString = UserDefaults.standard.string(forKey: timetableRideTimeKey) ?? ""
        let defaultRideTime = UserDefaults.standard.integer(forKey: routeRideTimeKey)
        
        // Convert to arrays
        var departureTimes = currentTimetableString.timetableComponents
        var trainTypes = currentTrainTypeString.timetableComponents
        var rideTimes = currentRideTimeString.timetableComponents
        
        // Find and remove the time (try both single and double digit formats)
        let singleDigitTime = String(departureTime)
        let doubleDigitTime = departureTime.addZeroTime
        
        var indexToRemove: Int?
        for (index, time) in departureTimes.enumerated() {
            if time == singleDigitTime || time == doubleDigitTime {
                indexToRemove = index
                break
            }
        }
        
        // Remove the time, corresponding train type, and ride time
        if let index = indexToRemove {
            departureTimes.remove(at: index)
            if index < trainTypes.count {
                trainTypes.remove(at: index)
            }
            if index < rideTimes.count {
                rideTimes.remove(at: index)
            }
        }
        
        // Create triplets and sort by departure time
        var timeTypeRidePairs: [(time: String, type: String, rideTime: String)] = []
        for i in 0..<departureTimes.count {
            let type = i < trainTypes.count ? trainTypes[i] : "defaultLocal"
            let rideTime = i < rideTimes.count ? rideTimes[i] : defaultRideTime.addZeroTime
            timeTypeRidePairs.append((time: departureTimes[i], type: type, rideTime: rideTime))
        }
        
        // Sort triplets by time (convert to Int for proper sorting)
        timeTypeRidePairs.sort { (pair1, pair2) in
            pair1.time.isTimeLessThan(pair2.time)
        }
        
        // Extract sorted arrays
        let sortedTimes = timeTypeRidePairs.map { $0.time }
        let sortedTypes = timeTypeRidePairs.map { $0.type }
        let sortedRideTimes = timeTypeRidePairs.map { $0.rideTime }
        
        // Save to UserDefaults
        UserDefaults.standard.set(sortedTimes.joined(separator: " "), forKey: timetableKey)
        UserDefaults.standard.set(sortedTypes.joined(separator: " "), forKey: timetableTrainTypeKey)
        UserDefaults.standard.set(sortedRideTimes.joined(separator: " "), forKey: timetableRideTimeKey)
    }
    
    // MARK: - Helper Methods
    // Copy timetable times from another hour or route based on selection index
    private func copyTime(from index: Int) {
        UserDefaults.standard.set(
            goorback.choiceCopyTime(selectedCalendarType, num, hour, index),
            forKey: goorback.timetableKey(selectedCalendarType, num, hour)
        )
        // Update trainTimes when time is copied
        transportationTimes = goorback.loadTransportationTimes(selectedCalendarType, num, hour)
        
        // Notify TimetableGridView to update
        NotificationCenter.default.post(name: NSNotification.Name("TimetableDataUpdated"), object: nil)
        dismiss()
    }
}

// MARK: - Preview Provider
struct SettingsTimetableSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTimetableSheet(
            goorback: "back1",
            selectedCalendarType: .weekday,
            num: 0,
            hour: 4
        )
    }
}
