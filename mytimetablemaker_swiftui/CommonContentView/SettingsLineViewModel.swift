//
//  SettingsLineViewModel.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2025/08/12.
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
    @Published var query: String = ""                    // Search query input for line search
    @Published var lineSuggestions: [TransportationLine] = [] // Search results for line suggestions
    @Published var isLoading: Bool = false               // Loading state for update operations
    @Published var lastUpdatedDisplay: String? = nil     // Last update timestamp for display
    @Published var showColorSelection: Bool = false      // Color picker visibility state
    @Published var showStationSelection: Bool = false    // Station selection UI visibility state
    @Published var statistics: DataStatistics = DataStatistics()  // Data statistics for monitoring
    
    // Line and station selection state management
    @Published var selectedLine: TransportationLine?           // Currently selected railway line
    @Published var lineStations: [Station] = []               // Stations available on the selected line
    @Published var selectedDepartureStation: Station?         // User-selected departure station
    @Published var selectedArrivalStation: Station?           // User-selected arrival station
    
    // User input fields for data entry
    @Published var departureStationInput: String = ""         // Departure station search input text
    @Published var arrivalStationInput: String = ""           // Arrival station search input text
    @Published var selectedRideTime: Int = 0                  // Selected ride time in minutes
    
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
    
    // Line configuration and customization
    @Published var selectedLineColor: String? = nil            // Selected line color hex value for display
    @Published var selectedTransportationKind: TransportationLine.Kind = .railway  // Selected transportation kind (default: railway)
    @Published var selectedTransferTime: Int = 5               // Acceptable transfer time in minutes
    @Published var selectedTransportation: String = "none"     // Selected transportation method (default: none)
    @Published var selectedLineNumber: Int = 1                 // Currently selected line number (1-3)
    @Published var availableLineNumbers: [Int] = [1]           // Available line numbers based on changeLine
    @Published var isLineNumberChanging: Bool = false          // Flag to indicate line number is being changed
    @Published var selectedGoorback: String = "back1"          // Currently selected route direction
    
    let goorbackOptions: [String] = ["back1", "back2", "go1", "go2"]  // Available route options
    
    // Computed properties for UI state checking
    var hasSelectedLine: Bool { selectedLine != nil }
    var hasStations: Bool { !lineStations.isEmpty }
    
    // Get localized display names for route options
    var goorbackDisplayNames: [String: String] {
        [
            "back1": "Route 1".localized,
            "back2": "Route 2".localized, 
            "go1": "Route 1".localized,
            "go2": "Route 2".localized
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
        
        // Setup search query debouncing for improved performance
        $query
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
        if UserDefaults.standard.object(forKey: goorback.changeLineKey) == nil {
            UserDefaults.standard.set(0, forKey: goorback.changeLineKey)
        }
        
        updateAvailableLineNumbers()
        loadAllSettings()
        
        // Load data from shared service in background
        Task.detached(priority: .userInitiated) { [weak self] in
            await self?.loadFromSharedService()
        }
        
        // Check saved line in background for validation
        Task.detached(priority: .background) { [weak self] in
            await self?.checkSavedLineInData()
        }
    }
    
    // MARK: - Route Selection Management
    // Handle goorback selection changes and reset related state
    func selectGoorback(_ newGoorback: String) {
        selectedGoorback = newGoorback
        resetSelections()
        loadAllSettings()
        updateAvailableLineNumbers()
    }
    
    // Reset all selections when route changes
    private func resetSelections() {
        query = ""
        selectedLine = nil
        lineStations = []
        selectedDepartureStation = nil
        selectedArrivalStation = nil
        departureStationInput = ""
        arrivalStationInput = ""
        selectedRideTime = 5
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
    
    // Load all settings from UserDefaults
    private func loadAllSettings() {
        loadLineColorSettings()
        loadLineNameSettings()
        loadStationSettings()
        loadRideTimeSettings()
        loadTransferSettings()
        loadTransportationKindSettings()
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
        
        await filter(query)
        await updateStatistics()
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
    // Filter railway lines based on search query with performance optimizations
    func filter(_ q: String) async {
        let t = q.normalizedForSearch
        guard !t.isEmpty else { 
            lineSuggestions = []
            nameCounts = [:]
            showLineSuggestions = false
            return 
        }
        
        // Don't show suggestions if line number is being changed or line is already selected
        if isLineNumberChanging || lineSelected { return }
        
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
            let starts = searchData.filter { displayName(for: $0).normalizedForSearch.hasPrefix(t) }
            let contains = searchData.filter { !displayName(for: $0).normalizedForSearch.hasPrefix(t) && displayName(for: $0).normalizedForSearch.contains(t) }
            let allResults = starts + contains
            
            // Remove duplicates by displayName to show only unique route names
            let displayNames = allResults.map { displayName(for: $0) }
            let uniqueDisplayNames = Array(Set(displayNames))
            let uniqueResults = uniqueDisplayNames.compactMap { uniqueDisplayName in
                allResults.first { displayName(for: $0) == uniqueDisplayName }
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
            showLineSuggestions = displayName(for: singleLine).normalizedForSearch != q.normalizedForSearch
        } else {
            showLineSuggestions = !lineSuggestions.isEmpty
        }
        
        nameCounts = Dictionary(grouping: lineSuggestions) { displayName(for: $0) }
            .mapValues { $0.count }
    }
    
    // Get localized display name for transportation line
    func displayName(for line: TransportationLine) -> String {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        if line.kind == .bus {
            if currentLanguage == "ja" {
                return line.name
            } else {
                return line.busRouteEnglishName ?? line.railwayTitle?.en ?? line.name
            }
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
    // Filter candidate departure stations based on search query
    func filterDepartureStations(_ query: String) {
        let filtered = filterStations(query, excludeStation: selectedArrivalStation)
        departureSuggestions = filtered
        showDepartureSuggestions = isDepartureFieldFocused && !filtered.isEmpty && !departureStationSelected
    }
    
    // Filter candidate arrival stations based on search query
    func filterArrivalStations(_ query: String) {
        let filtered = filterStations(query, excludeStation: selectedDepartureStation)
        arrivalSuggestions = filtered
        showArrivalSuggestions = isArrivalFieldFocused && !filtered.isEmpty && !arrivalStationSelected
    }
    
    // Common station filtering logic used by both departure and arrival station searches
    private func filterStations(_ query: String, excludeStation: Station?) -> [Station] {
        guard !query.isEmpty else { return [] }
        
        let filtered: [Station] = {
            // Bus route filtering - only search within selected line's bus stops
            if let selectedLine = selectedLine, selectedLine.kind == .bus {
                if !lineStations.isEmpty {
                    return lineStations.filter { $0.getLocalizedName().localizedCaseInsensitiveContains(query) }
                } else {
                    if let busstopPoleOrder = selectedLine.busstopPoleOrder {
                        let busStops: [Station] = busstopPoleOrder.compactMap { busStop in
                            let stopName = busStop.busstopPoleTitle?.getLocalizedName() ?? 
                                         busStop.busStopEnglishName ?? 
                                         busStop.note ?? ""
                            guard !stopName.isEmpty else { return nil }
                            return Station(
                                name: stopName,
                                code: busStop.busstopPole,
                                title: StationTitle(
                                    ja: busStop.busstopPoleTitle?.ja ?? busStop.note,
                                    en: busStop.busstopPoleTitle?.en ?? busStop.busStopEnglishName ?? busStop.note
                                )
                            )
                        }
                        return busStops.filter { $0.getLocalizedName().localizedCaseInsensitiveContains(query) }
                    }
                    return []
                }
            }
            
            // Railway line filtering - use existing logic
            if selectedLine != nil, !lineStations.isEmpty {
                return lineStations.filter { $0.getLocalizedName().localizedCaseInsensitiveContains(query) }
            } else if !self.query.isEmpty {
                let lineStations = getStationsForLineName(self.query)
                if !lineStations.isEmpty {
                    return lineStations.filter { $0.getLocalizedName().localizedCaseInsensitiveContains(query) }
                } else {
                    return getAllAvailableStations().filter { $0.getLocalizedName().localizedCaseInsensitiveContains(query) }
                }
            } else {
                return getAllAvailableStations().filter { $0.getLocalizedName().localizedCaseInsensitiveContains(query) }
            }
        }()
        
        return excludeStation.map { station in
            filtered.filter { $0.getLocalizedName() != station.getLocalizedName() }
        } ?? filtered
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
    func extractStationsFromRailway(_ railway: [String: Any], searchMethod: String, searchValue: String) -> [Station]? {
        // Handle bus routes - extract bus stops from odpt:busstopPoleOrder
        if let type = railway["@type"] as? String, type == "odpt:BusroutePattern" {
            let busStops: [Station]? = (railway["odpt:busstopPoleOrder"] as? [[String: Any]])?.compactMap { busStopInfo in
                if let busstopPoleTitle = busStopInfo["odpt:busstopPoleTitle"] as? [String: Any] {
                    let jaName = busstopPoleTitle["ja"] as? String
                    let enName = busstopPoleTitle["en"] as? String
                    let stopName = enName ?? jaName ?? busStopInfo["odpt:note"] as? String ?? ""
                    guard !stopName.isEmpty else { return nil }
                    return Station(
                        name: stopName,
                        code: busStopInfo["odpt:busstopPole"] as? String,
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
                        title: StationTitle(ja: note, en: englishName)
                    )
                } else if let note = busStopInfo["odpt:note"] as? String {
                    return Station(
                        name: note,
                        code: busStopInfo["odpt:busstopPole"] as? String,
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
                
                return Station(
                    name:  jaName ?? enName ?? "Unknown station",
                    code: nil,
                    title: StationTitle(ja: jaName, en: enName)
                )
            }
        }
        return stations?.isEmpty == false ? stations : nil
    }
    
    // Get station information based on line name
    func getStationsForLineName(_ lineName: String) -> [Station] {
        // Handle bus routes - extract bus stops from TransportationLine.busstopPoleOrder
        if let selectedLine = selectedLine, selectedLine.kind == .bus {
            if let busstopPoleOrder = selectedLine.busstopPoleOrder {
                let busStops: [Station] = busstopPoleOrder.compactMap { busStop in
                    let stopName = busStop.busstopPoleTitle?.getLocalizedName() ?? 
                                 busStop.busStopEnglishName ?? 
                                 busStop.note ?? ""
                    guard !stopName.isEmpty else { return nil }
                    return Station(
                        name: stopName,
                        code: busStop.busstopPole,
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
        
        // Search through data files for railway stations
        return stationDataFiles.lazy.compactMap { [self] filename in
            self.loadLocalData(for: filename).flatMap { [self] data in
                self.parseStationsByLineName(data, lineName: lineName)
            }
        }.first ?? []
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
            query = displayName(for: line)
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
        return !query.isEmpty && !departureStationInput.isEmpty && !arrivalStationInput.isEmpty && departureStationInput != arrivalStationInput
    }
    
    // Set line color without saving to UserDefaults
    func setLineColor(_ color: String) {
        selectedLineColor = color
        showColorSelection = false
    }
    
    // Common save processing for all line types
    func handleLineSave(dismiss: DismissAction) {
        saveAllDataToUserDefaults()
        updateDisplay()        
        NotificationCenter.default.post(name: NSNotification.Name("SettingsLineUpdated"), object: nil)
        dismiss()
    }
    
    // MARK: - Data Validation
    // Check if line read from UserDefaults exists in current data
    func checkSavedLineInData() async {
        // Wait for data loading to complete before validation
        while all.isEmpty {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let lineSelectedKey = goorback.lineSelectedKey(lineIndex)
        let wasLineSelected = UserDefaults.standard.bool(forKey: lineSelectedKey)
        
        if wasLineSelected {
            if let foundLine = all.first(where: { line in
                if line.kind == .bus {
                    return line.name == query || 
                           line.railwayTitle?.getLocalizedName() == query ||
                           line.busRouteEnglishName == query
                } else {
                    return line.name == query || line.railwayTitle?.getLocalizedName() == query
                }
            }) {
                selectedLine = foundLine
                showStationSelection = true
                
                // Set bus stops for bus routes
                if foundLine.kind == .bus {
                    if let busstopPoleOrder = foundLine.busstopPoleOrder {
                        let busStops: [Station] = busstopPoleOrder.compactMap { busStop in
                            let stopName = busStop.busstopPoleTitle?.getLocalizedName() ?? 
                                         busStop.busStopEnglishName ?? 
                                         busStop.note ?? ""
                            guard !stopName.isEmpty else { return nil }
                            return Station(
                                name: stopName,
                                code: busStop.busstopPole,
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
            }
        }
    }
    
    // MARK: - Data Persistence
    // Save all information when save button is pressed
    func saveAllDataToUserDefaults() {
        let lineIndex = selectedLineNumber - 1
        
        // Save line name and code
        if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lineNameKey = selectedGoorback.lineNameKey(lineIndex)
            UserDefaults.standard.set(query, forKey: lineNameKey)
            
            let lineCodeKey = selectedGoorback.lineCodeKey(lineIndex)
            let lineCodeToSave = all.first { line in
                if line.kind == .bus {
                    return line.name == query || 
                           line.railwayTitle?.getLocalizedName() == query ||
                           line.busRouteEnglishName == query
                } else {
                    return line.name == query || line.railwayTitle?.getLocalizedName() == query
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
        
        // Save station information
        if !departureStationInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let departureKey = selectedGoorback.departStationKey(lineIndex)
            UserDefaults.standard.set(departureStationInput, forKey: departureKey)
        }
        
        if !arrivalStationInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let arrivalKey = selectedGoorback.arriveStationKey(lineIndex)
            UserDefaults.standard.set(arrivalStationInput, forKey: arrivalKey)
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
        
        // Enable route 2 display when saving data for route 2
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
                                
                                let stationName = jaName ?? enName ?? "Unknown station"
                                
                                let station = Station(
                                    name: stationName,
                                    code: nil,
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
        let userDefaultsKey = selectedGoorback.lineColorKey(lineIndex)
        self.selectedLineColor = UserDefaults.standard.string(forKey: userDefaultsKey)
    }
    
    // Load line name settings from UserDefaults
    private func loadLineNameSettings() {
        let lineNameKey = selectedGoorback.lineNameKey(lineIndex)
        if let savedLineName = UserDefaults.standard.string(forKey: lineNameKey) {
            self.query = savedLineName
        }
    }
    
    // Load station settings from UserDefaults
    private func loadStationSettings() {
        let departureKey = selectedGoorback.departStationKey(lineIndex)
        if let savedDeparture = UserDefaults.standard.string(forKey: departureKey) {
            self.departureStationInput = savedDeparture
            self.selectedDepartureStation = findStationByName(savedDeparture)
        } else {
            self.departureStationInput = ""
            self.selectedDepartureStation = nil
        }
        
        let arrivalKey = selectedGoorback.arriveStationKey(lineIndex)
        if let savedArrival = UserDefaults.standard.string(forKey: arrivalKey) {
            self.arrivalStationInput = savedArrival
            self.selectedArrivalStation = findStationByName(savedArrival)
        } else {
            self.arrivalStationInput = ""
            self.selectedArrivalStation = nil
        }
    }
    
    // Load ride time settings from UserDefaults
    private func loadRideTimeSettings() {
        let rideTimeKey = selectedGoorback.rideTimeKey(lineIndex)
        self.selectedRideTime = UserDefaults.standard.integer(forKey: rideTimeKey)
    }
    
    // Load transfer settings from UserDefaults
    private func loadTransferSettings() {
        if lineIndex < 2 {
            let transportationKey = selectedGoorback.transportationKey(lineIndex + 2)
            if let savedTransportation = UserDefaults.standard.string(forKey: transportationKey), !savedTransportation.isEmpty {
                self.selectedTransportation = savedTransportation
            } else {
                self.selectedTransportation = "none"
            }
            
            let transferTimeKey = selectedGoorback.transferTimeKey(lineIndex + 2)
            let savedTransferTime = UserDefaults.standard.integer(forKey: transferTimeKey)
            if savedTransferTime > 0 {
                self.selectedTransferTime = savedTransferTime
            } else {
                self.selectedTransferTime = 5
            }
        } else {
            self.selectedTransportation = "none"
            self.selectedTransferTime = 5
        }
    }
    
    // Load transportation kind settings from UserDefaults
    private func loadTransportationKindSettings() {
        let lineKindKey = selectedGoorback.lineKindKey(lineIndex)
        if let savedKindString = UserDefaults.standard.string(forKey: lineKindKey) {
            self.selectedTransportationKind = TransportationLine.Kind(rawValue: savedKindString) ?? .railway
        } else {
            self.selectedTransportationKind = .railway
        }
    }
    
    // MARK: - Line Selection Management
    // Update available line numbers based on changeLine setting
    func updateAvailableLineNumbers() {
        let changeLineValue = UserDefaults.standard.integer(forKey: selectedGoorback.changeLineKey)
        
        availableLineNumbers = Array(1...min(changeLineValue + 1, 3))
        
        // Reset transportation settings for lines beyond current transfer count
        for i in (changeLineValue + 2)...4 {
            let transportationKey = selectedGoorback.transportationKey(i)
            UserDefaults.standard.set("none", forKey: transportationKey)
        }
        
        if selectedLineNumber == 1 && lineIndex > 0 {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isLineNumberChanging = false
        }
    }
    
    // Load settings for the currently selected line number
    private func loadSettingsForSelectedLine() {
        let currentLineIndex = selectedLineNumber - 1
        
        let colorKey = goorback.lineColorKey(currentLineIndex)
        self.selectedLineColor = UserDefaults.standard.string(forKey: colorKey)
        
        let lineNameKey = goorback.lineNameKey(currentLineIndex)
        if let savedLineName = UserDefaults.standard.string(forKey: lineNameKey) {
            self.query = savedLineName
        }
        
        let lineKindKey = goorback.lineKindKey(currentLineIndex)
        if let savedKindString = UserDefaults.standard.string(forKey: lineKindKey) {
            self.selectedTransportationKind = TransportationLine.Kind(rawValue: savedKindString) ?? .railway
        } else {
            self.selectedTransportationKind = .railway
        }
        
        let departureKey = goorback.departStationKey(currentLineIndex)
        if let savedDeparture = UserDefaults.standard.string(forKey: departureKey) {
            self.departureStationInput = savedDeparture
            self.selectedDepartureStation = findStationByName(savedDeparture)
        } else {
            self.departureStationInput = ""
            self.selectedDepartureStation = nil
        }
        
        let arrivalKey = goorback.arriveStationKey(currentLineIndex)
        if let savedArrival = UserDefaults.standard.string(forKey: arrivalKey) {
            self.arrivalStationInput = savedArrival
            self.selectedArrivalStation = findStationByName(savedArrival)
        } else {
            self.arrivalStationInput = ""
            self.selectedArrivalStation = nil
        }
        
        let rideTimeKey = goorback.rideTimeKey(currentLineIndex)
        self.selectedRideTime = UserDefaults.standard.integer(forKey: rideTimeKey)
        
        if selectedLineNumber < 3 {
            let transportationKey = goorback.transportationKey(currentLineIndex + 2)
            if let savedTransportation = UserDefaults.standard.string(forKey: transportationKey), !savedTransportation.isEmpty {
                self.selectedTransportation = savedTransportation
            } else {
                self.selectedTransportation = "none"
            }
            
            let transferTimeKey = goorback.transferTimeKey(currentLineIndex + 2)
            let savedTransferTime = UserDefaults.standard.integer(forKey: transferTimeKey)
            if savedTransferTime > 0 {
                self.selectedTransferTime = savedTransferTime
            } else {
                self.selectedTransferTime = 5
            }
        } else {
            self.selectedTransportation = "none"
            self.selectedTransferTime = 5
        }
    }
    
    // Find station object by name from all available stations
    private func findStationByName(_ stationName: String) -> Station? {
        return getAllAvailableStations().first { station in
            station.getLocalizedName() == stationName
        }
    }
}
