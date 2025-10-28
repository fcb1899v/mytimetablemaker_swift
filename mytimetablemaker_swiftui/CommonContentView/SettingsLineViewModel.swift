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
    
    let goorbackOptions: [String] = ["back1", "back2", "go1", "go2"]  // Available route options
    
    // Computed properties for UI state checking
    var hasSelectedLine: Bool { selectedLine != nil }
    var hasStops: Bool { 
        return !lineStops.isEmpty
    }
    
    // Get localized display names for direction options
    var goorbackDisplayNames: [String: String] {
        [
            "back1": "Return Route 1".localized,
            "back2": "Return Route 2".localized,
            "go1": "Outbound Route 1".localized,
            "go2": "Outbound Route 2".localized
        ]
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
        print("🔄 selectGoorback called with: \(newGoorback)")
        print("   Current selectedGoorback: \(selectedGoorback)")
        print("   Current selectedLineNumber: \(selectedLineNumber)")
        
        // Early return if same value to avoid unnecessary processing
        if selectedGoorback == newGoorback {
            return
        }
        
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
    private func resetSelections() {
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
    // Only load data for the currently selected transportation kind
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
        guard !t.isEmpty else {
            lineSuggestions = []
            nameCounts = [:]
            showLineSuggestions = false
            return
        }
        
        // Don't show suggestions if line number or direction is being changed or line is already selected
        if isLineNumberChanging || isGoorBackChanging || lineSelected { return }
        
        // Use cached data for better performance based on transportation kind
        let searchData = selectedTransportationKind == .railway ? railwayLines: busLines
        
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
            // Only search if query has 2 or more characters for bus routes
            guard t.count >= 2 else {
                lineSuggestions = []
                showLineSuggestions = false
                nameCounts = [:]
                return
            }
            
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
        lineSuggestions = Array(allResults.prefix(100))
        
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
    
    // Get localized display name for transportation line
    func lineDisplayName(for line: TransportationLine) -> String {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        if line.kind == .bus {
            return currentLanguage == "ja" ? line.title! :
            (line.busRouteEnglishName ?? line.railwayTitle?.en ?? line.name)
        }
        
        guard let railwayTitle = line.railwayTitle else { return line.name }
        return railwayTitle.getLocalizedName(fallbackTo: line.name)
    }
    
    // Get localized display name based on operator code
    func getOperatorDisplayName(for operatorCode: String, lineKind: TransportationLine.Kind? = nil) -> String {
        let operatorName = operatorCode.replacingOccurrences(of: "odpt.Operator:", with: "")
        return NSLocalizedString(operatorName, comment: "Railway operator name")
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
    
    // Extract bus stops from bus route data
    func extractStopsFromBusRoute(_ busRoute: [String: Any], searchMethod: String, searchValue: String, lineCode: String? = nil) -> [TransportationStop]? {
        guard let busStopData = busRoute["odpt:busstopPoleOrder"] as? [[String: Any]] else { return nil }
        
        let busStops: [TransportationStop] = busStopData.compactMap { busStopInfo -> TransportationStop? in
            let note = busStopInfo["odpt:note"] as? String ?? ""
            let busstopPole = busStopInfo["odpt:busstopPole"] as? String ?? ""
            
            guard !note.isEmpty || !busstopPole.isEmpty else { return nil }
            
            // Check if note contains Japanese characters
            let hasJapaneseInNote = note.contains(where: { $0.isJapanese })
            
            // If note doesn't contain Japanese or is empty, and we have busstopPole, fetch from API
            if (!hasJapaneseInNote || note.isEmpty) && !busstopPole.isEmpty {
                // Japanese name will be fetched later in selectLine
                // For now, use busstopPole as fallback
                let finalNote = note.isEmpty ? busstopPole : note
                let title = String.generateBusStopTitle(note: finalNote, busstopPole: busstopPole)
                let stopName = title?.getLocalizedName(fallbackTo: finalNote) ?? finalNote
                
                return TransportationStop(
                    kind: .bus,
                    name: stopName,
                    code: busstopPole.isEmpty ? nil : busstopPole,
                    index: busStopInfo["odpt:index"] as? Int,
                    lineCode: lineCode,
                    title: title,
                    note: finalNote,
                    busstopPole: busstopPole.isEmpty ? nil : busstopPole
                )
            }
            
            // Use shared bus stop title generation logic for stops with Japanese
            let title = String.generateBusStopTitle(note: note, busstopPole: busstopPole)
            let stopName = title?.getLocalizedName(fallbackTo: note) ?? (note.isEmpty ? busstopPole : note)
            
            return TransportationStop(
                kind: .bus,
                name: stopName,
                code: busstopPole.isEmpty ? nil : busstopPole,
                index: busStopInfo["odpt:index"] as? Int,
                lineCode: lineCode,
                title: title,
                note: note,
                busstopPole: busstopPole.isEmpty ? nil : busstopPole
            )
        }
        
        return busStops.isEmpty ? nil : busStops
    }
    
    
    // Extract stations from railway data
    func extractStationsFromRailway(_ railway: [String: Any], searchMethod: String, searchValue: String, lineCode: String? = nil) -> [TransportationStop]? {
        let stations: [TransportationStop]? = (railway["odpt:stationOrder"] as? [[String: Any]])?.compactMap { stationInfo in
            (stationInfo["odpt:stationTitle"] as? [String: Any]).map { stationTitle in
                let jaName = stationTitle["ja"] as? String
                let enName = stationTitle["en"] as? String
                let stationCode = stationInfo["odpt:station"] as? String
                let stationIndex = stationInfo["odpt:index"] as? Int
                
                return TransportationStop(
                    kind: .railway,
                    name: jaName ?? enName ?? "Unknown station",
                    code: stationCode,
                    index: stationIndex,
                    lineCode: lineCode,
                    title: LocalizedTitle(ja: jaName, en: enName),
                    note: nil,
                    busstopPole: nil
                )
            }
        }
        return !(stations?.isEmpty ?? true) ? stations : nil
    }
    
    // Get stops information for the selected line (unified for both railway and bus)
    func getStopsForSelectedLine() -> [TransportationStop] {
        guard let selectedLine = selectedLine else { 
            print("🚫 getStopsForSelectedLine: No selected line")
            return [] 
        }
        
        print("🚌 getStopsForSelectedLine: Line kind = \(selectedLine.kind), code = \(selectedLine.code)")
        
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
                print("🚌 getStopsForSelectedLine: Found \(stops.count) bus stops from lineBusStops")
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
                print("🚌 getStopsForSelectedLine: Found \(stops.count) bus stops from busstopPoleOrder")
                return stops
            } else {
                print("🚫 getStopsForSelectedLine: No busstopPoleOrder found")
                
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
            
            print("🚂 getStopsForSelectedLine: Found \(stations.count) railway stations")
            return stations
        }
        
        print("🚫 getStopsForSelectedLine: Returning empty array")
        return []
    }
    
    // Parse stations by line code
    // Generic parser for both bus stops and railway stations by line code
    private func parseStationsByLineCode(_ data: Data, lineCode: String, isBus: Bool) -> [TransportationStop]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let array = json as? [[String: Any]] else { return nil }
            
            for item in array {
                if isBus != ((item["@type"] as? String) == "odpt:BusroutePattern") { continue }
                
                if let itemCode = item["owl:sameAs"] as? String, itemCode == lineCode {
                    return isBus ? 
                        extractStopsFromBusRoute(item, searchMethod: "owl:sameAs", searchValue: lineCode, lineCode: lineCode) :
                        extractStationsFromRailway(item, searchMethod: "owl:sameAs", searchValue: lineCode, lineCode: lineCode)
                }
            }
        } catch {
            print("❌ Failed to parse stations by line code: \(error)")
        }
        return nil
    }
    
    // Load local data from cache or bundle
    func loadLocalData(for filename: String) -> Data? {
        // Try ODPT cache first
        let cache = CacheStore()
        if let data = cache.loadData(for: filename) {
            return data
        }
        
        // Try LineData folder
        if let lineDataURL = Bundle.main.url(forResource: "LineData", withExtension: nil) {
            let jsonURL = lineDataURL.appendingPathComponent(filename)
            if let data = try? Data(contentsOf: jsonURL) {
                return data
            }
        }
        
        // Fallback to bundle
        guard let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json") else {
            print("❌ File not found: \(filename)")
            return nil
        }
        return try? Data(contentsOf: url)
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
    
    // Check if custom line station input is complete
    func isCustomLineStationInputComplete() -> Bool {
        return !lineInput.isEmpty && !departureStopInput.isEmpty && !arrivalStopInput.isEmpty && departureStopInput != arrivalStopInput
    }
    
    // Set line color without saving to UserDefaults
    func setLineColor(_ color: String) {
        selectedLineColor = color
        showColorSelection = false
    }
    
    // Common save processing for all line types
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
        print("🔍 checkSavedLineInData called")
        print("   selectedGoorback: \(selectedGoorback)")
        print("   selectedLineNumber: \(selectedLineNumber)")
        print("   lineInput: '\(lineInput)'")
        
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
                    
                    // Set lineSelected flag to true when line is found and restored
                    let lineSelectedKey = selectedGoorback.lineSelectedKey(selectedLineNumber - 1)
                    UserDefaults.standard.set(true, forKey: lineSelectedKey)
                    
                    // Set bus stops for bus routes
                    if foundLine.kind == .bus {
                        if let busstopPoleOrder = foundLine.busstopPoleOrder {
                            let busStops: [Station] = busstopPoleOrder.compactMap { busStop -> Station? in
                                guard !busStop.name.isEmpty else { return nil }
                                return Station(
                                    name: busStop.name,
                                    code: busStop.code,
                                    index: busStop.index,
                                    lineCode: selectedLine?.code,
                                    title: busStop.title
                                )
                            }
                            lineStations = busStops
                        }
                    }
                    
                    // Don't show color selection for saved lines - user can manually change color if needed
                    showColorSelection = false
                    
                    // Update transportation kind to match found line
                    selectedTransportationKind = foundLine.kind
                    
                    print("✅ Restored saved line: \(foundLine.name) (\(foundLine.kind.rawValue))")
                }
            } else {
                // Keep user input even if saved line not found in current data
                await MainActor.run {
                    // Don't clear lineInput - preserve user's saved line name
                    selectedLine = nil
                    lineStations = []
                    showStationSelection = false
                    
                    // Set lineSelected flag to false when line is not found
                    let lineSelectedKey = selectedGoorback.lineSelectedKey(selectedLineNumber - 1)
                    UserDefaults.standard.set(false, forKey: lineSelectedKey)
                    
                    print("⚠️ Saved line '\(lineInput)' not found in current data - keeping user input")
                }
            }
        }
        
        // Always load station settings regardless of line status
        // Station information is independent of line information
        await MainActor.run {
            loadStationSettings()
            print("✅ Loaded station settings independently of line status")
        }
        
        // Station information is now loaded directly from UserDefaults
        // No need for complex station object restoration
        print("✅ Station information loaded from UserDefaults")
    }
    
    // Helper method to find saved line in current data
    private func findSavedLineInData() -> TransportationLine? {
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
    
    // MARK: - Data Persistence
    // Save all information when save button is pressed
    func saveAllDataToUserDefaults() async {
        let lineIndex = selectedLineNumber - 1
        
        // Save line name and code
        if !lineInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lineNameKey = selectedGoorback.lineNameKey(lineIndex)
            UserDefaults.standard.set(lineInput, forKey: lineNameKey)
            
            let lineCodeKey = selectedGoorback.lineCodeKey(lineIndex)
            let lineCodeToSave = all.first { line in
                if line.kind == .bus {
                    return line.name == lineInput ||
                    line.railwayTitle?.getLocalizedName() == lineInput ||
                    line.busRouteEnglishName == lineInput
                } else {
                    return line.name == lineInput || line.railwayTitle?.getLocalizedName() == lineInput
                }
            }?.lineCode ?? ""
            
            UserDefaults.standard.set(lineCodeToSave, forKey: lineCodeKey)
        }
        
        // Save line color
        if let lineColor = selectedLineColor, !lineColor.isEmpty {
            let lineColorKey = selectedGoorback.lineColorKey(lineIndex)
            UserDefaults.standard.set(lineColor, forKey: lineColorKey)
        }
        
        // Save transportation kind
        let lineKindKey = selectedGoorback.lineKindKey(lineIndex)
        UserDefaults.standard.set(selectedTransportationKind.rawValue, forKey: lineKindKey)
                
        // Update selectedLine's lineDirection
        if var updatedLine = selectedLine {
            print("🔍 Before update - selectedLine.lineDirection: \(selectedLine?.lineDirection ?? "nil")")
            
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
            
            print("✅ Saved departure stop: \(departureStopInput)")
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
            
            print("✅ Saved arrival stop: \(arrivalStopInput)")
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
        print("🔍 loadStationSettings - selectedGoorback: \(selectedGoorback), selectedLineNumber: \(selectedLineNumber), currentLineIndex: \(currentLineIndex)")
        
        let departureKey = selectedGoorback.departStationKey(currentLineIndex)
        print("   Departure key: \(departureKey)")
        if let savedDeparture = UserDefaults.standard.string(forKey: departureKey) {
            self.departureStopInput = savedDeparture
            print("✅ Restored departure station: \(savedDeparture)")
        } else {
            self.departureStopInput = ""
            print("   No saved departure found")
        }
        
        let arrivalKey = selectedGoorback.arriveStationKey(currentLineIndex)
        print("   Arrival key: \(arrivalKey)")
        if let savedArrival = UserDefaults.standard.string(forKey: arrivalKey) {
            self.arrivalStopInput = savedArrival
            print("✅ Restored arrival station: \(savedArrival)")
        } else {
            self.arrivalStopInput = ""
            print("   No saved arrival found")
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
        
        let colorKey = selectedGoorback.lineColorKey(currentLineIndex)
        self.selectedLineColor = UserDefaults.standard.string(forKey: colorKey)
        
        let lineNameKey = selectedGoorback.lineNameKey(currentLineIndex)
        if let savedLineName = UserDefaults.standard.string(forKey: lineNameKey) {
            self.lineInput = savedLineName
        }
        
        let lineKindKey = selectedGoorback.lineKindKey(currentLineIndex)
        if let savedKindString = UserDefaults.standard.string(forKey: lineKindKey) {
            self.selectedTransportationKind = TransportationLine.Kind(rawValue: savedKindString) ?? .railway
        } else {
            self.selectedTransportationKind = .railway
        }
        
        let departureKey = selectedGoorback.departStationKey(currentLineIndex)
        if let savedDeparture = UserDefaults.standard.string(forKey: departureKey) {
            self.departureStopInput = savedDeparture
            print("✅ Restored departure station: \(savedDeparture)")
        } else {
            self.departureStopInput = ""
            print("   No saved departure found")
        }
        
        let arrivalKey = selectedGoorback.arriveStationKey(currentLineIndex)
        if let savedArrival = UserDefaults.standard.string(forKey: arrivalKey) {
            self.arrivalStopInput = savedArrival
            print("✅ Restored arrival station: \(savedArrival)")
        } else {
            self.arrivalStopInput = ""
            print("   No saved arrival found")
        }
        
        let rideTimeKey = selectedGoorback.rideTimeKey(currentLineIndex)
        let savedRideTime = UserDefaults.standard.integer(forKey: rideTimeKey)
        // Use saved value or default to 0 if not set
        self.selectedRideTime = savedRideTime > 0 ? savedRideTime : 0
        
        // Load lineSelected flag from UserDefaults
        let lineSelectedKey = selectedGoorback.lineSelectedKey(currentLineIndex)
        self.lineSelected = UserDefaults.standard.bool(forKey: lineSelectedKey)
        
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
    // Clear all timetable data for all calendar types and lines
    private func clearAllTimetableData() async {
        print("🗑️ Clearing all existing timetable data...")
        
        // Clear data for all calendar types
        for calendarType in ODPTCalendarType.allCases {
            clearTimetableData(calendarType: calendarType)
        }
        
        // Clear cached calendar types to force refresh
        if let selectedLine = selectedLine {
            let cacheKey = "\(selectedLine.code)_\(selectedLine.kind.rawValue)_calendarTypes"
            UserDefaults.standard.removeObject(forKey: cacheKey)
            
            // Clear route-specific cache
            for goorback in goorbackOptions {
                let routeCacheKey = "\(goorback)_calendarTypes"
                UserDefaults.standard.removeObject(forKey: routeCacheKey)
            }
        }
        
        print("✅ All timetable data and cache cleared")
    }
    
    // MARK: - Unified Timetable Data Processing
    // Get timetable data and extract departure/arrival times for selected stops/stations
    func getTimeTableData() async -> [ODPTCalendarType: [any TransportationTime]] {
        
        // Skip timetable generation if not all required fields are filled
        guard isAllNotEmpty else {
            print("⚠️ Skipping timetable generation: not all required fields are filled")
            return [:]
        }
        
        guard let selectedLine = selectedLine else {
            print("⚠️ No line selected")
            return [:]
        }
        
        print("🚌🚂 Starting \(selectedLine.kind.rawValue) timetable data generation")
        print("🚌🚂 Departure: \(selectedDepartureStop?.name ?? "Unknown") (Code: \(selectedDepartureStop?.code ?? "nil"))")
        print("🚌🚂 Arrival: \(selectedArrivalStop?.name ?? "Unknown") (Code: \(selectedArrivalStop?.code ?? "nil"))")
        
        // Clear existing timetable data for all calendar types before generating new data
        await clearAllTimetableData()
        
        // Get available calendar types for this line
        let availableCalendarTypes = await getAvailableCalendarTypes()
        print("📅 Available calendar types for \(selectedLine.name): \(availableCalendarTypes.map { $0.debugDisplayName })")
        
        // Process data for each available calendar type
        var allTimes: [ODPTCalendarType: [any TransportationTime]] = [:]
        
        for calendarType in availableCalendarTypes {
            
            print("🚌🚂 Processing \(calendarType.debugDisplayName) \(selectedLine.kind.rawValue) timetable data")
            
            let times: [any TransportationTime] = (selectedLine.kind == .bus) ? 
                await processBusTimetableData(calendarType: calendarType): 
                await processTrainTimetableData(calendarType: calendarType)
            
            // Save times for this specific calendar type
            allTimes[calendarType] = times
            
            print("✅ \(calendarType.debugDisplayName) \(selectedLine.kind.rawValue)s: \(times.count)")
        }
        
        print("✅ \(selectedLine.kind.rawValue.capitalized) timetable generation completed")
        
        return allTimes        
    }
    
    // MARK: - Available Calendar Types Detection
    // Get available calendar types for the selected line by fetching from timetable API
    private func getAvailableCalendarTypes() async -> [ODPTCalendarType] {
        guard let selectedLine = selectedLine,
              let operatorCode = selectedLine.operatorCode,
              let selectedOperator = LocalDataSource.allCases.first(where: { $0.operatorCode == operatorCode }) else {
            print("⚠️ Cannot determine available calendar types - using default")
            return [.weekday, .holiday] // Fallback to default
        }
        
        // Check cache first
        let cacheKey = "\(selectedLine.code)_\(selectedLine.kind.rawValue)_calendarTypes"
        if let cachedTypes = UserDefaults.standard.stringArray(forKey: cacheKey),
           !cachedTypes.isEmpty {
            let cachedCalendarTypes = cachedTypes.compactMap { ODPTCalendarType(rawValue: $0) }
            if !cachedCalendarTypes.isEmpty {
                print("📅 Using cached calendar types: \(cachedCalendarTypes.map { $0.debugDisplayName })")
                return cachedCalendarTypes
            }
        }
        
        // Fetch available calendar types from timetable API
        let availableTypes = await fetchAvailableCalendarTypes(dataSource: selectedOperator)
        
        // Cache the results
        let typeStrings = availableTypes.map { $0.rawValue }
        UserDefaults.standard.set(typeStrings, forKey: cacheKey)
        
        // Also cache for each route direction for TimetableContentView
        for goorback in goorbackOptions {
            let routeCacheKey = "\(goorback)_calendarTypes"
            UserDefaults.standard.set(typeStrings, forKey: routeCacheKey)
        }
        
        // Ensure we have at least weekday and holiday as fallback
        if availableTypes.isEmpty {
            print("⚠️ No calendar types found - using default fallback")
            return [.weekday, .holiday]
        }
        
        print("📅 Available calendar types: \(availableTypes.map { $0.debugDisplayName })")
        return availableTypes
    }
    
    // Fetch available calendar types from timetable API
    private func fetchAvailableCalendarTypes(dataSource: LocalDataSource) async -> [ODPTCalendarType] {
        do {
            let apiLink: String
            if selectedLine?.kind == .bus {
                guard let selectedLineTitle = selectedLine?.title else { return [] }
                // Fetch without calendar filter to get all available calendar types
                apiLink = "\(dataSource.apiLink(for: .timetable, transportationKind: .bus))&dc:title=\(selectedLineTitle)"
            } else {
                guard let selectedLineCode = selectedLine?.code else { return [] }
                // Fetch without calendar filter to get all available calendar types
                apiLink = "\(dataSource.apiLink(for: .timetable, transportationKind: .railway))&odpt:railway=\(selectedLineCode)"
            }
            
            print("🔍 Fetching available calendar types from: \(apiLink)")
            
            guard let url = URL(string: apiLink) else { return [] }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check HTTP status code
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
            
            // Convert to ODPTCalendarType array
            let availableTypes = foundCalendarTypes.compactMap { ODPTCalendarType(rawValue: $0) }
                .sorted { $0.rawValue < $1.rawValue }
            
            print("📅 Found calendar types: \(availableTypes.map { $0.displayName })")
            return availableTypes
            
        } catch {
            print("❌ Error fetching available calendar types: \(error.localizedDescription)")
            return []
        }
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
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    print("❌ Calendar type \(calendarType.displayName) not found (404)")
                    return false
                }
                if httpResponse.statusCode != 200 {
                    print("❌ Calendar type \(calendarType.displayName) returned status \(httpResponse.statusCode)")
                    return false
                }
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            
            // Consider it available if we get a valid response (even empty array means the calendar type exists)
            // But we can also check if there's actual timetable data
            let hasTimetableData = json.contains { timetable in
                if selectedLine?.kind == .bus {
                    return timetable["odpt:busTimetableObject"] != nil
                } else {
                    return timetable["odpt:trainTimetableObject"] != nil
                }
            }
            
            if hasTimetableData {
                print("✅ Calendar type \(calendarType.displayName) has timetable data")
            } else {
                print("⚠️ Calendar type \(calendarType.displayName) exists but has no timetable data")
            }
            
            return true // Return true if the calendar type exists, even without data
            
        } catch {
            print("❌ Error testing calendar type \(calendarType.displayName): \(error.localizedDescription)")
            return false
        }
    }
    
    // Process bus timetable data for specific day type
    private func processBusTimetableData(calendarType: ODPTCalendarType) async -> [any TransportationTime] {
        print("🚌 Processing \(calendarType.displayName) bus timetable data")
        print("🚌 Departure stop busstopPole: \(selectedDepartureStop?.busstopPole ?? "nil")")
        print("🚌 Arrival stop busstopPole: \(selectedArrivalStop?.busstopPole ?? "nil")")
        
        // Fetch bus timetable data from API
        let busTimetableData = await fetchBusTimetableData(calendarType: calendarType)
        
        // Extract bus information and timetable objects in a single loop
        var transportationTimes: [any TransportationTime] = []
        
        for timetable in busTimetableData {
            
            guard let busTimetableObjects = timetable["odpt:busTimetableObject"] as? [[String: Any]] else {
                print("   ❌ Failed to extract bus timetable objects")
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
                print("🕐 Time comparison: \(depTime) (\(depMinutes)min) → \(arrTime) (\(arrMinutes)min)")
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
                    print("✅ Added bus time: \(depTime) → \(arrTime) (\(rideTime)min)")
                } else {
                    print("❌ Skipped bus time: \(depTime) → \(arrTime) (arrival not later than departure)")
                }
            } else {
                print("❌ Missing times: departure=\(departureTime ?? "nil"), arrival=\(arrivalTime ?? "nil")")
            }
        }
        
        print("🚌 Bus Times: \(transportationTimes.count) buses")
        
        return transportationTimes
    }
    
    // Fetch bus timetable data from API
    private func fetchBusTimetableData(calendarType: ODPTCalendarType) async -> [[String: Any]] {
        guard let operatorCode = selectedLine?.operatorCode,
              let selectedLineTitle = selectedLine?.title,
              let selectedOperator = LocalDataSource.allCases.first(where: { $0.operatorCode == operatorCode }) else { return [] }
        
        print("🔍 Calendar type: \(calendarType.rawValue)")
        
        // Use bus-specific timetable API (force bus API regardless of transportationType)
        let apiLink = "\(selectedOperator.apiLink(for: .timetable, transportationKind: .bus))&dc:title=\(selectedLineTitle)&odpt:calendar=\(calendarType.rawValue)"
        print("🔍 Bus timetable API link: \(apiLink)")
        
        guard let url = URL(string: apiLink) else {
            print("❌ Invalid bus timetable API URL")
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                print("❌ Failed to parse bus timetable JSON")
                return []
            }
            
            print("✅ Bus timetable data fetched: \(json.count) timetables")
            return json
        } catch {
            print("❌ Error fetching bus timetable data: \(error)")
            return []
        }
    }

    
    // Process train timetable data for specific day type
    private func processTrainTimetableData(calendarType: ODPTCalendarType) async -> [any TransportationTime] {
        print("🚂 Processing \(calendarType.displayName) train timetable data")
        
        // Fetch train timetable data from API
        let trainTimetableData = await fetchTrainTimetableData(calendarType: calendarType)
        
        // Extract train information and timetable objects in a single loop
        var transportationTimes: [any TransportationTime] = []
        
        for timetable in trainTimetableData {
            
            guard let trainNumber = timetable["odpt:trainNumber"] as? String,
                  let trainType = timetable["odpt:trainType"] as? String,
                  let trainTimetableObjects = timetable["odpt:trainTimetableObject"] as? [[String: Any]] else {
                print("   ❌ Failed to extract required fields")
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
        
        print("🚂 Train Times: \(transportationTimes.count) trains")
        
        return transportationTimes
    }
    
    // Fetch train timetable data from API
    private func fetchTrainTimetableData(calendarType: ODPTCalendarType) async -> [[String: Any]] {
        guard let operatorCode = selectedLine?.operatorCode,
              let selectedLineCode = selectedLine?.code,
              let selectedOperator = LocalDataSource.allCases.first(where: { $0.operatorCode == operatorCode }) else { return [] }
        
        print("🔍 Calendar type: \(calendarType.rawValue)")
        
        let apiLink = "\(selectedOperator.apiLink(for: .timetable))&odpt:railway=\(selectedLineCode)&odpt:calendar=\(calendarType.rawValue)"
        
        do {
            guard let url = URL(string: apiLink) else {
                print("❌ Invalid URL: \(apiLink)")
                return []
            }
            print("🌐 Fetching train timetable from: \(apiLink)")

            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                print("❌ Failed to parse train timetable JSON")
                return []
            }
            
            print("✅ Fetched \(json.count) train timetable records for \(calendarType.rawValue)")
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
            print("⚠️ Skipping timetable generation: not all required fields are filled")
            return [:]
        }
        
        print("🔗 Get Timetable Links for both directions:")
        
        // Get the actual direction from selectedLine
        let actualDirection = selectedLine?.lineDirection ?? ""
        print("🔍 Actual direction from selectedLine: \(actualDirection)")
        
        // Get actual directions from JSON data with fallback
        let ascendingDirection = selectedLine?.ascendingRailDirection ?? actualDirection
        let descendingDirection = selectedLine?.descendingRailDirection ?? actualDirection
        
        print("🔍 Using directions:")
        print("   Ascending: \(ascendingDirection)")
        print("   Descending: \(descendingDirection)")
        
        var allTimes: [ODPTCalendarType: [any TransportationTime]] = [:]
        
        // Get available calendar types dynamically
        let availableCalendarTypes = await getAvailableCalendarTypesForStation()
        print("📅 Available calendar types for station: \(availableCalendarTypes.map { $0.debugDisplayName })")
        
        for calendarType in availableCalendarTypes {
            print("🔄 Processing \(calendarType.debugDisplayName) data for both directions")
            
            // Get data for both directions
            let directions = [ascendingDirection, descendingDirection]
            let directionNames = ["ascending", "descending"]
            var directionResults: [[any TransportationTime]] = []
            
            for (index, direction) in directions.enumerated() {
                print("📊 Get \(directionNames[index].capitalized) Direction Timetable Data:")
                
                // Get departure and arrival data for this direction
                let departureLink = stationTimetableApiLink(isDeparture: true, calendarType: calendarType, direction: direction)
                let arrivalLink = stationTimetableApiLink(isDeparture: false, calendarType: calendarType, direction: direction)
                
                print("🔗 Departure link: \(departureLink)")
                print("🔗 Arrival link: \(arrivalLink)")
                
                let departureData = await fetchStationTimetableData(from: departureLink)
                let arrivalData = await fetchStationTimetableData(from: arrivalLink)
                
                print("\(directionNames[index]) \(calendarType.debugDisplayName) Departure count: \(departureData.count)")
                print("\(directionNames[index]) \(calendarType.debugDisplayName) Arrival count: \(arrivalData.count)")
                
                // Process this direction if we have both departure and arrival data
                var result: [any TransportationTime] = []
                if departureData.count > 0 {
                    print("Get \(directionNames[index]) departure timetable not using train numbers (no trains with numbers found)")
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
    
    // MARK: - Available Calendar Types Detection
    // Get available calendar types for station timetable
    private func getAvailableCalendarTypesForStation() async -> [ODPTCalendarType] {
        let operatorCode = selectedLine?.operatorCode ?? ""
        let dataSource = LocalDataSource.allCases.first { $0.operatorCode == operatorCode }
        let stationTimetableApiLink = dataSource?.apiLink(for: .stopTimetable) ?? ""
        
        // Test each calendar type by making API calls
        var availableTypes: [ODPTCalendarType] = []
        
        for calendarType in ODPTCalendarType.allCases {
            let testLink = "\(stationTimetableApiLink)&acl:consumerKey=\(odptAccessKey)&owl:sameAs=odpt.StationTimetable:\(operatorCode).\(calendarType.rawValue)"
            
            do {
                let data = try await fetchData(from: testLink)
                if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]], !json.isEmpty {
                    availableTypes.append(calendarType)
                    print("✅ Calendar type \(calendarType.debugDisplayName) is available")
                }
            } catch {
                print("❌ Calendar type \(calendarType.debugDisplayName) is not available: \(error)")
            }
        }
        
        // Fallback to basic types if none found
        if availableTypes.isEmpty {
            availableTypes = [.weekday, .saturdayHoliday]
            print("⚠️ No calendar types found, using fallback: weekday, saturdayHoliday")
        }
        
        return availableTypes
    }
    
    // MARK: - Data Fetching
    // Simple data fetching method for API calls
    private func fetchData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
        }
        
        return data
    }
    
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
        
        print("🔍 Station timetable link - isDeparture: \(isDeparture), calendarType: \(calendarType.debugDisplayName), direction: \(directionName), apiLink: \(apiLink)")
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
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
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
                
                print("✅ Parsed \(result.count) valid timetable entries (sorted ascending)")
                return result
                
                } else {
                print("❌ No stationTimetableObject found in JSON data")
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

        print("🚀🚀🚀 getEstimatedTrainTime STARTED 🚀🚀🚀")
        print("🔍 getEstimatedTrainTime: Processing \(departureTimetableData.count) departure records and \(arrivalTimetableData.count) arrival records")

        // Get unique train types from departure data
        let trainTypeList = departureTimetableData.trainTypeList
        print("🔍 Processing train types: \(trainTypeList)")
        
        var allTransportationTimes: [any TransportationTime] = []
        
        // Process each train type separately
        for trainType in trainTypeList {
            print("🚂 Processing train type: \(trainType)")
            
            // Filter departure and arrival data by train type
            let departureData = departureTimetableData.filtered(by: trainType)
            let arrivalData = arrivalTimetableData.filtered(by: trainType)
            print("   Departure data count: \(departureData.count)")
            print("   Arrival data count: \(arrivalData.count)")
            
            // Skip if no data for this train type
            guard !departureData.isEmpty else { continue }
            
            let terminalDepartureData = departureData.filter { data in
                !data.destinationStation.isEmpty && data.destinationStation == selectedArrivalStop?.code
            }
            
            print("📊 terminalDepartureData: \(terminalDepartureData)")
            
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

            print("🚉 terminalTrainTimes count: \(terminalTrainTimes.count)")
            
            // Remove terminalDepartureData from departureData
            let filteredDepartureData = departureData.filter { data in
                data.destinationStation.isEmpty || data.destinationStation != selectedArrivalStop?.code
            }
            
            print("📊 Filtered departure data: \(departureData.count) → \(filteredDepartureData.count)")
            
            // Process this train type with filtered data
            print("🔬 Using algorithm for train type: \(trainType)")
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
            } else {
                print("❌ No data for train type: \(trainType)")
            }
        }
        
        // Sort all train times by departure time
        let sortedTrainTimes = allTransportationTimes.sorted { first, second in
            let firstMinutes = first.departureTime.timeToMinutes
            let secondMinutes = second.departureTime.timeToMinutes
            return firstMinutes < secondMinutes
        }
        
        print("✅ getEstimatedTrainTime: Generated \(sortedTrainTimes.count) total train times")
        print("🏁🏁🏁 getEstimatedTrainTime FINISHED 🏁🏁🏁")
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
                let departureIndex = selectedDepartureStop?.index ?? -1
                let arrivalIndex = selectedArrivalStop?.index ?? -1
                let destinationIndex = getStationIndexFromDestinationStation(data.destinationStation) ?? -1
                print("🚫 Filtered out estimated train - Departure: \(departureIndex), Arrival: \(arrivalIndex), Destination: \(destinationIndex)")
                return false
            }
            return true
        }
        print("📊 Filtered departure data: \(departureData.count) → \(filteredDepartureData.count)")
        
        // 0.5) Filter arrival data to match departure destinations
        let filteredArrivalData = arrivalData.filter { arrivalDataItem in
            // Check if there's a matching departure with the same destination
            return filteredDepartureData.contains { departureDataItem in
                departureDataItem.destinationStation == arrivalDataItem.destinationStation
            }
        }
        print("📊 Filtered arrival data: \(arrivalData.count) → \(filteredArrivalData.count)")
        
        // 1) Build departure and arrival station data
        let departureTimes = filteredDepartureData.compactMap(\.departureTime).filter { !$0.isEmpty }
        let arrivalTimes = filteredArrivalData.compactMap(\.departureTime).filter { !$0.isEmpty }

        // 2) Sort time strings directly
        let sortedDepartureTimes = departureTimes.sorted()
        let sortedArrivalTimes = arrivalTimes.sorted()
        print("📊 \(sortedDepartureTimes.count) departure times, \(sortedArrivalTimes.count) arrival times")
        print("📊 Departure Times: \(sortedDepartureTimes)")
        print("📊 Arrival Times: \(sortedArrivalTimes)")
        print("📊 User input: \(approxRideTime) min (no range restrictions)")

        
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
            print("🚫 Line code mismatch - skipping destination station")
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
            let matchType = station.code == destinationStationCode ? "code" : "name"
            if station.index == -1 {
                print("✅ Found station by \(matchType) match: \(station.name) (index: -1)")
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
        clearTimetableData(calendarType: calendarType)
        
        print("💾 Saving timetable data for \(calendarType.debugDisplayName)")
        print("📊 Total TransportationTime objects: \(transportationTimes.count)")
        
        // Group TransportationTime objects by hour
        var hourlyTransportationTimes: [Int: [any TransportationTime]] = [:]
        
        for (index, transportationTimeItem) in transportationTimes.enumerated() {
            let timeComponents = transportationTimeItem.departureTime.components(separatedBy: ":")
            if timeComponents.count == 2, let hour = Int(timeComponents[0]) {
                hourlyTransportationTimes[hour, default: []].append(transportationTimeItem)
                if index < 5 {
                    if let busTime = transportationTimeItem as? BusTime {
                        print("🚌\(busTime.busNumber ?? "N/A"): \(busTime.departureTime) → \(busTime.arrivalTime) (\(busTime.rideTime)min)")
                    } else if let trainTime = transportationTimeItem as? TrainTime {
                        print("🚉\(trainTime.trainNumber ?? "N/A") (\(trainTime.trainType?.split(separator: ".").last ?? "N/A")): \(trainTime.departureTime) → \(trainTime.arrivalTime) (\(trainTime.rideTime)min)")
                    }
                }
            }
        }
        
        // Sort and save to UserDefaults using unified TransportationTime format
        for (hour, transportationTimesForHour) in hourlyTransportationTimes {
            let sortedTransportationTimes = transportationTimesForHour.sorted { 
                $0.departureTime < $1.departureTime 
            }
            selectedGoorback.saveTransportationTimes(sortedTransportationTimes, calendarType, selectedLineNumber - 1, hour)
        }
        
        // Save train type list for the entire timetable
        let allTransportationTimes = hourlyTransportationTimes.values.flatMap { $0 }
        selectedGoorback.saveTrainTypeList(allTransportationTimes, calendarType, selectedLineNumber - 1)
        
        // Ensure all UserDefaults changes are synchronized to disk
        UserDefaults.standard.synchronize()
        
        // Summary log
        print("📈 Summary - Saved \(hourlyTransportationTimes.count) hours of timetable data")
        
        // Print ride time list for verification
        print("AllTransportationTimes: \(allTransportationTimes.count)")
    }
    
    // MARK: - Common Timetable Data Finalization with Arrays
    // Common post-processing for timetable data with weekday/weekend arrays
    func finalizeTimetableData(weekdayTimes: [any TransportationTime], weekendTimes: [any TransportationTime]) async {
        // Save timetable data using unified TransportationTime format
        saveTimetableToUserDefaults(transportationTimes: weekdayTimes, calendarType: .weekday)
        saveTimetableToUserDefaults(transportationTimes: weekendTimes, calendarType: .holiday)
        
        // Save all data after timetable data has been processed and saved
        await saveAllDataToUserDefaults()
        
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
        await saveAllDataToUserDefaults()
        
        // Notify that timetable data has been updated
        NotificationCenter.default.post(name: NSNotification.Name("TimetableDataUpdated"), object: nil)
    }
    
    
    // MARK: - Timetable Data Clearing
    // Clear existing timetable data for specified day type
    private func clearTimetableData(calendarType: ODPTCalendarType) {
        print("🧹 Clearing timetable data for \(calendarType.debugDisplayName)")
        
        // Clear all hours (4-24) for the specified calendar type and line
        for hour in 4...25 {
            let timetableKey = selectedGoorback.timetableKey(calendarType, selectedLineNumber - 1, hour)
            let timetableRideTimeKey = selectedGoorback.timetableRideTimeKey(calendarType, selectedLineNumber - 1, hour)
            let timetableTrainTypeKey = selectedGoorback.timetableTrainTypeKey(calendarType, selectedLineNumber - 1, hour)
            UserDefaults.standard.removeObject(forKey: timetableKey)
            UserDefaults.standard.removeObject(forKey: timetableRideTimeKey)
            UserDefaults.standard.removeObject(forKey: timetableTrainTypeKey)
        }
        
        // Clear train type list
        let trainTypeListKey = selectedGoorback.trainTypeListKey(calendarType, selectedLineNumber - 1)
        UserDefaults.standard.removeObject(forKey: trainTypeListKey)
        
        UserDefaults.standard.synchronize()
        print("✅ Timetable data clearing completed")
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
        }
    }
    
    // MARK: - Input Processing
    /// Processes departure station input changes
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
    
    /// Processes arrival station input changes
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
    
    /// Processes line input changes
    func processLineInput(_ newValue: String) {
        // Don't reset station selection if line number is being changed
        if isLineNumberChanging {
            return
        }
        
        // Trigger filtering when lineInput changes
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
                print("🚌 selectLine: Initialized lineBusStops with \(busstopPoleOrder.count) bus stops")
                
                // Check if any bus stops need Japanese names and fetch them once
                let needsJapaneseNames = busstopPoleOrder.contains { busStop in
                    let hasJapaneseInNote = (busStop.note?.contains(where: { $0.isJapanese }) ?? false)
                    return (!hasJapaneseInNote || busStop.note?.isEmpty ?? true) && !(busStop.busstopPole?.isEmpty ?? true)
                }
                
                if needsJapaneseNames {
                    print("🚌 selectLine: Some bus stops need Japanese names, fetching...")
                    Task {
                        await fetchJapaneseNamesForAllBusStops()
                    }
                }
            } else {
                lineBusStops = []
                print("🚫 selectLine: No busstopPoleOrder found, cleared lineBusStops")
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
    /// Get corresponding LocalDataSource from selected line's operator code
    private func getLocalDataSource() -> LocalDataSource? {
        guard let operatorCode = selectedLine?.operatorCode else { return nil }
        return LocalDataSource.allCases.first { $0.operatorCode == operatorCode }
    }
    
    /// Check if selected line has train timetable support
    func hasTrainTimetableSupport() -> Bool {
        return getLocalDataSource()?.hasTrainTimeTable ?? false
    }
    
    // MARK: - BusstopPole API Integration
    /// Flag to prevent multiple simultaneous API calls
    private var isFetchingJapaneseNames = false
    
    /// Fetches Japanese names for all bus stops in the selected route
    private func fetchJapaneseNamesForAllBusStops() async {
        // Prevent multiple simultaneous calls
        guard !isFetchingJapaneseNames else {
            print("🚌 fetchJapaneseNamesForAllBusStops: Already fetching, skipping duplicate call")
            return
        }
        
        isFetchingJapaneseNames = true
        defer { isFetchingJapaneseNames = false }
        guard let selectedLine = selectedLine,
              let operatorCode = selectedLine.operatorCode else {
            print("❌ fetchJapaneseNamesForAllBusStops: Missing selected line or operator code")
            return
        }
        
        do {
            // Find the corresponding LocalDataSource for the operator
            guard let dataSource = LocalDataSource.allCases.first(where: { $0.operatorCode == operatorCode }) else {
                print("❌ fetchJapaneseNamesForAllBusStops: No matching LocalDataSource found for operator: \(operatorCode)")
                return
            }
            
            // Generate API link for BusstopPole with busroutePattern filter
            let urlString = dataSource.apiLink(for: .stop, transportationKind: .bus) + "&odpt:busroutePattern=\(selectedLine.code)"
            
            guard let url = URL(string: urlString) else {
                print("❌ fetchJapaneseNamesForAllBusStops: Invalid URL: \(urlString)")
                return
            }
            
            print("🚌 fetchJapaneseNamesForAllBusStops: Fetching Japanese names for route pattern: \(selectedLine.code)")
            print("🔗 API URL: \(urlString)")
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ fetchJapaneseNamesForAllBusStops: Invalid HTTP response")
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                print("❌ fetchJapaneseNamesForAllBusStops: HTTP error \(httpResponse.statusCode)")
                return
            }
            
            // Decode BusstopPoleDTO array
            let allBusstopPoles = try JSONDecoder().decode([BusstopPoleDTO].self, from: data)
            
            // Filter out bus stops that have odpt:busstopPoleTimetable (exclude timetable data)
            // But keep bus stops that have both odpt:busstopPoleTimetable AND owl:sameAs
            let busstopPoles = allBusstopPoles.filter { pole in
                // Keep bus stops that have owl:sameAs (these are actual bus stops)
                // Exclude only those that have odpt:busstopPoleTimetable but no owl:sameAs
                if let sameAs = pole.sameAs, !sameAs.isEmpty {
                    return true // Keep bus stops with owl:sameAs
                }
                // Exclude bus stops without owl:sameAs (these are likely timetable-only entries)
                return false
            }
            
            print("✅ fetchJapaneseNamesForAllBusStops: Successfully fetched \(allBusstopPoles.count) total bus stop poles, filtered to \(busstopPoles.count) with owl:sameAs")
            
            await MainActor.run {
                // Debug: Log API response
                print("🔍 API Response contains \(busstopPoles.count) bus stop poles (after filtering):")
                for (i, pole) in busstopPoles.enumerated() {
                    print("  [\(i)] \(pole.title)")
                }
                
                // Update all bus stops with Japanese names using owl:sameAs matching
                for (index, busStop) in self.lineBusStops.enumerated() {
                    print("🔍 Checking bus stop [\(index)]: \(busStop.name) (busstopPole: \(busStop.busstopPole ?? "nil"))")
                    
                    // Match by owl:sameAs identifier
                    if let busstopPole = busStop.busstopPole,
                       let matchingBusStopPole = busstopPoles.first(where: { $0.sameAs == busstopPole }) {
                        // Extract English name from busstopPole for bilingual support
                        let englishName: String?
                        if let busstopPole = busStop.busstopPole, !busstopPole.isEmpty {
                            let components = busstopPole.components(separatedBy: ".")
                            englishName = components.count > 2 ? components[2].trimmingCharacters(in: .whitespacesAndNewlines) : nil
                        } else {
                            englishName = nil
                        }
                        
                        let updatedBusStop = BusStop(
                            name: matchingBusStopPole.title,
                            code: busStop.code,
                            index: busStop.index,
                            lineCode: busStop.lineCode,
                            title: LocalizedTitle(ja: matchingBusStopPole.title, en: englishName),
                            note: matchingBusStopPole.title,
                            busstopPole: busStop.busstopPole
                        )
                        self.lineBusStops[index] = updatedBusStop
                        print("✅ fetchJapaneseNamesForAllBusStops: Updated bus stop '\(busStop.name)' with Japanese name: \(matchingBusStopPole.title)")
                    } else {
                        print("❌ fetchJapaneseNamesForAllBusStops: No matching Japanese name found for bus stop [\(index)]: \(busStop.name)")
                    }
                }
                
                // Update lineStops to reflect the changes
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
              let pattern = line.pattern else {
            print("❌ fetchBusStopsFromAPI: Missing operator code or bus route pattern")
            return
        }
        
        do {
            // Find the corresponding LocalDataSource for the operator
            guard let dataSource = LocalDataSource.allCases.first(where: { $0.operatorCode == operatorCode }) else {
                print("❌ fetchBusStopsFromAPI: No matching LocalDataSource found for operator: \(operatorCode)")
                return
            }
            
            // Generate API link using apiLink
            let urlString = dataSource.apiLink(for: .stop, transportationKind: .bus) + "&odpt:busroutePattern=\(pattern)"
            
            guard let url = URL(string: urlString) else {
                print("❌ fetchBusStopsFromAPI: Invalid URL: \(urlString)")
                return
            }
            
            print("🚌 fetchBusStopsFromAPI: Fetching bus stops for pattern: \(pattern)")
            print("🔗 API URL: \(urlString)")
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ fetchBusStopsFromAPI: Invalid HTTP response")
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                print("❌ fetchBusStopsFromAPI: HTTP error \(httpResponse.statusCode)")
                return
            }
            
            // Decode BusstopPoleDTO array
            let busstopPoles = try JSONDecoder().decode([BusstopPoleDTO].self, from: data)
            print("✅ fetchBusStopsFromAPI: Successfully fetched \(busstopPoles.count) bus stop poles")
            
            // Convert to TransportationStop objects using only dc:title
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
                // Update lineBusStops with fetched data (convert TransportationStop to BusStop)
                self.lineBusStops = transportationStops.map { BusStop(from: $0) }
                print("✅ fetchBusStopsFromAPI: Updated lineBusStops with \(transportationStops.count) stops")
            }
            
        } catch {
            print("❌ fetchBusStopsFromAPI: Failed to fetch bus stops: \(error)")
        }
    }
}

