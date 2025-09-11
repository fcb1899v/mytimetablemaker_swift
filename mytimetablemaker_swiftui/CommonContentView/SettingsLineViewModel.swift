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
    @Published var selectedRideTime: Int = 0                  // Selected ride time in minutes
    var isAllNotEmpty: Bool { !departureStationInput.isEmpty && !arrivalStationInput.isEmpty && !lineInput.isEmpty }
    
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
    @Published var selectedLineColor: String? = nil            // Selected line color hex value for display
    @Published var selectedTransportationKind: TransportationLine.Kind = .railway  // Selected transportation kind (default: railway)
    @Published var selectedTransferTime: Int = 5               // Acceptable transfer time in minutes
    @Published var selectedTransportation: String = "none"     // Selected transportation method (default: none)
    @Published var selectedLineNumber: Int = 1                 // Currently selected line number (1-3)
    @Published var availableLineNumbers: [Int] = [1]           // Available line numbers based on changeLine
    @Published var isLineNumberChanging: Bool = false          // Flag to indicate line number is being changed
    @Published var isGoorBackChanging: Bool = false          // Flag to indicate direction is being changed
    @Published var selectedGoorback: String = "back1"          // Currently selected route direction
    
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
        
        // Set flag to indicate route is changing
        isGoorBackChanging = true
        
        // Hide all suggestions during direction change (same as line number change)
        showDepartureSuggestions = false
        showArrivalSuggestions = false
        showLineSuggestions = false
        isDepartureFieldFocused = false
        isArrivalFieldFocused = false
        lineSuggestions = []
        
        selectedGoorback = newGoorback
        updateAvailableLineNumbers()
        loadSettingsForSelectedLine()
        
        // Check if saved line exists in loaded data and restore it (same as initialization)
        Task {
            await checkSavedLineInData()
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
            let starts = searchData.filter { displayName(for: $0).normalizedForSearch.hasPrefix(t) }
            let contains = searchData.filter { !displayName(for: $0).normalizedForSearch.hasPrefix(t) && displayName(for: $0).normalizedForSearch.contains(t) }
            let allResults = starts + contains
            
            // Remove duplicates by displayName to show only unique direction names
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
            lineInput = displayName(for: line)
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
                    
                    // Ensure station information is properly restored
                    // Re-load station settings to ensure they are correctly restored
                    loadStationSettings()
                    
                    // Update station selection flags based on current station data
                    departureStationSelected = selectedDepartureStation != nil
                    arrivalStationSelected = selectedArrivalStation != nil
                    lineSelected = selectedLine != nil
                    
                    print("✅ Restored saved line: \(foundLine.name) (\(foundLine.kind.rawValue))")
                }
            } else {
                // Keep user input even if saved line not found in current data
                await MainActor.run {
                    // Don't clear lineInput - preserve user's saved line name
                    selectedLine = nil
                    lineStations = []
                    showStationSelection = false
                    
                    // Reset station selection flags when line is not found
                    lineSelected = false
                    departureStationSelected = false
                    arrivalStationSelected = false
                    
                    // Set lineSelected flag to false when line is not found
                    let lineSelectedKey = selectedGoorback.lineSelectedKey(selectedLineNumber - 1)
                    UserDefaults.standard.set(false, forKey: lineSelectedKey)
                    
                    print("⚠️ Saved line '\(lineInput)' not found in current data - keeping user input")
                }
            }
        } else {
            // Even if lineInput is empty, ensure station information is restored
            await MainActor.run {
                // Re-load station settings to ensure they are correctly restored
                loadStationSettings()
                
                // Update station selection flags based on current station data
                departureStationSelected = selectedDepartureStation != nil
                arrivalStationSelected = selectedArrivalStation != nil
                lineSelected = selectedLine != nil
                
                print("✅ Restored station information for empty line input")
            }
        }
        
        // Always ensure station information is properly restored after all processing
        await MainActor.run {
            print("🔄 Final station restoration check")
            print("   departureStationInput: '\(departureStationInput)'")
            print("   arrivalStationInput: '\(arrivalStationInput)'")
            print("   selectedDepartureStation: \(selectedDepartureStation?.getLocalizedName() ?? "nil")")
            print("   selectedArrivalStation: \(selectedArrivalStation?.getLocalizedName() ?? "nil")")
            
            // If station inputs exist but station objects are nil, try to restore them
            if !departureStationInput.isEmpty && selectedDepartureStation == nil {
                print("   Attempting to restore departure station: \(departureStationInput)")
                selectedDepartureStation = findStationByName(departureStationInput)
                departureStationSelected = selectedDepartureStation != nil
            }
            
            if !arrivalStationInput.isEmpty && selectedArrivalStation == nil {
                print("   Attempting to restore arrival station: \(arrivalStationInput)")
                selectedArrivalStation = findStationByName(arrivalStationInput)
                arrivalStationSelected = selectedArrivalStation != nil
            }
            
            print("   Final departureStation: \(selectedDepartureStation?.getLocalizedName() ?? "nil")")
            print("   Final arrivalStation: \(selectedArrivalStation?.getLocalizedName() ?? "nil")")
        }
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
            calculatedDirection = (departureIndex > arrivalIndex) ?
                await getRailDirectionFromJSON(isAscending: false):
                await getRailDirectionFromJSON(isAscending: true)
            
            print("✅ Calculated direction: \(calculatedDirection ?? "nil")")

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
                                        return ascendingDirection.replacingOccurrences(of: "odpt.RailDirection:", with: "")
                                    } else {
                                        print("❌ No ascendingRailDirection found")
                                    }
                                } else {
                                    // Extract descendingRailDirection
                                    print("🔍 isAscending: false - looking for odpt:descendingRailDirection")
                                    if let descendingDirection = railway["odpt:descendingRailDirection"] as? String {
                                        print("✅ Found descendingRailDirection: \(descendingDirection)")
                                        return descendingDirection.replacingOccurrences(of: "odpt.RailDirection:", with: "")
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
            print("   Found saved departure: '\(savedDeparture)'")
            self.departureStationInput = savedDeparture
            self.selectedDepartureStation = findStationByName(savedDeparture)
            self.departureStationSelected = self.selectedDepartureStation != nil
            print(self.selectedDepartureStation != nil ?
                  "✅ Restored departure station: \(savedDeparture)" :
                    "⚠️ Departure station '\(savedDeparture)' not found in current data")
        } else {
            print("   No saved departure found")
            self.departureStationInput = ""
            self.selectedDepartureStation = nil
            self.departureStationSelected = false
        }
        
        let arrivalKey = selectedGoorback.arriveStationKey(currentLineIndex)
        print("   Arrival key: \(arrivalKey)")
        if let savedArrival = UserDefaults.standard.string(forKey: arrivalKey) {
            print("   Found saved arrival: '\(savedArrival)'")
            self.arrivalStationInput = savedArrival
            self.selectedArrivalStation = findStationByName(savedArrival)
            self.arrivalStationSelected = self.selectedArrivalStation != nil
            print(self.selectedArrivalStation != nil ?
                  "✅ Restored arrival station: \(savedArrival)" :
                    "⚠️ Arrival station '\(savedArrival)' not found in current data")
        } else {
            print("   No saved arrival found")
            self.arrivalStationInput = ""
            self.selectedArrivalStation = nil
            self.arrivalStationSelected = false
        }
        
        // Ensure station objects are created even if not found in data
        if !self.departureStationInput.isEmpty && self.selectedDepartureStation == nil {
            print("   Creating departure station object for: \(self.departureStationInput)")
            self.selectedDepartureStation = findStationByName(self.departureStationInput)
            self.departureStationSelected = self.selectedDepartureStation != nil
        }
        
        if !self.arrivalStationInput.isEmpty && self.selectedArrivalStation == nil {
            print("   Creating arrival station object for: \(self.arrivalStationInput)")
            self.selectedArrivalStation = findStationByName(self.arrivalStationInput)
            self.arrivalStationSelected = self.selectedArrivalStation != nil
        }
    }
    
    // Load ride time settings from UserDefaults
    private func loadRideTimeSettings() {
        let rideTimeKey = selectedGoorback.rideTimeKey(selectedLineNumber - 1)
        self.selectedRideTime = UserDefaults.standard.integer(forKey: rideTimeKey)
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
                self.selectedTransferTime = 5
            }
        } else {
            self.selectedTransportation = "none"
            self.selectedTransferTime = 5
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
            self.selectedDepartureStation = findStationByName(savedDeparture)
            self.departureStationSelected = self.selectedDepartureStation != nil
            if self.selectedDepartureStation != nil {
                print("✅ Restored departure station: \(savedDeparture)")
            } else {
                print("⚠️ Departure station '\(savedDeparture)' not found in current data")
            }
        } else {
            self.departureStationInput = ""
            self.selectedDepartureStation = nil
            self.departureStationSelected = false
        }
        
        let arrivalKey = selectedGoorback.arriveStationKey(currentLineIndex)
        if let savedArrival = UserDefaults.standard.string(forKey: arrivalKey) {
            self.arrivalStationInput = savedArrival
            self.selectedArrivalStation = findStationByName(savedArrival)
            self.arrivalStationSelected = self.selectedArrivalStation != nil
            print(self.selectedArrivalStation != nil ?
                  "✅ Restored arrival station: \(savedArrival)" :
                    "⚠️ Arrival station '\(savedArrival)' not found in current data")
        } else {
            self.arrivalStationInput = ""
            self.selectedArrivalStation = nil
            self.arrivalStationSelected = false
        }
        
        let rideTimeKey = selectedGoorback.rideTimeKey(currentLineIndex)
        self.selectedRideTime = UserDefaults.standard.integer(forKey: rideTimeKey)
        
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
                self.selectedTransferTime = 5
            }
        } else {
            self.selectedTransportation = "none"
            self.selectedTransferTime = 5
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
        return dataSource?.timetableInfomationLink ?? ""
    }
    
    // Generate station timetable link with flexible parameters
    func stationInformationLink(isDeparture: Bool, isWeekday: Bool) -> String {
        let timetableLink = getTimetableInformationLink()
        
        // Extract station name from station code (remove "odpt.Station:" prefix)
        let lineCode = selectedLine?.code ?? ""
        let lineName = lineCode.replacingOccurrences(of: "odpt.Railway:", with: "&owl:sameAs=odpt.StationTimetable:")
        
        let stationCode = (isDeparture ? selectedDepartureStation?.code: selectedArrivalStation?.code) ?? ""
        let stationName = stationCode.components(separatedBy: ".").last ?? ""
        
        // Use lineDirection from selectedLine
        let directionCode = selectedLine?.lineDirection ?? ""
        let direction = directionCode.replacingOccurrences(of: "odpt.RailDirection:", with: "")
        
        print("🔍 stationInformationLink - selectedLine?.lineDirection: \(selectedLine?.lineDirection ?? "nil")")
        print("🔍 stationInformationLink - direction: \(direction)")
    
        let dateSuffix = isWeekday ? ".Weekday" : ".SaturdayHoliday"
        
        return "\(timetableLink)\(lineName).\(stationName).\(direction)\(dateSuffix)"
    }
    
    // MARK: - Train Number Extraction
    // Get first train number and departure time from a timetable link
    private func getFirstTrainNumbers(from urlString: String, index: Int) async -> (trainNumber: String, departureTime: String) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return ("", "")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    print("❌ HTTP error \(httpResponse.statusCode) for URL: \(urlString)")
                    return ("", "")
                }
            }
            
            // Parse JSON and extract first train number and departure time
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let firstObject = json.first,
               let stationTimetableObjects = firstObject["odpt:stationTimetableObject"] as? [[String: Any]],
               let firstTimetableObject = stationTimetableObjects.first {
                
                let trainNumber = firstTimetableObject["odpt:trainNumber"] as? String ?? "No train number"
                let departureTime = firstTimetableObject["odpt:departureTime"] as? String ?? "No departure time"
                
                print("✅ Link \(index) - First Train:")
                print("   Train Number: \(trainNumber)")
                print("   Departure Time: \(departureTime)")
                
                return (trainNumber, departureTime)
                
            } else {
                print("❌ Link \(index) - No stationTimetableObject found in JSON data")
                return ("", "")
            }
            
        } catch {
            print("❌ Failed to process timetable data from \(urlString): \(error)")
            return ("", "")
        }
    }
    
    // MARK: - Train Number Matching with Time Comparison
    // Find matching train number and compare departure times
    private func findMatchingTrainAndCompare(from urlString: String, index: Int, targetTrain: (trainNumber: String, departureTime: String), compareWith: (trainNumber: String, departureTime: String)) async -> (found: Bool, departureTime: String, isEarlier: Bool?) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return (false, "", nil)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    print("❌ HTTP error \(httpResponse.statusCode) for URL: \(urlString)")
                    return (false, "", nil)
                }
            }
            
            // Parse JSON and search for matching train number
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let firstObject = json.first,
               let stationTimetableObjects = firstObject["odpt:stationTimetableObject"] as? [[String: Any]] {
                
                print("🔍 Link \(index) - Searching for train number: \(targetTrain.trainNumber)")
                
                // Search through all stationTimetableObjects for matching train number
                for timetableObject in stationTimetableObjects {
                    let trainNumber = timetableObject["odpt:trainNumber"] as? String ?? ""
                    let departureTime = timetableObject["odpt:departureTime"] as? String ?? ""
                    
                    if trainNumber == targetTrain.trainNumber {
                        print("✅ Link \(index) - Found matching train:")
                        print("   Train Number: \(trainNumber)")
                        print("   Departure Time: \(departureTime)")
                        
                        // Compare times
                        let isEarlier = compareTimes(time1: departureTime, time2: compareWith.departureTime)
                        print("   Time Comparison: \(departureTime) vs \(compareWith.departureTime)")
                        print("   Link \(index) is \(isEarlier ? "earlier" : "later") than Link \(index == 2 ? 0 : 1)")
                        
                        return (true, departureTime, isEarlier)
                    }
                }
                
                print("❌ Link \(index) - No matching train number found")
                return (false, "", nil)
                
            } else {
                print("❌ Link \(index) - No stationTimetableObject found in JSON data")
                return (false, "", nil)
            }
            
        } catch {
            print("❌ Failed to process timetable data from \(urlString): \(error)")
            return (false, "", nil)
        }
    }
    
    // MARK: - Time Comparison Helper
    // Compare two time strings in HH:mm format
    private func compareTimes(time1: String, time2: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let date1 = formatter.date(from: time1),
              let date2 = formatter.date(from: time2) else {
            print("❌ Failed to parse time strings: \(time1), \(time2)")
            return false
        }
        
        return date1 < date2
    }
    
    // MARK: - Target Timetable Data Processing
    // Get timetable data for determined direction and find common train numbers
    func getTargetTimetableData() async {
        
        // First, save all data to ensure selectedLine.lineDirection is updated
        await saveAllDataToUserDefaults()
        
        print("🔍 getTargetTimetableData - selectedLine?.lineDirection: \(selectedLine?.lineDirection ?? "nil")")
        
        let links = [true, false].flatMap { isDeparture in
            [true, false].map { isWeekday in
                stationInformationLink(isDeparture: isDeparture, isWeekday: isWeekday)
            }
        }
        
        // Print generated links for debugging
        print("\n🔗 Target Timetable Links:")
        for (index, link) in links.enumerated() {
            print("Link \(index): \(link)")
        }
        
        //　Process weekday data (isWeekday = true)
        await processWeekdayTimetableData(links: links)
        
        // Process weekend data (isWeekday = false)
        await processWeekendTimetableData(links: links)
    }
    
    // MARK: - Weekday Timetable Processing
    // Process weekday timetable data and find common train numbers
    private func processWeekdayTimetableData(links: [String]) async {
        print("\n📅 Weekday Timetable Analysis:")
        
        // Get departure and arrival data for weekday
        let departureData = await getTimetableData(from: links[0]) // isDeparture: true, isWeekday: true
        let arrivalData = await getTimetableData(from: links[2])   // isDeparture: false, isWeekday: true
        
        // Find common train numbers
        let commonTrains = findCommonTrainNumbers(departureData: departureData, arrivalData: arrivalData)
        
        print("✅ Weekday Common Trains Found: \(commonTrains.count)")
        for train in commonTrains {
            print("   Train Number: \(train.trainNumber), Departure: \(train.departureTime)")
        }
        
        // Print departure timetable for common trains
        print("\n🚉 Weekday Departure Timetable:")
        printDepartureTimetable(data: departureData, commonTrains: commonTrains)
        
        // Save timetable data to UserDefaults
        saveTimetableToUserDefaults(data: departureData, commonTrains: commonTrains, isWeekday: true)
    }
    
    // MARK: - Weekend Timetable Processing
    // Process weekend timetable data and find common train numbers
    private func processWeekendTimetableData(links: [String]) async {
        print("\n📅 Weekend Timetable Analysis:")
        
        // Get departure and arrival data for weekend
        let departureData = await getTimetableData(from: links[1]) // isDeparture: true, isWeekday: false
        let arrivalData = await getTimetableData(from: links[3])    // isDeparture: false, isWeekday: false
        
        // Find common train numbers
        let commonTrains = findCommonTrainNumbers(departureData: departureData, arrivalData: arrivalData)
        
        print("✅ Weekend Common Trains Found: \(commonTrains.count)")
        for train in commonTrains {
            print("   Train Number: \(train.trainNumber), Departure: \(train.departureTime)")
        }
        
        // Print departure timetable for common trains
        print("\n🚉 Weekend Departure Timetable:")
        printDepartureTimetable(data: departureData, commonTrains: commonTrains)
        
        // Save timetable data to UserDefaults
        saveTimetableToUserDefaults(data: departureData, commonTrains: commonTrains, isWeekday: false)
    }
    
    // MARK: - Timetable Data Retrieval
    // Get timetable data from API endpoint
    private func getTimetableData(from urlString: String) async -> [(trainNumber: String, departureTime: String)] {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return []
        }
        
        do {
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
                
                return stationTimetableObjects.compactMap { timetableObject in
                    guard let trainNumber = timetableObject["odpt:trainNumber"] as? String,
                          let departureTime = timetableObject["odpt:departureTime"] as? String else {
                        return nil
                    }
                    return (trainNumber: trainNumber, departureTime: departureTime)
                }
                
            } else {
                print("❌ No stationTimetableObject found in JSON data")
                return []
            }
            
        } catch {
            print("❌ Failed to process timetable data from \(urlString): \(error)")
            return []
        }
    }
    
    // MARK: - Common Train Number Finding
    // Find common train numbers between departure and arrival data
    private func findCommonTrainNumbers(departureData: [(trainNumber: String, departureTime: String)], arrivalData: [(trainNumber: String, departureTime: String)]) -> [(trainNumber: String, departureTime: String)] {
        let departureTrainNumbers = Set(departureData.map { $0.trainNumber })
        let arrivalTrainNumbers = Set(arrivalData.map { $0.trainNumber })
        
        let commonTrainNumbers = departureTrainNumbers.intersection(arrivalTrainNumbers)
        
        return departureData.filter { commonTrainNumbers.contains($0.trainNumber) }
    }
    
    // MARK: - Departure Timetable Printing
    // Print departure timetable for common trains
    private func printDepartureTimetable(data: [(trainNumber: String, departureTime: String)], commonTrains: [(trainNumber: String, departureTime: String)]) {
        let commonTrainNumbers = Set(commonTrains.map { $0.trainNumber })
        
        for train in data {
            if commonTrainNumbers.contains(train.trainNumber) {
                print("   \(train.departureTime) - Train \(train.trainNumber)")
            }
        }
    }
    
    // MARK: - Timetable Data Saving
    // Save timetable data to UserDefaults for display in TimetableContentView
    private func saveTimetableToUserDefaults(data: [(trainNumber: String, departureTime: String)], commonTrains: [(trainNumber: String, departureTime: String)], isWeekday: Bool) {
        let commonTrainNumbers = Set(commonTrains.map { $0.trainNumber })
        
        // Group times by hour using Int arrays for better performance
        var hourlyMinutes: [Int: [Int]] = [:]
        
        for train in data {
            if commonTrainNumbers.contains(train.trainNumber) {
                let timeComponents = train.departureTime.components(separatedBy: ":")
                if timeComponents.count == 2,
                   let hour = Int(timeComponents[0]),
                   let minute = Int(timeComponents[1]) {
                    hourlyMinutes[hour, default: []].append(minute)
                }
            }
        }
        
        // Sort and save to UserDefaults
        for (hour, minutes) in hourlyMinutes {
            let timetableKey = selectedGoorback.timetableKey(isWeekday, selectedLineNumber - 1, hour)
            let sortedMinutes = minutes.sorted()
            let newTimes = sortedMinutes.map(String.init).joined(separator: " ")
            
            // Ensure consistent format with leading space
            let formattedTimes = newTimes.isEmpty ? "" : " \(newTimes)"
            UserDefaults.standard.set(formattedTimes, forKey: timetableKey)
            print("💾 Saved timetable for \(isWeekday ? "weekdays" : "weekends") hour \(hour): \(formattedTimes)")
        }
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
        selectedLineColor = accentColorString
        
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
}

