//
//  SettingsLineSheet.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2025/08/12.
//
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
    // View model for managing line selection logic and data
    @StateObject private var vm: SettingsLineSheetViewModel
    @State private var selected: TransportationLine?
    @State private var showColorSelect = false
    @State private var showTimetableSettings = false
    @FocusState private var focused: Bool
    @FocusState private var operatorFocused: Bool
    @FocusState private var departureFocused: Bool
    @FocusState private var arrivalFocused: Bool
    
    // Environment value to dismiss the sheet
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Configuration
    private let goorback: String
    private let lineIndex: Int
    
    init(
        goorback: String,
        lineIndex: Int
    ) {
        // Validate goorback value and use default if invalid
        let validGoorback = goorback.isEmpty || !goorbackOptions.contains(goorback) ? "back1" : goorback
        self.goorback = validGoorback
        self.lineIndex = lineIndex
        self._vm = StateObject(wrappedValue: SettingsLineSheetViewModel(goorback: validGoorback, lineIndex: lineIndex))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                ScrollView {
                    VStack(alignment: .leading, spacing: screen.settingsSheetVerticalSpacing) {
                        routeHeaderMenu
                        lineNumberMenu
                        operatorInputSection
                        lineInputSection
                        lineColorSection
                        stationHeaderText
                        departureStopInputSection
                        arrivalStopInputSection
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
                        timetableAutoSettingsButtonSection
                    }
                    .coordinateSpace(name: "scrollView")
                    .padding(.horizontal, screen.settingsSheetHorizontalPadding)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .animation(.default, value: vm.showStationSelection)
                    .adaptiveSheet(isPresented: $showTimetableSettings) {
                        NavigationStack {
                            TimetableContentView(goorback, lineIndex)
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }

                // MARK: - Operator Suggestions
                if vm.showOperatorSuggestions && !vm.operatorSuggestions.isEmpty && !vm.isLineNumberChanging && !vm.operatorSelected {
                    operatorSuggestionsView
                }

                // MARK: - Line Suggestions
                if vm.showLineSuggestions && !vm.lineSuggestions.isEmpty && !vm.isLineNumberChanging && !vm.lineSelected {
                    lineSuggestionsView
                }
                // MARK: - Color Selection Section
                if vm.showColorSelection || (!vm.lineInput.isEmpty && vm.selectedLineColor == nil && selected?.lineColor == nil && !vm.lineSelected) {
                    colorSelectionSection
                }

                // MARK: - Departure Station Suggestions
                if vm.showDepartureSuggestions && !vm.departureSuggestions.isEmpty && vm.lineSelected {
                    departureStopSuggestionsView
                }
                
                // MARK: - Arrival Station Suggestions
                if vm.showArrivalSuggestions && !vm.arrivalSuggestions.isEmpty && vm.lineSelected {
                    arrivalStopSuggestionsView
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
                CustomBackButton(
                    foregroundColor: vm.isLoadingBusStops || vm.isLoadingTimetable || vm.isLoadingLines ? .white: .black,
                    action: { dismiss() }
                )
                .disabled(vm.isLoadingBusStops || vm.isLoadingTimetable || vm.isLoadingLines)
            }
        }
        .overlay {
            // MARK: - Loading Overlay
            // Dark overlay with progress bar when loading bus stops, generating timetable, or fetching line list
            // Displayed on top of all other views including navigation bar
            if vm.isLoadingBusStops || vm.isLoadingTimetable || vm.isLoadingLines {
                ZStack {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                    
                    VStack(spacing: screen.splashLoadingSpacing) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        if let message = vm.loadingMessage {
                            Text(message)
                                .font(.system(size: screen.splashLoadingFontSize))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .onAppear {
            // Reset isChangedOperator flag on appear (load from UserDefaults)
            vm.isChangedOperator = false
            
            // Ensure selectedGoorback matches the specified goorback parameter
            if vm.selectedGoorback != goorback {
                vm.selectGoorback(goorback)
            }
        }
    }
    
    // MARK: - Route Header Menu
    /// Main header view with direction selection dropdown and cancel button
    private var routeHeaderMenu: some View {
        HStack {
            
            // Direction selection dropdown
            Menu {
                ForEach(goorbackOptions, id: \.self) { option in
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
        .padding(.top, screen.settingsSheetVerticalSpacing)
    }
    
    private var lineNumberMenu: some View {
        HStack {
            Menu {
                ForEach(vm.availableLineNumbers, id: \.self) { lineNumber in
                    Button("\("Line".localized)\(lineNumber)") {
                        vm.selectLineNumber(lineNumber)
                    }
                }
            } label: {
                HStack {
                    Text("\("Line".localized)\(vm.selectedLineNumber)")
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
            .fixedSize(horizontal: true, vertical: false)
        }
    }

    
    // MARK: - Line Header Menu
    /// Line header with line number selection menu
    private var operatorInputSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            Text("Operator Name".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)

            TextField("Enter operator name".localized,
                text: $vm.operatorInput
            )
            .keyboardType(.default)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(.system(size: screen.settingsSheetInputFontSize))
            .padding(.vertical, screen.settingsSheetInputPaddingVertical)
            .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
            .background(CustomBackground())
            .overlay(CustomBorder())
            .focused($operatorFocused)
            .onChange(of: operatorFocused) { isFocused in
                vm.isOperatorFieldFocused = isFocused
                if isFocused {
                    // Show all operators when field is focused and operator input is empty
                    if vm.operatorInput.isEmpty {
                        Task {
                            await vm.filterOperators("")
                        }
                    }
                } else {
                    // Hide suggestions when field loses focus
                    vm.showOperatorSuggestions = false
                }
            }
            .onChange(of: vm.operatorInput) { newValue in
                vm.processOperatorInput(newValue)
                // Ensure focus is maintained when typing and show operator selection UI
                if !newValue.isEmpty {
                    operatorFocused = true
                    vm.showOperatorSelection = true
                }
            }
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.operatorInput.isEmpty ? .gray : .accent)
        }
    }
    
    // MARK: - Operator Suggestions View
    // Dropdown list showing suggested operators based on search input
    private var operatorSuggestionsView: some View {
        VStack(alignment: .leading, spacing: screen.settingsLineSheetSuggestionSpacing) {
            ScrollView {
                ForEach(Array(vm.operatorSuggestions.enumerated()), id: \.offset) { index, operatorName in
                    if index == 0 {
                        Color.clear.frame(height: 0)
                    }
                    Button {
                        vm.operatorInput = operatorName
                        vm.operatorSelected = true
                        vm.showOperatorSuggestions = false
                        vm.operatorSuggestions = []
                        
                        // Find and set operator code from operator name
                        if let dataSource = LocalDataSource.allCases.first(where: { 
                            $0.transportationType == vm.selectedTransportationKind &&
                            $0.operatorDisplayName == operatorName
                        }) {
                            // Check if operator has changed from saved value
                            let previousOperatorCode = vm.selectedOperatorCode
                            if previousOperatorCode != dataSource.operatorCode {
                                vm.isChangedOperator = true
                            }
                            
                            vm.selectedOperatorCode = dataSource.operatorCode
                            
                            // Clear line input when operator is selected
                            vm.lineInput = ""
                            vm.selectedLine = nil
                            vm.lineSelected = false
                            
                            // Focus on line input field after operator is selected
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                focused = true
                            }
                            
                            // For GTFS operators, fetch lines from ZIP cache
                            if dataSource.apiType == .gtfs {
                                // Clear line suggestions immediately to prevent showing old data
                                vm.lineSuggestions = []
                                vm.showLineSuggestions = false
                                
                                Task {
                                    await vm.fetchGTFSLinesForOperator(dataSource)
                                }
                                vm.showLineSuggestions = false
                            } else {
                                // For non-GTFS operators, use filter to show line suggestions
                                Task {
                                    await vm.filterLine(vm.lineInput)
                                }
                            }
                        }
                        
                        // Reset flag after a short delay to allow UI updates
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            vm.isLineNumberChanging = false
                        }
                    } label: {
                        HStack {
                            Text(vm.selectedTransportationKind == .railway ? "Railway".localized : "Bus".localized)
                                .font(.system(size: screen.settingsLineSheetCaptionFontSize))
                                .padding(.vertical, screen.settingsLineSheetTagPaddingVertical)
                                .padding(.horizontal, screen.settingsLineSheetTagPaddingHorizontal)
                                .background(Capsule().fill(Color(0xAAAAAA).opacity(0.5)))

                            Text(operatorName)
                                .font(.system(size: screen.settingsSheetInputFontSize))
                                .lineLimit(1)
                                .foregroundColor(.primary)
                                
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, screen.settingsLineSheetSuggestionPaddingVertical)
                        .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                    }
                    .buttonStyle(.plain)
                    if index < vm.operatorSuggestions.count - 1 {
                        Color.clear.frame(height: 0)
                    }
                }
            }
            Spacer()
        }
        .frame(maxHeight: min(CGFloat(vm.operatorSuggestions.count) * screen.settingsLineSheetSuggestionItemHeight, screen.settingsLineSheetMaxSuggestionHeight))
        .background(CustomBackground())
        .overlay(CustomBorder())
        .animation(.default, value: vm.operatorSuggestions)
        .shadow(radius: screen.settingsLineSheetShadowRadius)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding()
        .offset(y: screen.settingsLineSheetOperatorOffset)
        .zIndex(100)
    }
    
    // MARK: - Line Name Section
    /// Section for inputting line name information
    private var lineInputSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            Text("Line Name".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)

            TextField(
                vm.selectedTransportationKind == .railway ? "Enter line name".localized : "Enter bus route name".localized,
                text: $vm.lineInput
            )
            .keyboardType(.default)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(.system(size: screen.settingsSheetInputFontSize))
            .padding(.vertical, screen.settingsSheetInputPaddingVertical)
            .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
            .background(CustomBackground())
            .overlay(CustomBorder())
            .focused($focused)
            .onChange(of: focused) { isFocused in
                vm.isLineFieldFocused = isFocused
                if isFocused {
                    // Show line suggestions when field is focused, operator is selected, and line input is empty
                    if vm.selectedOperatorCode != nil && vm.operatorSelected && vm.lineInput.isEmpty {
                        // Reset lineSelected flag to allow suggestions to show when field is focused
                        vm.lineSelected = false
                        Task {
                            await vm.filterLine("")
                        }
                    }
                } else {
                    // Hide suggestions when field loses focus
                    vm.showLineSuggestions = false
                }
            }
            .onChange(of: vm.lineInput) { newValue in
                vm.processLineInput(newValue)
                // Ensure focus is maintained when typing and show station selection UI
                if !newValue.isEmpty {
                    focused = true
                    vm.showStationSelection = true
                }
            }
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.lineInput.isEmpty ? .gray : .accent)
        }
    }
        
    // MARK: - Line Suggestions View
    // Dropdown list showing suggested lines based on search input
    private var lineSuggestionsView: some View {
        VStack(alignment: .leading, spacing: screen.settingsLineSheetSuggestionSpacing) {
            ScrollView {
                let uniqueLines = vm.removeDuplicates(from: vm.lineSuggestions)
                let enumeratedLines = Array(uniqueLines.enumerated())
                ForEach(enumeratedLines, id: \.element.id) { index, line in
                    if index == 0 {
                        Color.clear.frame(height: 0)
                    }
                    Button {
                        vm.selectLine(line)
                        // Auto show color selection if line has no color
                        if line.lineColor == nil {
                            vm.showColorSelection = true
                        }
                        // Hide line suggestions after selection
                        vm.showLineSuggestions = false
                        vm.lineSelected = true
                        
                        // Remove focus from all fields after line is selected
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            focused = false
                            operatorFocused = false
                            departureFocused = false
                            arrivalFocused = false
                            vm.isLineNumberChanging = false
                        }

                    } label: {
                         HStack(alignment: .top, spacing: screen.settingsSheetHorizontalSpacing) {

                            if let lineCode = line.lineCode {
                                Text(lineCode)
                                    .font(.system(size: screen.settingsLineSheetCaptionFontSize))
                                    .padding(.vertical, screen.settingsLineSheetTagPaddingVertical)
                                    .padding(.horizontal, screen.settingsLineSheetTagPaddingHorizontal)
                                    .background(
                                        Capsule().fill(
                                            (line.lineColor?.safeColor ?? Color(0xAAAAAA)).opacity(0.5)
                                        )
                                    )
                            } else if let operatorCode = line.operatorCode {
                                 let displayText = vm.getOperatorDisplayNameForTag(for: operatorCode, lineKind: line.kind)
                                 let tagColor = line.lineColor?.safeColor
                                 CustomTag(text: displayText, backgroundColor: tagColor)
                             } else if let lineColor = line.lineColor {
                                 // Display line color when only lineColor is available
                                 Circle()
                                     .fill(lineColor.safeColor)
                                     .frame(width: screen.settingsLineSheetColorCircleSmallSize, height: screen.settingsLineSheetColorCircleSmallSize)
                             }
                                                         
                             Text(vm.lineDisplayName(for: line))
                                 .font(.system(size: screen.settingsSheetInputFontSize))
                                 .lineLimit(1)
                             
                             Spacer()
                         }
                         .contentShape(Rectangle())
                         .padding(.vertical, screen.settingsLineSheetSuggestionPaddingVertical)
                         .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                     }
                    .buttonStyle(.plain)
                    if index < uniqueLines.count - 1 {
                        Color.clear.frame(height: 0)
                    }
                }
            }
            Spacer()
        }
        .frame(maxHeight: min(CGFloat(vm.lineSuggestions.count) * screen.settingsLineSheetSuggestionItemHeight, screen.settingsLineSheetMaxSuggestionHeight))
        .background(CustomBackground())
        .overlay(CustomBorder())
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
            
            Spacer(minLength: 0)
        }
    }
    
    // MARK: - Color Selection Section
    // Color picker overlay for selecting line colors
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
            .background(CustomBackground())
            .overlay(CustomBorder())
            Spacer()
        }
        .offset(y: screen.settingsLineSheetColorOffset)
        .zIndex(100)
    }
    
    // MARK: - Station Header Text
    /// Station header with dynamic station information
    /// For GTFS routes, displays "出発停〜行き先" format
    private var stationHeaderText: some View {
        let headerText = vm.selectedTransportationKind == .bus ? "Bus Stop Input".localized : "Station Input".localized
        
        let stationInfo: String
        if vm.hasSelectedLine && vm.hasStops {
            let firstStop = vm.lineStops.first?.displayName ?? ""
            let lastStop = vm.lineStops.last?.displayName ?? ""
            
            // For GTFS routes, use "〜" separator (出発停〜行き先)
            if vm.selectedTransportationKind == .bus,
               let operatorCode = vm.selectedLine?.operatorCode,
               let dataSource = LocalDataSource.allCases.first(where: { $0.operatorCode == operatorCode }),
               dataSource.apiType == .gtfs {
                stationInfo = ": ".localized + firstStop + " to ".localized  + lastStop
            } else {
                stationInfo = ": ".localized + firstStop + " to ".localized + lastStop
            }
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
    private var departureStopInputSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            Text(vm.selectedTransportationKind == .bus ? "Departure Stop".localized : "Departure Station".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)

            TextField(vm.selectedTransportationKind == .bus ? "Enter departure stop".localized : "Enter departure station".localized, text: $vm.departureStopInput)
                .keyboardType(.default)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: screen.settingsSheetInputFontSize))
                .padding(.vertical, screen.settingsSheetInputPaddingVertical)
                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
                .background(CustomBackground())
                .overlay(CustomBorder())
                .focused($departureFocused)
                .onChange(of: departureFocused) { isFocused in
                    vm.isDepartureFieldFocused = isFocused
                    if isFocused {
                        // Show departure stop suggestions when field is focused, operator and line are selected, and input is empty
                        if vm.selectedOperatorCode != nil && vm.operatorSelected && vm.lineSelected && vm.departureStopInput.isEmpty {
                            // Reset departureStopSelected flag to allow suggestions to show when field is focused
                            vm.departureStopSelected = false
                            vm.filterDepartureStops("")
                        }
                    } else {
                        // Hide suggestions when field loses focus
                        vm.showDepartureSuggestions = false
                    }
                }
                .onChange(of: vm.departureStopInput) { newValue in
                    vm.processdepartureStopInput(newValue)
                }
                .onChange(of: vm.selectedDepartureStop) { _ in
                    // Re-filter arrival station suggestions after departure station selection
                    if !vm.arrivalStopInput.isEmpty {
                        vm.filterArrivalStops(vm.arrivalStopInput)
                    }
                }
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.departureStopInput.isEmpty ? .gray : .accent)
        }
    }

    // MARK: - Departure Stop Suggestions
    // Dropdown list showing suggested departure stops based on search input
    private var departureStopSuggestionsView: some View {
        VStack(alignment: .leading, spacing: screen.settingsLineSheetSuggestionSpacing) {
            ScrollView {
                ForEach(vm.departureSuggestions, id: \.id) { stop in
                    if stop == vm.departureSuggestions.first {
                        Color.clear.frame(height: 0)
                    }
                    StopRowView(stop: stop, isDeparture: true, vm: vm)
                }
            }
        }
        .frame(maxHeight: min(
            CGFloat(vm.departureSuggestions.count) * screen.settingsLineSheetSuggestionItemHeight,
            screen.settingsLineSheetStopMaxSuggestionHeight
        ))
        .background(CustomBackground())
        .overlay(CustomBorder())
        .animation(.default, value: vm.departureSuggestions.count)
        .shadow(radius: screen.settingsLineSheetShadowRadius)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding()
        .offset(y: screen.settingsLineSheetDepartureOffset(isEmpty: vm.departureStopInput.isEmpty))
        .zIndex(100)
    }
    
    // MARK: - Arrival Station Input Section
    /// Section for inputting arrival station information
    private var arrivalStopInputSection: some View {
        HStack(spacing: screen.settingsSheetHorizontalSpacing) {
            Text(vm.selectedTransportationKind == .bus ? "Arrival Stop".localized : "Arrival Station".localized)
                .font(.system(size: screen.settingsSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primary)

            TextField(vm.selectedTransportationKind == .bus ? "Enter arrival stop".localized : "Enter arrival station".localized, text: $vm.arrivalStopInput)
                .keyboardType(.default)
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
                .focused($arrivalFocused)
                .onChange(of: arrivalFocused) { isFocused in
                    vm.isArrivalFieldFocused = isFocused
                    if isFocused {
                        // Show arrival stop suggestions when field is focused, operator and line are selected, and input is empty
                        if vm.selectedOperatorCode != nil && vm.operatorSelected && vm.lineSelected && vm.arrivalStopInput.isEmpty {
                            // Reset arrivalStopSelected flag to allow suggestions to show when field is focused
                            vm.arrivalStopSelected = false
                            vm.filterArrivalStops("")
                        }
                    } else {
                        // Hide suggestions when field loses focus
                        vm.showArrivalSuggestions = false
                    }
                }
                .onChange(of: vm.arrivalStopInput) { newValue in
                    vm.processarrivalStopInput(newValue)
                }
                .onChange(of: vm.selectedArrivalStop) { _ in
                    // Re-filter departure station suggestions after arrival station selection
                    if !vm.departureStopInput.isEmpty {
                        vm.filterDepartureStops(vm.departureStopInput)
                    }
                }
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.arrivalStopInput.isEmpty ? .gray : .accent)
        }
    }
    
    // MARK: - Arrival Stop Suggestions
    // Dropdown list showing suggested arrival stops based on search input
    private var arrivalStopSuggestionsView: some View {
        VStack(alignment: .leading, spacing: screen.settingsLineSheetSuggestionSpacing) {
            ScrollView {
                ForEach(vm.arrivalSuggestions, id: \.id) { stop in
                    if stop == vm.arrivalSuggestions.first {
                        Color.clear.frame(height: 0)
                    }
                    StopRowView(stop: stop, isDeparture: false, vm: vm)
                }
            }
        }
        .frame(maxHeight: min(CGFloat(vm.arrivalSuggestions.count) * screen.settingsLineSheetSuggestionItemHeight, screen.settingsLineSheetStopMaxSuggestionHeight))
        .background(CustomBackground())
        .overlay(CustomBorder())
        .animation(.default, value: vm.arrivalSuggestions.count)
        .shadow(radius: screen.settingsLineSheetShadowRadius)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding()
        .offset(y: screen.settingsLineSheetArrivalOffset(isEmpty: vm.arrivalStopInput.isEmpty))
        .zIndex(100)
    }

    // MARK: - StopRowView
    // Individual row component for displaying a stop in the suggestions list
    private struct StopRowView: View {
        // Stop data to display
        let stop: TransportationStop
        
        // Whether this is a departure or arrival stop
        let isDeparture: Bool
        
        // View model reference for updating state context
        @ObservedObject var vm: SettingsLineSheetViewModel
        
        var body: some View {
            Button {
                // Set line number changing flag to prevent unwanted suggestions
                vm.isLineNumberChanging = true
                
                let stopDisplayName = stop.displayName
                
                if isDeparture {
                    // Departure stop selection
                    let arrivalDisplayName = vm.selectedArrivalStop?.displayName ?? ""
                    let isSameAsArrival = arrivalDisplayName == stopDisplayName
                    vm.departureStopInput = isSameAsArrival ? "" : stopDisplayName
                    vm.selectedDepartureStop = isSameAsArrival ? nil : stop
                    // Completely disable departure suggestions after selection
                    vm.showDepartureSuggestions = false
                    vm.isDepartureFieldFocused = false
                    vm.departureSuggestions = []
                    // Set a flag to prevent re-display
                    vm.departureStopSelected = true
                } else {
                    // Arrival stop selection
                    let departureDisplayName = vm.selectedDepartureStop?.displayName ?? ""
                    let isSameAsDeparture = departureDisplayName == stopDisplayName
                    vm.arrivalStopInput = isSameAsDeparture ? "" : stopDisplayName
                    vm.selectedArrivalStop = isSameAsDeparture ? nil : stop
                    // Completely disable arrival suggestions after selection
                    vm.showArrivalSuggestions = false
                    vm.isArrivalFieldFocused = false
                    vm.arrivalSuggestions = []
                    // Set a flag to prevent re-display
                    vm.arrivalStopSelected = true
                }
                
                // Reset flag after a short delay to allow UI updates
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    vm.isLineNumberChanging = false
                }
            } label: {
                HStack {
                    Text(stop.displayName)
                        .font(.system(size: screen.settingsSheetInputFontSize))
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .contentShape(Rectangle())
                .padding(.vertical, screen.settingsLineSheetSuggestionPaddingVertical)
                .padding(.horizontal, screen.settingsSheetInputPaddingHorizontal)
            }
            .buttonStyle(.plain)
        }
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
            // Gray if ride time is 0 and timetable support is not available
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.selectedRideTime == 0 && !vm.hasTimetableSupport() ? .gray : .accent)
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
                Image(systemName: transferType(from: vm.selectedTransportation).iconName)
                    .frame(height: screen.settingsSheetIconSize)
                    .foregroundColor(.black)

                Text(transferType(from: vm.selectedTransportation).transportationDisplayName)
                    .font(.system(size: screen.settingsSheetInputFontSize))
                    .foregroundColor(.black)
                
                Menu {
                    ForEach(TransferType.allCases.reversed(), id: \.self) { type in
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
            
            // Checkmark indicator (0 minutes is valid for direct connections)
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.accent)
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
                Task {
                    await vm.handleLineSave()
                    NotificationCenter.default.post(name: NSNotification.Name("SettingsLineUpdated"), object: nil)
                    dismiss()
                }
            }
        )
        .disabled(!vm.isAllNotEmpty)
        .padding(.top, screen.settingsSheetVerticalSpacing)
    }
    
    // MARK: - Timetable Settings Button Section
    // Button to open manual timetable configuration settings
    private var timetableSettingsButtonSection: some View {
        CustomButton(
            title: "Timetable Settings".localized,
            icon: vm.isAllNotEmpty ? "clock.badge.checkmark.fill": "clock.fill",
            backgroundColor: vm.isAllNotEmpty ? Color.accent: Color.gray,
            isEnabled: vm.isAllNotEmpty,
            action: {
                if vm.isAllNotEmpty {
                    // Save input data before opening timetable settings
                    Task {
                        await vm.handleLineSave()
                        showTimetableSettings = true
                    }
                }
            }
        )
        .disabled(!vm.isAllNotEmpty)
    }

    // MARK: - Timetable Auto Settings Button Section
    // Button to automatically generate timetable data using ODPT API
    private var timetableAutoSettingsButtonSection: some View {
        CustomButton(
            title: "Auto Generate Timetable".localized,
            icon: (vm.isAllNotEmpty && vm.isAllSelected) ? "clock.badge.checkmark.fill" : "clock.fill",
            backgroundColor: (vm.isAllNotEmpty && vm.isAllSelected) ? Color.primary : Color.gray,
            isEnabled: vm.isAllNotEmpty && vm.isAllSelected,
            action: {
                // Auto mode: execute getStationTimetableData if all selected, otherwise just open settings
                if vm.isAllNotEmpty && vm.isAllSelected {
                    // Save input data before auto generating timetable
                    Task {
                        await vm.handleLineSave()
                        if vm.hasTimetableSupport() {
                            let result: [ODPTCalendarType: [any TransportationTime]] = await vm.getTimeTableData()
                            // Use new finalizeTimetableData method with individual calendar types
                            await vm.finalizeTimetableData(calendarTimes: result)
                        } else {
                            let result = await vm.getStationTimetableData()
                            await vm.finalizeTimetableData(calendarTimes: result)
                        }
                        showTimetableSettings = true
                    } 
                }
            }
        )
        .disabled(!vm.isAllNotEmpty)
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


