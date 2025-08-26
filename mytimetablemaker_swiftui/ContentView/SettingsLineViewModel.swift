//
//  SettingsLineViewModel.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2025/08/12.
//  
//  MARK: - Overview
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
    @Published var isLoading: Bool = false               // Loading state indicator for UI feedback

    @Published var showColorSelection: Bool = false      // Color picker visibility state
    @Published var showStationSelection: Bool = false    // Station selection UI visibility state
    @Published var statistics: DataStatistics = DataStatistics()  // Data statistics for monitoring
    
    // MARK: - State Properties
    // Line and station selection state management
    @Published var selectedLine: TransportationLine?           // Currently selected railway line
    @Published var lineStations: [Station] = []               // Stations available on the selected line
    @Published var selectedDepartureStation: Station?         // User-selected departure station
    @Published var selectedArrivalStation: Station?           // User-selected arrival station
    
    // MARK: - User Input Fields
    // Text input fields for user data entry
    @Published var departureStationInput: String = ""         // Departure station search input text
    @Published var arrivalStationInput: String = ""           // Arrival station search input text
    @Published var selectedRideTime: Int = 0                  // Selected ride time in minutes
    
    // MARK: - Suggestion and Focus State
    // UI state management for suggestion displays and field focus
    @Published var showDepartureSuggestions: Bool = false     // Departure station suggestions visibility
    @Published var departureSuggestions: [Station] = []       // Departure station search results
    @Published var isDepartureFieldFocused: Bool = false      // Departure field focus state
    @Published var showArrivalSuggestions: Bool = false       // Arrival station suggestions visibility
    @Published var arrivalSuggestions: [Station] = []         // Arrival station search results
    @Published var isArrivalFieldFocused: Bool = false        // Arrival field focus state
    
    // MARK: - Station Selection Flags
    // Flags to prevent re-display of suggestions after selection
    @Published var departureStationSelected: Bool = false     // Flag to prevent departure suggestions re-display
    @Published var arrivalStationSelected: Bool = false       // Flag to prevent arrival suggestions re-display
    
    // MARK: - Computed Properties
    // Convenience properties for UI state checking
    var hasSelectedLine: Bool { selectedLine != nil }
    var hasStations: Bool { !lineStations.isEmpty }
    
    // MARK: - Public Access Properties
    // Public properties for View access
    var lastUpdatedDisplay: String? { lastUpdated }
    
    // MARK: - Private Properties
    // Internal data storage and state management
    private var all: [TransportationLine] = []                // All available railway lines from all sources
    private var allData: [TransportationLine] = []            // Cached railway data for performance
    private var lastUpdated: String?                          // Last data update timestamp for UI display
    private var cancellables = Set<AnyCancellable>()          // Combine cancellables for proper cleanup
    private var nameCounts: [String: Int] = [:]               // Name frequency tracking for duplicate display
    
    // MARK: - Configuration Properties
    // Application configuration and initialization parameters
    private let consumerKey: String                           // ODPT API access token for data retrieval
    private let goorback: String                              // Direction identifier (go/back) for route context
    private let lineIndex: Int                                // Line index for UserDefaults key generation
    // First launch flag removed - using lastUpdated existence instead
    
    // MARK: - Network and Data Management
    // External service connections and data management
    private let net = ODPTNetworkClient()                     // ODPT network client for API communication
    
    // MARK: - Line Color Selection State
    // User preference for line color customization
    @Published var selectedLineColor: String? = nil            // Selected line color hex value for display
    
    // MARK: - Initialization
    // Initialize view model with direction and line index
    init(goorback: String = "back1", lineIndex: Int = 0) {
        self.goorback = goorback
        self.lineIndex = lineIndex
        
        // MARK: - ODPT API Token Configuration
        // Get ODPT access token from Debug.xcconfig for API authentication
        self.consumerKey = Bundle.main.infoDictionary?["ODPT_ACCESS_TOKEN"] as? String ?? ""
        print(consumerKey.isEmpty ? "⚠️ ODPT_ACCESS_TOKEN is not set": "✅ ODPT_ACCESS_TOKEN is set: \(String(consumerKey.prefix(10)))...")
        
        // MARK: - Search Query Debouncing Setup
        // Configure search query debouncing for improved performance
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] q in Task { await self?.filter(q) } }
            .store(in: &cancellables)
        
            // MARK: - UserDefaults Initialization
    // Restore user preferences and previous selections from persistent storage
    
    // Restore last updated timestamp
    if let savedLastUpdated = UserDefaults.standard.string(forKey: "dataUpdatedKey") {
        self.lastUpdated = savedLastUpdated
    }
    
    // Restore line color preference
    let userDefaultsKey = goorback.lineColorKey(lineIndex)
    self.selectedLineColor = UserDefaults.standard.string(forKey: userDefaultsKey)
        
        // Restore line name preference
        let lineNameKey = goorback.lineNameKey(lineIndex)
        if let savedLineName = UserDefaults.standard.string(forKey: lineNameKey) {
            self.query = savedLineName
        }
        
        // Restore departure station preference
        let departureKey = goorback.departStationKey(lineIndex)
        if let savedDeparture = UserDefaults.standard.string(forKey: departureKey) {
            self.departureStationInput = savedDeparture
        }
        
        // Restore arrival station preference
        let arrivalKey = goorback.arriveStationKey(lineIndex)
        if let savedArrival = UserDefaults.standard.string(forKey: arrivalKey) {
            self.arrivalStationInput = savedArrival
        }
        
        // Restore ride time preference
        let rideTimeKey = goorback.rideTimeKey(lineIndex)
        self.selectedRideTime = UserDefaults.standard.integer(forKey: rideTimeKey)
        
        // MARK: - Initial Data Loading
        // Load data on initialization and start background updates
        Task { await loadInitialAndUpdate() }
        
        // MARK: - Saved Line Validation
        // Check if the line read from UserDefaults exists in current data
        Task { await checkSavedLineInData() }
    }
    
    // MARK: - Data Loading and Initialization
    // Read initial data and check for updates from multiple sources, implements multi-tier data loading strategy: local → cache → API
    func loadInitialAndUpdate() async {
        isLoading = true
        defer { isLoading = false }
        
        // MARK: - Step 1: Local Data Loading
        // Load data from local JSON files for offline fallback
        let localLines = LocalFileLoader.loadLocalData()

        // MARK: - Step 2: Cached Data Loading
        // Load data from ODPT API cache if available
        let railways = net.loadCached(source: .railways).flatMap { try? ODPTParser.parseRailways($0) } ?? []
        
        // MARK: - Data Combination and Initialization
        // Remove duplicates and combine data sources for comprehensive coverage
        self.all = localLines + railways
        self.allData = self.all
        // Don't set lastUpdated here - only set when user manually updates
        
        // MARK: - Initial Data Processing
        // Apply initial filtering and update statistics for immediate user feedback
        await filter(query)
        await updateStatistics()
        
        // MARK: - Step 3: API Data Update (First Time Only)
        // Check for updates from ODPT API if no previous update exists
        if lastUpdated == nil && !consumerKey.isEmpty {
            // Fetch updated data asynchronously while maintaining current data
            async let updatedRailways: [TransportationLine] = fetchAndUpdate(.railways, consumerKey: consumerKey) ?? railways
            
            let newRailways = await updatedRailways
            
            // MARK: - Data Update and Finalization
            // Remove duplicates and combine updated data for final dataset
            self.all = localLines + newRailways
            self.allData = self.all
            
            // Apply filtering and update statistics with new data
            await filter(query)
            await updateStatistics()
            
            // MARK: - Set Initial Update Timestamp
            // Set lastUpdated after first automatic update to prevent repeated API calls
            let formatter = DateFormatter()
            if Locale.current.language.languageCode?.identifier == "ja" {
                // Japanese format: 2019/6/27 15:30
                formatter.dateFormat = "yyyy/M/d HH:mm"
            } else {
                // English format: June 27th, 2019 at 3:30 PM
                formatter.dateStyle = .long
                formatter.timeStyle = .short
            }
            let dateString = formatter.string(from: Date())
            self.lastUpdated = dateString
            
            // Save initial update timestamp to UserDefaults
            UserDefaults.standard.set(dateString, forKey: "dataUpdatedKey")
        } 
    }
    
    // MARK: - Statistics Management
    // Update application statistics including data counts and cache status
    private func updateStatistics() async {
        var stats = DataStatistics()
        
        // MARK: - Basic Statistics Collection
        // Count total available railway lines and track last update time
        stats.totalRailways = all.filter { $0.kind == .railway }.count
        stats.lastUpdated = lastUpdated
        
        // MARK: - ODPT API Cache Status Monitoring
        // Check ODPT API cache status for each data source
        ODPTSource.allCases.forEach { source in
            stats.cacheStatus[source.displayName] = net.loadCached(source: source) != nil
        }
        
        // MARK: - Local File Availability Monitoring
        // Check local file availability for each data source
        LocalDataSource.allCases.forEach { source in
            // Check if file exists in LineData folder (primary location)
            var fileExists = false
            if let lineDataURL = Bundle.main.url(forResource: "LineData", withExtension: nil) {
                let jsonURL = lineDataURL.appendingPathComponent(source.fileName)
                fileExists = FileManager.default.fileExists(atPath: jsonURL.path)
            }
            
            // Fallback to original bundle search if not found in LineData
            if !fileExists {
                fileExists = Bundle.main.url(forResource: source.fileName.replacingOccurrences(of: ".json", with: ""), withExtension: "json") != nil
            }
            
            stats.cacheStatus[source.displayName] = fileExists
        }
        
        // MARK: - Statistics Update
        // Update statistics on main actor for UI updates
        await MainActor.run {
            self.statistics = stats
        }
    }
    
    // MARK: - Manual Data Refresh
    // Force update of data (only executed when data update button is pressed)
    func refreshAllData() async {
        isLoading = true
        defer { isLoading = false }
        
        // MARK: - Local Data Refresh
        // Re-read local file data for latest offline information
        let localLines = LocalFileLoader.loadLocalData()
        
        // MARK: - API Data Refresh (When Available)
        // Force update of all ODPT API data when consumer key is available
        if !consumerKey.isEmpty {
            await performDataRefresh(localLines: localLines)
        } else {
            // MARK: - Offline-Only Refresh
            // If ODPT API is not available, use only local file data
            self.all = localLines
            self.allData = self.all
            await filter(query)
            await updateStatistics()
        }
        
        // MARK: - Update Timestamp
        // Set lastUpdated only when user manually refreshes data
        let formatter = DateFormatter()
        if Locale.current.language.languageCode?.identifier == "ja" {
            // Japanese format: 2019/6/27 15:30
            formatter.dateFormat = "yyyy/M/d HH:mm"
        } else {
            // English format: June 27th, 2019 at 3:30 PM
            formatter.dateStyle = .long
            formatter.timeStyle = .short
        }
        let dateString = formatter.string(from: Date())
        self.lastUpdated = dateString
        UserDefaults.standard.set(dateString, forKey: "dataUpdatedKey")
    }
    
    // MARK: - Data Refresh Implementation
    // Perform comprehensive data refresh from all sources
    private func performDataRefresh(localLines: [TransportationLine]) async {
        // Fetch updated data from ODPT API for comprehensive refresh
        async let updatedRailways: [TransportationLine] = fetchAndUpdate(.railways, consumerKey: consumerKey) ?? []
        
        let newRailways = await updatedRailways
        
        // MARK: - Data Update and Processing
        // Remove duplicates and combine updated data for final dataset
        self.all = localLines + newRailways
        self.allData = self.all
        await filter(query)
        await updateStatistics()
    }
    
    // MARK: - ODPT Data Fetching and Update
    // Fetch and update data from ODPT API with intelligent caching
    private func fetchAndUpdate(_ source: ODPTSource, consumerKey: String) async -> [TransportationLine]? {
        do {
            let result: (Data, Bool)
            
            // MARK: - Conditional Update Logic
            // Use conditional update if cache exists for efficiency
            if net.loadCached(source: source) != nil {
                // Use conditional update if cache exists
                result = try await net.fetchWithUpdateIfNeeded(source: source, consumerKey: consumerKey)
            } else {
                // Fetch fresh data if no cache exists
                let data = try await net.fetchSimple(source: source, consumerKey: consumerKey)
                result = (data, true)
            }
                
            // MARK: - Data Parsing and Return
            // Parse the fetched data into TransportationLine objects
            return try ODPTParser.parseRailways(result.0)
        } catch {
            // MARK: - Error Handling
            // Handle errors gracefully by returning nil
            return nil
        }
    }
    
    // MARK: - Line Search and Filtering
    // Filter railway lines based on search query with intelligent matching, implements normalized search for improved matching with hiragana support
    func filter(_ q: String) async {
        let t = q.normalizedForSearch
        guard !t.isEmpty else { lineSuggestions = []; nameCounts = [:]; return }
        
        // MARK: - Search Key Generation Helper
        // Helper function to generate search key for each line
        let key: (TransportationLine) -> String = { p in
            // If odpt:railwayTitle is available, use value based on current language
            if let railwayTitle = p.railwayTitle {
                let localizedName = railwayTitle.getLocalizedName()
                if !localizedName.isEmpty {
                    return localizedName.normalizedForSearch
                }
            }
            return p.name.normalizedForSearch 
        }
        
        // MARK: - Hiragana Query Matching Helper
        // Helper function to check if line matches query (including hiragana variations)
        let matchesQuery: (TransportationLine) -> Bool = { line in
            let searchKey = key(line)
            
            // MARK: - Direct Match Logic
            // Direct match with normalized query for immediate results
            if searchKey.hasPrefix(t) || searchKey.contains(t) {
                return true
            }
            
            // MARK: - Hiragana to Kanji Mapping
            // Check if query is hiragana and try to match with common variations
            if q.containsHiragana {
                return hiraganaMappings.contains { hiragana, variations in
                    q.contains(hiragana) && variations.contains { variation in
                        searchKey.contains(variation.normalizedForSearch)
                    }
                }
            }
            return false
        }
        
        // MARK: - Search Result Prioritization
        // Apply search with priority: exact prefix matches first, then contains matches
        let starts = all.filter { key($0).hasPrefix(t) }
        let contains = all.filter { !key($0).hasPrefix(t) && key($0).contains(t) }
        let hiraganaMatches = all.filter { !key($0).hasPrefix(t) && !key($0).contains(t) && matchesQuery($0) }
        
        lineSuggestions = starts + contains + hiraganaMatches
        
        // MARK: - Duplicate Counting
        // Count duplicates for display purposes to show frequency information
        nameCounts = Dictionary(grouping: lineSuggestions) { displayName(for: $0) }
            .mapValues { $0.count }
    }
    
    // MARK: - Display Name Generation
    // Get localized display name for railway line, prioritizes multi-language support when available
    func displayName(for line: TransportationLine) -> String {
        guard let railwayTitle = line.railwayTitle else { return line.name }
        let localizedName = railwayTitle.getLocalizedName()
        return localizedName.isEmpty ? line.name : localizedName
    }
    
    // MARK: - Operator Display Name
    // Get localized display name based on operator code, maps technical ODPT identifiers to user-friendly display names
    func getOperatorDisplayName(for operatorCode: String, lineKind: TransportationLine.Kind? = nil) -> String {
        // MARK: - ODPT Operator Code Mapping
        // Get operator name based on ODPTSource definition
        let operatorName = operatorCode.replacingOccurrences(of: "odpt.Operator:", with: "")
        return NSLocalizedString(operatorName, comment: "Railway operator name")
        
    }
    
    // MARK: - Station Search and Filtering
    // Filter candidate departure stations based on search query, implements intelligent search that considers line context
    func filterDepartureStations(_ query: String) {
        let filtered = filterStations(query, excludeStation: selectedArrivalStation)
        departureSuggestions = filtered
        showDepartureSuggestions = isDepartureFieldFocused && !filtered.isEmpty && !departureStationSelected
    }
    
    // MARK: - Arrival Station Filtering
    // Filter candidate arrival stations based on search query, implements intelligent search that considers line context and departure station
    func filterArrivalStations(_ query: String) {
        let filtered = filterStations(query, excludeStation: selectedDepartureStation)
        arrivalSuggestions = filtered
        showArrivalSuggestions = isArrivalFieldFocused && !filtered.isEmpty && !arrivalStationSelected
    }
    
    // MARK: - Common Station Search Logic
    // Common station filtering logic used by both departure and arrival station searches
    private func filterStations(_ query: String, excludeStation: Station?) -> [Station] {
        guard !query.isEmpty else { return [] }
        
        let filtered: [Station] = {
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
    
    // MARK: - Line Code Based Station Parsing
    // Parse station information for a given line code, searches for stations using ODPT line code for precise identification
    private func parseStationsForLine(_ data: Data, lineCode: String) -> [Station]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let array = json as? [[String: Any]] {               
                // MARK: - Line Code Search
                // Search for lines matching the given line code
                return array.first { railway in
                    railway["odpt:lineCode"] as? String == lineCode
                }.flatMap { railway in
                    // MARK: - Station Order Extraction
                    // Get station order information for the matching line
                    (railway["odpt:stationOrder"] as? [[String: Any]])?.compactMap { stationInfo in
                        // MARK: - Station Object Creation
                        // Build station information based on station order
                        (stationInfo["odpt:stationTitle"] as? [String: Any]).map { stationTitle in
                            let jaName = stationTitle["ja"] as? String
                            let enName = stationTitle["en"] as? String
                            
                            // MARK: - Name Priority Logic
                            // Use Japanese name first, then English name if no Japanese name exists
                            let stationName = jaName ?? enName ?? "Unknown station"
                            
                            return Station(
                                name: stationName,
                                code: nil,
                                title: StationTitle(ja: jaName, en: enName)
                            )
                        }
                    }
                }
            }
        } catch {
            // MARK: - Error Handling
            // Handle JSON parsing errors silently
            return nil
        }
        return nil
    }
    
    // MARK: - Line Name Based Station Parsing
    // Parse station information for a given line name, searches for stations using line name instead of line code
    private func parseStationsByLineName(_ data: Data, lineName: String) -> [Station]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let array = json as? [[String: Any]] {
                // Search for lines matching the given line name
                for railway in array {
                    // Search by dc:title (standard Dublin Core title field)
                    if let railwayName = railway["dc:title"] as? String,
                       railwayName == lineName {
                        return extractStationsFromRailway(railway, searchMethod: "dc:title", searchValue: lineName)
                    }
                    
                    // Search by railwayTitle (Japanese or English name)
                    if let railwayTitle = railway["odpt:railwayTitle"] as? [String: Any] {
                        if let stations = searchByRailwayTitle(railway, railwayTitle: railwayTitle, lineName: lineName) {
                            return stations
                        }
                    }
                }
                
                // MARK: - Partial Match Search
                // If no exact match is found, search for partial matches
                for railway in array {
                    // Search by partial match of dc:title
                    if let railwayName = railway["dc:title"] as? String,
                       railwayName.contains(lineName) || lineName.contains(railwayName) {
                        if let stations = extractStationsFromRailway(railway, searchMethod: "dc:title partial match", searchValue: railwayName) {
                            return stations
                        }
                    }
                    
                    // Search by partial match of railwayTitle (Japanese or English name)
                    if let railwayTitle = railway["odpt:railwayTitle"] as? [String: Any] {
                        if let stations = searchByRailwayTitlePartialMatch(railway, railwayTitle: railwayTitle, lineName: lineName) {
                            return stations
                        }
                    }
                }
                
                return nil
            }
        } catch {
            // Handle JSON parsing errors silently
            return nil
        }
        return nil
    }
    
    // MARK: - RailwayTitle Search Helper
    // Search for stations by railwayTitle (Japanese or English name)
    private func searchByRailwayTitle(_ railway: [String: Any], railwayTitle: [String: Any], lineName: String) -> [Station]? {
        // Search by Japanese name
        if let jaName = railwayTitle["ja"] as? String, jaName == lineName {
            return extractStationsFromRailway(railway, searchMethod: "odpt:railwayTitle.ja", searchValue: lineName)
        }
        
        // Search by English name
        if let enName = railwayTitle["en"] as? String, enName == lineName {
            return extractStationsFromRailway(railway, searchMethod: "odpt:railwayTitle.en", searchValue: lineName)
        }
        
        return nil
    }
    
    // MARK: - RailwayTitle Partial Match Search Helper
    // Search for stations by railwayTitle partial match (Japanese or English name)
    private func searchByRailwayTitlePartialMatch(_ railway: [String: Any], railwayTitle: [String: Any], lineName: String) -> [Station]? {
        // Search by partial match of Japanese name
        if let jaName = railwayTitle["ja"] as? String,
           jaName.contains(lineName) || lineName.contains(jaName) {
            return extractStationsFromRailway(railway, searchMethod: "odpt:railwayTitle.ja partial match", searchValue: jaName)
        }
        
        // Search by partial match of English name
        if let enName = railwayTitle["en"] as? String,
           enName.contains(lineName) || lineName.contains(enName) {
            return extractStationsFromRailway(railway, searchMethod: "odpt:railwayTitle.en partial match", searchValue: enName)
        }
        
        return nil
    }
    
    // MARK: - Station Data Extraction
    // Extract station information from railway object, parses station data from railway JSON structure
    func extractStationsFromRailway(_ railway: [String: Any], searchMethod: String, searchValue: String) -> [Station]? {
        let stations = (railway["odpt:stationOrder"] as? [[String: Any]])?.compactMap { stationInfo in
            // MARK: - Station Information Building
            // Build station information based on station order
            (stationInfo["odpt:stationTitle"] as? [String: Any]).map { stationTitle in
                let jaName = stationTitle["ja"] as? String
                let enName = stationTitle["en"] as? String
                
                // MARK: - Localized Name Selection
                // Use Japanese name first, then English name if no Japanese name exists
                return Station(
                    name:  jaName ?? enName ?? "Unknown station",
                    code: nil,
                    title: StationTitle(ja: jaName, en: enName)
                )
            }
        }
        // Return stations only if the array is not empty
        return stations?.isEmpty == false ? stations : nil
    }
    
    // MARK: - Railway Type Based Station Parsing
    // Parse station information for a given railway type, searches for stations based on railway classification (JR, private, etc.)
    func parseStationsByRailwayType(_ data: Data, railwayType: String?) -> [Station]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let array = json as? [[String: Any]] {
                // MARK: - Railway Type Search
                // Search for lines matching the given railway type
                for railway in array {
                    if let rt = railway["odpt:railwayType"] as? String,
                       rt == railwayType {
                        // MARK: - Station Order Extraction
                        // Get station order information for the matching railway type
                        if let stationOrder = railway["odpt:stationOrder"] as? [[String: Any]] {
                            var stations: [Station] = []
                            
                            // MARK: - Station Object Creation
                            // Build station information based on station order
                            for stationInfo in stationOrder {
                                if let stationTitle = stationInfo["odpt:stationTitle"] as? [String: Any] {
                                    let jaName = stationTitle["ja"] as? String
                                    let enName = stationTitle["en"] as? String
                                    
                                    // MARK: - Localized Name Selection
                                    // Use Japanese name first, then English name if no Japanese name exists
                                    let stationName = jaName ?? enName ?? "Unknown station"
                                    
                                    let station = Station(
                                        name: stationName,
                                        code: nil,
                                        title: StationTitle(ja: jaName, en: enName)
                                    )
                                    stations.append(station)
                                }
                            }
                            return stations
                        }
                    }
                }
                return nil
            }
        } catch {
            // MARK: - Error Handling
            // Handle JSON parsing errors silently
            return nil
        }
        return nil
    }
        
    // MARK: - Line Name Based Station Retrieval
    // Get station information based on line name, searches across multiple data sources to find stations for a specific line
    func getStationsForLineName(_ lineName: String) -> [Station] {
        // MARK: - Sequential File Search
        // Search through each operator's data file for the specified line
        return stationDataFiles.lazy.compactMap { [self] filename in
            self.loadLocalData(for: filename).flatMap { [self] data in
                self.parseStationsByLineName(data, lineName: lineName)
            }
        }.first ?? []
    }
    
    // MARK: - Local Data Loading
    // Load local data from LineData folder, retrieves JSON data files for offline operation
    func loadLocalData(for filename: String) -> Data? {
        // MARK: - Primary Data Source
        // First try to load from LineData folder
        if let lineDataURL = Bundle.main.url(forResource: "LineData", withExtension: nil) {
            let jsonURL = lineDataURL.appendingPathComponent(filename)
            if let data = try? Data(contentsOf: jsonURL) {
                return data
            }
        }
        
        // MARK: - Fallback Data Source
        // Fallback to original bundle search (for backward compatibility)
        guard let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: url)
    }
    
    // MARK: - State Reset and Management
    // Reset station selection and clear all related state, provides clean slate for new line selection
    func resetStationSelection() {
        // MARK: - Line Selection Reset
        // Clear line selection and related UI state
        selectedLine = nil
        showStationSelection = false
        lineStations = []
        
        // MARK: - Station Selection Reset
        // Clear station selections and user input
        selectedDepartureStation = nil
        selectedArrivalStation = nil
        selectedRideTime = 0
        
        // MARK: - UI State Reset
        // Clear candidate suggestions and focus states
        showDepartureSuggestions = false
        departureSuggestions = []
        showArrivalSuggestions = false
        arrivalSuggestions = []
        isDepartureFieldFocused = false
        isArrivalFieldFocused = false
    }
    
    // MARK: - Display Update
    // Update all line information at once, synchronizes UI state with selected line data
    func updateDisplay() {
        // MARK: - Line Information Update
        // Update line name display with selected line information
        if let line = selectedLine {
            query = displayName(for: line)
        }
        
        // MARK: - Line Color Update
        // Update line color selection with selected line's color
        if let line = selectedLine, let lineColor = line.lineColor {
            selectedLineColor = lineColor
        }
        
        // MARK: - Station Information Update
        // Update departure station input field with selected station
        if let departureStation = selectedDepartureStation {
            departureStationInput = departureStation.getLocalizedName()
        }
        
        // Update arrival station input field with selected station
        if let arrivalStation = selectedArrivalStation {
            arrivalStationInput = arrivalStation.getLocalizedName()
        }
    }
    
    // MARK: - Custom Line Validation
    // Check if custom line station input is complete, validates that both departure and arrival stations are specified
    func isCustomLineStationInputComplete() -> Bool {
        return !query.isEmpty && !departureStationInput.isEmpty && !arrivalStationInput.isEmpty && departureStationInput != arrivalStationInput
    }
    
    // MARK: - Line Color Management
    // Set line color (do not save to UserDefaults), updates UI state without persisting changes
    func setLineColor(_ color: String) {
        selectedLineColor = color
        showColorSelection = false
    }
    
    // MARK: - Line Save Processing
    // Common save processing for all line types, handles data persistence and UI updates
    func handleLineSave(dismiss: DismissAction) {
        saveAllDataToUserDefaults()
        updateDisplay()
        dismiss()
    }
    
    // MARK: - Saved Line Validation
    // Check if line read from UserDefaults exists in JSON data, validates that saved preferences are still valid
    func checkSavedLineInData() async {
        // MARK: - Data Loading Wait
        // Wait for data loading to complete before validation
        while all.isEmpty {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds wait
        }
        
        // MARK: - Input Validation
        // Check only if query is not empty
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // MARK: - Saved Line Status Check
        // Check saved line selection status from UserDefaults
        let lineSelectedKey = goorback.lineSelectedKey(lineIndex)
        let wasLineSelected = UserDefaults.standard.bool(forKey: lineSelectedKey)
        
        if wasLineSelected {
            // MARK: - Line Restoration
            // If previously selected from JSON data, search for lines matching the query
            if let foundLine = all.first(where: { $0.name == query || $0.railwayTitle?.getLocalizedName() == query }) {
                selectedLine = foundLine
                showStationSelection = true
            }
        }
    }
    
    // MARK: - Data Persistence
    // Update and save all information when save button is pressed, persists user selections to UserDefaults for future restoration
    func saveAllDataToUserDefaults() {
        var savedItems: [String] = []
        
        // MARK: - Line Information Persistence
        // Line information is already set in the UI input fields, save line name and lineCode (only if not empty)
        if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lineNameKey = goorback.lineNameKey(lineIndex)
            UserDefaults.standard.set(query, forKey: lineNameKey)
            savedItems.append("Line name: \(query)")
            
            // MARK: - Line Code Search and Save
            // Save lineCode by searching in loaded data based on query
            let lineCodeKey = goorback.lineCodeKey(lineIndex)
            let lineCodeToSave = all.first { line in
                line.name == query || line.railwayTitle?.getLocalizedName() == query
            }?.lineCode ?? ""
            
            // MARK: - Line Code Persistence
            // Save the found lineCode or empty string
            UserDefaults.standard.set(lineCodeToSave, forKey: lineCodeKey)
            savedItems.append(!lineCodeToSave.isEmpty ? "Line code: \(lineCodeToSave)": "Line code: empty string")
        }
        
        // MARK: - Line Color Persistence
        // Save line color (only if set)
        if let lineColor = selectedLineColor, !lineColor.isEmpty {
            let lineColorKey = goorback.lineColorKey(lineIndex)
            UserDefaults.standard.set(lineColor, forKey: lineColorKey)
            savedItems.append("Line color: \(lineColor)")
        }
        
        // MARK: - Station Information Persistence
        // Save departure station information (always save if input is complete)
        if !departureStationInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let departureKey = goorback.departStationKey(lineIndex)
            UserDefaults.standard.set(departureStationInput, forKey: departureKey)
            savedItems.append("Departure station: \(departureStationInput)")
        }
        
        // Save arrival station information (always save if input is complete)
        if !arrivalStationInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let arrivalKey = goorback.arriveStationKey(lineIndex)
            UserDefaults.standard.set(arrivalStationInput, forKey: arrivalKey)
            savedItems.append("Arrival station: \(arrivalStationInput)")
        }
        
        // MARK: - Ride Time Persistence
        // Save ride time (always save)
        let rideTimeKey = goorback.rideTimeKey(lineIndex)
        UserDefaults.standard.set(selectedRideTime, forKey: rideTimeKey)
        savedItems.append("Ride time: \(selectedRideTime) minutes")
    }
    
    // MARK: - Station Data Retrieval
    // Get all stations (regardless of line selection), provides comprehensive station list for search and selection
    func getAllAvailableStations() -> [Station] {

        // MARK: - Sequential File Processing
        // Process each operator's data file for complete station collection
        let allStations = stationDataFiles.flatMap { filename in
            loadLocalData(for: filename).flatMap { parseAllStationsFromFile($0) } ?? []
        }
        
        // MARK: - Data Deduplication and Sorting
        // Remove duplicates and sort alphabetically for consistent display
        return Array(Set(allStations)).sorted { $0.getLocalizedName() < $1.getLocalizedName() }
    }
    
    // MARK: - File Station Parsing
    // Extract all stations from file, parses station data from JSON files and creates Station objects
    func parseAllStationsFromFile(_ data: Data) -> [Station]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let array = json as? [[String: Any]] {
                var stations: [Station] = []
                
                // MARK: - Railway Line Processing
                // Process each railway line in the file
                for railway in array {
                    if let stationOrder = railway["odpt:stationOrder"] as? [[String: Any]] {
                        // MARK: - Station Extraction
                        // Extract stations from each line's station order
                        for stationInfo in stationOrder {
                            if let stationTitle = stationInfo["odpt:stationTitle"] as? [String: Any] {
                                let jaName = stationTitle["ja"] as? String
                                let enName = stationTitle["en"] as? String
                                
                                // MARK: - Localized Name Selection
                                // Use Japanese name first, then English name as fallback
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
            // MARK: - Error Handling
            // Handle JSON parsing errors silently
            return nil
        }
        return nil
    }
}
