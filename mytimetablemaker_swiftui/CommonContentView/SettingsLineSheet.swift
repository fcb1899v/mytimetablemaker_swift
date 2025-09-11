//
//  SettingsLineSheet.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2025/08/12.
//  Sheet view for configuring railway lines and bus routes in settings
//  Provides functionality to search, select, and configure transportation lines
//  including predefined railway data from ODPT API and custom line configurations.
//  Features multi-language support, station search, and line color customization.
//

import SwiftUI
import Combine
import Foundation

// View for selecting railway lines and configuring line settings
struct SettingsLineSheet: View {
    
    // MARK: - State Management
    @StateObject private var vm: SettingsLineSheetViewModel
    @FocusState private var focused: Bool
    @State private var selected: TransportationLine?
    @State private var showColorSelect = false
    @State private var shouldClearText = false
    @State private var showTimetableSettings = false
    @State private var departureStationPosition: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Configuration
    // Integration with lineInfomation.swift
    private let goorback: String
    private let lineIndex: Int
    
    init(
        goorback: String,
        lineIndex: Int
    ) {
        self.goorback = goorback
        self.lineIndex = lineIndex
        self._vm = StateObject(wrappedValue: SettingsLineSheetViewModel(goorback: goorback, lineIndex: lineIndex))
    }
    
    // MARK: - Data Processing
    /// Remove duplicates based on operator and line name combination
    /// Ensures unique line representation in the UI
    private func removeDuplicates(from lines: [TransportationLine]) -> [TransportationLine] {
        var seen = Set<String>()
        var result: [TransportationLine] = []
        
        for line in lines {
            // Create unique key combining operator code and display name
            let key = "\(line.operatorCode ?? "")_\(vm.displayName(for: line))"
            if !seen.contains(key) {
                seen.insert(key)
                result.append(line)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                ScrollView {
                    VStack(alignment: .leading, spacing: screen.settingsLineSheetSpacing) {
                        routeHeaderMenu
                        lineHeaderMenu
                        lineNameSection
                        lineColorSection
                        stationHeaderText
                        departureStationInputSection
                        arrivalStationInputSection
                        timeHeaderText
                        rideTimeSection
                        if vm.selectedLineNumber < 3 {
                            transferSettingsSection
                        }
                        saveButtonSection
                        timetableSettingsButtonSection
                    }
                    .coordinateSpace(name: "scrollView")
                    .onPreferenceChange(DepartureStationPositionKey.self) { value in
                        departureStationPosition = value
                    }
                    .padding(.horizontal, screen.settingsLineSheetPadding)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .animation(.default, value: vm.showStationSelection)
                    .sheet(isPresented: $showTimetableSettings) {
                        NavigationStack {
                            TimetableContentView(goorback, lineIndex)
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }

                // MARK: - Departure Station Suggestions
                if vm.showDepartureSuggestions && !vm.departureSuggestions.isEmpty && vm.lineSelected {
                    departureStationSuggestionsView
                }
                
                // MARK: - Arrival Station Suggestions
                if vm.showArrivalSuggestions && !vm.arrivalSuggestions.isEmpty && vm.lineSelected {
                    arrivalStationSuggestionsView
                }
                
                // MARK: - Line Suggestions
                if vm.showLineSuggestions && !vm.lineSuggestions.isEmpty && !vm.isLineNumberChanging {
                    lineSuggestionsView
                }
                
                // MARK: - Color Selection Section
                if vm.showColorSelection || (!vm.lineInput.isEmpty && vm.selectedLineColor == nil && (selected?.lineColor == nil)) {
                    colorSelectionSection
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // Back button
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrowshape.backward.fill")
                            .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                            .foregroundColor(Color.black)
                        Text("Back to homepage".localized)
                            .font(.system(size: screen.settingsFontSize, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .onPreferenceChange(DepartureStationPositionKey.self) { value in
            departureStationPosition = value
        }
        .padding(.horizontal, screen.settingsLineSheetPadding)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .animation(.default, value: vm.showStationSelection)
        .sheet(isPresented: $showTimetableSettings) {
            NavigationStack {
                TimetableContentView(goorback, lineIndex)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
        
    // MARK: - Departure Station Suggestions
    private var departureStationSuggestionsView: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(vm.departureSuggestions, id: \.id) { station in
                    if station == vm.departureSuggestions.first {
                        Color.clear.frame(height: 0)
                    }
                    Button {
                        // Set line number changing flag to prevent unwanted suggestions
                        vm.isLineNumberChanging = true
                        
                        // Clear input if same station as arrival station is selected
                        let isSameAsArrival = vm.selectedArrivalStation?.getLocalizedName() == station.getLocalizedName()
                        vm.departureStationInput = isSameAsArrival ? "" : station.getLocalizedName()
                        vm.selectedDepartureStation = isSameAsArrival ? nil : station
                        // Completely disable departure suggestions after selection
                        vm.showDepartureSuggestions = false
                        vm.isDepartureFieldFocused = false
                        vm.departureSuggestions = []
                        // Set a flag to prevent re-display
                        vm.departureStationSelected = true
                        // No need to re-filter arrival station suggestions after departure station selection
                        
                        // Reset flag after a short delay to allow UI updates
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            vm.isLineNumberChanging = false
                        }
                    } label: {
                        HStack {
                            Text(station.getLocalizedName())
                                .font(.system(size: screen.settingsLineSheetInputFontSize))
                                .lineLimit(1)
                                .foregroundColor(.primary)
                                .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
                                .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if station != vm.departureSuggestions.last { Divider() }
                }
            }
        }
        .frame(maxHeight: min(CGFloat(vm.departureSuggestions.count) * screen.settingsLineSheetSuggestionItemHeight, screen.settingsLineSheetMaxSuggestionHeight))
        .background(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).fill(.background))
        .overlay(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth))
        .animation(.default, value: vm.departureSuggestions)
        .shadow(radius: screen.settingsLineSheetShadowRadius)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding()
        .offset(y: screen.settingsLineSheetDepartureOffset)
        .zIndex(100)
    }

    // MARK: - Arrival Station Suggestions
    private var arrivalStationSuggestionsView: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(vm.arrivalSuggestions, id: \.id) { station in
                    if station == vm.arrivalSuggestions.first {
                        Color.clear.frame(height: 0)
                    }
                    Button {
                        // Set line number changing flag to prevent unwanted suggestions
                        vm.isLineNumberChanging = true
                        
                        // Clear input if same station as departure station is selected
                        let isSameAsDeparture = vm.selectedDepartureStation?.getLocalizedName() == station.getLocalizedName()
                        vm.arrivalStationInput = isSameAsDeparture ? "" : station.getLocalizedName()
                        vm.selectedArrivalStation = isSameAsDeparture ? nil : station
                        // Completely disable arrival suggestions after selection
                        vm.showArrivalSuggestions = false
                        vm.isArrivalFieldFocused = false
                        vm.arrivalSuggestions = []
                        // Set a flag to prevent re-display
                        vm.arrivalStationSelected = true
                        // No need to re-filter departure station suggestions after arrival station selection
                        
                        // Reset flag after a short delay to allow UI updates
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            vm.isLineNumberChanging = false
                        }
                    } label: {
                        HStack {
                            Text(station.getLocalizedName())
                                .font(.system(size: screen.settingsLineSheetInputFontSize))
                                .lineLimit(1)
                                .foregroundColor(.primary)
                            .contentShape(Rectangle())
                                                     .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
                         .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)

                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if station != vm.arrivalSuggestions.last { Divider() }
                }
            }
        }
        .frame(maxHeight: min(CGFloat(vm.arrivalSuggestions.count) * screen.settingsLineSheetSuggestionItemHeight, screen.settingsLineSheetMaxSuggestionHeight))
        .background(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).fill(.background))
        .overlay(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth))
        .animation(.default, value: vm.arrivalSuggestions)
        .shadow(radius: screen.settingsLineSheetShadowRadius)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding()
        .offset(y: screen.settingsLineSheetArrivalOffset)
        .zIndex(100)
    }

    // MARK: - Line Suggestions
    private var lineSuggestionsView: some View {
        VStack(alignment: .leading) {
            ScrollView {
                let uniqueLines = removeDuplicates(from: vm.lineSuggestions)
                let enumeratedLines = Array(uniqueLines.enumerated())
                ForEach(enumeratedLines, id: \.element.id) { index, line in
                    if index == 0 {
                        Color.clear.frame(height: 0)
                    }
                    Button {
                        handleLineSelection(line)
                        handleLineStations(line)
                        handleLineColorSelection(line)
                        handleLineSelectionCompletion()

                    } label: {
                         HStack(alignment: .top, spacing: screen.settingsLineSheetHStackSpacing) {
                             Text(line.kind == .railway ? (line.lineCode ?? "Railway".localized) : "Bus".localized)
                                 .font(.system(size: screen.settingsLineSheetCaptionFontSize))
                                 .padding(.vertical, screen.settingsLineSheetTagPaddingVertical)
                                 .padding(.horizontal, screen.settingsLineSheetTagPaddingHorizontal)
                                 .background(Capsule().fill((line.lineColor?.safeColor ?? Color(0xAAAAAA)).opacity(0.5)))
                             
                             Text(vm.displayName(for: line))
                                 .font(.system(size: screen.settingsLineSheetInputFontSize))
                                 .lineLimit(1)
                             
                             if let operatorCode = line.operatorCode {
                                 let displayText = vm.getOperatorDisplayName(for: operatorCode, lineKind: line.kind)
                                 CustomTag(text: displayText)
                             }
                             
                             Spacer()
                         }
                         .contentShape(Rectangle())
                         .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
                         .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)
                     }
                    .buttonStyle(.plain)
                    if index < removeDuplicates(from: vm.lineSuggestions).count - 1 {
                        Color.clear.frame(height: 0)
                    }
                }
            }
            Spacer()
        }
        .frame(maxHeight: min(CGFloat(vm.lineSuggestions.count) * screen.settingsLineSheetSuggestionItemHeight, screen.settingsLineSheetMaxSuggestionHeight))
        .background(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).fill(.background))
        .overlay(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth))
        .animation(.default, value: vm.lineSuggestions)
        .shadow(radius: screen.settingsLineSheetShadowRadius)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding()
        .offset(y: screen.settingsLineSheetLineOffset)
        .zIndex(100)
        .onTapGesture {
            if vm.showDepartureSuggestions {
                vm.showDepartureSuggestions = false
                vm.isDepartureFieldFocused = false
            }
            if vm.showArrivalSuggestions {
                vm.showArrivalSuggestions = false
                vm.isArrivalFieldFocused = false
            }
        }
    }
    
    // MARK: - Color Selection Section
    private var colorSelectionSection: some View {
        VStack(alignment: .leading) {
            colorSelectionHeader
            colorSelectionGrid
        }
        .background(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
        .overlay(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth))
        .padding(.horizontal, screen.settingsLineSheetPadding)
        .offset(y: screen.settingsLineSheetColorOffset)
        .zIndex(100)
    }
    
    // MARK: - Color Selection Header
    private var colorSelectionHeader: some View {
        HStack {
            Text("Select Line Color".localized)
                .font(.system(size: screen.settingsLineSheetHeaderFontSize, weight: .semibold))
                .foregroundColor(.black)
            Spacer()
            // Cancel button (only shown during manual color selection)
            if vm.showColorSelection {
                Button("Cancel".localized) {
                    vm.showColorSelection = false
                }
                .tint(.black)
            }
        }
        .padding()
    }
    
    // MARK: - Color Selection Grid
    private var colorSelectionGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: screen.settingsLineSheetGridSpacing) {
            ForEach(CustomColor.allCases, id: \.self) { color in
                colorSelectionButton(for: color)
            }
        }
        .padding(.all, screen.settingsLineSheetGridSpacing)
    }
    
    // MARK: - Color Selection Button
    /// Button for selecting a specific line color
    private func colorSelectionButton(for color: CustomColor) -> some View {
        Button(action: {
            // Set selected color and hide color selection UI
            vm.setLineColor(color.RGB)
            vm.showColorSelection = false
        }) {
            VStack {
                // Color circle with border
                Circle()
                    .fill(color.RGB.safeColor)
                    .frame(width: screen.settingsLineSheetColorCircleSize, height: screen.settingsLineSheetColorCircleSize)
                    .overlay(Circle().stroke(Color.secondary, lineWidth: screen.settingsLineSheetStrokeLineWidth))
                
                // Color name label (localized)
                Text(color.rawValue.localized)
                    .font(.system(size: screen.settingsLineSheetCaptionFontSize))
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Save Button Section
    /// Save button for storing line configuration data
    private var saveButtonSection: some View {
        actionButton(
            title: "Save".localized,
            icon: "square.and.arrow.down.on.square.fill",
            color: vm.isAllNotEmpty ? .accentColor: .gray,
        ) {
            vm.handleLineSave(dismiss: dismiss)
        }
        .disabled(!vm.isCustomLineStationInputComplete())
        .padding(.top, screen.settingsLineSheetPadding)
    }
    
    // MARK: - Timetable Settings Button Section
    /// Button to open timetable configuration screen
    private var timetableSettingsButtonSection: some View {
        actionButton(
            title: vm.isAllSelected ? "Auto Generate Timetable".localized: "Timetable Settings".localized,
            icon: vm.isAllSelected ? "clock.badge.checkmark.fill": "clock.fill",
            color: vm.isAllSelected ? .accentColor: .primaryColor,
        ) {
            if vm.isAllSelected {
                Task {
                    await vm.getTargetTimetableData()
                }
            }
            showTimetableSettings = true
        }.padding(.top, screen.settingsLineSheetPadding)
    }
    
    // MARK: - Action Button Helper
    /// Reusable button component with consistent styling
    @ViewBuilder
    private func actionButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .bold))
                Text(title)
                    .font(.system(size: screen.settingsLineSheetButtonFontSize, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: screen.settingsLineSheetButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: screen.settingsLineSheetButtonCornerRadius)
                    .fill(color)
            )
        }
    }
    

    // MARK: - Header View
    /// Main header view with direction selection dropdown and cancel button
    private var routeHeaderMenu: some View {
        HStack {
            
            // Direction selection dropdown
            Menu {
                ForEach(vm.goorbackOptions, id: \.self) { option in
                    Button(vm.goorbackDisplayNames[option] ?? option) {
                        vm.selectGoorback(option)
                    }
                }
            } label: {
                HStack {
                    Text(vm.goorbackDisplayNames[vm.selectedGoorback] ?? vm.selectedGoorback)
                        .font(.system(size: screen.settingsLineSheetTitleFontSize, weight: .bold))
                        .foregroundColor(.black)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: screen.settingsLineSheetTitleFontSize, weight: .medium))
                        .foregroundColor(.black)
                    Spacer()
                }
            }
            
            Spacer()
            
            // MARK: - Data Update Button
            Button(action: {
                Task { await vm.performDataUpdate() }
            }) {
                HStack(spacing: screen.settingsLineSheetIconSpacing) {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
                        .font(.system(size: screen.settingsLineSheetButtonFontSize))
                        .foregroundColor(.white)
                    Text("Update Line Data".localized)
                        .font(.system(size: screen.settingsLineSheetButtonFontSize))
                }
            }
            .font(.system(size: screen.settingsLineSheetButtonFontSize))
            .buttonStyle(.borderedProminent)
            .tint(vm.lastUpdatedDisplay != nil ? .accentColor: .secondary)
        }
    }
    
    // MARK: - Header Implementations
    /// Line header with line number selection menu
    private var lineHeaderMenu: some View {
        HStack {

            Menu {
                ForEach(vm.availableLineNumbers, id: \.self) { lineNumber in
                    Button("\("Line".localized)\(lineNumber)") {
                        vm.selectLineNumber(lineNumber)
                    }
                }
            } label: {
                HStack {
                    Text("\("Line".localized)\(vm.selectedLineNumber) \("Input".localized)")
                        .font(.system(size: screen.settingsLineSheetTitleFontSize, weight: .bold))
                        .foregroundColor(Color.black)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: screen.settingsLineSheetHeaderFontSize, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            
            Spacer()


            // MARK: - Transportation Kind Toggle
            // Custom toggle for switching between railway and bus transportation types
            CustomToggle(
                isLeftSelected: Binding(
                    get: { vm.selectedTransportationKind == .railway },
                    set: { isRailway in
                        vm.switchTransportationKind(isRailway)
                    }
                ),
                leftText: "Railway".localized,
                leftColor: .primaryColor,
                rightText: "Bus".localized,
                rightColor: .primaryColor,
                circleColor: .white
            )
        }
        .padding(.top, screen.settingsLineSheetPadding)
    }
    
    /// Station header with dynamic station information
    private var stationHeaderText: some View {
        let headerText = vm.selectedTransportationKind == .bus ? "Bus Stop Input".localized : "Station Input".localized
        
        let stationInfo: String
        if vm.hasSelectedLine && vm.hasStations {
            let firstStation = vm.lineStations.first?.getLocalizedName() ?? ""
            let lastStation = vm.lineStations.last?.getLocalizedName() ?? ""
            stationInfo = ": ".localized + firstStation + " to ".localized + lastStation
        } else {
            stationInfo = ""
        }
        
        let finalText = headerText + stationInfo
        
        return Text(finalText)
            .font(.system(size: screen.settingsLineSheetHeaderFontSize, weight: .bold))
            .foregroundColor(Color.black)
            .padding(.top, screen.settingsLineSheetPadding)
    }
    
    /// Time header with simple text
    private var timeHeaderText: some View {
        Text("Time Settings".localized)
            .font(.system(size: screen.settingsLineSheetHeaderFontSize, weight: .bold))
            .foregroundColor(Color.black)
            .padding(.top, screen.settingsLineSheetPadding)
    }
    
    // MARK: - Line Name Section
    private var lineNameSection: some View {
        VStack(alignment: .leading, spacing: screen.settingsLineSheetSpacing) {
            HStack {
                Text("Line Name".localized)
                    .font(.system(size: screen.settingsLineSheetHeadlineFontSize, weight: .semibold))
                    .foregroundColor(.primaryColor)

                TextField("Enter line name or bus route name".localized, text: $vm.lineInput)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(size: screen.settingsLineSheetInputFontSize))
                    .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
                    .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)
                    .background(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth))
                    .focused($focused)
                    .onSubmit {
                        // Handle enter key press
                        Task { await vm.filter(vm.lineInput) }
                    }
                    .onTapGesture {
                        // Don't show suggestions if line number is being changed
                        if vm.isLineNumberChanging {
                            return
                        }
                        
                        // Set focus and show suggestions when tapped
                        focused = true
                        vm.showDepartureSuggestions = false
                        vm.showLineSuggestions = true
                        vm.lineSelected = false
                        // Trigger filtering if there's already input
                        if !vm.lineInput.isEmpty {
                            Task { await vm.filter(vm.lineInput) }
                        }
                    }
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(vm.lineInput.isEmpty ? .gray : .accentColor)
            }
            .onChange(of: vm.lineInput) { newValue in
                handleLineInputChange(newValue)
            }
        }
    }
    
    // MARK: - Line Color Section
    /// Section for displaying and selecting line colors
    private var lineColorSection: some View {
        HStack {
            Text("Line Color".localized)
                .font(.system(size: screen.settingsLineSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primaryColor)

            // Display selected color as a circle
            Circle()
                .fill(vm.selectedLineColor?.safeColor ?? selected?.lineColor?.safeColor ?? Color.primaryColor)
                .frame(width: screen.settingsLineSheetColorCircleSmallSize, height: screen.settingsLineSheetColorCircleSmallSize)
                .overlay(Circle().stroke(Color.primaryColor, lineWidth: screen.settingsLineSheetStrokeLineWidth))
                .padding(.horizontal, screen.settingsLineSheetColorPaddingHorizontal)
                .padding(.vertical, screen.settingsLineSheetColorPaddingVertical)
                .background(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                .overlay(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth))

            // Color selection button
            Button(action: {
                vm.showColorSelection = true
            }) {
                HStack(spacing: screen.settingsLineSheetIconSpacing) {
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: screen.settingsLineSheetButtonFontSize))
                        .foregroundColor(.white)
                    Text("Select".localized)
                        .font(.system(size: screen.settingsLineSheetButtonFontSize))
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.primaryColor)
            
            Spacer()
            
            // MARK: - Clear Button
            Button(action: {
                // Clear line name
                vm.lineInput = ""
                selected = nil
                
                // Reset station selection
                vm.resetStationSelection()
                
                // Clear departure and arrival station input fields
                vm.departureStationInput = ""
                vm.arrivalStationInput = ""
                
                // Reset ride time to 5 minutes
                vm.selectedRideTime = 5
                
                // Reset line color to accent (not saved to UserDefaults)
                vm.selectedLineColor = accentColorString
                
                // Reset transfer settings to none
                vm.selectedTransportation = "none"
                vm.selectedTransferTime = 5
                
                // Hide color selection UI
                vm.showColorSelection = false
            }) {
                HStack(spacing: screen.settingsLineSheetIconSpacing) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: screen.settingsLineSheetButtonFontSize))
                        .foregroundColor(.white)
                    Text("Clear".localized)
                        .font(.system(size: screen.settingsLineSheetButtonFontSize))
                        .buttonStyle(.borderedProminent)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
    }
    
    // MARK: - Ride Time Section
    /// Section for configuring travel time between stations
    private var rideTimeSection: some View {
        HStack(alignment: .center) {
            Text("Ride Time".localized)
                .font(.system(size: screen.settingsLineSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primaryColor)
            
            HStack {
                Text("\(vm.selectedRideTime)\(" min".localized)")
                    .font(.system(size: screen.settingsLineSheetInputFontSize))
                    .foregroundColor(.black)
                
                Menu {
                    ForEach(0...99, id: \.self) { minute in
                        Button("\(minute)" + " min".localized) {
                            vm.selectedRideTime = minute
                        }
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: screen.settingsLineSheetInputFontSize, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
            .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)
            .background(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
            .overlay(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth))
        }
    }
    
    // MARK: - Transfer Settings Section
    private var transferSettingsSection: some View {
        VStack(alignment: .leading, spacing: screen.settingsLineSheetSpacing) {
            
            // MARK: - Transportation Settings
            HStack {
                Text("Next Transfer".localized)
                    .font(.system(size: screen.settingsLineSheetHeadlineFontSize, weight: .semibold))
                    .foregroundColor(Color.primaryColor)
                
                HStack {
                    // Display icon for selected transportation method
                    Image(systemName: getTransportationType(label: vm.selectedTransportation).iconName)
                        .frame(height: screen.settingsLineSheetIconSize)
                        .foregroundColor(.black)

                    Text(getTransportationType(label: vm.selectedTransportation).displayName)
                        .font(.system(size: screen.settingsLineSheetInputFontSize))
                        .foregroundColor(.black)
                    
                    Menu {
                        ForEach(TransportationType.allCases.reversed(), id: \.self) { type in
                            Button(action: {
                                vm.selectedTransportation = type.rawValue
                            }) {
                                HStack {
                                    Image(systemName: type.iconName)
                                        .foregroundColor(.black)
                                        .frame(height: screen.settingsLineSheetIconSize)
                                    Text(type.displayName)
                                        .font(.system(size: screen.settingsLineSheetInputFontSize))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: screen.settingsLineSheetInputFontSize, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)
                .background(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                .overlay(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth))

                Spacer()
            }

            // MARK: - Transfer Time Settings
            if vm.selectedTransportation != "none" {
                HStack {
                    Text("Transfer Time".localized)
                        .font(.system(size: screen.settingsLineSheetHeadlineFontSize, weight: .semibold))
                        .foregroundColor(Color.primaryColor)
                    
                    HStack {
                        Text("\(vm.selectedTransferTime)" + " min".localized)
                            .font(.system(size: screen.settingsLineSheetInputFontSize))
                            .foregroundColor(.black)
                        
                        Menu {
                            ForEach(0...99, id: \.self) { minute in
                                Button("\(minute)" + " min".localized) {
                                    vm.selectedTransferTime = minute
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: screen.settingsLineSheetInputFontSize, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
                    .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)
                    .background(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth))
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Departure Station Input Section
    /// Section for inputting departure station information
    private var departureStationInputSection: some View {
        HStack {
            Text(vm.selectedTransportationKind == .bus ? "Departure Stop".localized : "Departure Station".localized)
                .font(.system(size: screen.settingsLineSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primaryColor)
            
            TextField(vm.selectedTransportationKind == .bus ? "Enter departure stop".localized : "Enter departure station".localized, text: $vm.departureStationInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: screen.settingsLineSheetInputFontSize))
                .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)
                .background(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                .overlay(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth))
                .onChange(of: vm.departureStationInput) { newValue in
                    handleDepartureStationInputChange(newValue)
                }
                .onChange(of: vm.selectedDepartureStation) { _ in
                    // Re-filter arrival station suggestions after departure station selection
                    if !vm.arrivalStationInput.isEmpty {
                        vm.filterArrivalStations(vm.arrivalStationInput)
                    }
                }
                .onTapGesture {
                    // Show suggestions on tap and reset selection flag
                    vm.isDepartureFieldFocused = true
                    vm.departureStationSelected = false
                    if !vm.departureStationInput.isEmpty {
                        vm.filterDepartureStations(vm.departureStationInput)
                    }
                }
                .onSubmit {
                    // Hide suggestions on input completion
                    vm.showDepartureSuggestions = false
                    vm.isDepartureFieldFocused = false
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: DepartureStationPositionKey.self, value: geometry.frame(in: .named("scrollView")).minY)
                    }
                )
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.departureStationInput.isEmpty ? .gray : .accentColor)
        }
    }
    
    // MARK: - Arrival Station Input Section
    /// Section for inputting arrival station information
    private var arrivalStationInputSection: some View {
        HStack {
            Text(vm.selectedTransportationKind == .bus ? "Arrival Stop".localized : "Arrival Station".localized)
                .font(.system(size: screen.settingsLineSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primaryColor)

            TextField(vm.selectedTransportationKind == .bus ? "Enter arrival stop".localized : "Enter arrival station".localized, text: $vm.arrivalStationInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: screen.settingsLineSheetInputFontSize))
                .padding(.vertical, screen.settingsLineSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsLineSheetInputPaddingHorizontal)
                .background(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                .overlay(RoundedRectangle(cornerRadius: screen.settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: screen.settingsLineSheetStrokeLineWidth))
                .onChange(of: vm.arrivalStationInput) { newValue in
                    handleArrivalStationInputChange(newValue)
                }
                .onChange(of: vm.selectedArrivalStation) { _ in
                    // Re-filter departure station suggestions after arrival station selection
                    if !vm.departureStationInput.isEmpty {
                        vm.filterDepartureStations(vm.departureStationInput)
                    }
                }
                .onTapGesture {
                    // Show suggestions on tap and reset selection flag
                    vm.isArrivalFieldFocused = true
                    vm.arrivalStationSelected = false
                    if !vm.arrivalStationInput.isEmpty {
                        vm.filterArrivalStations(vm.arrivalStationInput)
                    }
                }
                .onSubmit {
                    // Hide suggestions on input completion
                    vm.showArrivalSuggestions = false
                    vm.isArrivalFieldFocused = false
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ArrivalStationPositionKey.self, value: geometry.frame(in: .named("scrollView")).minY)
                    }
                )
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.arrivalStationInput.isEmpty ? .gray : .accentColor)
        }
    }
    
    
    // MARK: - Departure Station Input Change Handler
    /// Handles changes in departure station input field
    private func handleDepartureStationInputChange(_ newValue: String) {
        // Don't show suggestions if line number is being changed
        if vm.isLineNumberChanging {
            return
        }
        
        // Set focus state and reset selection flag when input changes
        vm.isDepartureFieldFocused = true
        vm.departureStationSelected = false
        // Clear input if same station as arrival station is entered
        let isSameAsArrival = vm.selectedArrivalStation?.getLocalizedName() == newValue
        if isSameAsArrival {
            vm.departureStationInput = ""
            vm.selectedDepartureStation = nil
        } else {
            // Filter suggestions
            vm.filterDepartureStations(newValue)
        }
    }
    
    // MARK: - Arrival Station Input Change Handler
    /// Handles changes in arrival station input field
    private func handleArrivalStationInputChange(_ newValue: String) {
        // Don't show suggestions if line number is being changed
        if vm.isLineNumberChanging {
            return
        }
        
        // Set focus state and reset selection flag when input changes
        vm.isArrivalFieldFocused = true
        vm.arrivalStationSelected = false
        // Clear input message on input
        let isSameAsDeparture = vm.selectedDepartureStation?.getLocalizedName() == newValue
        if isSameAsDeparture {
            vm.arrivalStationInput = ""
            vm.selectedArrivalStation = nil
        } else {
            // Filter suggestions
            vm.filterArrivalStations(newValue)
        }
    }
    
    // MARK: - LineInput Change Handler
    /// Handles changes in line name lineInput field
    private func handleLineInputChange(_ newValue: String) {
        // Ensure focus is maintained when typing
        if !newValue.isEmpty {
            focused = true
        }
        
        // Don't reset station selection if line number is being changed
        if vm.isLineNumberChanging {
            return
        }
        
        // Trigger filtering when lineInput changes
        Task { await vm.filter(newValue) }
        
        // Reset station selection when lineInput changes
        let currentLineName = vm.selectedLine?.name ?? ""
        let currentDisplayName: String
        if let selectedLine = vm.selectedLine {
            currentDisplayName = vm.displayName(for: selectedLine)
        } else {
            currentDisplayName = ""
        }
        
        let shouldResetSelection = newValue != currentLineName && newValue != currentDisplayName
        
        if shouldResetSelection {
            // Clear line selection and station data without resetting ride time
            vm.selectedLine = nil
            vm.showStationSelection = false
            vm.lineStations = []
            vm.selectedDepartureStation = nil
            vm.selectedArrivalStation = nil
            vm.departureStationInput = ""
            vm.arrivalStationInput = ""
            vm.showDepartureSuggestions = false
            vm.departureSuggestions = []
            vm.showArrivalSuggestions = false
            vm.arrivalSuggestions = []
            vm.isDepartureFieldFocused = false
            vm.isArrivalFieldFocused = false
            // Reset station selection flags to allow suggestions to show
            vm.departureStationSelected = false
            vm.arrivalStationSelected = false
            vm.lineSelected = false
            selected = nil
            // Show station selection UI for custom line input
            if !newValue.isEmpty {
                vm.showStationSelection = true
            }
        }
    }
    
    // MARK: - Helper Functions
    private func handleLineSelection(_ line: TransportationLine) {
        // Set line number changing flag to prevent unwanted suggestions
        vm.isLineNumberChanging = true
        
        selected = line
        // Set selectedLine for proper filtering
        vm.selectedLine = line
        // Update display name with operator information on selection
        vm.lineInput = vm.displayName(for: line)
        focused = false
        // Clear station fields when line is selected
        vm.departureStationInput = ""
        vm.arrivalStationInput = ""
        vm.selectedDepartureStation = nil
        vm.selectedArrivalStation = nil
        // Clear suggestion displays
        vm.showDepartureSuggestions = false
        vm.departureSuggestions = []
        vm.showArrivalSuggestions = false
        vm.arrivalSuggestions = []
        vm.isDepartureFieldFocused = false
        vm.isArrivalFieldFocused = false
        // Reset ride time to 5 minutes when line is selected
        vm.selectedRideTime = 5
        // Set line color or default to accent color
        vm.selectedLineColor = line.lineColor ?? accentColorString
    }
    
    private func handleLineStations(_ line: TransportationLine) {
        vm.lineStations = vm.getStationsForSelectedLine()
    }
    
    private func handleLineColorSelection(_ line: TransportationLine) {
        // MARK: - Auto Show Color Selection
        // Automatically show color selection sheet if line has no color
        if line.lineColor == nil {
            vm.showColorSelection = true
        }
    }
    
    private func handleLineSelectionCompletion() {
        // Hide line suggestions after selection
        vm.showLineSuggestions = false
        vm.lineSelected = true
        
        // Reset flag after a short delay to allow UI updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            vm.isLineNumberChanging = false
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct SettingsLineSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsLineSheet(goorback: "back1", lineIndex: 0)
    }
}


// MARK: - File Summary
// Comprehensive line configuration sheet interface for MyTimeTableMaker app
// Features: ODPT API integration, station search, line customization, data management
