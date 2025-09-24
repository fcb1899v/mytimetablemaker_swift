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
    @Published var statistics: DataStatistics = DataStatistics()  // Data statistics for monitoring
    
    // Line and station selection state management
    @Published var selectedLine: TransportationLine?          // Currently selected railway line
    @Published var lineStations: [Station] = []               // Stations available on the selected line
    @Published var selectedDepartureStation: Station?         // User-selected departure station
    @Published var selectedArrivalStation: Station?           // User-selected arrival station
    
    // User input fields for data entry
    @Published var departureStationInput: String = ""         // Departure station search input text
    @Published var arrivalStationInput: String = ""           // Arrival station search input text
    @Published var selectedRideTime: Int = 0                  // Selected ride time in minutes (initial value: 0)
    var isAllNotEmpty: Bool { 
        !departureStationInput.isEmpty && 
        !arrivalStationInput.isEmpty && 
        !lineInput.isEmpty && 
        selectedRideTime > 0 && 
        (selectedTransportation == "none" || selectedTransferTime > 0)
    }
    
    // Suggestion and focus state management
    @Published var showDepartureSuggestions: Bool = false     // Departure station suggestions visibility
    @Published var departureSuggestions: [Station] = []       // Departure station search results
    @Published var isDepartureFieldFocused: Bool = false      // Departure field focus state
    @Published var showArrivalSuggestions: Bool = false       // Arrival station suggestions visibility
    @Published var arrivalSuggestions: [Station] = []         // Arrival station search results
    @Published var isArrivalFieldFocused: Bool = false        // Arrival field focus state
    @Published var showLineSuggestions: Bool = false          // Line suggestions visibility
    
    // Selection flags to prevent re-display of suggestions after selection
    @Published var departureStationSelected: Bool = false     // Flag to prevent departure suggestions re-display
    @Published var arrivalStationSelected: Bool = false       // Flag to prevent arrival suggestions re-display
    @Published var lineSelected: Bool = false                 // Flag to prevent line suggestions re-display
    var isAllSelected: Bool { lineSelected && departureStationSelected && arrivalStationSelected }
    
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
    @Published var isTimetableManual: Bool = false            // Manual mode flag (true: manual, false: auto)
    
    let goorbackOptions: [String] = ["back1", "back2", "go1", "go2"]  // Available route options
    
    // Computed properties for UI state checking
    var hasSelectedLine: Bool { selectedLine != nil }
    var hasStations: Bool { !lineStations.isEmpty }
    
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
            .sink { [weak self] _ in self?.updateAvailableLineNumbers() }
            .store(in: &cancellables)
        
        selectedLineNumber = lineIndex + 1
        
        // Initialize transfer count if not set
        if UserDefaults.standard.object(forKey: selectedGoorback.changeLineKey) == nil {
            UserDefaults.standard.set(0, forKey: selectedGoorback.changeLineKey)
        }
        
        updateAvailableLineNumbers()
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
        lineStations = []
        selectedDepartureStation = nil
        selectedArrivalStation = nil
        departureStationInput = ""
        arrivalStationInput = ""
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
        departureStationSelected = false
        arrivalStationSelected = false
        lineSelected = false
    }
    
    
    // MARK: - Data Management
    // Load data from shared manager for better performance
    func loadFromSharedService() async {
        let sharedLines = await sharedDataManager.getAllLines()
        
        await MainActor.run {
            self.all = sharedLines
            self.allData = self.all
            // Pre-filter and cache railway and bus lines for performance
            self.railwayLines = sharedLines.filter { $0.kind == .railway }
            self.busLines = sharedLines.filter { $0.kind == .bus }
        }
        
        await filter(lineInput)
        await updateStatistics()
        
        // Check if saved line exists in loaded data and restore it
        await checkSavedLineInData()
    }
    
    // Perform manual data update for both railway and bus operators
    func performDataUpdate() async {
        await sharedDataManager.performRailwayUpdate()
        await sharedDataManager.performBusUpdate()
        
        let updatedLines = await sharedDataManager.getAllLines()
        
        await MainActor.run {
            self.all = updatedLines
            self.allData = self.all
            self.railwayLines = updatedLines.filter { $0.kind == .railway }
            self.busLines = updatedLines.filter { $0.kind == .bus }
            self.isLoading = sharedDataManager.isLoading
            self.lastUpdatedDisplay = sharedDataManager.lastUpdated?.formatted()
        }
    }
    
    // Update application statistics including data counts and cache status
    func updateStatistics() async {
        var stats = DataStatistics()
        stats.totalLines = all.count
        stats.railwayLines = all.filter { $0.kind == .railway }.count
        stats.busLines = all.filter { $0.kind == .bus }.count
        stats.operators = Set(all.compactMap { $0.operatorCode }).count
        stats.cacheStatus = sharedDataManager.statistics.cacheStatus
        
        await MainActor.run {
            self.statistics = stats
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
        let searchData = selectedTransportationKind == .railway ? railwayLines : busLines
        
        // Search key generation helper for different transportation types
        let key: (TransportationLine) -> String = { p in
            if p.kind == .bus {
                return p.name.normalizedForSearch
            }
            if let railwayTitle = p.railwayTitle {
                let localizedName = railwayTitle.getLocalizedName()
                if !localizedName.isEmpty {
                    return localizedName.normalizedForSearch
                }
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
        
        if selectedTransportationKind == .bus {
            lineSuggestions = Array(searchData.filter { $0.name.normalizedForSearch.contains(t) }.prefix(20))
        } else {
            let allResults = starts + contains + hiraganaMatches
            lineSuggestions = Array(allResults.prefix(100))
        }
        
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
            return currentLanguage == "ja" ? line.name :
            (line.busRouteEnglishName ?? line.railwayTitle?.en ?? line.name)
        }
        
        guard let railwayTitle = line.railwayTitle else { return line.name }
        let localizedName = railwayTitle.getLocalizedName()
        return localizedName.isEmpty ? line.name : localizedName
    }
    
    // Get localized display name based on operator code
    func getOperatorDisplayName(for operatorCode: String, lineKind: TransportationLine.Kind? = nil) -> String {
        let operatorName = operatorCode.replacingOccurrences(of: "odpt.Operator:", with: "")
        return NSLocalizedString(operatorName, comment: "Railway operator name")
    }
    
    // MARK: - Station Search and Filtering
    // Filter candidate departure stations based on search lineInput
    func filterDepartureStations(_ lineInput: String) {
        let filtered = filterStations(lineInput, excludeStation: selectedArrivalStation)
        departureSuggestions = filtered
        showDepartureSuggestions = isDepartureFieldFocused && !filtered.isEmpty && !departureStationSelected
    }
    
    // Filter candidate arrival stations based on search lineInput
    func filterArrivalStations(_ lineInput: String) {
        let filtered = filterStations(lineInput, excludeStation: selectedDepartureStation)
        arrivalSuggestions = filtered
        showArrivalSuggestions = isArrivalFieldFocused && !filtered.isEmpty && !arrivalStationSelected
    }
    
    // Common station filtering logic used by both departure and arrival station searches
    private func filterStations(_ lineInput: String, excludeStation: Station?) -> [Station] {
        guard !lineInput.isEmpty else { return [] }
        
        let filtered: [Station] = {
            // Bus route filtering - only search within selected line's bus stops
            if let selectedLine = selectedLine, selectedLine.kind == .bus {
                if !lineStations.isEmpty {
                    return lineStations.filter { $0.getLocalizedName().localizedCaseInsensitiveContains(lineInput) }
                } else {
                    if let busstopPoleOrder = selectedLine.busstopPoleOrder {
                        let busStops: [Station] = busstopPoleOrder.compactMap { busStop -> Station? in
                            let stopName = busStop.busstopPoleTitle?.getLocalizedName() ??
                            busStop.busStopEnglishName ??
                            busStop.note ?? ""
                            guard !stopName.isEmpty else { return nil }
                            return Station(
                                name: stopName,
                                code: busStop.busstopPole,
                                index: nil,
                                lineCode: selectedLine.code,
                                title: StationTitle(
                                    ja: busStop.busstopPoleTitle?.ja ?? busStop.note,
                                    en: busStop.busstopPoleTitle?.en ?? busStop.busStopEnglishName ?? busStop.note
                                )
                            )
                        }
                        return busStops.filter { $0.getLocalizedName().localizedCaseInsensitiveContains(lineInput) }
                    }
                    return []
                }
            }
            
            // Railway line filtering - use existing logic
            if selectedLine != nil, !lineStations.isEmpty {
                return lineStations.filter { $0.getLocalizedName().localizedCaseInsensitiveContains(lineInput) }
            } else if !self.lineInput.isEmpty {
                let lineStations = getStationsForSelectedLine()
                if !lineStations.isEmpty {
                    return lineStations.filter { $0.getLocalizedName().localizedCaseInsensitiveContains(lineInput) }
                } else {
                    return getAllAvailableStations().filter { $0.getLocalizedName().localizedCaseInsensitiveContains(lineInput) }
                }
            } else {
                return getAllAvailableStations().filter { $0.getLocalizedName().localizedCaseInsensitiveContains(lineInput) }
            }
        }()
        
        return excludeStation != nil ?
        filtered.filter { $0.getLocalizedName() != excludeStation!.getLocalizedName() } :
        filtered
    }
    
    // MARK: - Station Data Processing
    // Parse station information for a given line name
    private func parseStationsByLineName(_ data: Data, lineName: String) -> [Station]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let array = json as? [[String: Any]] {
                // Search for exact matches first
                for railway in array {
                    if let railwayName = railway["dc:title"] as? String,
                       railwayName == lineName {
                        return extractStationsFromRailway(railway, searchMethod: "dc:title", searchValue: lineName)
                    }
                    
                    if let railwayTitle = railway["odpt:railwayTitle"] as? [String: Any] {
                        if let stations = searchByRailwayTitle(railway, railwayTitle: railwayTitle, lineName: lineName) {
                            return stations
                        }
                    }
                }
                
                // Search for partial matches if no exact match found
                for railway in array {
                    if let railwayName = railway["dc:title"] as? String,
                       railwayName.contains(lineName) || lineName.contains(railwayName) {
                        if let stations = extractStationsFromRailway(railway, searchMethod: "dc:title partial match", searchValue: railwayName) {
                            return stations
                        }
                    }
                    
                    if let railwayTitle = railway["odpt:railwayTitle"] as? [String: Any] {
                        if let stations = searchByRailwayTitlePartialMatch(railway, railwayTitle: railwayTitle, lineName: lineName) {
                            return stations
                        }
                    }
                }
                
                return nil
            }
        } catch {
            return nil
        }
        return nil
    }
    
    // Search for stations by railwayTitle (Japanese or English name)
    private func searchByRailwayTitle(_ railway: [String: Any], railwayTitle: [String: Any], lineName: String) -> [Station]? {
        if let jaName = railwayTitle["ja"] as? String, jaName == lineName {
            return extractStationsFromRailway(railway, searchMethod: "odpt:railwayTitle.ja", searchValue: lineName)
        }
        
        if let enName = railwayTitle["en"] as? String, enName == lineName {
            return extractStationsFromRailway(railway, searchMethod: "odpt:railwayTitle.en", searchValue: lineName)
        }
        
        return nil
    }
    
    // Search for stations by railwayTitle partial match
    private func searchByRailwayTitlePartialMatch(_ railway: [String: Any], railwayTitle: [String: Any], lineName: String) -> [Station]? {
        if let jaName = railwayTitle["ja"] as? String,
           jaName.contains(lineName) || lineName.contains(jaName) {
            return extractStationsFromRailway(railway, searchMethod: "odpt:railwayTitle.ja partial match", searchValue: jaName)
        }
        
        if let enName = railwayTitle["en"] as? String,
           enName.contains(lineName) || lineName.contains(enName) {
            return extractStationsFromRailway(railway, searchMethod: "odpt:railwayTitle.en partial match", searchValue: enName)
        }
        
        return nil
    }
    
    // Extract station information from railway object
    func extractStationsFromRailway(_ railway: [String: Any], searchMethod: String, searchValue: String, lineCode: String? = nil) -> [Station]? {
        // Handle bus routes - extract bus stops from odpt:busstopPoleOrder
        if let type = railway["@type"] as? String, type == "odpt:BusroutePattern" {
            let busStops: [Station]? = (railway["odpt:busstopPoleOrder"] as? [[String: Any]])?.compactMap { busStopInfo -> Station? in
                if let busstopPoleTitle = busStopInfo["odpt:busstopPoleTitle"] as? [String: Any] {
                    let jaName = busstopPoleTitle["ja"] as? String
                    let enName = busstopPoleTitle["en"] as? String
                    let stopName = enName ?? jaName ?? busStopInfo["odpt:note"] as? String ?? ""
                    guard !stopName.isEmpty else { return nil }
                    return Station(
                        name: stopName,
                        code: busStopInfo["odpt:busstopPole"] as? String,
                        index: nil,
                        lineCode: lineCode,
                        title: StationTitle(ja: jaName, en: enName)
                    )
                } else if let busstopPole = busStopInfo["odpt:busstopPole"] as? String {
                    let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
                    let englishName: String?
                    if currentLanguage != "ja" {
                        let components = busstopPole.components(separatedBy: ".")
                        englishName = components.count >= 3 ? components[2] : nil
                    } else {
                        englishName = nil
                    }
                    let note = busStopInfo["odpt:note"] as? String ?? ""
                    let stopName = englishName ?? note
                    guard !stopName.isEmpty else { return nil }
                    return Station(
                        name: stopName,
                        code: busstopPole,
                        index: nil,
                        lineCode: lineCode,
                        title: StationTitle(ja: note, en: englishName)
                    )
                } else if let note = busStopInfo["odpt:note"] as? String {
                    return Station(
                        name: note,
                        code: busStopInfo["odpt:busstopPole"] as? String,
                        index: nil,
                        lineCode: lineCode,
                        title: StationTitle(ja: note, en: note)
                    )
                }
                return nil
            }
            return busStops?.isEmpty == false ? busStops : nil
        }
        
        // Handle railway stations - extract from odpt:stationOrder
        let stations: [Station]? = (railway["odpt:stationOrder"] as? [[String: Any]])?.compactMap { stationInfo in
            (stationInfo["odpt:stationTitle"] as? [String: Any]).map { stationTitle in
                let jaName = stationTitle["ja"] as? String
                let enName = stationTitle["en"] as? String
                let stationCode = stationInfo["odpt:station"] as? String
                let stationIndex = stationInfo["odpt:index"] as? Int
                
                return Station(
                    name: jaName ?? enName ?? "Unknown station",
                    code: stationCode,
                    index: stationIndex,
                    lineCode: lineCode,
                    title: StationTitle(ja: jaName, en: enName)
                )
            }
        }
        return !(stations?.isEmpty ?? true) ? stations : nil
    }
    
    // Get station information for the selected line
    func getStationsForSelectedLine() -> [Station] {
        guard let selectedLine = selectedLine else { return [] }
        
        // Handle bus routes - extract bus stops from TransportationLine.busstopPoleOrder
        if selectedLine.kind == .bus {
            if let busstopPoleOrder = selectedLine.busstopPoleOrder {
                let busStops: [Station] = busstopPoleOrder.compactMap { busStop -> Station? in
                    let stopName = busStop.busstopPoleTitle?.getLocalizedName() ??
                    busStop.busStopEnglishName ??
                    busStop.note ?? ""
                    guard !stopName.isEmpty else { return nil }
                    return Station(
                        name: stopName,
                        code: busStop.busstopPole,
                        index: nil,
                        lineCode: selectedLine.code,
                        title: StationTitle(
                            ja: busStop.busstopPoleTitle?.ja ?? busStop.note,
                            en: busStop.busstopPoleTitle?.en ?? busStop.busStopEnglishName ?? busStop.note
                        )
                    )
                }
                return busStops
            }
            return []
        }
        
        // For railway lines, search by line code
        return stationDataFiles.lazy.compactMap { [self] filename in
            self.loadLocalData(for: filename).flatMap { [self] data in
                self.parseStationsByLineCode(data, lineCode: selectedLine.code)
            }
        }.first ?? []
    }
    
    // Parse stations by line code
    private func parseStationsByLineCode(_ data: Data, lineCode: String) -> [Station]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let array = json as? [[String: Any]] {
                for railway in array {
                    if let railwayCode = railway["owl:sameAs"] as? String,
                       railwayCode == lineCode {
                        return extractStationsFromRailway(railway, searchMethod: "owl:sameAs", searchValue: lineCode, lineCode: lineCode)
                    }
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
        selectedDepartureStation = nil
        selectedArrivalStation = nil
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
        
        if let departureStation = selectedDepartureStation {
            departureStationInput = departureStation.getLocalizedName()
        }
        
        if let arrivalStation = selectedArrivalStation {
            arrivalStationInput = arrivalStation.getLocalizedName()
        }
    }
    
    // Check if custom line station input is complete
    func isCustomLineStationInputComplete() -> Bool {
        return !lineInput.isEmpty && !departureStationInput.isEmpty && !arrivalStationInput.isEmpty && departureStationInput != arrivalStationInput
    }
    
    // Set line color without saving to UserDefaults
    func setLineColor(_ color: String) {
        selectedLineColor = color
        showColorSelection = false
    }
    
    // Common save processing for all line types
    func handleLineSave(dismiss: DismissAction) {
        Task {
            await saveAllDataToUserDefaults()
            updateDisplay()
            NotificationCenter.default.post(name: NSNotification.Name("SettingsLineUpdated"), object: nil)
            dismiss()
        }
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
                                let stopName = busStop.busstopPoleTitle?.getLocalizedName() ??
                                busStop.busStopEnglishName ??
                                busStop.note ?? ""
                                guard !stopName.isEmpty else { return nil }
                                return Station(
                                    name: stopName,
                                    code: busStop.busstopPole,
                                    index: nil,
                                    lineCode: selectedLine?.code,
                                    title: StationTitle(
                                        ja: busStop.busstopPoleTitle?.ja ?? busStop.note,
                                        en: busStop.busstopPoleTitle?.en ?? busStop.busStopEnglishName ?? busStop.note
                                    )
                                )
                            }
                            lineStations = busStops
                        }
                    }
                    
                    // Show color selection if no color set
                    if foundLine.lineColor == nil {
                        showColorSelection = true
                    }
                    
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
        
        // Calculate and save lineDirection based on station index comparison
        var calculatedDirection: String? = nil
        if let departureIndex = selectedDepartureStation?.index, let arrivalIndex = selectedArrivalStation?.index {
            print("🔍 Direction calculation: departureIndex=\(departureIndex), arrivalIndex=\(arrivalIndex)")
            print("🔍 Station names: \(selectedDepartureStation?.name ?? "nil") (index: \(departureIndex)) -> \(selectedArrivalStation?.name ?? "nil") (index: \(arrivalIndex))")
            
            let isDescending = departureIndex > arrivalIndex
            print("🔍 Direction logic: departureIndex > arrivalIndex = \(isDescending)")
            
            calculatedDirection = isDescending ?
                await getRailDirectionFromJSON(isAscending: false):
                await getRailDirectionFromJSON(isAscending: true)
            
            print("✅ Calculated direction: \(calculatedDirection ?? "nil")")
            print("🔍 Expected: ascendingRailDirection=Southbound, descendingRailDirection=Northbound")

            // Save lineDirection
            let lineDirectionKey = selectedGoorback.lineDirectionKey(lineIndex)
            UserDefaults.standard.set(calculatedDirection, forKey: lineDirectionKey)
        }
                
        // Update selectedLine's lineDirection
        if var updatedLine = selectedLine {
            print("🔍 Before update - selectedLine.lineDirection: \(selectedLine?.lineDirection ?? "nil")")
            print("🔍 calculatedDirection: \(calculatedDirection ?? "nil")")
            
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
                lineDirection: calculatedDirection ?? "",
                busRoute: updatedLine.busRoute,
                pattern: updatedLine.pattern,
                busDirection: updatedLine.busDirection,
                busstopPoleOrder: updatedLine.busstopPoleOrder
            )
            selectedLine = updatedLine
            
            print("🔍 After update - selectedLine.lineDirection: \(selectedLine?.lineDirection ?? "nil")")
        }
        
        // Save station information with lineCode validation
        if !departureStationInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Validate lineCode before saving departure station
            if let departureStation = selectedDepartureStation,
               let stationLineCode = departureStation.lineCode,
               let selectedLineCode = selectedLine?.code,
               stationLineCode == selectedLineCode {
                
                let departureKey = selectedGoorback.departStationKey(lineIndex)
                UserDefaults.standard.set(departureStationInput, forKey: departureKey)
                
                // Save departure station ODPT code
                if let stationCode = departureStation.code {
                    let departureCodeKey = selectedGoorback.departStationCodeKey(lineIndex)
                    UserDefaults.standard.set(stationCode, forKey: departureCodeKey)
                }
                
                // Save departure station lineCode
                let departureLineCodeKey = "\(selectedGoorback.departStationCodeKey(lineIndex))_lineCode"
                UserDefaults.standard.set(stationLineCode, forKey: departureLineCodeKey)
                
                print("✅ Saved departure station with matching lineCode: \(stationLineCode)")
            } else {
                print("⚠️ Departure station lineCode mismatch - not saving")
            }
        }
        
        if !arrivalStationInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Validate lineCode before saving arrival station
            if let arrivalStation = selectedArrivalStation,
               let stationLineCode = arrivalStation.lineCode,
               let selectedLineCode = selectedLine?.code,
               stationLineCode == selectedLineCode {
                
                let arrivalKey = selectedGoorback.arriveStationKey(lineIndex)
                UserDefaults.standard.set(arrivalStationInput, forKey: arrivalKey)
                
                // Save arrival station ODPT code
                if let stationCode = arrivalStation.code {
                    let arrivalCodeKey = selectedGoorback.arriveStationCodeKey(lineIndex)
                    UserDefaults.standard.set(stationCode, forKey: arrivalCodeKey)
                }
                
                // Save arrival station lineCode
                let arrivalLineCodeKey = "\(selectedGoorback.arriveStationCodeKey(lineIndex))_lineCode"
                UserDefaults.standard.set(stationLineCode, forKey: arrivalLineCodeKey)
                
                print("✅ Saved arrival station with matching lineCode: \(stationLineCode)")
            } else {
                print("⚠️ Arrival station lineCode mismatch - not saving")
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
    
    // MARK: - Rail Direction Extraction
    // Extract rail direction from JSON data based on station index comparison
    private func getRailDirectionFromJSON(isAscending: Bool) async -> String {
        guard let selectedLineCode = selectedLine?.code else { return "" }
        
        // Search through all station data files to find the matching railway
        for filename in stationDataFiles {
            if let data = loadLocalData(for: filename) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let array = json as? [[String: Any]] {
                        for railway in array {
                            if let railwayCode = railway["owl:sameAs"] as? String,
                               railwayCode == selectedLineCode {
                                
                                if isAscending {
                                    // Extract ascendingRailDirection
                                    print("🔍 isAscending: true - looking for odpt:ascendingRailDirection")
                                    if let ascendingDirection = railway["odpt:ascendingRailDirection"] as? String {
                                        print("✅ Found ascendingRailDirection: \(ascendingDirection)")
                                        let result = ascendingDirection.replacingOccurrences(of: "odpt.RailDirection:", with: "")
                                        print("🔍 Returning: \(result)")
                                        return result
                                    } else {
                                        print("❌ No ascendingRailDirection found")
                                    }
                                } else {
                                    // Extract descendingRailDirection
                                    print("🔍 isAscending: false - looking for odpt:descendingRailDirection")
                                    if let descendingDirection = railway["odpt:descendingRailDirection"] as? String {
                                        print("✅ Found descendingRailDirection: \(descendingDirection)")
                                        let result = descendingDirection.replacingOccurrences(of: "odpt.RailDirection:", with: "")
                                        print("🔍 Returning: \(result)")
                                        return result
                                    } else {
                                        print("❌ No descendingRailDirection found")
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print("❌ Failed to parse JSON for rail direction: \(error)")
                }
            }
        }
        
        return ""
    }
    
    // MARK: - Station Data Retrieval
    // Get all stations regardless of line selection
    func getAllAvailableStations() -> [Station] {
        let allStations = stationDataFiles.flatMap { filename in
            loadLocalData(for: filename).flatMap { parseAllStationsFromFile($0) } ?? []
        }
        
        return Array(Set(allStations)).sorted { $0.getLocalizedName() < $1.getLocalizedName() }
    }
    
    // Extract all stations from file
    func parseAllStationsFromFile(_ data: Data) -> [Station]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let array = json as? [[String: Any]] {
                var stations: [Station] = []
                
                for railway in array {
                    if let stationOrder = railway["odpt:stationOrder"] as? [[String: Any]] {
                        for stationInfo in stationOrder {
                            if let stationTitle = stationInfo["odpt:stationTitle"] as? [String: Any] {
                                let jaName = stationTitle["ja"] as? String
                                let enName = stationTitle["en"] as? String
                                let stationCode = stationInfo["odpt:station"] as? String
                                let stationIndex = stationInfo["odpt:index"] as? Int
                                let stationName = jaName ?? enName ?? "Unknown station"
                                let station = Station(
                                    name: stationName,
                                    code: stationCode, // Parse odpt:station code
                                    index: stationIndex, // Parse odpt:index
                                    lineCode: railway["owl:sameAs"] as? String, // Parse line code
                                    title: StationTitle(ja: jaName, en: enName)
                                )
                                stations.append(station)
                            }
                        }
                    }
                }
                return stations
            }
        } catch {
            return nil
        }
        return nil
    }
    
    // MARK: - Settings Loading Functions
    // Load line color settings from UserDefaults
    private func loadLineColorSettings() {
        let userDefaultsKey = selectedGoorback.lineColorKey(selectedLineNumber - 1)
        self.selectedLineColor = UserDefaults.standard.string(forKey: userDefaultsKey)
    }
    
    // Load line name settings from UserDefaults
    private func loadLineNameSettings() {
        let lineNameKey = selectedGoorback.lineNameKey(selectedLineNumber - 1)
        if let savedLineName = UserDefaults.standard.string(forKey: lineNameKey) {
            self.lineInput = savedLineName
        }
    }
    
    // Load station settings from UserDefaults
    private func loadStationSettings() {
        let currentLineIndex = selectedLineNumber - 1
        print("🔍 loadStationSettings - selectedGoorback: \(selectedGoorback), selectedLineNumber: \(selectedLineNumber), currentLineIndex: \(currentLineIndex)")
        
        let departureKey = selectedGoorback.departStationKey(currentLineIndex)
        print("   Departure key: \(departureKey)")
        if let savedDeparture = UserDefaults.standard.string(forKey: departureKey) {
            self.departureStationInput = savedDeparture
            print("✅ Restored departure station: \(savedDeparture)")
        } else {
            self.departureStationInput = ""
            print("   No saved departure found")
        }
        
        let arrivalKey = selectedGoorback.arriveStationKey(currentLineIndex)
        print("   Arrival key: \(arrivalKey)")
        if let savedArrival = UserDefaults.standard.string(forKey: arrivalKey) {
            self.arrivalStationInput = savedArrival
            print("✅ Restored arrival station: \(savedArrival)")
        } else {
            self.arrivalStationInput = ""
            print("   No saved arrival found")
        }
    }
    
    // Load ride time settings from UserDefaults
    private func loadRideTimeSettings() {
        let rideTimeKey = selectedGoorback.rideTimeKey(selectedLineNumber - 1)
        let savedRideTime = UserDefaults.standard.integer(forKey: rideTimeKey)
        // Use saved value or default to 0 if not set
        self.selectedRideTime = savedRideTime > 0 ? savedRideTime : 0
    }
    
    // Load transfer settings from UserDefaults
    private func loadTransferSettings() {
        if (selectedLineNumber - 1) < 2 {
            let transportationKey = selectedGoorback.transportationKey((selectedLineNumber - 1) + 2)
            if let savedTransportation = UserDefaults.standard.string(forKey: transportationKey), !savedTransportation.isEmpty {
                self.selectedTransportation = savedTransportation
            } else {
                self.selectedTransportation = "none"
            }
            
            let transferTimeKey = selectedGoorback.transferTimeKey((selectedLineNumber - 1) + 2)
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
    
    // Load transportation kind settings from UserDefaults
    private func loadTransportationKindSettings() {
        let lineKindKey = selectedGoorback.lineKindKey(selectedLineNumber - 1)
        if let savedKindString = UserDefaults.standard.string(forKey: lineKindKey) {
            self.selectedTransportationKind = TransportationLine.Kind(rawValue: savedKindString) ?? .railway
        } else {
            self.selectedTransportationKind = .railway
        }
    }
    
    // MARK: - Line Selection Management
    // Update available line numbers based on changeLine setting
    func updateAvailableLineNumbers() {
        updateAvailableLineNumbers(shouldPreserveLineNumber: false)
    }
    
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
            self.departureStationInput = savedDeparture
            print("✅ Restored departure station: \(savedDeparture)")
        } else {
            self.departureStationInput = ""
            print("   No saved departure found")
        }
        
        let arrivalKey = selectedGoorback.arriveStationKey(currentLineIndex)
        if let savedArrival = UserDefaults.standard.string(forKey: arrivalKey) {
            self.arrivalStationInput = savedArrival
            print("✅ Restored arrival station: \(savedArrival)")
        } else {
            self.arrivalStationInput = ""
            print("   No saved arrival found")
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
    
    // Find station object by name from all available stations
    private func findStationByName(_ stationName: String) -> Station? {
        print("🔍 findStationByName searching for: '\(stationName)'")
        
        // First try to find from current line stations if available
        if !lineStations.isEmpty {
            if let station = lineStations.first(where: { $0.getLocalizedName() == stationName }) {
                print("✅ Found station in lineStations: \(stationName)")
                return station
            }
        }
        
        // Try to find from all available stations (local data) with lineCode validation
        let localStations = getAllAvailableStations()
        print("   Searching in \(localStations.count) local stations")
        
        // Filter stations by lineCode if selectedLine is available
        let filteredStations = selectedLine != nil ? 
            localStations.filter { $0.lineCode == selectedLine?.code } : 
            localStations
        
        if let station = filteredStations.first(where: { $0.getLocalizedName() == stationName }) {
            print("✅ Found station in local data with matching lineCode: \(stationName)")
            return station
        }
        
        // If not found, create a basic station object from the name
        print("⚠️ Station '\(stationName)' not found in data, creating basic station object")
        let basicStation = Station(
            name: stationName,
            code: nil,
            index: nil,
            lineCode: selectedLine?.code,
            title: StationTitle(ja: stationName, en: stationName)
        )
        print("✅ Created basic station object: \(basicStation.getLocalizedName())")
        return basicStation
    }
    
    // MARK: - Timetable Link Generation
    // Generate timetable information links for departure and arrival stations
    private func getTimetableInformationLink() -> String {
        let operatorCode = selectedLine?.operatorCode ?? ""
        let dataSource = LocalDataSource.allCases.first { $0.operatorCode == operatorCode }
        return dataSource?.apiLink(for: .timetable) ?? ""
    }
    
    // Generate station timetable link with flexible parameters
    func stationInformationLink(isDeparture: Bool, isWeekday: Bool) -> String {
        
        // Extract station name from station code (remove "odpt.Station:" prefix)
        let lineCode = selectedLine?.code ?? ""
        let lineName = lineCode.replacingOccurrences(of: "odpt.Railway:", with: "&owl:sameAs=odpt.StationTimetable:")
        
        let stationCode = (isDeparture ? selectedDepartureStation?.code: selectedArrivalStation?.code) ?? ""
        let stationName = stationCode.components(separatedBy: ".").last ?? ""
        
        // Use lineDirection from selectedLine for both departure and arrival
        let directionCode = selectedLine?.lineDirection ?? ""
        let direction = directionCode.replacingOccurrences(of: "odpt.RailDirection:", with: "")
        
        let dateSuffix = isWeekday ? ".Weekday" : ".SaturdayHoliday"
        
        let timetableLink = "\(getTimetableInformationLink())\(lineName).\(stationName).\(direction)\(dateSuffix)"
        
        print("🔍 stationInformationLink - isDeparture: \(isDeparture), isWeekday: \(isWeekday), direction: \(direction), link: \(timetableLink)")
        return timetableLink
    }
        
    // MARK: - Target Timetable Data Processing
    // Get timetable data for determined direction and find common train numbers
    func getTargetTimetableData() async {
        
        // Skip timetable generation if not all required fields are filled
        guard isAllNotEmpty else {
            print("⚠️ Skipping timetable generation: not all required fields are filled")
            return
        }
        
        print("🔗 Get Timetable Links:")
        let links = [true, false].flatMap { isDeparture in
            [true, false].map { isWeekday in
                stationInformationLink(isDeparture: isDeparture, isWeekday: isWeekday)
            }
        }
        
        print("📊 Get Timetable Data:")
        let weekdayDepartureData = await getTimetableData(from: links[0]) // isDeparture: true, isWeekday: true
        print("weekdayDepartureData count: \(weekdayDepartureData.count)")
        let weekendDepartureData = await getTimetableData(from: links[1]) // isDeparture: true, isWeekday: false
        print("weekendDepartureData count: \(weekendDepartureData.count)")
        let weekdayArrivalData = await getTimetableData(from: links[2])   // isDeparture: false, isWeekday: true
        print("weekdayArrivalData count: \(weekdayArrivalData.count)")
        let weekendArrivalData = await getTimetableData(from: links[3])    // isDeparture: false, isWeekday: false
        print("weekendArrivalData count: \(weekendArrivalData.count)")
        
        // [Weekday, Weekend] timetable data
        var commonTrainTimes: [TrainTime] = []
        for isWeekday in [true, false] {
            let departureData = isWeekday ? weekdayDepartureData : weekendDepartureData
            let arrivalData = isWeekday ? weekdayArrivalData : weekendArrivalData
            
            print("🔄 Processing \(isWeekday ? "Weekday" : "Weekend") data")
            if departureData.count > 0 {

                // Step 1: Compare departure and arrival stations if arrival data exists
                if arrivalData.count > 0 {
                    // Check if any departure data has train numbers
                    let hasTrainNumbers = departureData.contains { !$0.trainNumber.isEmpty }
                    
                    if hasTrainNumbers {
                        print("Get departure timetable using train numbers (found \(departureData.filter { !$0.trainNumber.isEmpty }.count) trains with numbers)")
                        commonTrainTimes = await getCommonTrainNumberTrainTime(
                            departureTimetableData: departureData,
                            arrivalTimetableData: arrivalData,
                            isWeekday: isWeekday
                        )
                    } else {
                        print("Get departure timetable not using train numbers (no trains with numbers found)")
                        commonTrainTimes = await getEstimatedTrainTime(
                            departureTimetableData: departureData,
                            arrivalTimetableData: arrivalData,
                            isWeekday: isWeekday,
                            approxRideTime: selectedRideTime > 0 ? selectedRideTime : nil
                        )
                    }
                }

                // Step 2: Always check for trains with destination matching arrival station
                print("Get departure timetable with destination matching arrival station")
                let additionalTrainTimes = await getTerminalStationTrainTime(
                    departureTimetableData: departureData,
                    isWeekday: isWeekday
                )
                commonTrainTimes.append(contentsOf: additionalTrainTimes)
                
                // Remove duplicates from the combined list
                commonTrainTimes = Array(Set(commonTrainTimes))
                
                if !commonTrainTimes.isEmpty {
                    saveTimetableToUserDefaults(trainTime: commonTrainTimes, isWeekday: isWeekday)
                }
            }
        }
        
        // Save all data after timetable data has been processed and saved
        await saveAllDataToUserDefaults()
        
        // Notify that timetable data has been updated
        NotificationCenter.default.post(name: NSNotification.Name("TimetableDataUpdated"), object: nil)
    }
    
    // MARK: - Terminal Station Timetable Processing
    // Process timetable data when destination station is terminal station
    private func getTerminalStationTrainTime(
        departureTimetableData: [(trainNumber: String, departureTime: String, destinationStation: String, trainType: String)],
        isWeekday: Bool
    ) async -> [TrainTime] {
        print("🚉 Processing terminal station timetable for \(isWeekday ? "Weekday" : "Weekend")")
        print("🔍 Selected arrival station code: \(selectedArrivalStation?.code ?? "nil")")
        print("🔍 Total departure data count: \(departureTimetableData.count)")
        
        // Filter departure data by destination station and create TrainTime objects directly
        let terminalStationTrainTimes = departureTimetableData.compactMap { data -> TrainTime? in
            // Check if destination station matches
            if !data.destinationStation.isEmpty {
                // Compare with ODPT station code format: "odpt.Station:LineCode.StationCode"
                if data.destinationStation == selectedArrivalStation?.code {
                    // Create TrainTime object directly with all available data
                    return TrainTime(
                        departureTime: data.departureTime,
                        arrivalTime: "", // No arrival time available for terminal station
                        trainNumber: data.trainNumber.isEmpty ? nil : data.trainNumber,
                        trainType: data.trainType,
                        rideTime: selectedRideTime > 0 ? selectedRideTime : 0
                    )
                }
            }
            return nil
        }
        
        print("✅ Terminal station timetable: Found \(terminalStationTrainTimes.count) matching departures")
        
        return terminalStationTrainTimes
    }
    
    // MARK: - Timetable Data Processing
    // Process timetable data and find common train numbers for specified day type
    // Returns array of TrainTime objects with departure, arrival, and ride time information
    private func getCommonTrainNumberTrainTime(
        departureTimetableData: [(trainNumber: String, departureTime: String, destinationStation: String, trainType: String)],
        arrivalTimetableData: [(trainNumber: String, departureTime: String, destinationStation: String, trainType: String)],
        isWeekday: Bool
    ) async -> [TrainTime] {
        print("🔍 getCommonTrainNumberTrainTime: Processing \(departureTimetableData.count) departure records and \(arrivalTimetableData.count) arrival records")
        
        // Find common train numbers
        let departureTrainNumbers = Set(departureTimetableData.map { $0.trainNumber }).filter { !$0.isEmpty }
        let arrivalTrainNumbers = Set(arrivalTimetableData.map { $0.trainNumber }).filter { !$0.isEmpty }
        let commonTrainNumbers = departureTrainNumbers.intersection(arrivalTrainNumbers)
        
        print("🔍 Found \(commonTrainNumbers.count) common train numbers: i.e. \(Array(commonTrainNumbers).prefix(5))")
        
        var trainTimes: [TrainTime] = []
        
        // For each common train number, create TrainTime object
        for trainNumber in commonTrainNumbers {
            guard let departureData = departureTimetableData.first(where: { $0.trainNumber == trainNumber }),
                  let arrivalData = arrivalTimetableData.first(where: { $0.trainNumber == trainNumber }) else {
                continue
            }
            
            // Calculate ride time first
            let rideTimeMinutes = calculateRideTime(
                departureTime: departureData.departureTime,
                arrivalTime: arrivalData.departureTime
            )
            
            // Create TrainTime object with calculated ride time
            let trainTime = TrainTime(
                departureTime: departureData.departureTime,
                arrivalTime: arrivalData.departureTime,
                trainNumber: trainNumber,
                trainType: departureData.trainType,
                rideTime: rideTimeMinutes
            )
            
            trainTimes.append(trainTime)
        }
        
        // Also process trains without train numbers (destination matching)
        let trainsWithoutNumbers = departureTimetableData.filter { $0.trainNumber.isEmpty }
        print("🔍 Processing \(trainsWithoutNumbers.count) trains without train numbers")
        
        for departureData in trainsWithoutNumbers {
            // Find matching arrival data by destination station
            if let arrivalData = arrivalTimetableData.first(where: { 
                !$0.trainNumber.isEmpty && $0.destinationStation == departureData.destinationStation 
            }) {
                let rideTimeMinutes = calculateRideTime(
                    departureTime: departureData.departureTime,
                    arrivalTime: arrivalData.departureTime
                )
                
                let trainTime = TrainTime(
                    departureTime: departureData.departureTime,
                    arrivalTime: arrivalData.departureTime,
                    trainNumber: nil,
                    trainType: departureData.trainType,
                    rideTime: rideTimeMinutes
                )
                
                trainTimes.append(trainTime)
                print("✅ Train without number: Departure \(departureData.departureTime) -> Arrival \(arrivalData.departureTime) (Ride time: \(rideTimeMinutes) min, Type: \(departureData.trainType))")
            }
        }
        
        print("✅ \(isWeekday ? "Weekday" : "Weekend") Common Trains Found: \(trainTimes.count)")
        
        return trainTimes
    }
    
    // Calculate ride time in minutes between departure and arrival times
    private func calculateRideTime(departureTime: String, arrivalTime: String) -> Int {
        let departureComponents = departureTime.components(separatedBy: ":")
        let arrivalComponents = arrivalTime.components(separatedBy: ":")
        
        guard departureComponents.count == 2,
              arrivalComponents.count == 2,
              let departureHour = Int(departureComponents[0]),
              let departureMinute = Int(departureComponents[1]),
              let arrivalHour = Int(arrivalComponents[0]),
              let arrivalMinute = Int(arrivalComponents[1]) else {
            return 0
        }
        
        let departureTotalMinutes = departureHour * 60 + departureMinute
        let arrivalTotalMinutes = arrivalHour * 60 + arrivalMinute
        
        // Handle day rollover (arrival time is next day)
        let rideTimeMinutes = arrivalTotalMinutes >= departureTotalMinutes ?
            arrivalTotalMinutes - departureTotalMinutes :
            (24 * 60) - departureTotalMinutes + arrivalTotalMinutes
        
        return rideTimeMinutes
    }
    
    // MARK: - Timetable Data Retrieval
    // Get timetable data from API endpoint
    private func getTimetableData(from urlString: String) async -> [(trainNumber: String, departureTime: String, destinationStation: String, trainType: String)] {
        
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
                let result: [(trainNumber: String, departureTime: String, destinationStation: String, trainType: String)] = stationTimetableObjects.compactMap { timetableObject in
                    guard let departureTime = timetableObject["odpt:departureTime"] as? String else { return nil }
                    
                    let trainNumber = timetableObject["odpt:trainNumber"] as? String ?? ""
                    let trainType = timetableObject["odpt:trainType"] as? String ?? ""
                    let destinationStation = (timetableObject["odpt:destinationStation"] as? [String])?.first ?? ""
                    
                    return (trainNumber: trainNumber, departureTime: departureTime, destinationStation: destinationStation, trainType: trainType)
                }
                
                print("✅ Parsed \(result.count) valid timetable entries")
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
    
    // MARK: - Timetable Data Saving
    // Save timetable data to UserDefaults for display in TimetableContentView
    // Saves both departure times and ride times grouped by hour
    private func saveTimetableToUserDefaults(trainTime: [TrainTime], isWeekday: Bool) {
        // Clear existing timetable data for this line and day type
        clearTimetableData(isWeekday: isWeekday)
        
        print("💾 Saving timetable data for \(isWeekday ? "weekdays" : "weekends")")
        print("📊 Total TrainTime objects: \(trainTime.count)")
        
        // Group TrainTime objects by hour
        var hourlyTrainTimes: [Int: [TrainTime]] = [:]
        
        for (index, trainTimeItem) in trainTime.enumerated() {
            let timeComponents = trainTimeItem.departureTime.components(separatedBy: ":")
            if timeComponents.count == 2, let hour = Int(timeComponents[0]) {
                hourlyTrainTimes[hour, default: []].append(trainTimeItem)
                if index < 5 {
                    print("🚉\(trainTimeItem.trainNumber ?? "N/A") (\(trainTimeItem.trainType?.split(separator: ".").last ?? "N/A")): \(trainTimeItem.departureTime) → \(trainTimeItem.arrivalTime) (\(trainTimeItem.rideTime)min)")
                }
            }
        }
        
        // Sort and save to UserDefaults using new method
        for (hour, trainTimes) in hourlyTrainTimes {
            let sortedTrainTimes = trainTimes.sorted { 
                $0.departureTime < $1.departureTime 
            }
            selectedGoorback.saveTrainTimes(sortedTrainTimes, isWeekday, selectedLineNumber - 1, hour)
        }
        
        // Save train type list for the entire timetable
        let allTrainTimes = hourlyTrainTimes.values.flatMap { $0 }
        selectedGoorback.saveTrainTypeList(allTrainTimes, isWeekday, selectedLineNumber - 1)
        
        // Ensure all UserDefaults changes are synchronized to disk
        UserDefaults.standard.synchronize()
        
        // Summary log
        print("📈 Summary - Saved \(hourlyTrainTimes.count) hours of timetable data")
    }
    
    // MARK: - Complete Route Data Clearing
    // Clear all timetable data for all lines and day types when route changes
    private func clearAllRouteData() {
        print("🧹 Clearing all route data for \(selectedGoorback)")
        
        // Clear timetable data for all lines (0-2) and both day types
        for lineIndex in 0..<3 {
            for isWeekday in [true, false] {
                // Clear all hours (4-24) for each line and day type
                for hour in 4...25 {
                    let timetableKey = selectedGoorback.timetableKey(isWeekday, lineIndex, hour)
                    let rideTimeKey = selectedGoorback.rideTimeKeyForHour(isWeekday, lineIndex, hour)
                    let trainTypeKey = selectedGoorback.trainTypeKey(isWeekday, lineIndex, hour)
                    
                    UserDefaults.standard.removeObject(forKey: timetableKey)
                    UserDefaults.standard.removeObject(forKey: rideTimeKey)
                    UserDefaults.standard.removeObject(forKey: trainTypeKey)
                }
                
                // Clear train type list for each line
                let trainTypeListKey = selectedGoorback.trainTypeListKey(isWeekday, lineIndex)
                UserDefaults.standard.removeObject(forKey: trainTypeListKey)
            }
            
            // Clear line information for each line
            let lineNameKey = selectedGoorback.lineNameKey(lineIndex)
            let lineCodeKey = selectedGoorback.lineCodeKey(lineIndex)
            let lineColorKey = selectedGoorback.lineColorKey(lineIndex)
            let departStationKey = selectedGoorback.departStationKey(lineIndex)
            let arriveStationKey = selectedGoorback.arriveStationKey(lineIndex)
            let departStationCodeKey = selectedGoorback.departStationCodeKey(lineIndex)
            let arriveStationCodeKey = selectedGoorback.arriveStationCodeKey(lineIndex)
            let rideTimeKey = selectedGoorback.rideTimeKey(lineIndex)
            let lineSelectedKey = selectedGoorback.lineSelectedKey(lineIndex)
            
            UserDefaults.standard.removeObject(forKey: lineNameKey)
            UserDefaults.standard.removeObject(forKey: lineCodeKey)
            UserDefaults.standard.removeObject(forKey: lineColorKey)
            UserDefaults.standard.removeObject(forKey: departStationKey)
            UserDefaults.standard.removeObject(forKey: arriveStationKey)
            UserDefaults.standard.removeObject(forKey: departStationCodeKey)
            UserDefaults.standard.removeObject(forKey: arriveStationCodeKey)
            UserDefaults.standard.removeObject(forKey: rideTimeKey)
            UserDefaults.standard.removeObject(forKey: lineSelectedKey)
        }
        
        // Ensure UserDefaults changes are synchronized to disk
        UserDefaults.standard.synchronize()
        
        print("✅ All route data clearing completed")
    }
    
    // MARK: - Timetable Data Clearing
    // Clear existing timetable data for specified day type
    private func clearTimetableData(isWeekday: Bool) {
        print("🧹 Clearing timetable data for \(isWeekday ? "weekdays" : "weekends")")
        
        // Clear all hours (4-24) for the specified day type and line
        for hour in 4...25 {
            let timetableKey = selectedGoorback.timetableKey(isWeekday, selectedLineNumber - 1, hour)
            let rideTimeKey = selectedGoorback.rideTimeKeyForHour(isWeekday, selectedLineNumber - 1, hour)
            let trainTypeKey = selectedGoorback.trainTypeKey(isWeekday, selectedLineNumber - 1, hour)
            UserDefaults.standard.removeObject(forKey: timetableKey)
            UserDefaults.standard.removeObject(forKey: rideTimeKey)
            UserDefaults.standard.removeObject(forKey: trainTypeKey)
        }
        
        // Clear train type list
        let trainTypeListKey = selectedGoorback.trainTypeListKey(isWeekday, selectedLineNumber - 1)
        UserDefaults.standard.removeObject(forKey: trainTypeListKey)
        
        UserDefaults.standard.synchronize()
        print("✅ Timetable data clearing completed")
    }
    
    // MARK: - Transportation Kind Switching
    // Handle transportation kind switching with proper state management
    func switchTransportationKind(_ isRailway: Bool) {
        // Update transportation kind immediately for responsive UI
        selectedTransportationKind = isRailway ? .railway : .bus
        
        // Clear line name and station selections when switching transportation types
        lineInput = ""
        selectedLine = nil
        selectedDepartureStation = nil
        selectedArrivalStation = nil
        departureStationInput = ""
        arrivalStationInput = ""
        lineStations = []
        selectedLineColor = Color.accentString
        
        // Clear current suggestions immediately for instant UI update
        lineSuggestions = []
        showLineSuggestions = false
        nameCounts = [:]
        showDepartureSuggestions = false
        showArrivalSuggestions = false
        departureSuggestions = []
        arrivalSuggestions = []
        isDepartureFieldFocused = false
        isArrivalFieldFocused = false
        departureStationSelected = false
        arrivalStationSelected = false
        lineSelected = false
        showStationSelection = false
        
        // Only filter if there's an active lineInput and it's not empty
        if !lineInput.isEmpty && lineInput.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            // Use longer delay for bus to allow UI to fully update
            let delay = isRailway ? 0.1 : 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                Task { await self.filter(self.lineInput) }
            }
        }
    }
    
    // MARK: - Utility Functions for trainNumber-less Processing
    // Extract tail part of station code for matching
    private func tail(_ stationCode: String) -> String {
        return stationCode.components(separatedBy: ".").last ?? stationCode
    }
    
    // Calculate percentile using linear interpolation
    private func percentile(_ xs: [Double], _ p: Double) -> Double {
        guard !xs.isEmpty else { return .nan }
        let s = xs.sorted()
        let n = s.count
        let r = max(0.0, min(1.0, p/100.0))
        let idx = r * Double(n - 1)
        let lo = Int(floor(idx))
        let hi = Int(ceil(idx))
        if lo == hi { return s[lo] }
        let w = idx - Double(lo)
        return s[lo] * (1 - w) + s[hi] * w
    }
    
    // Calculate Freedman-Diaconis bin width
    private func fdBinWidth(_ xs: [Double]) -> Double {
        guard xs.count >= 2 else { return 1.0 }
        let q1 = percentile(xs, 25)
        let q3 = percentile(xs, 75)
        let iqr = q3 - q1
        let n = Double(xs.count)
        return 2.0 * iqr / pow(n, 1.0/3.0)
    }
    
    // Calculate MAD-based sigma
    private func madSigma(_ xs: [Double]) -> Double {
        guard !xs.isEmpty else { return .nan }
        let median = percentile(xs, 50)
        let deviations = xs.map { abs($0 - median) }
        let mad = percentile(deviations, 50)
        return 1.4826 * mad // MAD to sigma conversion factor
    }
    
    // Convert time strings to Date objects with day handling
    private func unwrapTimes(_ hhmmList: [String]) -> [Date] {
        let cal = Calendar(identifier: .gregorian)
        var out: [Date] = []
        var day = 0
        var last: Date? = nil
        for s in hhmmList {
            let parts = s.split(separator: ":")
            guard parts.count == 2, let hh = Int(parts[0]), let mm = Int(parts[1]) else { continue }
            var dc = DateComponents(year: 2000, month: 1, day: 1 + day, hour: hh, minute: mm)
            var t = cal.date(from: dc)!
            if let l = last, t < l {
                day += 1
                dc.day = 1 + day
                t = cal.date(from: dc)!
            }
            out.append(t); last = t
        }
        return out
    }

    // Calculate percentiles using linear interpolation
    private func percentiles(_ xs: [Double], ps: [Double]) -> [Double] {
        guard !xs.isEmpty else { return Array(repeating: .nan, count: ps.count) }
        let s = xs.sorted()
        let n = s.count
        return ps.map { p in
            let r = max(0.0, min(1.0, p/100.0))
            let idx = r * Double(n - 1)
            let lo = Int(floor(idx))
            let hi = Int(ceil(idx))
            if lo == hi { return s[lo] }
            let w = idx - Double(lo)
            return s[lo] * (1 - w) + s[hi] * w
        }
    }
        
    // MARK: - trainNumber-less Timetable Generation
    // Estimate departure times using advanced statistical methods when train numbers are not available
    // Returns array of TrainTime objects with estimated departure times
    private func getEstimatedTrainTime(
        departureTimetableData: [(trainNumber: String, departureTime: String, destinationStation: String, trainType: String)],
        arrivalTimetableData: [(trainNumber: String, departureTime: String, destinationStation: String, trainType: String)],
        isWeekday: Bool,
        approxRideTime: Int? = nil
    ) async -> [TrainTime] {

        _ = isWeekday // Used by caller, unused here
        
        print("🔍 getEstimatedTrainTime: Processing \(departureTimetableData.count) departure records and \(arrivalTimetableData.count) arrival records")
        print("🔍 Departure trainTypes: \(Set(departureTimetableData.map { $0.trainType }).filter { !$0.isEmpty })")
        print("🔍 Arrival trainTypes: \(Set(arrivalTimetableData.map { $0.trainType }).filter { !$0.isEmpty })")

        // 1) Build destination station and trainType sets from arrival data
        var destFull = Set<String>(), destTail = Set<String>()
        var destTypesArr = Set<String>(), destTypesDep = Set<String>()
        for r in arrivalTimetableData {
            if !r.destinationStation.isEmpty {
                destFull.insert(r.destinationStation); destTail.insert(tail(r.destinationStation))
            }
            if !r.trainType.isEmpty {
                destTypesArr.insert(r.trainType); destTypesDep.insert(r.trainType)
            }
        }

        // 2) Filter departure station trains (destination match + strict trainType match)
        struct OItem { let hhmm: String; let trainType: String; let finalTail: String }
        var O: [OItem] = []
        for r in departureTimetableData {
            guard !r.departureTime.isEmpty else { continue }
            let lastTail = tail(r.destinationStation)
            let stationOK = !r.destinationStation.isEmpty &&
                            (destFull.contains(r.destinationStation) || destTail.contains(lastTail))
            let typeOK = !r.trainType.isEmpty &&
                         (destTypesArr.contains(r.trainType) || destTypesDep.contains(r.trainType))
            if stationOK && typeOK {
                O.append(.init(hhmm: r.departureTime, trainType: r.trainType, finalTail: lastTail))
            }
        }
        if O.isEmpty { return [] }

        // 3) Build arrival station streams (arrival/departure) grouped by trainType
        struct DItem { let hhmm: String; let trainType: String }
        var Ddep = [String: [DItem]](), Darr = [String: [DItem]]()
        for r in arrivalTimetableData {
            guard !r.trainType.isEmpty else { continue }
            if !r.departureTime.isEmpty { Ddep[r.trainType, default: []].append(.init(hhmm: r.departureTime, trainType: r.trainType)) }
            // Note: Add arrival time to Darr[...] here if arrival time is available (adjust for input type)
        }

        // 4) Learn and match by trainType
        let ObyType = Dictionary(grouping: O, by: { $0.trainType })
        var picked: [String] = []

        func buildStream(_ rows: [DItem]) -> (times: [Date], hhmm: [String]) {
            let hh = rows.map { $0.hhmm }; let t = unwrapTimes(hh)
            let pairs = zip(t, hh).sorted { $0.0 < $1.0 }
            return (pairs.map{$0.0}, pairs.map{$0.1})
        }

        func tryStream(A_times: [Date], A_hhmm: [String], B_times: [Date]) -> (score: Int, out: [String]) {
            if A_times.isEmpty || B_times.isEmpty { return (0, []) }
            let Asec = A_times.map { $0.timeIntervalSince1970 }
            let Bsec = B_times.map { $0.timeIntervalSince1970 }
            let a10 = percentile(Asec, 10), a90 = percentile(Asec, 90)
            let b10 = percentile(Bsec, 10), b90 = percentile(Bsec, 90)
            var Tmin = Int(floor((b10 - a90) / 60.0))
            var Tmax = Int(ceil ((b90 - a10) / 60.0))
            if !Double(Tmin).isFinite || !Double(Tmax).isFinite || Tmax <= Tmin { Tmin = 1; Tmax = 240 }
            Tmin = max(1, Tmin); Tmax = min(240, Tmax)
            
            // Use user input to refine search window if available
            var roughMin = Double(Tmin * 60)
            var roughMax = Double(Tmax * 60)
            
            if let approxMin = approxRideTime {
                // Determine window width dynamically from "departure interval" (data-driven)
                var head: [Double] = []
                for i in 1..<Bsec.count { head.append(abs(Bsec[i] - Bsec[i-1])) }
                let h75min = (percentile(head, 75) / 60.0).isFinite ? percentile(head, 75) / 60.0 : 10.0
                // Window width = clamp(4 * p75(headway), 15, 40) [minutes] → adaptive width based on route congestion
                let winMin = max(20, min(60, Int(ceil(6.0 * h75min))))
                roughMin = Double(max(1, (approxMin - winMin)) * 60)  // 最低1分
                roughMax = Double(min(240, (approxMin + winMin)) * 60)  // 最大240分
            }

            // Collect deltas using two-pointer technique
            var deltas: [Double] = []; var j = 0
            for a in Asec {
                while j < Bsec.count && (Bsec[j] - a) < roughMin { j += 1 }
                var k = j
                while k < Bsec.count && (Bsec[k] - a) <= roughMax { deltas.append(Bsec[k] - a); k += 1 }
                if j >= Bsec.count { break }
            }
            if deltas.isEmpty { return (0, []) }

            // T* (representative travel time) estimation: prioritize bins close to user input
            let bw = fdBinWidth(deltas); let dmin = deltas.min()!, dmax = deltas.max()!
            let bins = max(1, Int(ceil((dmax - dmin) / bw)))
            var counts = Array(repeating: 0, count: bins)
            for d in deltas { let idx = min(bins - 1, max(0, Int((d - dmin) / bw))); counts[idx] += 1 }
            
            // Tie-breaker: prioritize bins closer to user input (minutes)
            let preferredSec = approxRideTime.map { Double($0 * 60) }
            let peakIdx = (0..<bins).max { (i, j) -> Bool in
                if counts[i] != counts[j] { return counts[i] < counts[j] }
                guard let pref = preferredSec else { return false }
                let ci = dmin + (Double(i) + 0.5) * bw
                let cj = dmin + (Double(j) + 0.5) * bw
                return abs(ci - pref) > abs(cj - pref)
            } ?? 0
            let Tstar = dmin + (Double(peakIdx) + 0.5) * bw

            // Calculate tau (p30 → MAD → minimum value)
            var tau = Double.nan
            if Bsec.count >= 3 {
                var hw: [Double] = []; for i in 1..<Bsec.count { hw.append(abs(Bsec[i] - Bsec[i-1])) }
                let p35 = percentile(hw, 35)
                if p35.isFinite && p35 > 0 { tau = p35 }
            }
            if !tau.isFinite {
                let local = deltas.filter { abs($0 - Tstar) <= bw }
                let sigma = madSigma(local)
                if sigma.isFinite && sigma > 0 { 
                    // Use approxRideTime's 10% as maximum tolerance, rounded up
                    let userToleranceMinutes = approxRideTime.map { Int(ceil(Double($0) * 0.10)) } ?? 3
                    let tauMinutes = max(1, min(userToleranceMinutes, Int(ceil(2.0 * sigma / 60.0))))
                    tau = Double(tauMinutes * 60)  // 分を秒に変換してTimeIntervalで使用
                }
            }
            if !tau.isFinite { tau = 120.0 }

            // Residuals → window (lower bound = p10, upper bound = Tukey upper fence)
            var residuals: [Double] = []; j = 0
            for a in A_times {
                let target = a.addingTimeInterval(Tstar)
                while j < B_times.count && B_times[j] < target.addingTimeInterval(-tau) { j += 1 }
                if j >= B_times.count { break }
                let diff = B_times[j].timeIntervalSince(target)
                if abs(diff) <= tau { residuals.append(diff); j += 1 }
            }
            if residuals.isEmpty { return (0, []) }
            let p05 = percentile(residuals, 5), q1 = percentile(residuals, 25), q3 = percentile(residuals, 75)
            let iqr = q3 - q1
            var lowerMin = Int(ceil(Tstar/60.0 + p05/60.0))
            var upperMin = Int(ceil(Tstar/60.0 + (q3 + 2.0 * iqr)/60.0))
            if upperMin < lowerMin { swap(&lowerMin, &upperMin) }
            if upperMin - lowerMin < 2 { lowerMin = Int(ceil(Tstar/60.0)) - 1; upperMin = Int(ceil(Tstar/60.0)) + 1 }

            // Two-pointer matching (return only departure HH:MM from origin station)
            let lower = TimeInterval(lowerMin * 60), upper = TimeInterval(upperMin * 60)
            var out: [String] = []; var j2 = 0
            for (idx, a) in A_times.enumerated() {
                while j2 < B_times.count && B_times[j2].timeIntervalSince(a) < lower { j2 += 1 }
                if j2 >= B_times.count { break }
                if B_times[j2].timeIntervalSince(a) <= upper { out.append(A_hhmm[idx]); j2 += 1 }
            }
            return (out.count, out)
        }

        for (ty, group) in ObyType {
            // Origin station A
            let Adep = group.map { $0.hhmm }; let At = unwrapTimes(Adep)
            let Apairs = zip(At, Adep).sorted { $0.0 < $1.0 }
            let A_times = Apairs.map { $0.0 }; let A_hhmm = Apairs.map { $0.1 }

            // Destination station B (arrival/departure) - use departure only for scoring if arrival is not available
            let dep = buildStream(Ddep[ty] ?? [])
            let arr = buildStream(Darr[ty] ?? [])

            let rArr = tryStream(A_times: A_times, A_hhmm: A_hhmm, B_times: arr.times)
            let rDep = tryStream(A_times: A_times, A_hhmm: A_hhmm, B_times: dep.times)
            let chosen = (rArr.score >= rDep.score) ? rArr.out : rDep.out
            picked.append(contentsOf: chosen)
        }

        // 5) Remove duplicates and sort
        let uniq = Array(Set(picked))
        let sorted = uniq.sorted { (a, b) -> Bool in
            let pa = a.split(separator: ":"), pb = b.split(separator: ":")
            let ha = Int(pa.first ?? "0") ?? 0, ma = Int(pa.last ?? "0") ?? 0
            let hb = Int(pb.first ?? "0") ?? 0, mb = Int(pb.last ?? "0") ?? 0
            return ha == hb ? ma < mb : ha < hb
        }
        
        // Convert sorted departure times to TrainTime objects
        let trainTimes = sorted.compactMap { departureTime in
            // Find the corresponding trainType from departureTimetableData
            let matchingData = departureTimetableData.first { $0.departureTime == departureTime }
            return TrainTime(
                departureTime: matchingData?.departureTime ?? "",
                arrivalTime: "", // No arrival time available for estimated times
                trainNumber: nil,
                trainType: matchingData?.trainType, // Get actual train type
                rideTime: approxRideTime ?? 0
            )
        }
        
        return trainTimes
    }
    
    // MARK: - Input Processing
    /// Processes departure station input changes
    func processDepartureStationInput(_ newValue: String) {
        // Don't show suggestions if line number is being changed
        if isLineNumberChanging {
            return
        }
        
        // Set focus state and reset selection flag when input changes
        isDepartureFieldFocused = true
        departureStationSelected = false
        
        // Clear input if same station as arrival station is entered
        let isSameAsArrival = selectedArrivalStation?.getLocalizedName() == newValue
        if isSameAsArrival {
            departureStationInput = ""
            selectedDepartureStation = nil
        } else {
            // Filter suggestions
            filterDepartureStations(newValue)
        }
    }
    
    /// Processes arrival station input changes
    func processArrivalStationInput(_ newValue: String) {
        // Don't show suggestions if line number is being changed
        if isLineNumberChanging {
            return
        }
        
        // Set focus state and reset selection flag when input changes
        isArrivalFieldFocused = true
        arrivalStationSelected = false
        
        // Clear input message on input
        let isSameAsDeparture = selectedDepartureStation?.getLocalizedName() == newValue
        if isSameAsDeparture {
            arrivalStationInput = ""
            selectedArrivalStation = nil
        } else {
            // Filter suggestions
            filterArrivalStations(newValue)
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
            // Clear line selection and station data without resetting ride time
            selectedLine = nil
            departureStationInput = ""
            arrivalStationInput = ""
            selectedDepartureStation = nil
            selectedArrivalStation = nil
            showDepartureSuggestions = false
            departureSuggestions = []
            showArrivalSuggestions = false
            arrivalSuggestions = []
            isDepartureFieldFocused = false
            isArrivalFieldFocused = false
            // Reset station selection flags to allow suggestions to show
            departureStationSelected = false
            arrivalStationSelected = false
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
        
        // Clear station fields when line is selected
        departureStationInput = ""
        arrivalStationInput = ""
        selectedDepartureStation = nil
        selectedArrivalStation = nil
        
        // Clear suggestion displays
        showDepartureSuggestions = false
        departureSuggestions = []
        showArrivalSuggestions = false
        arrivalSuggestions = []
        isDepartureFieldFocused = false
        isArrivalFieldFocused = false
        
        // Reset ride time to 0 minutes when line is selected
        selectedRideTime = 0
        
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
        departureStationInput = ""
        arrivalStationInput = ""
        
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
}


