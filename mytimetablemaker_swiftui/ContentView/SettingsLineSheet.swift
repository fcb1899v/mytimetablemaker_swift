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
                VStack(alignment: .leading, spacing: settingsLineSheetSpacing) {
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
                    dataManagementSection
                    saveButtonSection
                    timetableSettingsButtonSection
                }
                .coordinateSpace(name: "scrollView")
                .onPreferenceChange(DepartureStationPositionKey.self) { value in
                    departureStationPosition = value
                }
                .padding(.horizontal, settingsLineSheetPadding)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .animation(.default, value: vm.showStationSelection)
                .sheet(isPresented: $showTimetableSettings) {
                    NavigationStack {
                        TimetableContentView(goorback, lineIndex)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }

                // MARK: - Departure Station Suggestions
                if vm.showDepartureSuggestions && !vm.departureSuggestions.isEmpty {
                    departureStationSuggestionsView
                }
                
                // MARK: - Arrival Station Suggestions
                if vm.showArrivalSuggestions && !vm.arrivalSuggestions.isEmpty {
                    arrivalStationSuggestionsView
                }
                
                // MARK: - Line Suggestions
                if vm.showLineSuggestions && !vm.lineSuggestions.isEmpty && !vm.isLineNumberChanging {
                    lineSuggestionsView
                }
                
                // MARK: - Color Selection Section
                if vm.showColorSelection || (!vm.query.isEmpty && vm.selectedLineColor == nil && (selected?.lineColor == nil)) {
                    colorSelectionSection
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // Cancel button
                Button("Cancel".localized) {
                    dismiss()
                }
                .font(.system(size: settingsLineSheetButtonFontSize))
                .foregroundColor(.black)
            }
        }
        .onPreferenceChange(DepartureStationPositionKey.self) { value in
            departureStationPosition = value
        }
        .padding(.horizontal, settingsLineSheetPadding)
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
                        if let selectedArrivalStation = vm.selectedArrivalStation,
                           station.getLocalizedName() == selectedArrivalStation.getLocalizedName() {
                            vm.departureStationInput = ""
                            vm.selectedDepartureStation = nil
                        } else {
                            vm.departureStationInput = station.getLocalizedName()
                            vm.selectedDepartureStation = station
                        }
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
                                .font(.system(size: settingsLineSheetInputFontSize))
                                .lineLimit(1)
                                .foregroundColor(.primary)
                                .padding(.vertical, settingsLineSheetInputPaddingVertical)
                                .padding(.horizontal, settingsLineSheetInputPaddingHorizontal)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if station != vm.departureSuggestions.last { Divider() }
                }
            }
        }
        .frame(maxHeight: min(CGFloat(vm.departureSuggestions.count) * settingsLineSheetSuggestionItemHeight, settingsLineSheetMaxSuggestionHeight))
        .background(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).fill(.background))
        .overlay(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: settingsLineSheetStrokeLineWidth))
        .animation(.default, value: vm.departureSuggestions)
        .shadow(radius: settingsLineSheetShadowRadius)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding()
        .offset(y: settingsLineSheetDepartureOffset)
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
                        if let selectedDepartureStation = vm.selectedDepartureStation,
                           station.getLocalizedName() == selectedDepartureStation.getLocalizedName() {
                            vm.arrivalStationInput = ""
                            vm.selectedArrivalStation = nil
                        } else {
                            vm.arrivalStationInput = station.getLocalizedName()
                            vm.selectedArrivalStation = station
                        }
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
                                .font(.system(size: settingsLineSheetInputFontSize))
                                .lineLimit(1)
                                .foregroundColor(.primary)
                            .contentShape(Rectangle())
                            .padding(.vertical, settingsLineSheetInputPaddingVertical)
                            .padding(.horizontal, settingsLineSheetInputPaddingHorizontal)

                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if station != vm.arrivalSuggestions.last { Divider() }
                }
            }
        }
        .frame(maxHeight: min(CGFloat(vm.arrivalSuggestions.count) * settingsLineSheetSuggestionItemHeight, settingsLineSheetMaxSuggestionHeight))
        .background(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).fill(.background))
        .overlay(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: settingsLineSheetStrokeLineWidth))
        .animation(.default, value: vm.arrivalSuggestions)
        .shadow(radius: settingsLineSheetShadowRadius)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding()
        .offset(y: settingsLineSheetArrivalOffset)
        .zIndex(100)
    }

    // MARK: - Line Suggestions
    private var lineSuggestionsView: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(Array(removeDuplicates(from: vm.lineSuggestions).enumerated()), id: \.element.id) { index, line in
                    if index == 0 {
                        Color.clear.frame(height: 0)
                    }
                    Button {
                        // Set line number changing flag to prevent unwanted suggestions
                        vm.isLineNumberChanging = true
                        
                        selected = line
                        // Update display name with operator information on selection
                        vm.query = vm.displayName(for: line)
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
                        
                        // Hide line suggestions after selection
                        vm.showLineSuggestions = false
                        vm.lineSelected = true
                        
                        // Reset flag after a short delay to allow UI updates
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            vm.isLineNumberChanging = false
                        }

                    } label: {
                         HStack(alignment: .top, spacing: settingsLineSheetHStackSpacing) {
                             Text(line.kind == .railway ? (line.lineCode ?? "Railway".localized) : "Bus".localized)
                                 .font(.system(size: settingsLineSheetCaptionFontSize))
                                 .padding(.vertical, settingsLineSheetTagPaddingVertical)
                                 .padding(.horizontal, settingsLineSheetTagPaddingHorizontal)
                                 .background(Capsule().fill(Color(line.lineColor?.colorInt ?? 0xAAAAAA).opacity(0.5)))
                             
                             Text(vm.displayName(for: line))
                                 .font(.system(size: settingsLineSheetInputFontSize))
                                 .lineLimit(1)
                             
                             if let operatorCode = line.operatorCode {
                                 let displayText = vm.getOperatorDisplayName(for: operatorCode, lineKind: line.kind)
                                 Tag(text: displayText)
                             }
                             
                             Spacer()
                         }
                         .contentShape(Rectangle())
                         .padding(.vertical, settingsLineSheetInputPaddingVertical)
                         .padding(.horizontal, settingsLineSheetInputPaddingHorizontal)
                     }
                    .buttonStyle(.plain)
                    if index < removeDuplicates(from: vm.lineSuggestions).count - 1 {
                        Color.clear.frame(height: 0)
                    }
                }
            }
            Spacer()
        }
        .frame(maxHeight: min(CGFloat(vm.lineSuggestions.count) * settingsLineSheetSuggestionItemHeight, settingsLineSheetMaxSuggestionHeight))
        .background(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).fill(.background))
        .overlay(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: settingsLineSheetStrokeLineWidth))
        .animation(.default, value: vm.lineSuggestions)
        .shadow(radius: settingsLineSheetShadowRadius)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding()
        .offset(y: settingsLineSheetLineOffset)
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
        .background(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
        .overlay(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: settingsLineSheetStrokeLineWidth))
        .padding(.horizontal, settingsLineSheetPadding)
        .offset(y: settingsLineSheetColorOffset)
        .zIndex(100)
    }
    
    // MARK: - Color Selection Header
    private var colorSelectionHeader: some View {
        HStack {
            Text("Select Line Color".localized)
                .font(.system(size: settingsLineSheetHeaderFontSize, weight: .semibold))
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
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: settingsLineSheetGridSpacing) {
            ForEach(CustomColor.allCases, id: \.self) { color in
                colorSelectionButton(for: color)
            }
        }
        .padding(.all, settingsLineSheetGridSpacing)
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
                    .fill(Color(color.RGB.colorInt))
                    .frame(width: settingsLineSheetColorCircleSize, height: settingsLineSheetColorCircleSize)
                    .overlay(Circle().stroke(Color.secondary, lineWidth: settingsLineSheetStrokeLineWidth))
                
                // Color name label (localized)
                Text(color.rawValue.localized)
                    .font(.system(size: settingsLineSheetCaptionFontSize))
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Save Button Section
    /// Save button for storing line configuration data
    private var saveButtonSection: some View {
        VStack(spacing: settingsLineSheetSpacing) {
            actionButton(
                title: "Save".localized,
                icon: "square.and.arrow.down.fill",
                color: selected == nil && !vm.isCustomLineStationInputComplete() ? .gray : .accentColor
            ) {
                vm.handleLineSave(dismiss: dismiss)
            }
            .disabled(!vm.isCustomLineStationInputComplete())
        }
        .padding(.top, settingsLineSheetPadding)
    }
    
    // MARK: - Timetable Settings Button Section
    /// Button to open timetable configuration screen
    private var timetableSettingsButtonSection: some View {
        VStack(spacing: settingsLineSheetSpacing) {
            actionButton(
                title: "Timetable Settings".localized,
                icon: "clock.fill",
                color: .primaryColor
            ) {
                showTimetableSettings = true
            }
            
            Spacer()
        }
        .padding(.top, settingsLineSheetPadding)
    }
    
    // MARK: - Action Button Helper
    /// Reusable button component with consistent styling
    @ViewBuilder
    private func actionButton(
        title: String,
        icon: String,
        color: Color = .accentColor,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: settingsLineSheetButtonFontSize, weight: .medium))
                Text(title)
                    .font(.system(size: settingsLineSheetButtonFontSize, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: settingsLineSheetButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: settingsLineSheetButtonCornerRadius)
                    .fill(color)
            )
        }
    }
    

    // MARK: - Header View
    /// Main header view with route selection dropdown and cancel button
    private var routeHeaderMenu: some View {
        // Route selection dropdown
        Menu {
            ForEach(vm.goorbackOptions, id: \.self) { option in
                Button(vm.goorbackDisplayNames[option] ?? option) {
                    vm.selectGoorback(option)
                }
            }
        } label: {
            HStack {
                Text(vm.goorbackDisplayNames[vm.selectedGoorback] ?? vm.selectedGoorback)
                    .font(.system(size: settingsLineSheetTitleFontSize, weight: .bold))
                    .foregroundColor(.primary)

                Image(systemName: "chevron.down")
                    .font(.system(size: settingsLineSheetTitleFontSize, weight: .medium))
                    .foregroundColor(.black)
                Spacer()
            }
        }
    }
    
    // MARK: - Header Implementations
    /// Line header with line number selection menu
    private var lineHeaderMenu: some View {
        Menu {
            ForEach(vm.availableLineNumbers, id: \.self) { lineNumber in
                Button("\("Line".localized)\(lineNumber)") {
                    vm.selectLineNumber(lineNumber)
                }
            }
        } label: {
            HStack {
                Text("\("Line".localized)\(vm.selectedLineNumber) \("Input".localized)")
                    .font(.system(size: settingsLineSheetHeaderFontSize, weight: .bold))
                    .foregroundColor(Color.black)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: settingsLineSheetHeaderFontSize, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
            }
        }
        .padding(.top, settingsLineSheetPadding)
    }
    
    /// Station header with dynamic station information
    private var stationHeaderText: some View {
        Text("Station Input".localized + "\(vm.hasSelectedLine && vm.hasStations ? ": ".localized + "\(vm.lineStations.first?.name ?? "")" + " to ".localized + "\(vm.lineStations.last?.name ?? "")": "")")
            .font(.system(size: settingsLineSheetHeaderFontSize, weight: .bold))
            .foregroundColor(Color.black)
            .padding(.top, settingsLineSheetPadding)
    }
    
    /// Time header with simple text
    private var timeHeaderText: some View {
        Text("Time Settings".localized)
            .font(.system(size: settingsLineSheetHeaderFontSize, weight: .bold))
            .foregroundColor(Color.black)
            .padding(.top, settingsLineSheetPadding)
    }
    
    // MARK: - Line Name Section
    private var lineNameSection: some View {
        VStack(alignment: .leading, spacing: settingsLineSheetSpacing) {
            HStack {
                Text("Line Name".localized)
                    .font(.system(size: settingsLineSheetHeadlineFontSize, weight: .semibold))
                    .foregroundColor(.primaryColor)

                TextField("Enter line name or bus route name".localized, text: $vm.query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(size: settingsLineSheetInputFontSize))
                    .padding(.vertical, settingsLineSheetInputPaddingVertical)
                    .padding(.horizontal, settingsLineSheetInputPaddingHorizontal)
                    .background(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: settingsLineSheetStrokeLineWidth))
                    .focused($focused)
                    .onSubmit {
                        // Handle enter key press
                        Task { await vm.filter(vm.query) }
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
                        if !vm.query.isEmpty {
                            Task { await vm.filter(vm.query) }
                        }
                    }
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(vm.query.isEmpty ? .gray : .accentColor)
            }
            .onChange(of: vm.query) { newValue in
                handleQueryChange(newValue)
            }
        }
    }
    
    // MARK: - Line Color Section
    /// Section for displaying and selecting line colors
    private var lineColorSection: some View {
        HStack {
            Text("Line Color".localized)
                .font(.system(size: settingsLineSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primaryColor)

            // Display selected color as a circle
            Circle()
                .fill(vm.selectedLineColor != nil ? Color(vm.selectedLineColor!.colorInt) : 
                      selected?.lineColor != nil ? Color(selected!.lineColor!.colorInt) : 
                      Color.primaryColor)
                .frame(width: settingsLineSheetColorCircleSmallSize, height: settingsLineSheetColorCircleSmallSize)
                .overlay(Circle().stroke(Color.primaryColor, lineWidth: settingsLineSheetStrokeLineWidth))
                .padding(.horizontal, settingsLineSheetColorPaddingHorizontal)
                .padding(.vertical, settingsLineSheetColorPaddingVertical)
                .background(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                .overlay(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: settingsLineSheetStrokeLineWidth))

            Spacer()
            
            // Color selection button
            Button(action: {
                vm.showColorSelection = true
            }) {
                Text("Select Color".localized)
                    .font(.system(size: settingsLineSheetButtonFontSize))
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.primaryColor)
        }
    }
    
    // MARK: - Ride Time Section
    /// Section for configuring travel time between stations
    private var rideTimeSection: some View {
        HStack(alignment: .center) {
            Text("Ride Time".localized)
                .font(.system(size: settingsLineSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primaryColor)
            
            HStack {
                Text("\(vm.selectedRideTime)\(" min".localized)")
                    .font(.system(size: settingsLineSheetInputFontSize))
                    .foregroundColor(.black)
                
                Menu {
                    ForEach(0...99, id: \.self) { minute in
                        Button("\(minute)" + " min".localized) {
                            vm.selectedRideTime = minute
                        }
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: settingsLineSheetInputFontSize, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .padding(.vertical, settingsLineSheetInputPaddingVertical)
            .padding(.horizontal, settingsLineSheetInputPaddingHorizontal)
            .background(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
            .overlay(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: settingsLineSheetStrokeLineWidth))
        }
    }
    
    // MARK: - Transfer Settings Section
    private var transferSettingsSection: some View {
        VStack(alignment: .leading, spacing: settingsLineSheetSpacing) {
            
            // MARK: - Transportation Settings
            HStack {
                Text("Next Transfer".localized)
                    .font(.system(size: settingsLineSheetHeadlineFontSize, weight: .semibold))
                    .foregroundColor(Color.primaryColor)
                
                HStack {
                    // Display icon for selected transportation method
                    Image(systemName: getTransportationType(label: vm.selectedTransportation).iconName)
                        .foregroundColor(.black)
                        .frame(width: settingsLineSheetIconSize)

                    Text(getTransportationType(label: vm.selectedTransportation).displayName)
                        .font(.system(size: settingsLineSheetInputFontSize))
                        .foregroundColor(.black)
                    
                    Menu {
                        ForEach(TransportationType.allCases.reversed(), id: \.self) { type in
                            Button(action: {
                                vm.selectedTransportation = type.rawValue
                            }) {
                                HStack {
                                    Image(systemName: type.iconName)
                                        .foregroundColor(.black)
                                        .frame(width: settingsLineSheetIconSize)
                                    Text(type.displayName)
                                        .foregroundColor(.black)
                                        .frame(width: settingsLineSheetIconSize)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: settingsLineSheetInputFontSize, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical, settingsLineSheetInputPaddingVertical)
                .padding(.horizontal, settingsLineSheetInputPaddingHorizontal)
                .background(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                .overlay(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: settingsLineSheetStrokeLineWidth))

                Spacer()
            }

            // MARK: - Transfer Time Settings
            if vm.selectedTransportation != "none" {
                HStack {
                    Text("Transfer Time".localized)
                        .font(.system(size: settingsLineSheetHeadlineFontSize, weight: .semibold))
                        .foregroundColor(Color.primaryColor)
                    
                    HStack {
                        Text("\(vm.selectedTransferTime)" + " min".localized)
                            .font(.system(size: settingsLineSheetInputFontSize))
                            .foregroundColor(.black)
                        
                        Menu {
                            ForEach(0...99, id: \.self) { minute in
                                Button("\(minute)" + " min".localized) {
                                    vm.selectedTransferTime = minute
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: settingsLineSheetInputFontSize, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.vertical, settingsLineSheetInputPaddingVertical)
                    .padding(.horizontal, settingsLineSheetInputPaddingHorizontal)
                    .background(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: settingsLineSheetStrokeLineWidth))
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Data Management Section
    /// Section for updating data and clearing configuration
    private var dataManagementSection: some View {
        HStack {
            Button("Update Data".localized) {
                Task { await vm.refreshAllData() }
            }
            .font(.system(size: settingsLineSheetButtonFontSize))
            .buttonStyle(.borderedProminent)
            .tint(Color.secondary)

            if vm.isLoading { ProgressView() }
            
            if let updated = vm.lastUpdatedDisplay {
                Text("Updated: ".localized + updated)
                    .font(.system(size: settingsLineSheetCaptionFontSize))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            
            // MARK: - Clear Button
            Button(action: {
                // Clear line name
                vm.query = ""
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
                
                // Hide color selection UI
                vm.showColorSelection = false
            }) {
                Text("Clear".localized)
                    .font(.system(size: settingsLineSheetButtonFontSize))
                    .buttonStyle(.borderedProminent)
            }
            .buttonStyle(.borderedProminent)
            .padding(.leading, settingsLineSheetSpacing)
            .tint(.red)
        }
        .padding(.top, settingsLineSheetPadding)
    }
    
    // MARK: - Departure Station Input Section
    /// Section for inputting departure station information
    private var departureStationInputSection: some View {
        HStack {
            Text("Departure Station".localized)
                .font(.system(size: settingsLineSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primaryColor)
            
            TextField("Enter departure station".localized, text: $vm.departureStationInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: settingsLineSheetInputFontSize))
                .padding(.vertical, settingsLineSheetInputPaddingVertical)
                .padding(.horizontal, settingsLineSheetInputPaddingHorizontal)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                .overlay(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: settingsLineSheetStrokeLineWidth))
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
            Text("Arrival Station".localized)
                .font(.system(size: settingsLineSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primaryColor)

            TextField("Enter arrival station".localized, text: $vm.arrivalStationInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: settingsLineSheetInputFontSize))
                .padding(.vertical, settingsLineSheetInputPaddingVertical)
                .padding(.horizontal, settingsLineSheetInputPaddingHorizontal)
                .background(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).fill(Color(.secondarySystemBackground)))
                .overlay(RoundedRectangle(cornerRadius: settingsLineSheetCornerRadius).stroke(Color(.separator), lineWidth: settingsLineSheetStrokeLineWidth))
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
        if let selectedArrivalStation = vm.selectedArrivalStation,
           newValue == selectedArrivalStation.getLocalizedName() {
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
        if let selectedDepartureStation = vm.selectedDepartureStation,
           newValue == selectedDepartureStation.getLocalizedName() {
            vm.arrivalStationInput = ""
            vm.selectedArrivalStation = nil
        } else {
            // Filter suggestions
            vm.filterArrivalStations(newValue)
        }
    }
    
    // MARK: - Query Change Handler
    /// Handles changes in line name query field
    private func handleQueryChange(_ newValue: String) {
        // Ensure focus is maintained when typing
        if !newValue.isEmpty {
            focused = true
        }
        
        // Don't reset station selection if line number is being changed
        if vm.isLineNumberChanging {
            return
        }
        
        // Reset station selection when query changes
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
}

#Preview {
    SettingsLineSheet(goorback: "back1", lineIndex: 0)
        .environment(\.locale, .init(identifier: "ja_JP"))
}

// MARK: - File Summary
// Comprehensive line configuration sheet interface for MyTimeTableMaker app
// Features: ODPT API integration, station search, line customization, data management
