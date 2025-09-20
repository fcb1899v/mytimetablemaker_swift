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
    @State private var inputText = ""
    @State private var isShowingCopySheet = false
    @State private var selectedTrainType: String?
    @State private var trainTimes: [TrainTime] = []
    @State private var hour: Int
    
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
        self._selectedTrainType = State(initialValue: nil)
        self._trainTimes = State(initialValue: goorback.loadTrainTimes(weekflag, num, hour))
    }
    
    // MARK: - Helper Functions
    // Reload train times when hour changes
    private func reloadTrainTimes() {
        trainTimes = goorback.loadTrainTimes(weekflag, num, hour)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: screen.timetablePadding) {

                HStack {
                    // MARK: - Hour Control Buttons
                    // Decrease hour button
                    Button(action: {
                        if hour > 4 {
                            hour -= 1
                            reloadTrainTimes()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: screen.timetableTitleFontSize, weight: .bold))
                            .foregroundColor(hour > 4 ? .primary : .gray)
                    }
                    .disabled(hour <= 4)
                    
                    Text("\(hour)\("Hour".localized)")
                        .font(.system(size: screen.timetableTitleFontSize, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .frame(width: screen.timetableEditButtonWidth)
                    
                    // Increase hour button
                    Button(action: {
                        if hour < 24 {
                            hour += 1
                            reloadTrainTimes()
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: screen.timetableTitleFontSize, weight: .bold))
                            .foregroundColor(hour < 24 ? .primary : .gray)
                    }
                    .disabled(hour >= 24)
                }
                 
                // MARK: - Current Timetable Display
                HStack(spacing: screen.timetableSpacing) {
                    ForEach(trainTimes, id: \.self) { trainTime in
                        Text(trainTime.departureTime.trimmingLeadingZero)
                            .font(.system(size: screen.timetableTimeFontSize, weight: .semibold))
                            .foregroundColor(trainTime.trainType != nil ? Color.colorForTrainType(trainTime.trainType) : .white)
                    }
                }
                .frame(width: screen.timetableSettingWidth, height: screen.timetableGridHeight)
                .background(Color.primary)
                .padding(.horizontal, screen.timetableSpacing)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .scaledToFit()

                // Transparent spacer
                Spacer()
                    .frame(height: screen.timetableSpacing)

                // MARK: - Input and Action Grid
                HStack(spacing: screen.timetablePadding) {
                    // Left VStack: Train type selection and Time input field
                    VStack(spacing: screen.timetablePadding) {
                        // Train type selection dropdown (only for railway)
                        if goorback.lineKind(num) == .railway {
                            Menu {
                                ForEach(getAvailableTrainTypes(), id: \.self) { trainType in
                                    Button(trainType.localized) {
                                        selectedTrainType = trainType
                                    }
                                    .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .semibold))
                                    .foregroundColor(.primary)                            
                                }
                            } label: {
                                HStack {
                                    Text(selectedTrainType?.localized ?? "Select Type".localized)
                                        .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Image(systemName: "chevron.down")
                                    .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .semibold))
                                    .foregroundColor(.primary)                            
                                }
                            }
                            .frame(width: screen.timetableEditInputWidth)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .scaledToFit()
                        }
                        
                        // Time input field
                        TextField("Enter 0~59 [min]".localized, text: $inputText)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(.system(size: screen.settingsLineSheetInputFontSize))
                            .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
                            .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)
                            .background(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                            .overlay(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth))
                            .frame(width: screen.timetableEditInputWidth)
                    }
                     .frame(width: screen.timetableEditInputWidth)
                                        
                    // Right VStack: Add and Delete buttons
                    VStack(spacing: screen.timetablePadding) {
                        // Add button
                        Button(action: {
                            addTime()
                        }) {
                            HStack(spacing: screen.timetableSpacing) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .bold))
                                Text("Add".localized)
                                    .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(width: screen.timetableEditButtonWidth, height: screen.settingsLineSheetButtonHeight)
                            .background(
                                RoundedRectangle(cornerRadius: screen.settingsLineSheetButtonCornerRadius)
                                    .fill(inputText.isEmpty || inputText.intText(min: 0, max: 59) == -1 || (goorback.lineKind(num) == .railway && selectedTrainType == nil) ? Color.gray: Color.primary)
                            )
                        }
                        .disabled(inputText.isEmpty || inputText.intText(min: 0, max: 59) == -1 || (goorback.lineKind(num) == .railway && selectedTrainType == nil))
                        
                        // Delete button
                        Button(action: {
                            deleteTime()
                        }) {
                            HStack(spacing: screen.timetableSpacing) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .bold))
                                Text("Delete".localized)
                                    .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(width: screen.timetableEditButtonWidth, height: screen.settingsLineSheetButtonHeight)
                            .background(
                                RoundedRectangle(cornerRadius: screen.settingsLineSheetButtonCornerRadius)
                                    .fill(inputText.isEmpty || inputText.intText(min: 0, max: 59) == -1 ? Color.gray: Color.red)
                            )
                        }
                        .disabled(inputText.isEmpty || inputText.intText(min: 0, max: 59) == -1)
                    }
                    .frame(width: screen.timetableEditButtonWidth)
                }
                .padding(screen.timetablePadding)
                .background(
                    RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius)
                        .fill(Color.accent)
                )
                
                // Transparent spacer
                Spacer()
                    .frame(height: screen.timetableSpacing)
                                
                // Copy button
                HStack {
                    Spacer()
                        .frame(width: screen.timetablePadding * 2)
                    Button(action: {
                        isShowingCopySheet = true
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc.fill")
                                .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .bold))
                            Text("Copying your timetable".localized)
                                .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: screen.settingsLineSheetButtonHeight)
                        .background(
                    RoundedRectangle(cornerRadius: screen.settingsLineSheetButtonCornerRadius)
                        .fill(Color.accent)
                        )
                    }
                    Spacer()
                        .frame(width: screen.timetablePadding * 2)
                }
                
                Spacer()
            }
            .frame(width: screen.customWidth)
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Timetable".localized)
                        .font(.system(size: screen.timetableTitleFontSize, weight: .bold))
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
                                .font(.system(size: screen.timetableHeaderFontSize, weight: .bold))
                            Text("Back to homepage".localized)
                                .font(.system(size: screen.timetableButtonFontSize, weight: .bold))
                        }
                        .foregroundColor(.black)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .sheet(isPresented: $isShowingCopySheet) {
            CopyTimeSheet(
                goorback: goorback,
                weekflag: weekflag,
                num: num,
                hour: hour,
                onTimeCopied: {
                    // Update trainTimes when time is copied
                    trainTimes = goorback.loadTrainTimes(weekflag, num, hour)
                }
            )
        }
    }
        
    private func addTime() {
        if inputText.intText(min: 0, max: 59) > -1 {
            // Update UserDefaults with new timetable string
            UserDefaults.standard.set(
                goorback.addTimeFromTimetable(inputText, weekflag, num, hour),
                forKey: goorback.timetableKey(weekflag, num, hour)
            )
            
            // Save train type if selected
            if let trainType = selectedTrainType {
                saveTrainType(trainType)
            }
            
            // Update trainTimes array with fresh data from UserDefaults
            trainTimes = goorback.loadTrainTimes(weekflag, num, hour)
            
            inputText = ""
            selectedTrainType = nil
        }
    }
    
    private func deleteTime() {
        if inputText.intText(min: 0, max: 59) > -1 {
            // Update UserDefaults with new timetable string
            UserDefaults.standard.set(
                goorback.deleteTimeFromTimetable(inputText, weekflag, num, hour),
                forKey: goorback.timetableKey(weekflag, num, hour)
            )
            
            // Delete corresponding train type
            deleteTrainType()
            
            // Update trainTimes array with fresh data from UserDefaults
            trainTimes = goorback.loadTrainTimes(weekflag, num, hour)
            
            inputText = ""
        }
    }
    
    private func getAvailableTrainTypes() -> [String] {
        
        let defaultTypeList = [
            DisplayTrainType.defaultLocal.rawValue.localized,
            DisplayTrainType.defaultExpress.rawValue.localized,
            DisplayTrainType.defaultRapid.rawValue.localized,
            DisplayTrainType.defaultSpecialRapid.rawValue.localized,
            DisplayTrainType.defaultLimitedExpress.rawValue.localized,
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
        let deletedTimeIndex = departureTimes.firstIndex(of: inputText) ?? -1
        
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
