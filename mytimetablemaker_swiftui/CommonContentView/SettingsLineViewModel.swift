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
                busstopPoleOrder: updatedLine.busstopPoleOrder
            )
            selectedLine = updatedLine
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
    
    // MARK: - Train Timetable Data Processing
    // Get train timetable data and extract departure/arrival times for selected stations
    func getTrainTimeTableData() async -> (weekday: [TrainTime], weekend: [TrainTime]) {
        
        // Skip timetable generation if not all required fields are filled
        guard isAllNotEmpty else {
            print("⚠️ Skipping train timetable generation: not all required fields are filled")
            return (weekday: [], weekend: [])
        }
        
        print("🚂 Starting train timetable data generation")
        print("🚂 Departure Station: \(selectedDepartureStation?.name ?? "Unknown") (Code: \(selectedDepartureStation?.code ?? "nil"))")
        print("🚂 Arrival Station: \(selectedArrivalStation?.name ?? "Unknown") (Code: \(selectedArrivalStation?.code ?? "nil"))")
        
        // Process both weekday and weekend data
        var weekdayTrainTimes: [TrainTime] = []
        var weekendTrainTimes: [TrainTime] = []
        
        for isWeekday in [true, false] {
            let trainTimes = await processTrainTimetableData(isWeekday: isWeekday)
            
            // Save to appropriate array based on weekday/weekend
            if isWeekday {
                weekdayTrainTimes.append(contentsOf: trainTimes)
            } else {
                weekendTrainTimes.append(contentsOf: trainTimes)
            }
            
            print("✅ \(isWeekday ? "Weekday" : "Weekend") trains: \(trainTimes.count)")
        }
        
        print("✅ Train timetable generation completed")
        
        return (weekday: weekdayTrainTimes, weekend: weekendTrainTimes)        
    }
    
    // Process train timetable data for specific day type
    private func processTrainTimetableData(isWeekday: Bool) async -> [TrainTime] {
        print("🚂 Processing \(isWeekday ? "weekday" : "weekend") train timetable data")
        
        // Fetch train timetable data from API
        let trainTimetableData = await fetchTrainTimetableData(isWeekday: isWeekday)
        
        // Extract train information and timetable objects in a single loop
        var trainTimes: [TrainTime] = []
        
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
                if let departureStation = timetableObject["odpt:departureStation"] as? String,
                   departureStation == selectedDepartureStation?.code {
                    departureTime = timetableObject["odpt:departureTime"] as? String
                }
                
                // Check arrival station match
                if let arrivalStation = timetableObject["odpt:arrivalStation"] as? String,
                   arrivalStation == selectedArrivalStation?.code {
                    arrivalTime = timetableObject["odpt:arrivalTime"] as? String
                } else if let departureStation = timetableObject["odpt:departureStation"] as? String,
                          departureStation == selectedArrivalStation?.code {
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
                    trainTimes.append(trainTime)
                }
            }
        }
        
        print("🚂 Train Times: \(trainTimes.count) trains")
        
        return trainTimes
    }
    
    // Fetch train timetable data from API
    private func fetchTrainTimetableData(isWeekday: Bool) async -> [[String: Any]] {
        guard let operatorCode = selectedLine?.operatorCode,
              let selectedLineCode = selectedLine?.code,
              let selectedOperator = LocalDataSource.allCases.first(where: { $0.operatorCode == operatorCode }) else { return [] }
        
        let calendarType = isWeekday ? "odpt.Calendar:Weekday" : "odpt.Calendar:SaturdayHoliday"
        print("🔍 Calendar type: \(calendarType)")
        
        let apiLink = "\(selectedOperator.apiLink(for: .timetable))&odpt:railway=\(selectedLineCode)&odpt:calendar=\(calendarType)"
        
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
            
            print("✅ Fetched \(json.count) train timetable records for \(isWeekday ? "weekday" : "weekend")")
            return json
            
        } catch {
            print("❌ Error fetching train timetable data: \(error)")
            return []
        }
    }
    
    // MARK: - Train Route Validation
    // Get station timetable data for determined direction and find common train numbers
    func getStationTimetableData() async -> (weekday: [TrainTime], weekend: [TrainTime]) {
        
        // Skip timetable generation if not all required fields are filled
        guard isAllNotEmpty else {
            print("⚠️ Skipping timetable generation: not all required fields are filled")
            return (weekday: [], weekend: [])
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
        
        var results: [[TrainTime]] = []
        
        for isWeekday in [true, false] {
            print("🔄 Processing \(isWeekday ? "Weekday" : "Weekend") data for both directions")
            
            // Get data for both directions
            let directions = [ascendingDirection, descendingDirection]
            let directionNames = ["ascending", "descending"]
            var directionResults: [[TrainTime]] = []
            
            for (index, direction) in directions.enumerated() {
                print("📊 Get \(directionNames[index].capitalized) Direction Timetable Data:")
                
                // Get departure and arrival data for this direction
                let departureLink = stationTimetableApiLink(isDeparture: true, isWeekday: isWeekday, direction: direction)
                let arrivalLink = stationTimetableApiLink(isDeparture: false, isWeekday: isWeekday, direction: direction)
                
                print("🔗 Departure link: \(departureLink)")
                print("🔗 Arrival link: \(arrivalLink)")
                
                let departureData = await fetchStationTimetableData(from: departureLink)
                let arrivalData = await fetchStationTimetableData(from: arrivalLink)
                
                print("\(directionNames[index]) \(isWeekday ? "Weekday" : "Weekend") Departure count: \(departureData.count)")
                print("\(directionNames[index]) \(isWeekday ? "Weekday" : "Weekend") Arrival count: \(arrivalData.count)")
                
                // Process this direction if we have both departure and arrival data
                var result: [TrainTime] = []
                if departureData.count > 0 {
                    print("Get \(directionNames[index]) departure timetable not using train numbers (no trains with numbers found)")
                    result = await getEstimatedTrainTime(
                        departureTimetableData: departureData,
                        arrivalTimetableData: arrivalData,
                        isWeekday: isWeekday,
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
            
            // Save to appropriate array
            results.append(selectedResult)
        }
        return (weekday: results[0], weekend: results[1])
    }
    
    // MARK: - Station Timetable Data Processing
    // Generate station timetable link with flexible parameters
    func stationTimetableApiLink(isDeparture: Bool, isWeekday: Bool, direction: String? = nil) -> String {
        
    // Generate timetable information links for departure and arrival stations
        let operatorCode = selectedLine?.operatorCode ?? ""
        let dataSource = LocalDataSource.allCases.first { $0.operatorCode == operatorCode }
        let stationTimetableApiLink = dataSource?.apiLink(for: .stationTimetable) ?? ""
        
        // Extract station name from station code (remove "odpt.Station:" prefix)
        let lineCode = selectedLine?.code ?? ""
        let lineName = lineCode.replacingOccurrences(of: "odpt.Railway:", with: "&owl:sameAs=odpt.StationTimetable:")
        
        let stationCode = (isDeparture ? selectedDepartureStation?.code: selectedArrivalStation?.code) ?? ""
        let stationName = stationCode.components(separatedBy: ".").last ?? ""
        
        // Use provided direction or fallback to lineDirection from selectedLine
        let directionCode = direction ?? String(selectedLine?.lineDirection ?? "")
        let directionName = directionCode.replacingOccurrences(of: "odpt.RailDirection:", with: "")
        
        let dateSuffix = isWeekday ? ".Weekday" : ".SaturdayHoliday"
        
        let apiLink = "\(stationTimetableApiLink)\(lineName).\(stationName).\(directionName)\(dateSuffix)"
        
        print("🔍 stationInformationLink - isDeparture: \(isDeparture), isWeekday: \(isWeekday), direction: \(directionName), apiLink: \(apiLink)")
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
        isWeekday: Bool,
        approxRideTime: Int
    ) async -> [TrainTime] {

        print("🚀🚀🚀 getEstimatedTrainTime STARTED 🚀🚀🚀")
        print("🔍 getEstimatedTrainTime: Processing \(departureTimetableData.count) departure records and \(arrivalTimetableData.count) arrival records")

        // Get unique train types from departure data
        let trainTypeList = departureTimetableData.trainTypeList
        print("🔍 Processing train types: \(trainTypeList)")
        
        var allTrainTimes: [TrainTime] = []
        
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
                !data.destinationStation.isEmpty && data.destinationStation == selectedArrivalStation?.code
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
                allTrainTimes.append(contentsOf: terminalTrainTimes)
            }

            print("🚉 terminalTrainTimes count: \(terminalTrainTimes.count)")
            
            // Remove terminalDepartureData from departureData
            let filteredDepartureData = departureData.filter { data in
                data.destinationStation.isEmpty || data.destinationStation != selectedArrivalStation?.code
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
                    allTrainTimes.append(contentsOf: trainTimes)
                }
            } else {
                print("❌ No data for train type: \(trainType)")
            }
        }
        
        // Sort all train times by departure time
        let sortedTrainTimes = allTrainTimes.sorted { first, second in
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
    ) -> [TrainTime] {
        
        // 0) Filter out trains that don't reach the arrival station (only for trains without train numbers)
        let filteredDepartureData = departureData.filter { data in
            if data.trainNumber.isEmpty && !isTrainReachingArrivalStation(destinationStation: data.destinationStation) {
                let departureIndex = selectedDepartureStation?.index ?? -1
                let arrivalIndex = selectedArrivalStation?.index ?? -1
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
        var trainTimes: [TrainTime] = []
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
                trainTimes.append(trainTime)
                usedArrivals.insert(bestIndex)
            }
        }
        return trainTimes
    }
    
    // Check if train reaches the arrival station (destination station index is not between departure and arrival)
    private func isTrainReachingArrivalStation(destinationStation: String) -> Bool {
        // Get station indices for departure, arrival, and destination stations
        guard let departureIndex = selectedDepartureStation?.index,
              let arrivalIndex = selectedArrivalStation?.index,
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
        
        // Use already loaded line stations instead of filtering all stations
        let selectedLineStations = lineStations.isEmpty ? getStationsForSelectedLine() : lineStations
        
        // Find station by code or name match
        if let station = selectedLineStations.first(where: { 
            $0.code == destinationStationCode || 
            $0.name == stationName || 
            $0.getLocalizedName() == stationName
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
        
        // Print ride time list for verification
        print("AllTrainTimes: \(allTrainTimes.count)")
    }
    
    // MARK: - Common Timetable Data Finalization with Arrays
    // Common post-processing for timetable data with weekday/weekend arrays
    func finalizeTimetableData(weekdayTrainTimes: [TrainTime], weekendTrainTimes: [TrainTime]) async {
        // Save all timetable data to UserDefaults
        saveTimetableToUserDefaults(trainTime: weekdayTrainTimes, isWeekday: true)
        saveTimetableToUserDefaults(trainTime: weekendTrainTimes, isWeekday: false)
        
        // Save all data after timetable data has been processed and saved
        await saveAllDataToUserDefaults()
        
        // Notify that timetable data has been updated
        NotificationCenter.default.post(name: NSNotification.Name("TimetableDataUpdated"), object: nil)
    }
    
    
    // MARK: - Timetable Data Clearing
    // Clear existing timetable data for specified day type
    private func clearTimetableData(isWeekday: Bool) {
        print("🧹 Clearing timetable data for \(isWeekday ? "weekdays" : "weekends")")
        
        // Clear all hours (4-24) for the specified day type and line
        for hour in 4...25 {
            let timetableKey = selectedGoorback.timetableKey(isWeekday, selectedLineNumber - 1, hour)
            let timetableRideTimeKey = selectedGoorback.timetableRideTimeKey(isWeekday, selectedLineNumber - 1, hour)
            let timetableTrainTypeKey = selectedGoorback.timetableTrainTypeKey(isWeekday, selectedLineNumber - 1, hour)
            UserDefaults.standard.removeObject(forKey: timetableKey)
            UserDefaults.standard.removeObject(forKey: timetableRideTimeKey)
            UserDefaults.standard.removeObject(forKey: timetableTrainTypeKey)
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
            // Clear line selection but preserve station data and ride time
            selectedLine = nil
            // DO NOT clear departureStationInput, arrivalStationInput, or selectedRideTime
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
}



