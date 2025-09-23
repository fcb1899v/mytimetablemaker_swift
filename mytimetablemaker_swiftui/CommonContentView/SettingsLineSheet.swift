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
            let key = "\(line.operatorCode ?? "")_\(vm.lineDisplayName(for: line))"
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
                    VStack(alignment: .leading, spacing: screen.settingsSheetVerticalSpacing) {
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
                            transportationSettingsSection
                            if vm.selectedTransportation != "none" {
                                transferTimeSettingsSection
                            }
                        }
                        saveButtonSection
                        timetableSettingsButtonSection
                    }
                    .coordinateSpace(name: "scrollView")
                    .onPreferenceChange(DepartureStationPositionKey.self) { value in
                        departureStationPosition = value
                    }
                    .padding(.horizontal, screen.settingsSheetHorizontalPadding)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .animation(.default, value: vm.showStationSelection)
                    .sheet(isPresented: $showTimetableSettings) {
                        NavigationStack {
                            TimetableContentView(goorback, lineIndex)
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }

                // MARK: - Line Suggestions
                if vm.showLineSuggestions && !vm.lineSuggestions.isEmpty && !vm.isLineNumberChanging {
                    lineSuggestionsView
                }
                
                // MARK: - Color Selection Section
                if vm.showColorSelection || (!vm.lineInput.isEmpty && vm.selectedLineColor == nil && (selected?.lineColor == nil)) {
                    colorSelectionSection
                }

                // MARK: - Departure Station Suggestions
                if vm.showDepartureSuggestions && !vm.departureSuggestions.isEmpty && vm.lineSelected {
                    departureStationSuggestionsView
                }
                
                // MARK: - Arrival Station Suggestions
                if vm.showArrivalSuggestions && !vm.arrivalSuggestions.isEmpty && vm.lineSelected {
                    arrivalStationSuggestionsView
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.white, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Route Settings".localized)
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
                            .foregroundColor(.black)
                        Text("Back to homepage".localized)
                            .font(.system(size: screen.settingsFontSize, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
    
    // MARK: - Route Header Menu
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
                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .bold))
                        .foregroundColor(.black)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .medium))
                        .foregroundColor(.black)
                    Spacer()
                }
            }
            
            Spacer()
            
            // MARK: - Data Update Button
            CustomRectangleButton(
                title: "Update Line Data".localized,
                icon: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill",
                tintColor: vm.lastUpdatedDisplay != nil ? .accent : .secondary,
                action: {
                    Task { await vm.performDataUpdate() }
                }
            )
        }
        .padding(.top, screen.settingsSheetVerticalSpacing)
    }
    
    // MARK: - Line Header Menu
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
                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .bold))
                        .foregroundColor(.black)
                    Image(systemName: "chevron.down")
                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .medium))
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
                leftColor: .primary,
                rightText: "Bus".localized,
                rightColor: .primary,
                circleColor: .white,
                offColor: .secondary
            )
        }
        .padding(.top, screen.settingsSheetVerticalSpacing)
    }
    
    // MARK: - Line Name Section
    /// Section for inputting line name information
    private var lineNameSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            Text("Line Name".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)

            TextField(
                vm.selectedTransportationKind == .railway ? "Enter line name".localized : "Enter bus route name".localized,
                text: $vm.lineInput
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(.system(size: screen.settingsSheetInputFontSize))
            .padding(.vertical, screen.settingsSheetInputPaddingVertical)
            .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
            .background(StyledBackground())
            .overlay(StyledBorder())
            .onChange(of: vm.lineInput) { newValue in
                vm.processLineInput(newValue)
                // Ensure focus is maintained when typing
                if !newValue.isEmpty {
                    focused = true
                }
            }
            .onChange(of: vm.selectedLine) { _ in
                // Update line stations when line selection changes
                vm.lineStations = vm.getStationsForSelectedLine()
            }
            .onChange(of: vm.lineInput) { newValue in
                // Show station selection UI for custom line input
                if !newValue.isEmpty {
                    vm.showStationSelection = true
                }
            }
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.lineInput.isEmpty ? .gray : .accent)
        }
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
                        vm.selectLine(line)
                        vm.lineStations = vm.getStationsForSelectedLine()
                        // Auto show color selection if line has no color
                        if line.lineColor == nil {
                            vm.showColorSelection = true
                        }
                        // Hide line suggestions after selection
                        vm.showLineSuggestions = false
                        vm.lineSelected = true
                        
                        // Reset flag after a short delay to allow UI updates
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            vm.isLineNumberChanging = false
                        }

                    } label: {
                         HStack(alignment: .top, spacing: screen.settingsSheetHorizontalSpacing) {
                             Text(line.kind == .railway ? (line.lineCode ?? "Railway".localized) : "Bus".localized)
                                 .font(.system(size: screen.settingsLineSheetCaptionFontSize))
                                 .padding(.vertical, screen.settingsLineSheetTagPaddingVertical)
                                 .padding(.horizontal, screen.settingsLineSheetTagPaddingHorizontal)
                                 .background(Capsule().fill((line.lineColor?.safeColor ?? Color(0xAAAAAA)).opacity(0.5)))
                             
                             Text(vm.lineDisplayName(for: line))
                                 .font(.system(size: screen.settingsSheetInputFontSize))
                                 .lineLimit(1)
                             
                             if let operatorCode = line.operatorCode {
                                 let displayText = vm.getOperatorDisplayName(for: operatorCode, lineKind: line.kind)
                                 CustomTag(text: displayText)
                             }
                             
                             Spacer()
                         }
                         .contentShape(Rectangle())
                         .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                         .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
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
        .background(StyledBackground())
        .overlay(StyledBorder())
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
    
    // MARK: - Line Color Section
    /// Section for displaying and selecting line colors
    private var lineColorSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            Text("Line Color".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)

            // Color display circle
            Circle()
                .fill(vm.selectedLineColor?.safeColor ?? Color.gray)
                .frame(width: screen.settingsLineSheetColorCircleSmallSize, height: screen.settingsLineSheetColorCircleSmallSize)
                .overlay(Circle().stroke(.primary, lineWidth: screen.settingsSheetStrokeLineWidth))
                .padding(.horizontal, screen.settingsLineSheetColorHorizontalPadding)
                .padding(.vertical, screen.settingsLineSheetColorVerticalPadding)
                .background(
                    RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
                        .stroke(Color(.separator), lineWidth: screen.settingsSheetStrokeLineWidth)
                )
                .onTapGesture {
                    vm.showColorSelection = true
                }
            
            // MARK: - Color Selection Button
            CustomRectangleButton(
                title: "Select".localized,
                icon: "paintpalette.fill",
                tintColor: .primary,
                action: { vm.showColorSelection = true }
            )
            
            Spacer()
            
            // MARK: - Clear Button
            CustomRectangleButton(
                title: "Clear".localized,
                icon: "xmark.circle.fill",
                tintColor: .red,
                action: {
                    vm.clearAllFormData()
                    selected = nil
                }
            )
        }
    }
    
    // MARK: - Color Selection Section
    private var colorSelectionSection: some View {
        HStack {
            Spacer()
            VStack(spacing: screen.settingsSheetVerticalSpacing) {
                // MARK: - Color Selection Header
                HStack {
                    Text("Select Line Color".localized)
                        .font(.system(size: screen.settingsSheetTitleFontSize, weight: .semibold))
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
                .padding(.bottom, screen.settingsSheetVerticalSpacing)

                // MARK: - Color Selection Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: screen.settingsLineSheetGridSpacing) {
                    ForEach(CustomColor.allCases, id: \.self) { color in
                        // MARK: - Color Selection Button
                        /// Button for selecting a specific line color
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
                                    .overlay(Circle().stroke(Color.secondary, lineWidth: screen.settingsSheetStrokeLineWidth))
                                
                                // Color name label (localized)
                                Text(color.rawValue.localized)
                                    .font(.system(size: screen.settingsLineSheetCaptionFontSize))
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(width: screen.settingsLineSheetColorSettingWidth)
            .padding(screen.settingsLineSheetColorHorizontalPadding)
            .background(StyledBackground())
            .overlay(StyledBorder())
            Spacer()
        }
        .offset(y: screen.settingsLineSheetColorOffset)
        .zIndex(100)
    }
    
    // MARK: - Station Header Text
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
            .font(.system(size: screen.settingsSheetTitleFontSize, weight: .bold))
            .foregroundColor(.black)
            .padding(.top, screen.settingsSheetVerticalSpacing)
    }
    
    // MARK: - Departure Station Input Section
    /// Section for inputting departure station information
    private var departureStationInputSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            Text(vm.selectedTransportationKind == .bus ? "Departure Stop".localized : "Departure Station".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)

            TextField(vm.selectedTransportationKind == .bus ? "Enter departure stop".localized : "Enter departure station".localized, text: $vm.departureStationInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: screen.settingsSheetInputFontSize))
                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                .background(StyledBackground())
                .overlay(StyledBorder())
                .onChange(of: vm.departureStationInput) { newValue in
                    vm.processDepartureStationInput(newValue)
                }
                .onChange(of: vm.selectedDepartureStation) { _ in
                    // Re-filter arrival station suggestions after departure station selection
                    if !vm.arrivalStationInput.isEmpty {
                        vm.filterArrivalStations(vm.arrivalStationInput)
                    }
                }
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.departureStationInput.isEmpty ? .gray : .accent)
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
                                .font(.system(size: screen.settingsSheetInputFontSize))
                                .lineLimit(1)
                                .foregroundColor(.primary)
                                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
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
        .background(StyledBackground())
        .overlay(StyledBorder())
        .animation(.default, value: vm.departureSuggestions)
        .shadow(radius: screen.settingsLineSheetShadowRadius)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding()
        .offset(y: screen.settingsLineSheetDepartureOffset)
        .zIndex(100)
    }
    
    // MARK: - Arrival Station Input Section
    /// Section for inputting arrival station information
    private var arrivalStationInputSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            Text(vm.selectedTransportationKind == .bus ? "Arrival Stop".localized : "Arrival Station".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)

            TextField(vm.selectedTransportationKind == .bus ? "Enter arrival stop".localized : "Enter arrival station".localized, text: $vm.arrivalStationInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: screen.settingsSheetInputFontSize))
                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                .background(
                    RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
                        .stroke(Color(.separator), lineWidth: screen.settingsSheetStrokeLineWidth)
                )
                .onChange(of: vm.arrivalStationInput) { newValue in
                    vm.processArrivalStationInput(newValue)
                }
                .onChange(of: vm.selectedArrivalStation) { _ in
                    // Re-filter departure station suggestions after arrival station selection
                    if !vm.departureStationInput.isEmpty {
                        vm.filterDepartureStations(vm.departureStationInput)
                    }
                }
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.arrivalStationInput.isEmpty ? .gray : .accent)
        }
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
                                .font(.system(size: screen.settingsSheetInputFontSize))
                                .lineLimit(1)
                                .foregroundColor(.primary)
                                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
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
        .background(StyledBackground())
        .overlay(StyledBorder())
        .animation(.default, value: vm.arrivalSuggestions)
        .shadow(radius: screen.settingsLineSheetShadowRadius)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding()
        .offset(y: screen.settingsLineSheetArrivalOffset)
        .zIndex(100)
    }
    
    // MARK: - Time Header Text
    /// Time header with simple text
    private var timeHeaderText: some View {
        Text("Time Settings".localized)
            .font(.system(size: screen.settingsSheetTitleFontSize, weight: .bold))
            .foregroundColor(.black)
            .padding(.top, screen.settingsSheetVerticalSpacing)
    }
    
    // MARK: - Ride Time Section
    /// Section for configuring travel time between stations using Custom2DigitPicker
    private var rideTimeSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            Text("Ride Time".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)
            
            ZStack {
                HStack {
                    // Display current ride time (always show "-" for 0)
                    Text(vm.selectedRideTime == 0 ? "-" : "\(vm.selectedRideTime)\(" min".localized)")
                        .font(.system(size: screen.settingsSheetInputFontSize))
                        .foregroundColor(.black)
                    Spacer()
                }
                .frame(height: screen.settingsSheetPickerDisplayHeight)
                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                .background(
                    RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
                        .stroke(Color(.separator), lineWidth: screen.settingsSheetStrokeLineWidth)
                )
                
                HStack {
                    Spacer()
                    
                    Custom2DigitPicker(value: $vm.selectedRideTime, isZeroToFive: false)
                }
            }

            // Checkmark indicator
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.selectedRideTime == 0 ? .gray : .accent)
        }
        .padding(.vertical, screen.settingsLineSheetPickerPadding)
    }
    
    // MARK: - Transportation Settings Section
    /// Section for selecting transportation method for next transfer
    private var transportationSettingsSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            Text("Next Transfer".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack {
                // Display icon for selected transportation method
                Image(systemName: getTransportationType(label: vm.selectedTransportation).iconName)
                    .frame(height: screen.settingsSheetIconSize)
                    .foregroundColor(.black)

                Text(getTransportationType(label: vm.selectedTransportation).transportationDisplayName)
                    .font(.system(size: screen.settingsSheetInputFontSize))
                    .foregroundColor(.black)
                
                Menu {
                    ForEach(TransportationType.allCases.reversed(), id: \.self) { type in
                        Button(action: {
                            vm.selectedTransportation = type.rawValue
                        }) {
                            HStack {
                                Image(systemName: type.iconName)
                                    .foregroundColor(.black)
                                    .frame(height: screen.settingsSheetIconSize)
                                Text(type.transportationDisplayName)
                                    .font(.system(size: screen.settingsSheetInputFontSize))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: screen.settingsSheetInputFontSize, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .padding(.vertical, screen.settingsSheetInputPaddingVertical)
            .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
            .background(
                RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
                    .stroke(Color(.separator), lineWidth: screen.settingsSheetStrokeLineWidth)
            )

            Spacer()
        }
    }
    
    // MARK: - Transfer Time Settings Section
    /// Section for configuring transfer time when transportation is selected
    private var transferTimeSettingsSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            Text("Transfer Time".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)
            
            ZStack {
                HStack {
                    // Display current transfer time (always show "-" for 0)
                    Text(vm.selectedTransferTime == 0 ? "-" : "\(vm.selectedTransferTime)\(" min".localized)")
                        .font(.system(size: screen.settingsSheetInputFontSize))
                        .foregroundColor(.black)
                    Spacer()
                }
                .frame(height: screen.settingsSheetPickerDisplayHeight)
                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                .background(
                    RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
                        .stroke(Color(.separator), lineWidth: screen.settingsSheetStrokeLineWidth)
                )
                
                HStack {
                    Spacer()
                    // Custom2DigitPicker for transfer time selection (0-99 minutes)
                    Custom2DigitPicker(value: $vm.selectedTransferTime, isZeroToFive: false)
                }
            }
            
            // Checkmark indicator
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.selectedTransferTime == 0 ? .gray : .accent)
        }
        .padding(.vertical, screen.settingsLineSheetPickerPadding)
    }
    
    // MARK: - Save Button Section
    /// Save button for storing line configuration data
    private var saveButtonSection: some View {
        CustomButton(
            title: "Input Save".localized,
            icon: "square.and.arrow.down.on.square.fill",
            backgroundColor: Color.accent,
            isEnabled: vm.isAllNotEmpty,
            action: {
                vm.handleLineSave(dismiss: dismiss)
            }
        )
        .disabled(!vm.isCustomLineStationInputComplete() || !vm.isAllNotEmpty)
        .padding(.top, screen.settingsSheetSaveButtonSpacing)
    }
    
    // MARK: - Timetable Settings Button Section
    /// Button to open timetable configuration screen with auto/manual toggle
    private var timetableSettingsButtonSection: some View {
        CustomButton(
            title: (vm.isTimetableManual || !vm.isAllSelected) ? "Timetable Settings".localized: "Auto Generate Timetable".localized,
            icon: vm.isTimetableManual ? "clock.badge.exclamationmark.fill" : (vm.isAllSelected ? "clock.badge.checkmark.fill" : "clock.fill"),
            backgroundColor: !vm.isAllNotEmpty ? Color.gray : (!vm.isTimetableManual && vm.isAllSelected) ? Color.primary : Color.accent,
            isEnabled: vm.isAllNotEmpty,
            action: {
                // Auto mode: execute getTargetTimetableData if all selected, otherwise just open settings
                if !vm.isTimetableManual && vm.isAllSelected {
                    Task {
                        await vm.getTargetTimetableData()
                        showTimetableSettings = true
                    } 
                } else if vm.isAllNotEmpty {
                    showTimetableSettings = true
                }
            }
        )
        .disabled(!vm.isCustomLineStationInputComplete() || !vm.isAllNotEmpty)
        .padding(.top, screen.settingsSheetVerticalSpacing)
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
