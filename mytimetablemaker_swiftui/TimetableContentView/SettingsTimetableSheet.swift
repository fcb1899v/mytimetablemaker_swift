//
//  SettingsTimetableSheet.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/09/17.
//

import SwiftUI

// MARK: - Timetable Edit Sheet
// Sheet for editing timetable times with add/delete/copy functionality
struct SettingsTimetableSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var departureTime: Int? = nil
    @State private var rideTime: Int = 0
    @State private var isShowingCopySheet = false
    @State private var selectedTrainType: String?
    @State private var isTrainTypeDropdownOpen = false
    @State private var trainTimes: [TrainTime] = []
    @State private var hour: Int
    @State private var isWeekday: Bool
    
    private let goorback: String
    private let weekflag: Bool
    private let num: Int
    
    init(
        goorback: String,
        weekflag: Bool,
        num: Int,
        hour: Int
    ) {
        self.goorback = goorback
        self.weekflag = weekflag
        self.num = num
        self._hour = State(initialValue: hour)
        self._isWeekday = State(initialValue: weekflag)
        self._selectedTrainType = State(initialValue: nil)
        self._trainTimes = State(initialValue: goorback.loadTrainTimes(weekflag, num, hour))
        
        // Load saved ride time as default value (using route-level key without hour)
        let rideTimeKey = goorback.rideTimeKey(num)
        let savedRideTime = UserDefaults.standard.integer(forKey: rideTimeKey)
        print("🔍 SettingsTimetableSheet init: rideTimeKey='\(rideTimeKey)', savedRideTime=\(savedRideTime)")
        self._rideTime = State(initialValue: savedRideTime)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: screen.settingsSheetVerticalSpacing) {
                    weekdayToggleSection
                    hourControlSection
                    timetableDisplaySection
                    if goorback.lineKind(num) == .railway {
                        trainTypeSelectSection
                    }
                    HStack {
                        departureTimeSelectSection
                        Spacer()
                        rideTimeSelectSection
                    }
                    addDeleteButtonSection

                    CustomButton(
                        title: "Copying your timetable".localized,
                        icon: "doc.on.doc.fill",
                        backgroundColor: Color.accent,
                        action: {
                            isTrainTypeDropdownOpen = false
                            isShowingCopySheet = true
                        }
                    )
                    .padding(.top, screen.settingsSheetVerticalSpacing)

                    Spacer()
                }
                .frame(width: screen.timetableDisplayWidth)
                .background(Color.white)
                
                // Dropdown options overlay
                if isTrainTypeDropdownOpen {
                    trainTypeDropdownView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar)
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
                    // Back button
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrowshape.backward.fill")
                                .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                            Text("Back to homepage".localized)
                                .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                        }
                        .foregroundColor(.black)
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.7)])
        .sheet(isPresented: $isShowingCopySheet) {
            CopyTimeSheet(
                goorback: goorback,
                weekflag: weekflag,
                num: num,
                hour: hour,
                onTimeCopied: {
                    // Update trainTimes when time is copied
                    trainTimes = goorback.loadTrainTimes(weekflag, num, hour)
                    
                    // Notify TimetableGridView to update
                    NotificationCenter.default.post(name: NSNotification.Name("TimetableDataUpdated"), object: nil)
                }
            )
        }
    }

    
    
    // MARK: - View Components
    /// Weekday/Holiday toggle section
    @ViewBuilder
    private var weekdayToggleSection: some View {
        HStack {
            Spacer()
            CustomToggle(
                isLeftSelected: $isWeekday,
                leftText: "Weekday".localized,
                leftColor: .primary,
                rightText: "Sat/Sun/PH".localized,
                rightColor: .red,
                circleColor: .white,
                offColor: .secondary,
            )
            .onChange(of: isWeekday) { _ in
                trainTimes = goorback.loadTrainTimes(isWeekday, num, hour)
                // Notify TimetableContentView about weekday change
                NotificationCenter.default.post(
                    name: NSNotification.Name("WeekdayChanged"), 
                    object: nil, 
                    userInfo: ["isWeekday": isWeekday]
                )
                isTrainTypeDropdownOpen = false
            }
        }
    }
    
    /// Hour control section with decrease/increase buttons
    @ViewBuilder
    private var hourControlSection: some View {
        HStack {
            // Decrease hour button
            Button(action: {
                if hour > 4 {
                    hour -= 1
                    trainTimes = goorback.loadTrainTimes(isWeekday, num, hour)
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
                    trainTimes = goorback.loadTrainTimes(isWeekday, num, hour)
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
    @ViewBuilder
    private var timetableDisplaySection: some View {
        if trainTimes.count > 0 {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(screen.timetableNumberWidth), spacing: 0), count: screen.timetableNumberWidth > 0 ? max(1, Int(screen.timetableDisplayWidth / screen.timetableNumberWidth) - 1): 1), spacing: 0) {
                ForEach(trainTimes, id: \.self) { trainTime in
                    Text(trainTime.departureTime.trimmingLeadingZero)
                        .font(.system(size: screen.timetableMinuteFontSize, weight: .semibold))
                        .foregroundColor(trainTime.trainType != nil ? Color.colorForTrainType(trainTime.trainType) : .white)
                        .frame(width: screen.timetableNumberWidth, height: screen.timetableGridHeight)
                        .lineLimit(1)
                }
            }
            .frame(width: screen.timetableDisplayWidth, height: screen.timetableDisplayHeight)
            .background(Color.primary)
            .padding(.horizontal, screen.timetableHorizontalSpacing)
        } else {
            Color.primary
                .frame(width: screen.timetableDisplayWidth, height: screen.timetableDisplayHeight)
                .padding(.horizontal, screen.timetableHorizontalSpacing)
        }
    }
    
    // Train type selection (only for railway)
    private var trainTypeSelectSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {

            Text("Select Type".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)
                .frame(height: screen.timetableEditTitleHeight)
            
            // Custom dropdown for train type selection
            VStack(spacing: 0) {
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
                    .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                    .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                    .background(StyledBackground(backgroundColor: Color.primary))
                    .overlay(StyledBorder(borderColor: Color(.separator)))
                }
                 .buttonStyle(.plain)
             }

             // Checkmark indicator
             Image(systemName: "checkmark.circle.fill")
                 .foregroundColor(selectedTrainType == nil ? .red : .accent)
         }
    }
    
    // MARK: - Computed Properties
    // Train type dropdown view for overlay
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
                }
                .buttonStyle(.plain)
                
                if trainType != getAvailableTrainTypes().last {
                    Divider()
                        .frame(height: 1)
                        .background(.white)
                }
            }
        }
        .background(StyledBackground(backgroundColor: Color.primary))
        .overlay(StyledBorder(borderColor: .white))
        .frame(width: screen.timetableTypeMenuWidth)
        .offset(
            x: screen.timetableTypeMenuOffsetX,
            y: screen.timetableTypeMenuOffsetY,
        )
    }
            
    private var departureTimeSelectSection: some View {
        VStack(alignment: .leading, spacing: screen.settingsSheetVerticalSpacing) {
            HStack {
                Text("Departure Time".localized)
                    .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                    .foregroundColor(.primary)
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(departureTime == nil ? .gray : .accent)
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
                .background(StyledBackground())
                .overlay(StyledBorder())
                
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
    
    var rideTimeSelectSection: some View {
        VStack(alignment: .leading, spacing: screen.settingsSheetVerticalSpacing) {
            HStack {
                Text("Ride Time".localized)
                    .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                    .foregroundColor(.primary)
                                                    // Checkmark indicator
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(rideTime == 0 ? .red : .accent)
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
                .background(StyledBackground())
                .overlay(StyledBorder())
                
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
    
    // Add button
    var addDeleteButtonSection: some View {
        HStack {
            CustomButton(
                title: "Add".localized,
                icon: "plus.circle.fill",
                backgroundColor: Color.accent,
                isEnabled: !(rideTime == 0 || departureTime == nil || (goorback.lineKind(num) == .railway && selectedTrainType == nil)),
                action: {
                    addTime()
                }
            )
            .frame(width: screen.timetableEditButtonWidth)
            
            Spacer()
            
            CustomButton(
                title: "Delete".localized,
                icon: "minus.circle.fill",
                backgroundColor: Color.red,
                isEnabled: departureTime != nil,
                action: {
                    deleteTime()
                }
            )
            .frame(width: screen.timetableEditButtonWidth)
        }
        .padding(.top, screen.settingsSheetVerticalSpacing)
    }
    
    private func addTime() {
        guard let departureTime = departureTime else { return }
        
        // Update UserDefaults with new timetable string
        UserDefaults.standard.set(
            goorback.addTimeFromTimetable(String(format: "%02d", departureTime), weekflag, num, hour),
            forKey: goorback.timetableKey(weekflag, num, hour)
        )
        
        // Save train type if selected
        if let trainType = selectedTrainType {
            saveTrainType(trainType)
        }
        
        // Save ride time if entered
        if rideTime > 0 {
            saveRideTime()
        }
        
        // Update trainTimes array with fresh data from UserDefaults
        trainTimes = goorback.loadTrainTimes(weekflag, num, hour)
        
        // Notify TimetableGridView to update
        NotificationCenter.default.post(name: NSNotification.Name("TimetableDataUpdated"), object: nil)
        
        self.departureTime = nil
        // Keep ride time and train type unchanged
    }
    
    private func deleteTime() {
        guard let departureTime = departureTime else { return }
        
        // Update UserDefaults with new timetable string
        // Try both single digit and double digit formats to ensure deletion works
        let singleDigitTime = String(departureTime)
        let doubleDigitTime = String(format: "%02d", departureTime)
        
        var timetableString = goorback.timetableTime(weekflag, num, hour)
            .trimmingCharacters(in: .whitespaces)
            .timeSorting(charactersin: " ")
        
        // Remove both single and double digit formats if they exist
        timetableString = timetableString.filter { $0 != singleDigitTime && $0 != doubleDigitTime }
        
        UserDefaults.standard.set(
            timetableString.joined(separator: " "),
            forKey: goorback.timetableKey(weekflag, num, hour)
        )
        
        // Delete corresponding train type
        deleteTrainType()
        
        // Update trainTimes array with fresh data from UserDefaults
        trainTimes = goorback.loadTrainTimes(weekflag, num, hour)
        
        // Notify TimetableGridView to update
        NotificationCenter.default.post(name: NSNotification.Name("TimetableDataUpdated"), object: nil)
        
        self.departureTime = nil
        // Keep ride time and train type unchanged
    }
    
    private func saveRideTime() {
        let rideTimeKey = goorback.rideTimeKeyForHour(weekflag, num, hour)
        UserDefaults.standard.set(rideTime, forKey: rideTimeKey)
    }
    
    private func getAvailableTrainTypes() -> [String] {
        
        let defaultTypeList = [
            DisplayTrainType.defaultLocal.rawValue,
            DisplayTrainType.defaultExpress.rawValue,
            DisplayTrainType.defaultRapid.rawValue,
            DisplayTrainType.defaultSpecialRapid.rawValue,
            DisplayTrainType.defaultLimitedExpress.rawValue,
        ]
        
        // First, try to get existing train types from the current line
        let existingTrainTypes = goorback.loadTrainTypeList(weekflag, num)
        
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
    
    private func saveTrainType(_ trainType: String) {
        // Save train type for the current time
        let trainTypeKey = goorback.trainTypeKey(weekflag, num, hour)
        let timetableKey = goorback.timetableKey(weekflag, num, hour)
        
        // Get current timetable and train types
        let timetableString = UserDefaults.standard.string(forKey: timetableKey) ?? ""
        let departureTimes = timetableString.components(separatedBy: " ").compactMap { $0.isEmpty ? nil : $0 }
        let existingTypes = UserDefaults.standard.string(forKey: trainTypeKey)?.components(separatedBy: " ") ?? []
        
        // Find the index of the newly added time (should be the last one)
        let addedTimeIndex = departureTimes.count - 1
        
        // Ensure trainTypes array has the same length as departureTimes
        var updatedTypes = existingTypes
        while updatedTypes.count < departureTimes.count {
            updatedTypes.append("")
        }
        
        // Set the train type for the newly added time
        if addedTimeIndex >= 0 && addedTimeIndex < updatedTypes.count {
            updatedTypes[addedTimeIndex] = trainType
        }
        
        UserDefaults.standard.set(updatedTypes.joined(separator: " "), forKey: trainTypeKey)
        
        // Update train type list for the line
        updateTrainTypeList(trainType)
    }
    
    private func deleteTrainType() {
        // Delete train type for the current time
        let trainTypeKey = goorback.trainTypeKey(weekflag, num, hour)
        let timetableKey = goorback.timetableKey(weekflag, num, hour)
        
        // Get current timetable and train types
        let timetableString = UserDefaults.standard.string(forKey: timetableKey) ?? ""
        let departureTimes = timetableString.components(separatedBy: " ").compactMap { $0.isEmpty ? nil : $0 }
        let existingTypes = UserDefaults.standard.string(forKey: trainTypeKey)?.components(separatedBy: " ") ?? []
        
        // Find the index of the deleted time
        guard let departureTime = departureTime else { return }
        let deletedTimeIndex = departureTimes.firstIndex(of: String(format: "%02d", departureTime)) ?? -1
        
        if deletedTimeIndex >= 0 && deletedTimeIndex < existingTypes.count {
            var updatedTypes = existingTypes
            updatedTypes.remove(at: deletedTimeIndex)
            UserDefaults.standard.set(updatedTypes.joined(separator: " "), forKey: trainTypeKey)
        }
    }
    
    private func updateTrainTypeList(_ trainType: String) {
        let trainTypeListKey = goorback.trainTypeListKey(weekflag, num)
        let existingList = UserDefaults.standard.string(forKey: trainTypeListKey)?.components(separatedBy: " ") ?? []
        
        // Add new train type if not already in the list
        if !existingList.contains(trainType) {
            var updatedList = existingList
            updatedList.append(trainType)
            UserDefaults.standard.set(updatedList.joined(separator: " "), forKey: trainTypeListKey)
        }
    }
}

// MARK: - Copy Time Sheet
// Sheet for copying timetable times from other hours
struct CopyTimeSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let goorback: String
    private let weekflag: Bool
    private let num: Int
    private let hour: Int
    private let onTimeCopied: () -> Void
    
    init(
        goorback: String,
        weekflag: Bool,
        num: Int,
        hour: Int,
        onTimeCopied: @escaping () -> Void
    ) {
        self.goorback = goorback
        self.weekflag = weekflag
        self.num = num
        self.hour = hour
        self.onTimeCopied = onTimeCopied
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(((hour == 4) ? 1: 0)..<hour.choiceCopyTimeList(weekflag).count, id: \.self) { i in
                    if !(hour == 25 && i == 1) {
                        Button(action: {
                            copyTime(from: i)
                        }) {
                            Text(hour.choiceCopyTimeList(weekflag)[i])
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Copy Timetable".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("戻る".localized) {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private func copyTime(from index: Int) {
        UserDefaults.standard.set(
            goorback.choiceCopyTime(weekflag, num, hour, index),
            forKey: goorback.timetableKey(weekflag, num, hour)
        )
        onTimeCopied()
        dismiss()
    }
}

// MARK: - Preview Provider
struct SettingsTimetableSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTimetableSheet(
            goorback: "back1",
            weekflag: true,
            num: 0,
            hour: 4
        )
    }
}
