//
//  SettingsLineSheet.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2025/08/12.
//  Sheet view for configuring railway lines and bus routes in settings
//  This view provides functionality to search, select, and configure transportation lines
//  including both predefined railway data from ODPT API and custom line configurations.
//  Features include multi-language support, station search, and line color customization.
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
    
    init(goorback: String, lineIndex: Int) {
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
                    lineHeaderText
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
                    actionButtonsSection
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
        .offset(y: settingsLineSheetDepartureOffset) // Adjust position to match departure station input field
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
        .offset(y: settingsLineSheetArrivalOffset) // Adjust position to match arrival station input field
        .zIndex(100)
    }

    // MARK: - Line Suggestions
    private var lineSuggestionsView: some View {
        // Debug: Check conditions for line suggestions display
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
                        vm.selectedLineColor = line.lineColor ?? "#03DAC5"
                        
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
                .font(.system(size: settingsLineSheetTitleFontSize, weight: .semibold))
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
        // 4-column grid layout for color selection buttons
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: settingsLineSheetGridSpacing) {
            // Iterate through all available custom colors
            ForEach(CustomColor.allCases, id: \.self) { color in
                colorSelectionButton(for: color)
            }
        }.padding(.all, settingsLineSheetGridSpacing)
    }
    
    // MARK: - Color Selection Button
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
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: settingsLineSheetSpacing) {
            // MARK: - Save Button
            Button(action: {
                // Save all data (both predefined and custom lines)
                vm.handleLineSave(dismiss: dismiss)
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.title3)
                    Text("Save".localized)
                        .font(.system(size: settingsLineSheetButtonFontSize, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: settingsLineSheetButtonHeight)
                .background(
                    RoundedRectangle(cornerRadius: settingsLineSheetButtonCornerRadius)
                        .fill(selected == nil && !vm.isCustomLineStationInputComplete() ? .gray : .accentColor)
                )
            }
            .disabled(!vm.isCustomLineStationInputComplete())
            
            // MARK: - Timetable Settings Button
            Button(action: {
                showTimetableSettings = true
            }) {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.title3)
                    Text("Timetable Settings".localized)
                        .font(.system(size: settingsLineSheetButtonFontSize, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: settingsLineSheetButtonHeight)
                .background(
                    RoundedRectangle(cornerRadius: settingsLineSheetButtonCornerRadius)
                        .fill(Color.primaryColor)
                )
            }
            
            // Add space below buttons
            Spacer()
        }
        .padding(.top, settingsLineSheetPadding)
    }
    

    
    // MARK: - Station Header Text
    private var lineHeaderText: some View {
            
        Menu {
            ForEach(vm.availableLineNumbers, id: \.self) { lineNumber in
                Button("\("Line".localized)\(lineNumber)") {
                    vm.selectLineNumber(lineNumber)
                }
            }
        } label: {
            HStack {
                Text("\("Line".localized)\(vm.selectedLineNumber) \("Input".localized)")
                    .font(.system(size: settingsLineSheetTitleFontSize, weight: .bold))
                    .foregroundColor(Color.black)
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.black)
                
                Spacer()
            }
        }
    }

    // MARK: - Line Name Section
    private var lineNameSection: some View {
        VStack(alignment: .leading, spacing: settingsLineSheetSpacing) {
            // MARK: - Line Name Input
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
    
    // MARK: - Station Header Text
    private var stationHeaderText: some View {
        Text("Station Input".localized + "\(vm.hasSelectedLine && vm.hasStations ? ": ".localized + "\(vm.lineStations.first?.name ?? "")" + " to ".localized + "\(vm.lineStations.last?.name ?? "")": "")")
            .font(.system(size: settingsLineSheetTitleFontSize, weight: .bold))
            .foregroundColor(Color.black)
            .padding(.top, settingsLineSheetPadding)
    }
    
    // MARK: - Time Header Text
    private var timeHeaderText: some View {
        Text("Time Settings".localized)
            .font(.system(size: settingsLineSheetTitleFontSize, weight: .bold))
            .foregroundColor(Color.black)
            .padding(.top, settingsLineSheetPadding)
    }
    
    // MARK: - Ride Time Section
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
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.down")
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
                vm.selectedLineColor = "#03DAC5"
                
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
    private var departureStationInputSection: some View {
        HStack {
            Text("Departure Station".localized)
                .font(.system(size: settingsLineSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primaryColor)
            
            departureStationTextField
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.departureStationInput.isEmpty ? .gray : .accentColor)
        }
    }
    
    // MARK: - Departure Station TextField
    private var departureStationTextField: some View {
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
    }
    
    // MARK: - Arrival Station Input Section
    private var arrivalStationInputSection: some View {
        HStack {
            Text("Arrival Station".localized)
                .font(.system(size: settingsLineSheetHeadlineFontSize, weight: .semibold))
                .foregroundColor(.primaryColor)

            arrivalStationTextField
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(vm.arrivalStationInput.isEmpty ? .gray : .accentColor)
        }
    }
    
    // MARK: - Arrival Station TextField
    private var arrivalStationTextField: some View {
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
    }
    
    // MARK: - Departure Station Input Change Handler
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
// This file implements a comprehensive line configuration sheet interface for the MyTimeTableMaker app.
// Key components include:
// - TransportationLine data model with multi-language support
// - ODPT API integration for railway data
// - Local file parsing for custom configurations
// - Advanced search and filtering capabilities
// - Station selection with intelligent suggestions
// - Line color customization
// - Data persistence and management
// - Responsive UI with proper state management
