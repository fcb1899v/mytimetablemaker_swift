//
//  SettingsLineViewModel.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima  on 2025/08/12.
//
//  ViewModel for SettingsLineSheet view that manages railway line configuration.
//  Handles data loading from ODPT API and local JSON files, search functionality,
//  station selection, and user preferences persistence.
//

import SwiftUI
import Combine
import Foundation

// MARK: - ViewModel
// Main view model for the line selection interface
@MainActor
final class SettingsLineSheetViewModel: ObservableObject {
    
    // MARK: - Published Properties
    // UI state properties that trigger view updates when changed
    @Published var operatorInput: String = ""             // Operator search input
    @Published var operatorSuggestions: [String] = []    // Search results for operator suggestions
    @Published var showOperatorSuggestions: Bool = false // Operator suggestions visibility
    @Published var operatorSelected: Bool = false         // Flag to prevent operator suggestions re-display
    @Published var showOperatorSelection: Bool = false   // Operator selection UI visibility state
    @Published var selectedOperatorCode: String? = nil  // Selected operator code for filtering lines
    @Published var isOperatorFieldFocused: Bool = false  // Operator field focus state
    @Published var lineInput: String = ""                // Line search input
    @Published var lineSuggestions: [TransportationLine] = [] // Search results for line suggestions
    @Published var isLoading: Bool = false               // Loading state for update operations
    @Published var lastUpdatedDisplay: String? = nil     // Last update timestamp for display
    @Published var showColorSelection: Bool = false      // Color picker visibility state
    @Published var showStationSelection: Bool = false    // Station selection UI visibility state
    
    // MARK: - Data Properties
    // Station data files for railway lines
    private let stationDataFiles: [String] = LocalDataSource.allCases
        .filter { $0.transportationType == .railway }
        .map { $0.fileName }
    
    // Line and station selection state management
    @Published var selectedLine: TransportationLine?          // Currently selected railway line
    @Published var lineStations: [Station] = []               // Stations available on the selected line (for railway)
    @Published var lineBusStops: [BusStop] = []               // Bus stops available on the selected line (for bus)
    @Published var lineStops: [TransportationStop] = []       // Stops available on the selected line (unified)
    @Published var selectedDepartureStop: TransportationStop? // User-selected departure stop
    @Published var selectedArrivalStop: TransportationStop?   // User-selected arrival stop
    
    // User input fields for data entry
    @Published var departureStopInput: String = ""         // Departure station search input text
    @Published var arrivalStopInput: String = ""           // Arrival station search input text
    @Published var selectedRideTime: Int = 0                  // Selected ride time in minutes (initial value: 0)
    var isAllNotEmpty: Bool { 
        !departureStopInput.isEmpty && 
        !arrivalStopInput.isEmpty && 
        !lineInput.isEmpty && 
        selectedRideTime > 0 && 
        (selectedTransportation == "none" || selectedTransferTime > 0)
    }
    
    // Suggestion and focus state management
    @Published var showDepartureSuggestions: Bool = false     // Departure stop suggestions visibility
    @Published var departureSuggestions: [TransportationStop] = [] // Departure stop search results
    @Published var isDepartureFieldFocused: Bool = false      // Departure field focus state
    @Published var showArrivalSuggestions: Bool = false       // Arrival stop suggestions visibility
    @Published var arrivalSuggestions: [TransportationStop] = []   // Arrival stop search results
    @Published var isArrivalFieldFocused: Bool = false        // Arrival field focus state
    @Published var showLineSuggestions: Bool = false          // Line suggestions visibility
    @Published var isLineFieldFocused: Bool = false          // Line field focus state
    
    // Selection flags to prevent re-display of suggestions after selection
    @Published var departureStopSelected: Bool = false     // Flag to prevent departure suggestions re-display
    @Published var arrivalStopSelected: Bool = false       // Flag to prevent arrival suggestions re-display
    @Published var lineSelected: Bool = false                 // Flag to prevent line suggestions re-display
    var isAllSelected: Bool { lineSelected && departureStopSelected && arrivalStopSelected }
    
    // Line configuration and customization
    @Published var selectedLineColor: String? = nil           // Selected line color hex value for display
    @Published var selectedTransportationKind: TransportationLine.Kind = .railway  // Selected transportation kind (default: railway)
    @Published var selectedTransferTime: Int = 0              // Acceptable transfer time in minutes (initial value: 0)
    @Published var selectedTransportation: String = "none"    // Selected transportation method (default: none)
    @Published var selectedLineNumber: Int = 1                // Currently selected line number (1-3)
    @Published var availableLineNumbers: [Int] = [1]          // Available line numbers based on changeLine
    @Published var isLineNumberChanging: Bool = false         // Flag to indicate line number is being changed
    @Published var isGoorBackChanging: Bool = false           // Flag to indicate direction is being changed
    @Published var selectedGoorback: String = "back1"         // Currently selected route direction
    
    // Computed properties for UI state checking
    var hasSelectedLine: Bool { selectedLine != nil }
    var hasStops: Bool { !lineStops.isEmpty }
    
    // Get localized display names for direction options
    var goorbackDisplayNames: [String: String] {
        goorbackDisplayNamesRaw.mapValues { $0.localized }
    }
    
    // Private properties for internal data storage and state management
    private var all: [TransportationLine] = []                // All available railway lines from shared service
    private var allData: [TransportationLine] = []            // Cached railway data for performance
    var railwayLines: [TransportationLine] = []               // Cached railway lines for performance
    var busLines: [TransportationLine] = []                   // Cached bus lines for performance
    private var cancellables = Set<AnyCancellable>()          // Combine cancellables for proper cleanup
    var nameCounts: [String: Int] = [:]                       // Name frequency tracking for duplicate display
    
    // Configuration properties for initialization
    private let goorback: String                              // Direction identifier (go/back) for route context
    private let lineIndex: Int                                // Line index for UserDefaults key generation
    private let sharedDataManager = SharedDataManager.shared  // Shared data manager for app-wide data management
    
    // MARK: - Initialization
    // Initialize view model with direction and line index
    init(goorback: String = "back1", lineIndex: Int = 0) {
        self.goorback = goorback
        self.lineIndex = lineIndex
        self.selectedGoorback = goorback
        
        // Setup search lineInput debouncing for improved performance
        $lineInput
            .removeDuplicates()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] q in Task { await self?.filter(q) } }
            .store(in: &cancellables)
        
        // Monitor changeLine changes to update available line numbers
        NotificationCenter.default.publisher(for: NSNotification.Name("ChangeLineUpdated"))
            .sink { [weak self] _ in self?.updateAvailableLineNumbers(shouldPreserveLineNumber: false) }
            .store(in: &cancellables)
        
        selectedLineNumber = lineIndex + 1
        
        // Initialize transfer count if not set
        if UserDefaults.standard.object(forKey: selectedGoorback.changeLineKey) == nil {
            UserDefaults.standard.set(0, forKey: selectedGoorback.changeLineKey)
        }
        
        updateAvailableLineNumbers(shouldPreserveLineNumber: false)
        loadSettingsForSelectedLine()
        
        // Load data from shared service in background
        Task.detached(priority: .userInitiated) { [weak self] in
            await self?.loadFromSharedService()
        }
    }
    
    // MARK: - Direction Selection Management
    // Handle goorback selection changes and reset related state
    func selectGoorback(_ newGoorback: String) {
        // Early return if same value to avoid unnecessary processing
        if selectedGoorback == newGoorback { return }
        
        // Set flag to indicate route is changing
        isGoorBackChanging = true
        
        // Update selectedGoorback and process changes
        selectedGoorback = newGoorback
        
        // Update available line numbers based on new direction
        // Preserve current line number when switching directions
        updateAvailableLineNumbers(shouldPreserveLineNumber: true)
        
        // Load settings for the selected line after line numbers are updated
        loadSettingsForSelectedLine()
        
        // Check if saved line exists in loaded data and restore it asynchronously
        Task {
            await checkSavedLineInData()

            // Hide all suggestions during direction change to prevent UI conflicts
            showOperatorSuggestions = false
            operatorSuggestions = []
            showDepartureSuggestions = false
            showArrivalSuggestions = false
            showLineSuggestions = false
            isDepartureFieldFocused = false
            isArrivalFieldFocused = false
            lineSuggestions = []
        }

        // Reset flag after processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isGoorBackChanging = false
        }
    }
    
    // Reset all selections when direction changes
    // Clear all user selections to start fresh
    private func resetSelections() {
        operatorInput = ""
        operatorSuggestions = []
        showOperatorSuggestions = false
        operatorSelected = false
        showOperatorSelection = false
        selectedOperatorCode = nil
        lineInput = ""
        selectedLine = nil
        lineStops = []
        selectedDepartureStop = nil
        selectedArrivalStop = nil
        departureStopInput = ""
        arrivalStopInput = ""
        selectedRideTime = 0
        selectedLineColor = "#03DAC5"
        selectedTransportationKind = .railway
        showColorSelection = false
        showDepartureSuggestions = false
        departureSuggestions = []
        showArrivalSuggestions = false
        arrivalSuggestions = []
        isDepartureFieldFocused = false
        isArrivalFieldFocused = false
        departureStopSelected = false
        arrivalStopSelected = false
        lineSelected = false
    }
    
    
    // MARK: - Data Management
    // Load data from shared manager for better performance
    // Only load data for the currently selected transportation kind to improve efficiency
    func loadFromSharedService() async {
        // Load only the selected kind's data to improve performance
        let sharedLines = await sharedDataManager.getLines(for: selectedTransportationKind)
        
        await MainActor.run {
            self.all = sharedLines
            self.allData = self.all
            // Pre-filter and cache railway and bus lines for performance
            self.railwayLines = sharedLines.filter { $0.kind == .railway }
            self.busLines = sharedLines.filter { $0.kind == .bus }
        }
        
        await filter(lineInput)
        
        // Check if saved line exists in loaded data and restore it
        await checkSavedLineInData()
    }
    
    // Perform manual data update for both railway and bus operators
    // Refreshes all transportation data from ODPT API
    func performDataUpdate() async {
        await sharedDataManager.performRailwayUpdate()
        await sharedDataManager.performBusUpdate()
        
        // Reload only the selected kind's data after update
        let updatedLines = await sharedDataManager.getLines(for: selectedTransportationKind)
        
        await MainActor.run {
            self.all = updatedLines
            self.allData = self.all
            self.railwayLines = updatedLines.filter { $0.kind == .railway }
            self.busLines = updatedLines.filter { $0.kind == .bus }
            self.isLoading = sharedDataManager.isLoading
            self.lastUpdatedDisplay = sharedDataManager.lastUpdated?.formatted()
        }
    }
    
    
    // MARK: - Search and Filtering
    // Filter railway lines based on search lineInput with performance optimizations
    func filter(_ q: String) async {
        let t = q.normalizedForSearch
        
        // Don't show suggestions if line number or direction is being changed or line is already selected
        if isLineNumberChanging || isGoorBackChanging || lineSelected { return }
        
        // Don't show line suggestions if operator is not selected from dropdown
        // User must select an operator from dropdown before searching for lines
        guard let operatorCode = selectedOperatorCode, operatorSelected else {
            lineSuggestions = []
            nameCounts = [:]
            showLineSuggestions = false
            return
        }
        
        // Filter by transportation kind (.railway or .bus)
        // Always filter by selected transportation kind regardless of operator selection
        var searchData = selectedTransportationKind == .railway ? railwayLines: busLines
        
        // Filter by selected operator
        searchData = searchData.filter { $0.operatorCode == operatorCode }
        
        // If query is empty, don't show suggestions
        guard !t.isEmpty else {
            lineSuggestions = []
            nameCounts = [:]
            showLineSuggestions = false
            return
        }
        
        // Search key generation helper for different transportation types
        let key: (TransportationLine) -> String = { p in
            if p.kind == .bus {
                return p.name.normalizedForSearch
            }
            if let railwayTitle = p.railwayTitle {
                return railwayTitle.getLocalizedName(fallbackTo: p.name).normalizedForSearch
            }
            return p.name.normalizedForSearch
        }
        
        // Simplified search for bus data to improve performance
        if selectedTransportationKind == .bus {
            let starts = searchData.filter { lineDisplayName(for: $0).normalizedForSearch.hasPrefix(t) }
            let contains = searchData.filter { !lineDisplayName(for: $0).normalizedForSearch.hasPrefix(t) && lineDisplayName(for: $0).normalizedForSearch.contains(t) }
            let allResults = starts + contains
            
            // Remove duplicates by displayName to show only unique direction names
            let displayNames = allResults.map { lineDisplayName(for: $0) }
            let uniqueDisplayNames = Array(Set(displayNames))
            let uniqueResults = uniqueDisplayNames.compactMap { uniqueDisplayName in
                allResults.first { lineDisplayName(for: $0) == uniqueDisplayName }
            }
            
            lineSuggestions = Array(uniqueResults.prefix(10))
            showLineSuggestions = !lineSuggestions.isEmpty
            nameCounts = [:]
            return
        }
        
        // Railway line search with priority ordering
        let matchesQuery = { (line: TransportationLine) in
            let searchKey = key(line)
            return searchKey.hasPrefix(t) || searchKey.contains(t)
        }
        
        let starts = searchData.filter { key($0).hasPrefix(t) }
        let contains = searchData.filter { !key($0).hasPrefix(t) && key($0).contains(t) }
        let hiraganaMatches = searchData.filter { !key($0).hasPrefix(t) && !key($0).contains(t) && matchesQuery($0) }
        
        let allResults = starts + contains + hiraganaMatches
        // Remove duplicates for railway lines to ensure unique line representation
        let uniqueResults = removeDuplicates(from: allResults)
        lineSuggestions = Array(uniqueResults.prefix(100))
        
        // Show suggestions based on results count
        if lineSuggestions.count == 1 {
            let singleLine = lineSuggestions[0]
            showLineSuggestions = lineDisplayName(for: singleLine).normalizedForSearch != q.normalizedForSearch
        } else {
            showLineSuggestions = !lineSuggestions.isEmpty
        }
        
        nameCounts = Dictionary(grouping: lineSuggestions) { lineDisplayName(for: $0) }
            .mapValues { $0.count }
    }
    
    // MARK: - Operator Search and Filtering
    // Filter operators based on search input and transportation kind (railway or bus)
    func filterOperators(_ q: String) async {
        let t = q.normalizedForSearch
        
        // Don't show suggestions if line number or direction is being changed or operator is already selected
        if isLineNumberChanging || isGoorBackChanging || operatorSelected { return }
        
        // Get available operators filtered by transportation kind (railway or bus)
        // Only include operators that match the selected transportation kind
        let availableOperators = LocalDataSource.allCases
            .filter { dataSource in
                // Filter by transportation type: railway or bus
                dataSource.transportationType == selectedTransportationKind
            }
            .compactMap { dataSource -> String? in
                // Only include operators with valid operator codes
                // Use operatorDisplayName directly to ensure correct name for each transportation type
                guard dataSource.operatorCode != nil else { return nil }
                return dataSource.operatorDisplayName
            }
        
        // Filter operators based on search query
        let filtered: [String]
        if t.isEmpty {
            // If query is empty, show all operators when field is focused
            if isOperatorFieldFocused {
                filtered = availableOperators
            } else {
                operatorSuggestions = []
                showOperatorSuggestions = false
                return
            }
        } else {
            // If query is not empty, filter operators based on search input
            // Filter by prefix match or contains match
            filtered = availableOperators.filter { operatorName in
                operatorName.normalizedForSearch.hasPrefix(t) || operatorName.normalizedForSearch.contains(t)
            }
        }
        
        // Sort results: starts with query first, then contains (or all sorted if query is empty)
        let sortedResults: [String]
        if t.isEmpty {
            sortedResults = filtered.sorted()
        } else {
            // Prioritize operators that start with the query
            let starts = filtered.filter { $0.normalizedForSearch.hasPrefix(t) }
            let contains = filtered.filter { !$0.normalizedForSearch.hasPrefix(t) }
            sortedResults = starts + contains
        }
        
        operatorSuggestions = Array(sortedResults.prefix(20))
        showOperatorSuggestions = !operatorSuggestions.isEmpty
    }
    
    // MARK: - Data Processing
    /// Remove duplicates based on operator and line name combination
    /// Ensures unique line representation in the UI
    func removeDuplicates(from lines: [TransportationLine]) -> [TransportationLine] {
        var seen = Set<String>()
        var result: [TransportationLine] = []
        
        for line in lines {
            // Create unique key combining operator code and display name
            let key = "\(line.operatorCode ?? "")_\(lineDisplayName(for: line))"
            if !seen.contains(key) {
                seen.insert(key)
                result.append(line)
            }
        }
        
        return result
    }
    
    // MARK: - Station Search and Filtering
    // Filter candidate departure stops based on search lineInput
    func filterDepartureStops(_ lineInput: String) {
        let filtered = filterStops(lineInput, excludeStop: selectedArrivalStop)
        departureSuggestions = filtered
        showDepartureSuggestions = isDepartureFieldFocused && !filtered.isEmpty && !departureStopSelected
    }
    
    // Filter candidate arrival stops based on search lineInput
    func filterArrivalStops(_ lineInput: String) {
        let filtered = filterStops(lineInput, excludeStop: selectedDepartureStop)
        arrivalSuggestions = filtered
        showArrivalSuggestions = isArrivalFieldFocused && !filtered.isEmpty && !arrivalStopSelected
    }
    
    // Unified filtering logic for both railway stations and bus stops
    private func filterStops(_ lineInput: String, excludeStop: TransportationStop?) -> [TransportationStop] {
        guard !lineInput.isEmpty else { return [] }
        
        return lineStops.filter { stop in
            // Exclude the stop if it's the same as the excludeStop
            if let excludeStop = excludeStop, stop.id == excludeStop.id {
                return false
            }
            
            // Filter by name
            return stop.displayName.localizedCaseInsensitiveContains(lineInput)
        }
    }
    
    // Get stops information for the selected line (unified for both railway and bus)
    func getStopsForSelectedLine() -> [TransportationStop] {
        guard let selectedLine = selectedLine else { 
            return [] 
        }
        
        if selectedLine.kind == .bus {
            // Handle bus routes - use lineBusStops if available, otherwise fallback to busstopPoleOrder
            if !lineBusStops.isEmpty {
                let stops = lineBusStops.map { busStop -> TransportationStop in
                    // Check if we need to fetch Japanese name from API
                    let hasJapaneseInNote = (busStop.note?.contains(where: { $0.isJapanese }) ?? false)
                    
                    if (!hasJapaneseInNote || busStop.note?.isEmpty ?? true) && !(busStop.busstopPole?.isEmpty ?? true) {
                        // Japanese name will be fetched later in selectLine
                        
                        // Create TransportationStop with Japanese name from title if available
                        let transportationStop = TransportationStop(
                            kind: .bus,
                            name: busStop.title?.ja ?? busStop.name,
                            code: busStop.code,
                            index: busStop.index,
                            lineCode: busStop.lineCode,
                            title: busStop.title,
                            note: busStop.note,
                            busstopPole: busStop.busstopPole
                        )
                        return transportationStop
                    } else {
                        // Use existing TransportationStop conversion
                        return TransportationStop(from: busStop)
                    }
                }
                return stops
            } else if let busstopPoleOrder = selectedLine.busstopPoleOrder {
                let stops = busstopPoleOrder.map { busStop -> TransportationStop in
                    let transportationStop = TransportationStop(from: busStop)
                    
                    // Check if note is empty or doesn't contain Japanese characters
                    let hasJapaneseInNote = (busStop.note?.contains(where: { $0.isJapanese }) ?? false)
                    if (!hasJapaneseInNote || busStop.note?.isEmpty ?? true) && !(busStop.busstopPole?.isEmpty ?? true) {
                        // Japanese name will be fetched later in selectLine
                    }
                    
                    return transportationStop
                }
                return stops
            } else {
                // Fallback: Try to fetch bus stops from BusstopPole API if busstopPoleOrder is not available
                Task {
                    await fetchBusStopsFromAPI(for: selectedLine)
                }
            }
        } else {
            // Handle railway lines - get stations from data files
            let stations = stationDataFiles.lazy.compactMap { [self] filename in
                self.loadLocalData(for: filename).flatMap { [self] data in
                    self.parseStationsByLineCode(data, lineCode: selectedLine.code, isBus: false)
                }
            }.first ?? []
            
            return stations
        }
        
        return []
    }
    
    
    // MARK: - State Management
    // Reset station selection and clear all related state
    func resetStationSelection() {
        selectedLine = nil
        showStationSelection = false
        lineStations = []
        selectedDepartureStop = nil
        selectedArrivalStop = nil
        selectedRideTime = 0
        showDepartureSuggestions = false
        departureSuggestions = []
        showArrivalSuggestions = false
        arrivalSuggestions = []
        isDepartureFieldFocused = false
        isArrivalFieldFocused = false
    }
    
    // Update all line information at once
    // Synchronize UI display with current model state
    func updateDisplay() {
        if let line = selectedLine {
            lineInput = lineDisplayName(for: line)
        }
        
        if let line = selectedLine, let lineColor = line.lineColor {
            selectedLineColor = lineColor
        }
        
        if let departureStop = selectedDepartureStop {
            departureStopInput = departureStop.title?.getLocalizedName(fallbackTo: departureStop.name) ?? departureStop.name
        }
        
        if let arrivalStop = selectedArrivalStop {
            arrivalStopInput = arrivalStop.title?.getLocalizedName(fallbackTo: arrivalStop.name) ?? arrivalStop.name
        }
    }
    
    // Set line color without saving to UserDefaults
    // Update selected color for display only (saved when user explicitly saves)
    func setLineColor(_ color: String) {
        selectedLineColor = color
        showColorSelection = false
    }
    
    // Common save processing for all line types
    // Saves all current settings to persistent storage
    func handleLineSave() async {
        await saveAllDataToUserDefaults()
        
        // Save cache for the selected transportation kind when user saves
        await sharedDataManager.saveCacheForKind(selectedTransportationKind)
        
        updateDisplay()
        NotificationCenter.default.post(name: NSNotification.Name("SettingsLineUpdated"), object: nil)
    }
    
    // MARK: - Data Validation
    // Check if line read from UserDefaults exists in current data
    func checkSavedLineInData() async {
        // Wait for data loading to complete before validation
        while all.isEmpty {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        
        // Always try to restore station information, even if lineInput is empty
        // This ensures station data is properly restored when switching routes
        if !lineInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Try to find and restore saved line if lineInput is not empty
            if let foundLine = findSavedLineInData() {
                await MainActor.run {
                    selectedLine = foundLine
                    showStationSelection = true
                    lineSelected = true
                    
                    // Set up line stops (bus stops, stations, etc.)
                    setupLineStops(for: foundLine)
                    
                    // Don't show color selection for saved lines - user can manually change color if needed
                    showColorSelection = false
                    
                    // Update transportation kind to match found line
                    selectedTransportationKind = foundLine.kind
                }
            } else {
                // Keep user input even if saved line not found in current data
                await MainActor.run {
                    // Don't clear lineInput - preserve user's saved line name
                    selectedLine = nil
                    lineStations = []
                    showStationSelection = false
                    lineSelected = false
                }
            }
        }
        
        // Always load station settings regardless of line status
        // Station information is independent of line information
        await MainActor.run {
            loadStationSettings()
        }
        
        // Station information is now loaded directly from UserDefaults
        // No need for complex station object restoration
    }
    
    // Helper method to find saved line in current data
    // First tries to find by line code if available, then falls back to line name
    private func findSavedLineInData() -> TransportationLine? {
        let currentLineIndex = selectedLineNumber - 1
        let lineCodeKey = selectedGoorback.lineCodeKey(currentLineIndex)
        
        // Try to find by line code first (more reliable)
        // Compare with lineCode property (short code) or extract from code property
        if let savedLineCode = UserDefaults.standard.string(forKey: lineCodeKey), !savedLineCode.isEmpty {
            if let foundLine = all.first(where: { line in
                // Compare with lineCode property if available
                if let lineCode = line.lineCode, lineCode == savedLineCode {
                    return true
                }
                // Otherwise, extract from code and compare
                let codeParts = line.code.components(separatedBy: ".")
                let extractedCode = codeParts.last ?? line.code
                return extractedCode == savedLineCode
            }) {
                return foundLine
            }
        }
        
        // Fall back to finding by line name
        return all.first(where: { line in
            if line.kind == .bus {
                return line.name == lineInput ||
                line.railwayTitle?.getLocalizedName() == lineInput ||
                line.busRouteEnglishName == lineInput
            } else {
                return line.name == lineInput || line.railwayTitle?.getLocalizedName() == lineInput
            }
        })
    }
    
    // Helper method to set up line stops after finding a line
    // Handles bus stops and updates lineStops for station selection
    private func setupLineStops(for foundLine: TransportationLine) {
        // Set bus stops for bus routes
        if foundLine.kind == .bus {
            if let busstopPoleOrder = foundLine.busstopPoleOrder {
                self.lineBusStops = busstopPoleOrder
                
                let busStops: [Station] = busstopPoleOrder.compactMap { busStop -> Station? in
                    guard !busStop.name.isEmpty else { return nil }
                    return Station(
                        name: busStop.name,
                        code: busStop.code,
                        index: busStop.index,
                        lineCode: foundLine.code,
                        title: busStop.title
                    )
                }
                self.lineStations = busStops
            } else {
                self.lineBusStops = []
                self.lineStations = []
            }
        } else {
            self.lineBusStops = []
        }
        self.lineStops = getStopsForSelectedLine()
    }
    
    // MARK: - Data Persistence
    // Save all information when save button is pressed
    func saveAllDataToUserDefaults() async {
        let lineIndex = selectedLineNumber - 1
        
        // Save line name
        if !lineInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lineNameKey = selectedGoorback.lineNameKey(lineIndex)
            UserDefaults.standard.set(lineInput, forKey: lineNameKey)
        }
        
        // Save line code for Firestore synchronization
        // Always save lineCode if selectedLine is available, regardless of lineInput
        // Use lineCode property (odpt:lineCode) if available, otherwise extract from code
        let lineCodeKey = selectedGoorback.lineCodeKey(lineIndex)
        if let selectedLine = selectedLine {
            // Use lineCode property (short code like "JY", "TT") if available
            // Otherwise, extract short name from code (e.g., "ChuoRapid" from "odpt.Railway:JR-East.ChuoRapid")
            let codeToSave: String
            if let lineCode = selectedLine.lineCode, !lineCode.isEmpty {
                codeToSave = lineCode
            } else {
                // Extract last component from code as fallback
                let codeParts = selectedLine.code.components(separatedBy: ".")
                codeToSave = codeParts.last ?? selectedLine.code
            }
            UserDefaults.standard.set(codeToSave, forKey: lineCodeKey)
        } else {
            // Preserve existing lineCode if selectedLine is nil (e.g., during auto-generation)
            // Only preserve if lineCode already exists and is not empty
            let existingLineCode = UserDefaults.standard.string(forKey: lineCodeKey) ?? ""
            if existingLineCode.isEmpty {
                // Try to find lineCode from saved line name using reverse lookup
                if let foundLine = findSavedLineInData() {
                    // Use lineCode property if available, otherwise extract from code
                    let codeToSave: String
                    if let lineCode = foundLine.lineCode, !lineCode.isEmpty {
                        codeToSave = lineCode
                    } else {
                        let codeParts = foundLine.code.components(separatedBy: ".")
                        codeToSave = codeParts.last ?? foundLine.code
                    }
                    UserDefaults.standard.set(codeToSave, forKey: lineCodeKey)
                }
            }
        }
        
        // Save line color
        if let lineColor = selectedLineColor, !lineColor.isEmpty {
            let lineColorKey = selectedGoorback.lineColorKey(lineIndex)
            UserDefaults.standard.set(lineColor, forKey: lineColorKey)
        }
        
        // Save operator name (consistent with other fields like line name, station names)
        if !operatorInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let operatorNameKey = selectedGoorback.operatorNameKey(lineIndex)
            UserDefaults.standard.set(operatorInput, forKey: operatorNameKey)
        }
        
        // Save transportation kind
        let lineKindKey = selectedGoorback.lineKindKey(lineIndex)
        UserDefaults.standard.set(selectedTransportationKind.rawValue, forKey: lineKindKey)
                
        // Update selectedLine's lineDirection
        if var updatedLine = selectedLine {
            
            updatedLine = TransportationLine(
                kind: updatedLine.kind,
                name: updatedLine.name,
                code: updatedLine.code,
                operatorCode: updatedLine.operatorCode,
                lineColor: updatedLine.lineColor,
                startStation: updatedLine.startStation,
                endStation: updatedLine.endStation,
                destinationStation: updatedLine.destinationStation,
                railwayTitle: updatedLine.railwayTitle,
                lineCode: updatedLine.lineCode,
                lineDirection: updatedLine.lineDirection, // Keep existing direction
                ascendingRailDirection: updatedLine.ascendingRailDirection,
                descendingRailDirection: updatedLine.descendingRailDirection,
                busRoute: updatedLine.busRoute,
                pattern: updatedLine.pattern,
                busDirection: updatedLine.busDirection,
                busstopPoleOrder: updatedLine.busstopPoleOrder,
                title: updatedLine.title
            )
            selectedLine = updatedLine
        }
        
        // Save departure stop information
        if !departureStopInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let departureKey = selectedGoorback.departStationKey(lineIndex)
            UserDefaults.standard.set(departureStopInput, forKey: departureKey)
            
            // Save departure stop ODPT code
            if let departureStop = selectedDepartureStop,
               let stationCode = departureStop.code {
                let departureCodeKey = selectedGoorback.departStationCodeKey(lineIndex)
                UserDefaults.standard.set(stationCode, forKey: departureCodeKey)
            }
            
            // Save departure stop lineCode if available
            if let departureStop = selectedDepartureStop,
               let stationLineCode = departureStop.lineCode {
                let departureLineCodeKey = "\(selectedGoorback.departStationCodeKey(lineIndex))_lineCode"
                UserDefaults.standard.set(stationLineCode, forKey: departureLineCodeKey)
            }
            
        }
        
        // Save arrival stop information
        if !arrivalStopInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let arrivalKey = selectedGoorback.arriveStationKey(lineIndex)
            UserDefaults.standard.set(arrivalStopInput, forKey: arrivalKey)
            
            // Save arrival stop ODPT code
            if let arrivalStop = selectedArrivalStop,
               let stationCode = arrivalStop.code {
                let arrivalCodeKey = selectedGoorback.arriveStationCodeKey(lineIndex)
                UserDefaults.standard.set(stationCode, forKey: arrivalCodeKey)
            }
            
            // Save arrival stop lineCode if available
            if let arrivalStop = selectedArrivalStop,
               let stationLineCode = arrivalStop.lineCode {
                let arrivalLineCodeKey = "\(selectedGoorback.arriveStationCodeKey(lineIndex))_lineCode"
                UserDefaults.standard.set(stationLineCode, forKey: arrivalLineCodeKey)
            }
            
        }
        
        // Save ride time
        let rideTimeKey = selectedGoorback.rideTimeKey(lineIndex)
        UserDefaults.standard.set(selectedRideTime, forKey: rideTimeKey)
        
        // Save transfer settings and calculate transfer count
        let changeLineKey = selectedGoorback.changeLineKey
        let transportationKey = selectedGoorback.transportationKey(lineIndex + 2)
        let currentChangeLine = UserDefaults.standard.integer(forKey: changeLineKey)
        let currentTransportation = UserDefaults.standard.string(forKey: transportationKey)
        
        if currentTransportation != "none" && selectedTransportation == "none" {
            let newChangeLine = lineIndex
            UserDefaults.standard.set(newChangeLine, forKey: changeLineKey)
        } else if currentTransportation == "none" && selectedTransportation != "none" {
            let newChangeLine = min(2, currentChangeLine + 1)
            UserDefaults.standard.set(newChangeLine, forKey: changeLineKey)
        }
        
        UserDefaults.standard.set(selectedTransportation, forKey: transportationKey)
        
        let transferTimeKey = selectedGoorback.transferTimeKey(lineIndex + 2)
        UserDefaults.standard.set(selectedTransferTime, forKey: transferTimeKey)
        
        // Enable direction 2 display when saving data for direction 2
        if selectedGoorback == "back2" || selectedGoorback == "go2" {
            let route2DisplayKey = selectedGoorback.isShowRoute2Key
            UserDefaults.standard.set(true, forKey: route2DisplayKey)
        }
    }
    
    // Load station settings from UserDefaults
    private func loadStationSettings() {
        let currentLineIndex = selectedLineNumber - 1
        
        let departureKey = selectedGoorback.departStationKey(currentLineIndex)
        if let savedDeparture = UserDefaults.standard.string(forKey: departureKey) {
            self.departureStopInput = savedDeparture
        } else {
            self.departureStopInput = ""
        }
        
        let arrivalKey = selectedGoorback.arriveStationKey(currentLineIndex)
        if let savedArrival = UserDefaults.standard.string(forKey: arrivalKey) {
            self.arrivalStopInput = savedArrival
        } else {
            self.arrivalStopInput = ""
        }
    }
    
    // MARK: - Line Selection Management
    // Update available line numbers with option to preserve current line number
    private func updateAvailableLineNumbers(shouldPreserveLineNumber: Bool) {
        let changeLineValue = UserDefaults.standard.integer(forKey: selectedGoorback.changeLineKey)
        
        availableLineNumbers = Array(1...min(changeLineValue + 1, 3))
        
        // Reset transportation settings for lines beyond current transfer count
        for i in (changeLineValue + 2)...4 {
            let transportationKey = selectedGoorback.transportationKey(i)
            UserDefaults.standard.set("none", forKey: transportationKey)
        }
        
        // Only change selectedLineNumber if not preserving it (e.g., during initialization or notification)
        if !shouldPreserveLineNumber && selectedLineNumber == 1 && lineIndex > 0 {
            selectedLineNumber = min(lineIndex + 1, availableLineNumbers.last ?? 1)
        }
    }
    
    // Handle line number selection and update lineIndex accordingly
    func selectLineNumber(_ lineNumber: Int) {
        isLineNumberChanging = true
        
        // Hide all suggestions during line number change
        showDepartureSuggestions = false
        showArrivalSuggestions = false
        showLineSuggestions = false
        isDepartureFieldFocused = false
        isArrivalFieldFocused = false
        lineSuggestions = []
        
        selectedLineNumber = lineNumber
        
        loadSettingsForSelectedLine()
        
        // Check if saved line exists in loaded data and restore it (same as initialization)
        Task {
            await checkSavedLineInData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isLineNumberChanging = false
        }
    }
    
    // Load settings for the currently selected line number
    private func loadSettingsForSelectedLine() {
        let currentLineIndex = selectedLineNumber - 1
        
        // Load transportation kind first (needed for operator name restoration)
        let lineKindKey = selectedGoorback.lineKindKey(currentLineIndex)
        if let savedKindString = UserDefaults.standard.string(forKey: lineKindKey) {
            self.selectedTransportationKind = TransportationLine.Kind(rawValue: savedKindString) ?? .railway
        } else {
            self.selectedTransportationKind = .railway
        }
        
        // Load operator name (consistent with other fields like line name, station names)
        let operatorNameKey = selectedGoorback.operatorNameKey(currentLineIndex)
        if let savedOperatorName = UserDefaults.standard.string(forKey: operatorNameKey) {
            self.operatorInput = savedOperatorName
            
            // Restore operator code from operator name for filtering
            if let dataSource = LocalDataSource.allCases.first(where: {
                $0.transportationType == selectedTransportationKind &&
                $0.operatorDisplayName == savedOperatorName
            }) {
                self.selectedOperatorCode = dataSource.operatorCode
                self.operatorSelected = true
            } else {
                self.selectedOperatorCode = nil
                self.operatorSelected = false
            }
        } else {
            self.operatorInput = ""
            self.selectedOperatorCode = nil
            self.operatorSelected = false
        }
        
        // Load line name and restore line object from line name for filtering
        let lineNameKey = selectedGoorback.lineNameKey(currentLineIndex)
        if let savedLineName = UserDefaults.standard.string(forKey: lineNameKey) {
            self.lineInput = savedLineName
            
            // Restore line object from line name if data is available
            if !all.isEmpty {
                if let foundLine = findSavedLineInData() {
                    self.selectedLine = foundLine
                    self.lineSelected = true
                    
                    // Set up line stops (bus stops, stations, etc.)
                    setupLineStops(for: foundLine)
                } else {
                    self.selectedLine = nil
                    self.lineStations = []
                    self.lineBusStops = []
                    self.lineStops = []
                    self.lineSelected = false
                }
            }
        } else {
            self.lineInput = ""
            self.selectedLine = nil
            self.lineStations = []
            self.lineBusStops = []
            self.lineStops = []
            self.lineSelected = false
        }
                
        // Load line color
        let colorKey = selectedGoorback.lineColorKey(currentLineIndex)
        if let savedColor = UserDefaults.standard.string(forKey: colorKey) {
            self.selectedLineColor = savedColor
        } else {
            self.selectedLineColor = nil
        }

        // Load departure station name and restore station object from station name
        let departureKey = selectedGoorback.departStationKey(currentLineIndex)
        if let savedDeparture = UserDefaults.standard.string(forKey: departureKey) {
            self.departureStopInput = savedDeparture
            
            // Restore departure station object from station name if line stops are available
            if !self.lineStops.isEmpty {
                if let foundStop = self.lineStops.first(where: { stop in
                    stop.name == savedDeparture ||
                    stop.title?.ja == savedDeparture ||
                    stop.title?.en == savedDeparture
                }) {
                    self.selectedDepartureStop = foundStop
                } else {
                    self.selectedDepartureStop = nil
                }
            } else {
                self.selectedDepartureStop = nil
            }
        } else {
            self.departureStopInput = ""
            self.selectedDepartureStop = nil
        }
        
        // Load arrival station name and restore station object from station name
        let arrivalKey = selectedGoorback.arriveStationKey(currentLineIndex)
        if let savedArrival = UserDefaults.standard.string(forKey: arrivalKey) {
            self.arrivalStopInput = savedArrival
            
            // Restore arrival station object from station name if line stops are available
            if !self.lineStops.isEmpty {
                if let foundStop = self.lineStops.first(where: { stop in
                    stop.name == savedArrival ||
                    stop.title?.ja == savedArrival ||
                    stop.title?.en == savedArrival
                }) {
                    self.selectedArrivalStop = foundStop
                } else {
                    self.selectedArrivalStop = nil
                }
            } else {
                self.selectedArrivalStop = nil
            }
        } else {
            self.arrivalStopInput = ""
            self.selectedArrivalStop = nil
        }
        
        let rideTimeKey = selectedGoorback.rideTimeKey(currentLineIndex)
        let savedRideTime = UserDefaults.standard.integer(forKey: rideTimeKey)
        // Use saved value or default to 0 if not set
        self.selectedRideTime = savedRideTime > 0 ? savedRideTime : 0
        
        if selectedLineNumber < 3 {
            let transportationKey = selectedGoorback.transportationKey(currentLineIndex + 2)
            if let savedTransportation = UserDefaults.standard.string(forKey: transportationKey), !savedTransportation.isEmpty {
                self.selectedTransportation = savedTransportation
            } else {
                self.selectedTransportation = "none"
            }
            
            let transferTimeKey = selectedGoorback.transferTimeKey(currentLineIndex + 2)
            let savedTransferTime = UserDefaults.standard.integer(forKey: transferTimeKey)
            if savedTransferTime > 0 {
                self.selectedTransferTime = savedTransferTime
            } else {
                self.selectedTransferTime = 0
            }
        } else {
            self.selectedTransportation = "none"
            self.selectedTransferTime = 0
        }
    }
    
    // MARK: - Data Clearing
    // Clear timetable data for current route and line number for all calendar types
    private func clearAllTimetableData() async {
        // Clear data for all calendar types for current route and line number
        for calendarType in ODPTCalendarType.allCases {
            clearTimetableDataForRoute(calendarType: calendarType, goorback: goorback, lineNumber: lineIndex + 1)
        }
        
        // Clear cached calendar types to force refresh
        if let selectedLine = selectedLine {
            let cacheKey = "\(selectedLine.code)_\(selectedLine.kind.rawValue)_calendarTypes"
            UserDefaults.standard.removeObject(forKey: cacheKey)
            
            // Clear line-level cache for current route and line only
            let lineCacheKey = "\(goorback)line\(lineIndex + 1)_calendarTypes"
            UserDefaults.standard.removeObject(forKey: lineCacheKey)
        }
    }
    
    // MARK: - Unified Timetable Data Processing
    // Get timetable data and extract departure/arrival times for selected stops/stations
    func getTimeTableData() async -> [ODPTCalendarType: [any TransportationTime]] {
        
        // Skip timetable generation if not all required fields are filled
        guard isAllNotEmpty else {
            return [:]
        }
        
        guard let selectedLine = selectedLine else {
            return [:]
        }
        
        // Clear existing timetable data for all calendar types before generating new data
        await clearAllTimetableData()
        
        // Get available calendar types for this line
        let availableCalendarTypes = await getAvailableCalendarTypes()
        
        // Process data for each calendar type first (create timetables individually)
        var allTimes: [ODPTCalendarType: [any TransportationTime]] = [:]
        
        for calendarType in availableCalendarTypes {
            
            let times: [any TransportationTime] = (selectedLine.kind == .bus) ? 
                await processBusTimetableData(calendarType: calendarType): 
                await processTrainTimetableData(calendarType: calendarType)
            
            // Save times for this specific calendar type
            allTimes[calendarType] = times
            
        }
        
        // After creating all timetables, check and merge timetables with same displayCalendarType
        
        // Group calendar types by displayCalendarType
        var groupedByDisplayType: [ODPTCalendarType: [ODPTCalendarType]] = [:]
        for calendarType in availableCalendarTypes {
            let displayType = calendarType.displayCalendarType
            if groupedByDisplayType[displayType] == nil {
                groupedByDisplayType[displayType] = []
            }
            groupedByDisplayType[displayType]?.append(calendarType)
        }
        
        var mergedTimes: [ODPTCalendarType: [any TransportationTime]] = [:]
        var mergedSourceTypes: Set<ODPTCalendarType> = [] // Track all merged source calendar types (including representative) to clear later
        
        // Process each display calendar type group
        for (displayType, calendarTypes) in groupedByDisplayType {
            if calendarTypes.count > 1 {
                // Multiple calendar types with same display type - merge them
                
                var mergedTimeList: [any TransportationTime] = []
                
                // Use the first calendar type (prefer .specific if available) as the representative
                let representativeCalendarType = calendarTypes.first { if case .specific = $0 { return true }; return false } ?? calendarTypes.first ?? displayType
                
                for typeToMerge in calendarTypes {
                    if let times = allTimes[typeToMerge] {
                        mergedTimeList.append(contentsOf: times)
                    }
                }
                
                // Remove duplicates and sort by departure time
                mergedTimeList = mergedTimeList.mergeAndSortTransportationTimes()
                
                // Save merged timetable under representative calendar type
                mergedTimes[representativeCalendarType] = mergedTimeList
                
                // Track ALL merged source types (including representative) for cleanup
                // We need to clear all of them, including the representative, because it might have old data
                for typeToDelete in calendarTypes {
                    allTimes.removeValue(forKey: typeToDelete)
                    mergedSourceTypes.insert(typeToDelete)
                }
                
            } else {
                // Only one calendar type with this display type - keep as is
                if let calendarType = calendarTypes.first, let times = allTimes[calendarType] {
                    mergedTimes[calendarType] = times
                    allTimes.removeValue(forKey: calendarType)
                }
            }
        }
        
        // Clear ALL merged source calendar types from UserDefaults (including representatives)
        // This ensures old data is removed before new merged data is saved
        // IMPORTANT: Use initialized goorback and lineIndex to prevent data corruption across routes
        if !mergedSourceTypes.isEmpty {
            for sourceType in mergedSourceTypes {
                // Check if this type is actually in mergedTimes (it's the representative that will be saved)
                // If it's in mergedTimes, we still clear it first, then it will be re-saved with merged data
                let willBeResaved = mergedTimes.keys.contains(sourceType)
                
                // Double-check that we're clearing for the correct route and line number
                clearTimetableDataForRoute(calendarType: sourceType, goorback: goorback, lineNumber: lineIndex + 1)
                
                if willBeResaved {
                } else {
                }
            }
        }
        
        // Update cache with only the merged representative calendar types
        // This ensures that loadAvailableCalendarTypes returns only the merged types
        let mergedRepresentativeTypes = Array(mergedTimes.keys)
        let lineCacheKey = "\(goorback)line\(lineIndex + 1)_calendarTypes"
        let typeStrings = mergedRepresentativeTypes.map { $0.rawValue }
        UserDefaults.standard.set(typeStrings, forKey: lineCacheKey)
        
        return mergedTimes        
    }
    
    // MARK: - Available Calendar Types Detection
    // Get available calendar types for the selected line by fetching from timetable API
    private func getAvailableCalendarTypes() async -> [ODPTCalendarType] {
        guard let selectedLine = selectedLine,
              let operatorCode = selectedLine.operatorCode,
              let selectedOperator = LocalDataSource.allCases.first(where: { $0.operatorCode == operatorCode }) else {
            return [.weekday, .holiday] // Fallback to default
        }
        
        // Check cache first
        let cacheKey = "\(selectedLine.code)_\(selectedLine.kind.rawValue)_calendarTypes"
        if let cachedTypes = UserDefaults.standard.stringArray(forKey: cacheKey),
           !cachedTypes.isEmpty {
            let cachedCalendarTypes = cachedTypes.compactMap { ODPTCalendarType(rawValue: $0) }
            if !cachedCalendarTypes.isEmpty {
                print("📅 getAvailableCalendarTypes: Found cached calendar types: \(cachedCalendarTypes.map { $0.displayName }.joined(separator: ", "))")
                return cachedCalendarTypes
            }
        }
        
        // Fetch available calendar types from timetable API
        let availableTypes = await fetchAvailableCalendarTypes(dataSource: selectedOperator)
        
        // Cache the results
        let typeStrings = availableTypes.map { $0.rawValue }
        UserDefaults.standard.set(typeStrings, forKey: cacheKey)
        
        // Cache at line level (each line has its own calendar types list)
        // Structure: goorback -> line -> calendar types -> timetable data
        let lineCacheKey = "\(goorback)line\(lineIndex + 1)_calendarTypes"
        UserDefaults.standard.set(typeStrings, forKey: lineCacheKey)
        
        // Ensure we have at least weekday and holiday as fallback
        if availableTypes.isEmpty {
            print("📅 getAvailableCalendarTypes: No calendar types found, using fallback: [weekday, holiday]")
            return [.weekday, .holiday]
        }
        
        print("📅 getAvailableCalendarTypes: Found calendar types: \(availableTypes.map { $0.displayName }.joined(separator: ", "))")
        return availableTypes
    }
    
    // Fetch available calendar types from timetable API
    // Uses BusTimetable for bus, StationTimetable for railway
    private func fetchAvailableCalendarTypes(dataSource: LocalDataSource) async -> [ODPTCalendarType] {
        // Generate API link and type name based on transportation kind
        guard let selectedLine = selectedLine else { return [] }
        
        let apiTypeName: String = selectedLine.kind == .bus ? "BusTimetable" : "StationTimetable"
        
        let apiLink: String? = selectedLine.kind == .bus ?
            selectedLine.title.map { "\(dataSource.apiLink(for: .timetable, transportationKind: .bus))&dc:title=\($0)" } :
            selectedDepartureStop?.code.flatMap { stationCode in
                (selectedLine.ascendingRailDirection ?? selectedLine.lineDirection).map { direction in
                    "\(dataSource.apiLink(for: .stopTimetable))&odpt:station=\(stationCode)&odpt:railDirection=\(direction)"
                }
            }
        
        guard let apiLink = apiLink else {
            print("⚠️ \(apiTypeName): Missing required information")
            return []
        }
        
        guard let url = URL(string: apiLink) else {
            print("⚠️ \(apiTypeName): Invalid URL")
            return []
        }
        
        print("🔗 Fetch URL: \(apiLink)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("❌ Failed to fetch calendar types - status: \(httpResponse.statusCode)")
                    return []
                }
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            
            // Extract unique calendar types from the response
            var foundCalendarTypes: Set<String> = []
            
            for timetable in json {
                if let calendar = timetable["odpt:calendar"] as? String {
                    foundCalendarTypes.insert(calendar)
                }
            }
            
            // Convert to ODPTCalendarType array and process
            let result = processCalendarTypes(foundCalendarTypes, apiTypeName: apiTypeName)
            
            return result
            
        } catch {
            print("❌ Error fetching calendar types from \(apiTypeName): \(error.localizedDescription)")
            return []
        }
    }
    
    // Process calendar types: remove duplicates and preserve .specific types
    private func processCalendarTypes(_ foundCalendarTypes: Set<String>, apiTypeName: String) -> [ODPTCalendarType] {
        // Convert to ODPTCalendarType array
        let allTypes = foundCalendarTypes.compactMap { ODPTCalendarType(rawValue: $0) }
        
        // Remove duplicates based on displayCalendarType while preserving .specific types
        var uniqueTypes: [ODPTCalendarType] = []
        var seenDisplayTypes: Set<ODPTCalendarType> = []
        
        // First pass: Add all .specific types
        for type in allTypes {
            if case .specific = type {
                uniqueTypes.append(type)
                seenDisplayTypes.insert(type.displayCalendarType)
            }
        }
        
        // Second pass: Add standard types only if their display type hasn't been seen
        for type in allTypes {
            if case .specific = type {
                continue // Already added
            }
            let displayType = type.displayCalendarType
            if !seenDisplayTypes.contains(displayType) {
                uniqueTypes.append(type)
                seenDisplayTypes.insert(displayType)
            }
        }
        
        let result = uniqueTypes.sorted { $0.rawValue < $1.rawValue }
        
        if !result.isEmpty {
            print("📅 \(apiTypeName): Found calendar types: \(result.map { $0.displayName }.joined(separator: ", "))")
        } else {
            print("⚠️ \(apiTypeName): No calendar types found")
        }
        
        return result
    }
    
    // Test if a specific calendar type has data available
    private func testCalendarTypeAvailability(calendarType: ODPTCalendarType, dataSource: LocalDataSource) async -> Bool {
        do {
            let apiLink: String
            if selectedLine?.kind == .bus {
                guard let selectedLineTitle = selectedLine?.title else { return false }
                apiLink = "\(dataSource.apiLink(for: .timetable, transportationKind: .bus))&dc:title=\(selectedLineTitle)&odpt:calendar=\(calendarType.rawValue)"
            } else {
                guard let selectedLineCode = selectedLine?.code else { return false }
                apiLink = "\(dataSource.apiLink(for: .timetable))&odpt:railway=\(selectedLineCode)&odpt:calendar=\(calendarType.rawValue)"
            }
            
            guard let url = URL(string: apiLink) else { return false }
            
            print("🔗 Fetch URL: \(apiLink)")
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    print("❌ Calendar type \(calendarType.displayName) not found (404)")
                    return false
                }
                if httpResponse.statusCode != 200 {
                    return false
                }
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            
            // Consider it available if we get a valid response (even empty array means the calendar type exists)
            // But we can also check if there's actual timetable data
            let _ = json.contains { timetable in
                if selectedLine?.kind == .bus {
                    return timetable["odpt:busTimetableObject"] != nil
                } else {
                    return timetable["odpt:trainTimetableObject"] != nil
                }
            }
            // Return true if the calendar type exists, even without data
            return true 
            
        } catch {
            print("❌ Error testing calendar type \(calendarType.displayName): \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Timetable Data Processing
    // Process bus timetable data for specific day type
    private func processBusTimetableData(calendarType: ODPTCalendarType) async -> [any TransportationTime] {
        
        // Fetch bus timetable data from API
        let busTimetableData = await fetchBusTimetableData(calendarType: calendarType)
        
        // Extract bus information and timetable objects in a single loop
        var transportationTimes: [any TransportationTime] = []
        
        for timetable in busTimetableData {
            
            guard let busTimetableObjects = timetable["odpt:busTimetableObject"] as? [[String: Any]] else {
                continue
            }

            var departureTime: String?
            var arrivalTime: String?
            
            for timetableObject in busTimetableObjects {
                
                let currentBusstopPole = timetableObject["odpt:busstopPole"] as? String ?? ""
                let currentDepartureTime = timetableObject["odpt:departureTime"] as? String ?? ""
                let currentArrivalTime = timetableObject["odpt:arrivalTime"] as? String ?? ""

                // Check departure stop match using busstopPole
                if let selectedDepartureStop = selectedDepartureStop,
                   let departureStop = selectedDepartureStop.busstopPole,
                   currentBusstopPole == departureStop {
                    if !currentDepartureTime.isEmpty {
                        departureTime = currentDepartureTime
                        // print("✅ Found departure time: \(currentDepartureTime) at \(currentBusstopPole)")
                    } else if !currentArrivalTime.isEmpty {
                        departureTime = currentArrivalTime
                        // print("✅ Found arrival time: \(currentArrivalTime) at \(currentBusstopPole)")
                    }
                }
                
                // Check arrival stop match using busstopPole
                if let selectedArrivalStop = selectedArrivalStop,
                   let arrivalStop = selectedArrivalStop.busstopPole,
                   currentBusstopPole == arrivalStop {
                    if !currentArrivalTime.isEmpty {
                        arrivalTime = currentArrivalTime
                        // print("✅ Found arrival time: \(currentArrivalTime) at \(currentBusstopPole)")
                    } else if !currentDepartureTime.isEmpty {
                        arrivalTime = currentDepartureTime
                        // print("✅ Found arrival time (as departure): \(currentDepartureTime) at \(currentBusstopPole)")
                    }
                }
            }
        
            // Only append if arrival time is later than departure time
            if let depTime = departureTime, let arrTime = arrivalTime {
                // Convert time strings to minutes for comparison
                let depMinutes = depTime.timeToMinutes
                let arrMinutes = arrTime.timeToMinutes
                if arrMinutes > depMinutes {
                    // Calculate ride time in minutes
                    let rideTime = depTime.calculateRideTime(arrivalTime: arrTime)
                    let busNumber = timetable["dc:title"] as? String
                    let routePattern = timetable["odpt:busroutePattern"] as? String
                    let busTime = BusTime(
                        departureTime: depTime,
                        arrivalTime: arrTime,
                        busNumber: busNumber,
                        routePattern: routePattern,
                        rideTime: rideTime
                    )
                    transportationTimes.append(busTime)
                } else {
                }
            } else {
            }
        }
        
        
        return transportationTimes
    }
    
    // Fetch bus timetable data from API
    private func fetchBusTimetableData(calendarType: ODPTCalendarType) async -> [[String: Any]] {
        guard let operatorCode = selectedLine?.operatorCode,
              let selectedLineTitle = selectedLine?.title,
              let selectedOperator = LocalDataSource.allCases.first(where: { $0.operatorCode == operatorCode }) else { return [] }
        
        
        // Use bus-specific timetable API (force bus API regardless of transportationType)
        let apiLink = "\(selectedOperator.apiLink(for: .timetable, transportationKind: .bus))&dc:title=\(selectedLineTitle)&odpt:calendar=\(calendarType.rawValue)"
        
        guard let url = URL(string: apiLink) else {
            print("❌ Invalid bus timetable API URL")
            return []
        }
        
        do {
            print("🔗 Fetch URL: \(apiLink)")
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                print("❌ Failed to parse bus timetable JSON")
                return []
            }
            
            return json
        } catch {
            print("❌ Error fetching bus timetable data: \(error)")
            return []
        }
    }

    
    // Process train timetable data for specific day type
    private func processTrainTimetableData(calendarType: ODPTCalendarType) async -> [any TransportationTime] {
        
        // Fetch train timetable data from API
        let trainTimetableData = await fetchTrainTimetableData(calendarType: calendarType)
        
        // Extract train information and timetable objects in a single loop
        var transportationTimes: [any TransportationTime] = []
        
        for timetable in trainTimetableData {
            
            guard let trainNumber = timetable["odpt:trainNumber"] as? String,
                  let trainType = timetable["odpt:trainType"] as? String,
                  let trainTimetableObjects = timetable["odpt:trainTimetableObject"] as? [[String: Any]] else {
                continue
            }

            var departureTime: String?
            var arrivalTime: String?
            
            for timetableObject in trainTimetableObjects {
                
                // Check departure station match
                if let departureStop = timetableObject["odpt:departureStation"] as? String,
                   departureStop == selectedDepartureStop?.code {
                    departureTime = timetableObject["odpt:departureTime"] as? String
                }
                
                // Check arrival station match
                if let arrivalStop = timetableObject["odpt:arrivalStation"] as? String,
                   arrivalStop == selectedArrivalStop?.code {
                    arrivalTime = timetableObject["odpt:arrivalTime"] as? String
                } else if let departureStop = timetableObject["odpt:departureStation"] as? String,
                          departureStop == selectedArrivalStop?.code {
                    arrivalTime = timetableObject["odpt:departureTime"] as? String
                }

            }
        
            // Only append if arrival time is later than departure time
            if let depTime = departureTime, let arrTime = arrivalTime {
                // Convert time strings to minutes for comparison
                let depMinutes = depTime.timeToMinutes
                let arrMinutes = arrTime.timeToMinutes
                if arrMinutes > depMinutes {
                    // Calculate ride time in minutes
                    let rideTime = depTime.calculateRideTime(arrivalTime: arrTime)
                    let trainTime = TrainTime(
                        departureTime: depTime,
                        arrivalTime: arrTime,
                        trainNumber: trainNumber,
                        trainType: trainType,
                        rideTime: rideTime
                    )
                    transportationTimes.append(trainTime)
                }
            }
        }
        
        
        return transportationTimes
    }
    
    // Fetch train timetable data from API
    private func fetchTrainTimetableData(calendarType: ODPTCalendarType) async -> [[String: Any]] {
        guard let operatorCode = selectedLine?.operatorCode,
              let selectedLineCode = selectedLine?.code,
              let selectedOperator = LocalDataSource.allCases.first(where: { $0.operatorCode == operatorCode }) else { return [] }
        
        
        let apiLink = "\(selectedOperator.apiLink(for: .timetable))&odpt:railway=\(selectedLineCode)&odpt:calendar=\(calendarType.rawValue)"
        
        do {
            guard let url = URL(string: apiLink) else {
                print("❌ Invalid URL: \(apiLink)")
                return []
            }

            print("🔗 Fetch URL: \(apiLink)")
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                print("❌ Failed to parse train timetable JSON")
                return []
            }
            
            return json
            
        } catch {
            print("❌ Error fetching train timetable data: \(error)")
            return []
        }
    }
    
    // MARK: - Train Route Validation
    // Get station timetable data for determined direction and find common train numbers
    func getStationTimetableData() async -> [ODPTCalendarType: [any TransportationTime]] {
        
        // Skip timetable generation if not all required fields are filled
        guard isAllNotEmpty else {
            return [:]
        }
        
        // Clear existing timetable data for all calendar types before generating new data
        await clearAllTimetableData()
        
        
        // Get the actual direction from selectedLine
        let actualDirection = selectedLine?.lineDirection ?? ""
        
        // Get actual directions from JSON data with fallback
        let ascendingDirection = selectedLine?.ascendingRailDirection ?? actualDirection
        let descendingDirection = selectedLine?.descendingRailDirection ?? actualDirection
        
        
        var allTimes: [ODPTCalendarType: [any TransportationTime]] = [:]
        
        // Get available calendar types dynamically
        // Same calendar types for TrainTimetable and StationTimetable on the same line
        let availableCalendarTypes = await getAvailableCalendarTypes()
        
        for calendarType in availableCalendarTypes {
            
            // Get data for both directions
            let directions = [ascendingDirection, descendingDirection]
            var directionResults: [[any TransportationTime]] = []
            
            for direction in directions {
                
                // Get departure and arrival data for this direction
                let departureLink = stationTimetableApiLink(isDeparture: true, calendarType: calendarType, direction: direction)
                let arrivalLink = stationTimetableApiLink(isDeparture: false, calendarType: calendarType, direction: direction)
                
                
                let departureData = await fetchStationTimetableData(from: departureLink)
                let arrivalData = await fetchStationTimetableData(from: arrivalLink)
                
                
                // Process this direction if we have both departure and arrival data
                var result: [any TransportationTime] = []
                if departureData.count > 0 {
                    result = await getEstimatedTrainTime(
                        departureTimetableData: departureData,
                        arrivalTimetableData: arrivalData,
                        calendarType: calendarType,
                        approxRideTime: selectedRideTime
                    )
                }
                directionResults.append(result)
            }
            
            // Choose the direction with smaller average ride time
            let selectedResult = directionResults.min { 
                let avg1 = $0.isEmpty ? Int.max : $0.map { $0.rideTime }.reduce(0, +) / $0.count
                let avg2 = $1.isEmpty ? Int.max : $1.map { $0.rideTime }.reduce(0, +) / $1.count
                return avg1 < avg2
            } ?? []
            
            // Save to dictionary with calendar type as key
            allTimes[calendarType] = selectedResult
        }
        return allTimes
    }
    
    // MARK: - URL Data Fetching
    // Fetch data from URL string for API requests
    private func fetchData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        print("🔗 Fetch URL: \(urlString)")
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
        }
        
        return data
    }
    
    // MARK: - Data Fetching
    // Simple data fetching method for API calls    
    // MARK: - Station Timetable Data Processing
    // Generate station timetable link with flexible parameters
    func stationTimetableApiLink(isDeparture: Bool, calendarType: ODPTCalendarType, direction: String? = nil) -> String {
        
    // Generate timetable information links for departure and arrival stations
        let operatorCode = selectedLine?.operatorCode ?? ""
        let dataSource = LocalDataSource.allCases.first { $0.operatorCode == operatorCode }
        let stationTimetableApiLink = dataSource?.apiLink(for: .stopTimetable) ?? ""
        
        // Extract station name from station code (remove "odpt.Station:" prefix)
        let lineCode = selectedLine?.code ?? ""
        let lineName = lineCode.replacingOccurrences(of: "odpt.Railway:", with: "&owl:sameAs=odpt.StationTimetable:")
        
        let stationCode = (isDeparture ? selectedDepartureStop?.code: selectedArrivalStop?.code) ?? ""
        let stationName = stationCode.components(separatedBy: ".").last ?? ""
        
        // Use provided direction or fallback to lineDirection from selectedLine
        let directionCode = direction ?? String(selectedLine?.lineDirection ?? "")
        let directionName = directionCode.replacingOccurrences(of: "odpt.RailDirection:", with: "")
        
        let dateSuffix = calendarType.rawValue.replacingOccurrences(of: "odpt.Calendar:", with: "")
        
        let apiLink = "\(stationTimetableApiLink)\(lineName).\(stationName).\(directionName).\(dateSuffix)"
        
        return apiLink
    }

    // MARK: - Timetable Data Retrieval
    // Get timetable data from API endpoint
    private func fetchStationTimetableData(from urlString: String) async -> [(trainNumber: String, departureTime: String, destinationStation: String, trainType: String)] {
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return []
        }
        
        do {
            print("🔗 Fetch URL: \(urlString)")
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    print("❌ HTTP error \(httpResponse.statusCode) for URL: \(urlString)")
                    return []
                }
            }
            
            // Parse JSON and extract train data
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let firstObject = json.first,
               let stationTimetableObjects = firstObject["odpt:stationTimetableObject"] as? [[String: Any]] {

                // Parse timetable objects into structured data
                let parsedData = stationTimetableObjects.compactMap { (timetableObject: [String: Any]) -> (trainNumber: String, departureTime: String, destinationStation: String, trainType: String)? in
                    guard let departureTime = timetableObject["odpt:departureTime"] as? String else { return nil }
                    
                    let trainNumber = timetableObject["odpt:trainNumber"] as? String ?? ""
                    let trainType = timetableObject["odpt:trainType"] as? String ?? ""
                    let destinationStation = (timetableObject["odpt:destinationStation"] as? [String])?.first ?? ""
                    
                    // Apply timetableHour extension for 0-3 AM times (add 24 hours for previous day)
                    let adjustedDepartureTime = departureTime.adjustedForTimetable
                    
                    return (trainNumber: trainNumber, departureTime: adjustedDepartureTime, destinationStation: destinationStation, trainType: trainType)
                }
                
                // Sort by departure time in ascending order (earliest first)
                let result = parsedData.sorted { first, second in
                    let firstTime = first.departureTime
                    let secondTime = second.departureTime
                    
                    // Convert HH:MM to minutes for comparison
                    let firstMinutes = firstTime.timeToMinutes
                    let secondMinutes = secondTime.timeToMinutes
                    
                    return firstMinutes < secondMinutes
                }
                
                return result
                
                } else {
                return []
            }
            
        } catch {
            print("❌ Failed to process timetable data from \(urlString): \(error)")
            return []
        }
    }
    
    // MARK: - trainNumber-less Timetable Generation
    // Estimate departure times using simplified matching when train numbers are not available
    // Returns array of TrainTime objects with estimated departure times
    private func getEstimatedTrainTime(
        departureTimetableData: [(trainNumber: String, departureTime: String, destinationStation: String, trainType: String)],
        arrivalTimetableData: [(trainNumber: String, departureTime: String, destinationStation: String, trainType: String)],
        calendarType: ODPTCalendarType,
        approxRideTime: Int
    ) async -> [any TransportationTime] {


        // Get unique train types from departure data
        let trainTypeList = departureTimetableData.trainTypeList
        
        var allTransportationTimes: [any TransportationTime] = []
        
        // Process each train type separately
        for trainType in trainTypeList {
            
            // Filter departure and arrival data by train type
            let departureData = departureTimetableData.filtered(by: trainType)
            let arrivalData = arrivalTimetableData.filtered(by: trainType)
            
            // Skip if no data for this train type
            guard !departureData.isEmpty else { continue }
            
            let terminalDepartureData = departureData.filter { data in
                !data.destinationStation.isEmpty && data.destinationStation == selectedArrivalStop?.code
            }
            
            
            // Create terminalTrainTimes list from terminalDepartureData
            let terminalTrainTimes = terminalDepartureData.map { data in
                TrainTime(
                    departureTime: data.departureTime,
                    arrivalTime: "",
                    trainNumber: data.trainNumber.isEmpty ? nil : data.trainNumber,
                    trainType: data.trainType,
                    rideTime: selectedRideTime
                )
            }
            if !terminalTrainTimes.isEmpty {
                allTransportationTimes.append(contentsOf: terminalTrainTimes)
            }

            
            // Remove terminalDepartureData from departureData
            let filteredDepartureData = departureData.filter { data in
                data.destinationStation.isEmpty || data.destinationStation != selectedArrivalStop?.code
            }
            
            
            // Process this train type with filtered data
            if !filteredDepartureData.isEmpty {
                let trainTimes = processTrainType(
                    departureData: filteredDepartureData,
                    arrivalData: arrivalData,
                    trainType: trainType,
                    approxRideTime: approxRideTime
                )
                // Calculate average ride time for this train type
                if !trainTimes.isEmpty {
                    allTransportationTimes.append(contentsOf: trainTimes)
                }
            }
        }
        
        // Sort all train times by departure time
        let sortedTrainTimes = allTransportationTimes.sorted { first, second in
            let firstMinutes = first.departureTime.timeToMinutes
            let secondMinutes = second.departureTime.timeToMinutes
            return firstMinutes < secondMinutes
        }
        
        return sortedTrainTimes
    }
    
    // MARK: - Train Type Processing with Advanced Algorithm
    // Process timetable data for a specific train type using advanced statistical methods
    private func processTrainType(
        departureData: [(trainNumber: String, departureTime: String, destinationStation: String, trainType: String)],
        arrivalData: [(trainNumber: String, departureTime: String, destinationStation: String, trainType: String)],
        trainType: String,
        approxRideTime: Int
    ) -> [any TransportationTime] {
        
        // 0) Filter out trains that don't reach the arrival station (only for trains without train numbers)
        let filteredDepartureData = departureData.filter { data in
            if data.trainNumber.isEmpty && !isTrainReachingArrivalStop(destinationStation: data.destinationStation) {
                return false
            }
            return true
        }
        
        // 0.5) Filter arrival data to match departure destinations
        let filteredArrivalData = arrivalData.filter { arrivalDataItem in
            // Check if there's a matching departure with the same destination
            return filteredDepartureData.contains { departureDataItem in
                departureDataItem.destinationStation == arrivalDataItem.destinationStation
            }
        }
        
        // 1) Build departure and arrival station data
        let departureTimes = filteredDepartureData.compactMap(\.departureTime).filter { !$0.isEmpty }
        let arrivalTimes = filteredArrivalData.compactMap(\.departureTime).filter { !$0.isEmpty }

        // 2) Sort time strings directly
        let sortedDepartureTimes = departureTimes.sorted()
        let sortedArrivalTimes = arrivalTimes.sorted()

        
        // 5) Collect pairs using no duplicates with minimum ride time within range
        var transportationTimes: [any TransportationTime] = []
        var usedArrivals = Set<Int>() // Track used arrival indices
        
        for departureTime in sortedDepartureTimes {
            var bestArrivalIndex: Int? = nil
            var minDistanceFromAverage = Double.infinity
            
            for (index, arrivalTime) in sortedArrivalTimes.enumerated() {
                // Skip if this arrival has already been used
                if usedArrivals.contains(index) { continue }
                
                let rideTimeMinutes = departureTime.calculateRideTime(arrivalTime: arrivalTime)
                // Skip if distance from target exceeds half of approxRideTime
                let distanceFromTarget = abs(Double(rideTimeMinutes) - Double(approxRideTime))
                guard distanceFromTarget <= Double(approxRideTime) / 2.0 else { continue }
                
                if distanceFromTarget < minDistanceFromAverage {
                    minDistanceFromAverage = distanceFromTarget
                    bestArrivalIndex = index
                }
            }
            
            // Use the best arrival and mark it as used
            if let bestIndex = bestArrivalIndex {
                let trainTime = TrainTime(
                    departureTime: departureTime,
                    arrivalTime: sortedArrivalTimes[bestIndex],
                    trainNumber: nil,
                    trainType: trainType,
                    rideTime: departureTime.calculateRideTime(arrivalTime: sortedArrivalTimes[bestIndex])
                )
                transportationTimes.append(trainTime)
                usedArrivals.insert(bestIndex)
            }
        }
        return transportationTimes
    }
    
    // Check if train reaches the arrival station (destination station index is not between departure and arrival)
    private func isTrainReachingArrivalStop(destinationStation: String) -> Bool {
        // Get station indices for departure, arrival, and destination stations
        guard let departureIndex = selectedDepartureStop?.index,
              let arrivalIndex = selectedArrivalStop?.index,
              let destinationIndex = getStationIndexFromDestinationStation(destinationStation) else {
            // If any index is missing, allow the train (fallback behavior)
            return true
        }
        
        // Check if destination station index is between departure and arrival stations
        let minIndex = min(departureIndex, arrivalIndex)
        let maxIndex = max(departureIndex, arrivalIndex)
        
        // If destination station is between departure and arrival, the train doesn't reach the arrival station
        if destinationIndex > minIndex && destinationIndex < maxIndex {
            return false
        }
        
        // Train reaches the arrival station
        return true
    }
    
    // MARK: - Station Index Helper
    // Get station index from destination station code (only for selected line)
    private func getStationIndexFromDestinationStation(_ destinationStationCode: String) -> Int? {
        // Only search in the selected line's stations
        guard let selectedLine = selectedLine else {
            return nil
        }
        
        // Parse destination station code (e.g., "odpt.Station:Odakyu.Odawara.Odawara")
        // Extract the line code from selected (e.g., "Odawara" from "odpt.Railway:Odakyu.Odawara")
        let selectedComponents = selectedLine.code.components(separatedBy: ".")
        let selectedLineCode = selectedComponents.count >= 3 ? selectedComponents[2] : ""
        
        // Only process if the destination station belongs to the selected line
        // Check if the destination station code contains the selected line code
        guard destinationStationCode.contains(selectedLineCode) else {
            return nil
        }
        
        // Extract the station name from the code
        let stationName = destinationStationCode.components(separatedBy: ".").last ?? ""
        
        // Use already loaded line stops and filter for railway stations
        let selectedLineStations = lineStops.compactMap { stop in
            if stop.kind == .railway {
                return Station(
                    name: stop.name,
                    code: stop.code,
                    index: stop.index,
                    lineCode: stop.lineCode,
                    title: stop.title
                )
            }
            return nil
        }
        
        // Find station by code or name match
        if let station = selectedLineStations.first(where: { 
            $0.code == destinationStationCode || 
            $0.name == stationName || 
            $0.title?.getLocalizedName(fallbackTo: $0.name) ?? $0.name == stationName
        }) {
            if station.index == -1 {
            }
            return station.index
        }
        
        print("❌ Station not found: '\(stationName)'")
        
        return nil
    }
        
    // MARK: - Timetable Data Saving
    // Save timetable data to UserDefaults for display in TimetableContentView
    // Saves both departure times and ride times grouped by hour
    private func saveTimetableToUserDefaults(transportationTimes: [any TransportationTime], calendarType: ODPTCalendarType) {
        // Clear existing timetable data for this line and calendar type
        // IMPORTANT: Use initialized goorback and lineIndex to prevent data corruption across routes
        clearTimetableDataForRoute(calendarType: calendarType, goorback: goorback, lineNumber: lineIndex + 1)
        
        
        // Group TransportationTime objects by hour
        var hourlyTransportationTimes: [Int: [any TransportationTime]] = [:]
        
        for transportationTimeItem in transportationTimes {
            let timeComponents = transportationTimeItem.departureTime.components(separatedBy: ":")
            if timeComponents.count == 2, let hour = Int(timeComponents[0]) {
                hourlyTransportationTimes[hour, default: []].append(transportationTimeItem)
            }
        }
        
        // Sort and save to UserDefaults using unified TransportationTime format
        for (hour, transportationTimesForHour) in hourlyTransportationTimes {
            let sortedTransportationTimes = transportationTimesForHour.sorted { 
                $0.departureTime < $1.departureTime 
            }
            // IMPORTANT: Use initialized goorback and lineIndex to prevent data corruption across routes
            
            goorback.saveTransportationTimes(sortedTransportationTimes, calendarType, lineIndex, hour)
        }
        
        // Save train type list for the entire timetable
        // IMPORTANT: Use initialized goorback and lineIndex to prevent data corruption across routes
        let allTransportationTimes = hourlyTransportationTimes.values.flatMap { $0 }
        
        goorback.saveTrainTypeList(allTransportationTimes, calendarType, lineIndex)
        
        // Ensure all UserDefaults changes are synchronized to disk
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Common Timetable Data Finalization with Arrays
    // Common post-processing for timetable data with weekday/weekend arrays
    func finalizeTimetableData(weekdayTimes: [any TransportationTime], weekendTimes: [any TransportationTime]) async {
        // Save timetable data using unified TransportationTime format
        saveTimetableToUserDefaults(transportationTimes: weekdayTimes, calendarType: .weekday)
        saveTimetableToUserDefaults(transportationTimes: weekendTimes, calendarType: .holiday)
        
        // Save all data after timetable data has been processed and saved
        await saveAllDataToUserDefaults()
        
        // Clear cache for available calendar types to force reload
        goorback.clearCalendarTypesCache(num: lineIndex)
        
        // Notify that timetable data has been updated
        NotificationCenter.default.post(name: NSNotification.Name("TimetableDataUpdated"), object: nil)
    }
    
    // MARK: - Common Timetable Data Finalization with Calendar Types
    // Common post-processing for timetable data with individual calendar types
    func finalizeTimetableData(calendarTimes: [ODPTCalendarType: [any TransportationTime]]) async {
        // Save timetable data for each calendar type individually
        for (calendarType, times) in calendarTimes {
            saveTimetableToUserDefaults(transportationTimes: times, calendarType: calendarType)
        }
        
        // Save all data after timetable data has been processed and saved
        // Note: saveAllDataToUserDefaults() will save lineCode if selectedLine is available
        await saveAllDataToUserDefaults()
        
        // Update cache with only the merged representative calendar types
        // This ensures that loadAvailableCalendarTypes returns only the merged types
        let mergedRepresentativeTypes = Array(calendarTimes.keys)
        let lineCacheKey = "\(goorback)line\(lineIndex + 1)_calendarTypes"
        let typeStrings = mergedRepresentativeTypes.map { $0.rawValue }
        UserDefaults.standard.set(typeStrings, forKey: lineCacheKey)
        
        // Clear cache for available calendar types to force reload
        goorback.clearCalendarTypesCache(num: lineIndex)
        
        // Notify that timetable data has been updated
        NotificationCenter.default.post(name: NSNotification.Name("TimetableDataUpdated"), object: nil)
    }
    
    
    // MARK: - Timetable Data Clearing
    // Clear existing timetable data for specified route, line number, and calendar type
    private func clearTimetableDataForRoute(calendarType: ODPTCalendarType, goorback: String, lineNumber: Int) {
        var clearedCount = 0
        var clearedKeys: [String] = []
        
        // Clear all hours (4-24) for the specified calendar type, route, and line
        for hour in 4...25 {
            let timetableKey = goorback.timetableKey(calendarType, lineNumber - 1, hour)
            let timetableRideTimeKey = goorback.timetableRideTimeKey(calendarType, lineNumber - 1, hour)
            let timetableTrainTypeKey = goorback.timetableTrainTypeKey(calendarType, lineNumber - 1, hour)
            
            let hadTimetable = UserDefaults.standard.object(forKey: timetableKey) != nil
            let hadRideTime = UserDefaults.standard.object(forKey: timetableRideTimeKey) != nil
            let hadTrainType = UserDefaults.standard.object(forKey: timetableTrainTypeKey) != nil
            
            if hadTimetable || hadRideTime || hadTrainType {
                // Log actual key being deleted for first few hours
                if hour <= 6 && clearedKeys.count < 3 {
                    clearedKeys.append(timetableKey)
                }
            }
            
            UserDefaults.standard.removeObject(forKey: timetableKey)
            UserDefaults.standard.removeObject(forKey: timetableRideTimeKey)
            UserDefaults.standard.removeObject(forKey: timetableTrainTypeKey)
            
            if hadTimetable || hadRideTime || hadTrainType {
                clearedCount += 1
            }
        }
        
        // Clear train type list
        let trainTypeListKey = goorback.trainTypeListKey(calendarType, lineNumber - 1)
        UserDefaults.standard.removeObject(forKey: trainTypeListKey)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Transportation Kind Switching
    // Handle transportation kind switching without clearing data
    func switchTransportationKind(_ isRailway: Bool) {
        // Update transportation kind immediately for responsive UI
        selectedTransportationKind = isRailway ? .railway : .bus
        
        // Clear only suggestions to prevent UI conflicts
        lineSuggestions = []
        showLineSuggestions = false
        nameCounts = [:]
        showDepartureSuggestions = false
        showArrivalSuggestions = false
        departureSuggestions = []
        arrivalSuggestions = []
        isDepartureFieldFocused = false
        isArrivalFieldFocused = false
        showStationSelection = false
        
        // Clear operator suggestions and reset operator selection when switching transportation kind
        operatorSuggestions = []
        showOperatorSuggestions = false
        operatorSelected = false
        selectedOperatorCode = nil
        
        // Load data for the new kind from cache only (no fetch, no save)
        Task {
            let newLines = await sharedDataManager.getLines(for: selectedTransportationKind, allowFetch: false)
            
            await MainActor.run {
                self.all = newLines
                self.allData = self.all
                self.railwayLines = newLines.filter { $0.kind == .railway }
                self.busLines = newLines.filter { $0.kind == .bus }
            }
            
            // Re-filter existing data if line input exists
            if !lineInput.isEmpty && lineInput.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                await filter(lineInput)
            }
            
            // Re-filter operator suggestions if operator input exists
            if !operatorInput.isEmpty && operatorInput.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                await filterOperators(operatorInput)
            }
        }
    }
    
    // MARK: - Input Processing
    /// Process departure station input changes and filter suggestions
    func processdepartureStopInput(_ newValue: String) {
        // Don't show suggestions if line number is being changed
        if isLineNumberChanging {
            return
        }
        
        // Set focus state and reset selection flag when input changes
        isDepartureFieldFocused = true
        departureStopSelected = false
        
        // Clear input if same station as arrival station is entered
        let isSameAsArrival = selectedArrivalStop?.title?.getLocalizedName(fallbackTo: selectedArrivalStop?.name ?? "") ?? selectedArrivalStop?.name ?? "" == newValue
        if isSameAsArrival {
            departureStopInput = ""
            selectedDepartureStop = nil
        } else {
            // Filter suggestions
            filterDepartureStops(newValue)
        }
    }
    
    /// Process arrival station input changes and filter suggestions
    func processarrivalStopInput(_ newValue: String) {
        // Don't show suggestions if line number is being changed
        if isLineNumberChanging {
            return
        }
        
        // Set focus state and reset selection flag when input changes
        isArrivalFieldFocused = true
        arrivalStopSelected = false
        
        // Clear input message on input
        let isSameAsDeparture = selectedDepartureStop?.title?.getLocalizedName(fallbackTo: selectedDepartureStop?.name ?? "") ?? selectedDepartureStop?.name ?? "" == newValue
        if isSameAsDeparture {
            arrivalStopInput = ""
            selectedArrivalStop = nil
        } else {
            // Filter suggestions
            filterArrivalStops(newValue)
        }
    }
    
    /// Process operator input changes and trigger search/filter
    func processOperatorInput(_ newValue: String) {
        // Don't reset operator selection if line number is being changed
        if isLineNumberChanging {
            return
        }
        
        // Trigger filtering when operatorInput changes
        Task { await filterOperators(newValue) }
        
        // Get current selected operator name for comparison
        let currentOperatorName: String? = {
            guard let operatorCode = selectedOperatorCode else { return nil }
            return LocalDataSource.allCases.first(where: {
                $0.transportationType == selectedTransportationKind &&
                $0.operatorCode == operatorCode
            })?.operatorDisplayName
        }()
        
        // Reset operator selection and code when operatorInput changes
        if newValue.isEmpty {
            // Clear operator selection when input is empty
            selectedOperatorCode = nil
            operatorSelected = false
            showOperatorSuggestions = false
            operatorSuggestions = []
            
            // Re-filter lines without operator filter
            if !lineInput.isEmpty {
                Task { await filter(lineInput) }
            }
        } else if operatorSelected {
            // Only reset selection flag if input changes to a different value
            // Don't reset if input matches the currently selected operator name
            let shouldResetSelection = newValue != currentOperatorName
            
            if shouldResetSelection {
                // Reset selection flag if input changes after selection
                operatorSelected = false
                showOperatorSuggestions = false
                operatorSuggestions = []
                selectedOperatorCode = nil
                
                // Re-filter lines without operator filter
                if !lineInput.isEmpty {
                    Task { await filter(lineInput) }
                }
            }
        }
        
        // Show operator selection UI for custom operator input
        if !newValue.isEmpty {
            showOperatorSelection = true
        }
    }
    
    /// Process line input changes and trigger search/filter
    func processLineInput(_ newValue: String) {
        // Don't reset station selection if line number is being changed
        if isLineNumberChanging {
            return
        }
        
        // Trigger filtering when lineInput changes
        // Only show suggestions if operator is selected from dropdown
        Task { await filter(newValue) }
        
        // Reset station selection when lineInput changes
        let currentLineName = selectedLine?.name ?? ""
        let currentLineDisplayName = selectedLine != nil ? lineDisplayName(for: selectedLine!) : ""
        let shouldResetSelection = newValue != currentLineName && newValue != currentLineDisplayName
        
        if shouldResetSelection {
            // Clear line selection but preserve station data and ride time
            selectedLine = nil
            // DO NOT clear departureStopInput, arrivalStopInput, or selectedRideTime
            selectedDepartureStop = nil
            selectedArrivalStop = nil
            showDepartureSuggestions = false
            departureSuggestions = []
            showArrivalSuggestions = false
            arrivalSuggestions = []
            isDepartureFieldFocused = false
            isArrivalFieldFocused = false
            // Reset station selection flags to allow suggestions to show
            departureStopSelected = false
            arrivalStopSelected = false
            lineSelected = false
        }
        
        // Show station selection UI for custom line input
        if !newValue.isEmpty {
            showStationSelection = true
        }
    }
    
    // MARK: - Line Selection Management
    /// Handles line selection and updates all related state
    func selectLine(_ line: TransportationLine) {
        // Set line number changing flag to prevent unwanted suggestions
        isLineNumberChanging = true
        
        // Set selectedLine for proper filtering
        selectedLine = line
        
        // Update display name with operator information on selection
        lineInput = lineDisplayName(for: line)
        
        // Initialize lineBusStops for bus routes
        if line.kind == .bus {
            if let busstopPoleOrder = line.busstopPoleOrder {
                lineBusStops = busstopPoleOrder
                
                // Check if any bus stops need Japanese names and fetch them once
                let needsJapaneseNames = busstopPoleOrder.contains { busStop in
                    let hasJapaneseInNote = (busStop.note?.contains(where: { $0.isJapanese }) ?? false)
                    return (!hasJapaneseInNote || busStop.note?.isEmpty ?? true) && !(busStop.busstopPole?.isEmpty ?? true)
                }
                
                if needsJapaneseNames {
                    Task {
                        await fetchJapaneseNamesForAllBusStops()
                    }
                }
            } else {
                lineBusStops = []
            }
        } else {
            lineBusStops = []
        }
        
        // Update line stops immediately based on line type
        lineStops = getStopsForSelectedLine()
        
        // Preserve existing station and ride time settings instead of clearing them
        // Only clear suggestion displays
        showDepartureSuggestions = false
        departureSuggestions = []
        showArrivalSuggestions = false
        arrivalSuggestions = []
        isDepartureFieldFocused = false
        isArrivalFieldFocused = false
        
        // Set line color or default to accent color
        selectedLineColor = line.lineColor ?? Color.accentString
    }
    
    // MARK: - Form Data Management
    /// Clears all form data and resets to initial state
    func clearAllFormData() {
        // Clear operator name
        operatorInput = ""
        operatorSuggestions = []
        showOperatorSuggestions = false
        operatorSelected = false
        showOperatorSelection = false
        selectedOperatorCode = nil
        
        // Clear line name
        lineInput = ""
        
        // Reset station selection
        resetStationSelection()
        
        // Clear departure and arrival station input fields
        departureStopInput = ""
        arrivalStopInput = ""
        
        // Reset ride time to 0 minutes
        selectedRideTime = 0
        
        // Reset line color to accent (not saved to UserDefaults)
        selectedLineColor = Color.accentString
        
        // Reset transfer settings to none
        selectedTransportation = "none"
        selectedTransferTime = 0
        
        // Hide color selection UI
        showColorSelection = false
    }
    
    // MARK: - Helper Functions
    /// Check if selected line has train timetable support
    func hasTrainTimetableSupport() -> Bool {
        guard let operatorCode = selectedLine?.operatorCode else { return false }
        return LocalDataSource.allCases.first { $0.operatorCode == operatorCode }?.hasTrainTimeTable ?? false
    }
    
    // MARK: - BusstopPole API Integration
    /// Flag to prevent multiple simultaneous API calls
    private var isFetchingJapaneseNames = false
    
    /// Fetches Japanese names for all bus stops in the selected route
    /// Called when a bus line is selected and bus stops need Japanese names
    private func fetchJapaneseNamesForAllBusStops() async {
        guard !isFetchingJapaneseNames else { return }
        
        isFetchingJapaneseNames = true
        defer { isFetchingJapaneseNames = false }
        
        guard let selectedLine = selectedLine,
              let operatorCode = selectedLine.operatorCode,
              let dataSource = LocalDataSource.allCases.first(where: { $0.operatorCode == operatorCode }),
              let url = URL(string: dataSource.apiLink(for: .stop, transportationKind: .bus) + "&odpt:busroutePattern=\(selectedLine.code)") else {
            print("❌ fetchJapaneseNamesForAllBusStops: Missing required data or invalid URL")
            return
        }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
            
            print("🔗 Fetch URL: \(url.absoluteString)")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ fetchJapaneseNamesForAllBusStops: HTTP error \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return
            }
            
            let allBusstopPoles = try JSONDecoder().decode([BusstopPoleDTO].self, from: data)
            let busstopPoles = allBusstopPoles.filter { $0.sameAs != nil && !$0.sameAs!.isEmpty }
            
            await MainActor.run {
                for (index, busStop) in self.lineBusStops.enumerated() {
                    guard let busstopPole = busStop.busstopPole,
                          let matchingBusStopPole = busstopPoles.first(where: { $0.sameAs == busstopPole }) else {
                        continue
                    }
                    
                    let englishName = busstopPole.components(separatedBy: ".").count > 2 ?
                        busstopPole.components(separatedBy: ".")[2].trimmingCharacters(in: .whitespacesAndNewlines) : nil
                    
                    self.lineBusStops[index] = BusStop(
                        name: matchingBusStopPole.title,
                        code: busStop.code,
                        index: busStop.index,
                        lineCode: busStop.lineCode,
                        title: LocalizedTitle(ja: matchingBusStopPole.title, en: englishName),
                        note: matchingBusStopPole.title,
                        busstopPole: busStop.busstopPole
                    )
                }
                
                self.lineStops = self.getStopsForSelectedLine()
            }
        } catch {
            print("❌ fetchJapaneseNamesForAllBusStops: Failed to fetch Japanese names: \(error)")
        }
    }
    
    /// Fetches bus stops from BusstopPole API when busstopPoleOrder is not available
    /// - Parameter line: The selected transportation line
    private func fetchBusStopsFromAPI(for line: TransportationLine) async {
        guard let operatorCode = line.operatorCode,
              let pattern = line.pattern,
              let dataSource = LocalDataSource.allCases.first(where: { $0.operatorCode == operatorCode }),
              let url = URL(string: dataSource.apiLink(for: .stop, transportationKind: .bus) + "&odpt:busroutePattern=\(pattern)") else {
            print("❌ fetchBusStopsFromAPI: Missing required data or invalid URL")
            return
        }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
            
            print("🔗 Fetch URL: \(url.absoluteString)")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ fetchBusStopsFromAPI: HTTP error \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return
            }
            
            let busstopPoles = try JSONDecoder().decode([BusstopPoleDTO].self, from: data)
            let transportationStops = busstopPoles.enumerated().map { index, pole in
                TransportationStop(
                    name: pole.title,
                    code: nil,
                    index: index,
                    lineCode: line.code,
                    title: pole.title,
                    busstopPole: nil,
                    latitude: nil,
                    longitude: nil,
                    kana: nil
                )
            }
            
            await MainActor.run {
                self.lineBusStops = transportationStops.map { BusStop(from: $0) }
            }
        } catch {
            print("❌ fetchBusStopsFromAPI: Failed to fetch bus stops: \(error)")
        }
    }
}
