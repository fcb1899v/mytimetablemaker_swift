//
//  CacheService.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2025/08/24.
//
//  MARK: - Overview
//  Service for managing local cache storage and metadata.
//  Provides efficient data persistence and retrieval for offline access.
//

import Foundation
import Combine

// MARK: - File Cache Management
// Handles local storage of ODPT data and metadata.
// Provides efficient data persistence and retrieval for offline access.
final class CacheStore {
    private let dir: URL
    
    init() {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        dir = base.appendingPathComponent("ODPTCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    
    // MARK: - File Path Management
    // Get file path for a given filename in the cache directory.
    private func path(for file: String) -> URL { dir.appendingPathComponent(file) }

    // MARK: - Data Operations
    // Load cached data from file system.
    func loadData(for file: String) -> Data? {
        let url = path(for: file)
        return try? Data(contentsOf: url)
    }
    
    // Save data to cache with atomic write for data integrity.
    func saveData(_ data: Data, for file: String) {
        let url = path(for: file)
        try? data.write(to: url, options: [.atomic])
    }   
    
    // MARK: - Directory Operations
    // Get directory path for a given directory name in the cache directory.
    func directoryPath(for dirName: String) -> URL {
        return dir.appendingPathComponent(dirName, isDirectory: true)
    }
    
    // Check if cached directory exists.
    func directoryExists(for dirName: String) -> Bool {
        let url = directoryPath(for: dirName)
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
    
    // Copy directory to cache.
    func saveDirectory(from sourceDir: URL, for dirName: String) throws {
        let destDir = directoryPath(for: dirName)
        let fileManager = FileManager.default
        
        // Remove existing directory if it exists
        if fileManager.fileExists(atPath: destDir.path) {
            try fileManager.removeItem(at: destDir)
        }
        
        // Create parent directory if needed
        try fileManager.createDirectory(at: destDir.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        
        // Copy directory
        try fileManager.copyItem(at: sourceDir, to: destDir)
    }
    
    // Load cached directory path.
    func loadDirectoryPath(for dirName: String) -> URL? {
        let url = directoryPath(for: dirName)
        if directoryExists(for: dirName) {
            return url
        }
        return nil
    }
}


// MARK: - Shared Data Manager
// Singleton service for managing transportation line data across the app.
// Implements shared cache to avoid repeated loading and improve performance.
@MainActor
final class SharedDataManager: ObservableObject {
    
    // MARK: - Singleton Instance
    // Shared instance for app-wide data access
    static let shared = SharedDataManager()
    
    // MARK: - Published Properties
    // Observable properties for UI updates
    @Published var allLines: [TransportationLine] = []
    @Published var isLoading: Bool = false
    @Published var lastUpdated: Date?
    
    // MARK: - Private Properties
    // Internal state management
    private var isInitialized = false
    private var initializationTask: Task<Void, Never>?
    private var initializedKinds: Set<TransportationLine.Kind> = []
    private let cache = CacheStore()
    private let odptService = ODPTDataService()
    private let gtfsService = GTFSDataService()
    private let consumerKey: String
    
    // MARK: - Initialization
    // Private initializer for singleton pattern
    private init() {
        self.consumerKey = Bundle.main.infoDictionary?["ODPT_ACCESS_TOKEN"] as? String ?? ""
    }
    
    // MARK: - Data Access
    // Get lines for a specific transportation kind
    // Load only data for the requested kind to improve performance
    func getLines(for kind: TransportationLine.Kind, allowFetch: Bool = true) async -> [TransportationLine] {
        // Initialize only if needed for this kind
        if !initializedKinds.contains(kind) {
            if allowFetch {
                await ensureCacheForKind(kind)
            }
            initializedKinds.insert(kind)
        }
        
        // Load only the requested kind from cache
        var cacheLines: [TransportationLine] = []
        
        let operators = LocalDataSource.allCases.filter { $0.transportationType == kind }
        
        // Process each operator's cached data and parse into transportation lines
        // Filter by kind to ensure only relevant data is loaded
        for transportOperator in operators {
            // Handle GTFS operators separately
            // For GTFS, don't fetch lines at startup - only ensure ZIP cache exists
            // Lines will be fetched lazily when user selects the operator
            if transportOperator.apiType == .gtfs {
                // Check if ZIP cache exists, download if not (but don't extract)
                let date = GTFSDates.date(for: transportOperator) ?? ""
                let gtfsFileName = transportOperator.gtfsFileName
                let cacheKey = date.isEmpty ? "gtfs_\(gtfsFileName).zip" : "gtfs_\(gtfsFileName)_\(date).zip"
                
                if cache.loadData(for: cacheKey) == nil {
                    // Download ZIP file for caching (without extracting)
                do {
                        let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
                        if !gtfsURL.isEmpty {
                            _ = try await gtfsService.downloadGTFSZipOnly(url: gtfsURL, consumerKey: consumerKey, transportOperator: transportOperator)
                        }
                } catch {
                        print("⚠️ Failed to download GTFS ZIP for \(transportOperator.operatorDisplayName): \(error)")
                    }
                }
                // Don't fetch lines at startup - return empty array
                // Lines will be fetched when user selects this operator
                continue
            }
            
            let cacheKey = transportOperator.fileName
            guard let cachedData = cache.loadData(for: cacheKey) else { 
                continue 
            }
            
            let lines: [TransportationLine] = kind == .railway 
                ? (try? ODPTParser.parseRailwayRoutes(cachedData)) ?? []
                : (try? ODPTParser.parseBusRoutes(cachedData)) ?? []
            
            cacheLines.append(contentsOf: lines)
        }
        
        return cacheLines
    }
    
    // Ensure cache exists for a specific kind
    private func ensureCacheForKind(_ kind: TransportationLine.Kind) async {
        let operators = LocalDataSource.allCases.filter { $0.transportationType == kind }
        
        // Check if all operators for this kind have cache
        let allHaveCache = operators.allSatisfy { transportOperator in
            // For GTFS operators, check GTFS cache key instead of fileName
            if transportOperator.apiType == .gtfs {
                let date = GTFSDates.date(for: transportOperator) ?? ""
                let gtfsFileName = transportOperator.gtfsFileName
                let cacheKey = date.isEmpty ? "gtfs_\(gtfsFileName).zip" : "gtfs_\(gtfsFileName)_\(date).zip"
                return cache.loadData(for: cacheKey) != nil
            } else {
                return cache.loadData(for: transportOperator.fileName) != nil
            }
        }
        
        if !allHaveCache {
            // Some caches are missing, fetch them
            await performInitialFetch(for: kind)
        }
    }
    
    // Perform initial fetch for a specific kind only (without saving to cache)
    private func performInitialFetch(for kind: TransportationLine.Kind) async {
        let operators = LocalDataSource.allCases.filter { $0.transportationType == kind }
        
        for transportOperator in operators {
            // Fetch data
            do {
                // Handle GTFS operators separately
                if transportOperator.apiType == .gtfs {
                    // For GTFS, download ZIP file and extract for caching at startup
                    // Check for updates: date-based operators check date, Toei Bus uses ETag/Last-Modified
                    let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
                    if !gtfsURL.isEmpty {
                        // downloadGTFSZip() handles:
                        // - Date-based operators: cache key includes date, so date change = new cache key = new download
                        // - Toei Bus: checks for updates using ETag/Last-Modified via checkForToeiBusGTFSUpdate()
                        _ = try await gtfsService.downloadGTFSZipOnly(url: gtfsURL, consumerKey: consumerKey, transportOperator: transportOperator)
                        print("✅ Downloaded and extracted GTFS ZIP for caching: \(transportOperator.operatorDisplayName)")
                    }
                } else {
                    // Check if cache exists for non-GTFS operators
                    let cacheKey = transportOperator.fileName
                    let hasCache = cache.loadData(for: cacheKey) != nil
                    
                    if hasCache {
                        continue
                    }
                    
                    let data = try await odptService.fetchIndividualOperatorData(transportOperator, consumerKey: consumerKey)
                    
                    // Write to file
                    try await odptService.writeIndividualOperatorDataToFile(data: data, for: transportOperator)
                    
                    // Don't save to cache here - only load from cache
                    // Cache will be saved when user presses save button
                    
                    print("✅ Fetched: \(transportOperator.operatorDisplayName)")
                }
            } catch {
                print("❌ Failed to initialize \(transportOperator.operatorDisplayName): \(error)")
            }
        }
    }
    
    // Save cache for a specific kind
    func saveCacheForKind(_ kind: TransportationLine.Kind) async {
        let operators = LocalDataSource.allCases.filter { $0.transportationType == kind }
        
        for transportOperator in operators {
            let cacheKey = transportOperator.fileName
            
            // Load from file if exists
            if let fileData = await loadFromFile(for: transportOperator) {
                cache.saveData(fileData, for: cacheKey)
                print("💾 Saved cache for: \(transportOperator.operatorDisplayName)")
            }
        }
    }
    
    // Load data from file
    private func loadFromFile(for transportOperator: LocalDataSource) async -> Data? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let lineDataDirectory = documentsDirectory.appendingPathComponent("LineData", isDirectory: true)
        let fileName = transportOperator.fileName
        let fileURL = lineDataDirectory.appendingPathComponent(fileName)
        
        return try? Data(contentsOf: fileURL)
    }
    
    // MARK: - Data Initialization
    // Initialize data with cache-first approach
    private func initializeData() async {
        // Prevent multiple simultaneous initializations
        if let existingTask = initializationTask {
            await existingTask.value
            return
        }
        
        initializationTask = Task {
            await performInitialization()
        }
        
        await initializationTask?.value
    }
    
    // MARK: - Initialization Logic
    // Perform actual data initialization
    private func performInitialization() async {
        guard !isInitialized else { return }
        
        isLoading = true
        
        // MARK: - Cache Availability Check using closure
        let hasAnyCache = LocalDataSource.allCases.contains { transportOperator in
            let cacheKey = transportOperator.fileName
            return cache.loadData(for: cacheKey) != nil
        }
        
        if !hasAnyCache {
            // No cache available, perform initial fetch
            await performInitialFetch()
            
            // After initial fetch, perform railway and bus updates
            // Enable 24-hour rule to prevent unnecessary updates
            if !consumerKey.isEmpty && shouldPerformRailwayUpdate() {
                print("🔄 Performing railway auto update after initial fetch...")
                await performRailwayUpdate()
                
                print("🔄 Performing bus manual update after initial fetch...")
                await performBusUpdate()
            }
        } else {
            // Load from cache
            await loadFromCache()
            
            // Check for updates in background (both railway and bus)
            // Enable 24-hour rule to prevent unnecessary updates
            if !consumerKey.isEmpty && shouldPerformRailwayUpdate() {
                Task.detached(priority: .background) { [weak self] in
                    await self?.performRailwayUpdate()
                }
                
                Task.detached(priority: .background) { [weak self] in
                    await self?.performBusUpdate()
                }
            } else {
                print("ℹ️ Railway and bus auto update skipped - less than 24 hours since last update")
            }
        }
        
        isLoading = false
        isInitialized = true
        
        // Only set lastUpdated if we actually performed an update
        // Don't set it just for loading from cache
        if lastUpdated == nil {
            // Set to a date in the past to indicate we have data but haven't updated yet
            lastUpdated = Date().addingTimeInterval(-25 * 60 * 60) // 25 hours ago
        }
    }
    
    // MARK: - Cache Loading
    // Load data from cache
    private func loadFromCache() async {
        var cacheLines: [TransportationLine] = []
        
        // MARK: - Cache Loading using map and reduce
        var cacheResults: [(LocalDataSource, [TransportationLine])] = []
        
        for transportOperator in LocalDataSource.allCases {
            // Handle GTFS operators separately
            // For GTFS, download ZIP file for caching if not exists (but don't extract)
            // Lines will be fetched lazily when user selects the operator
            if transportOperator.apiType == .gtfs {
                // Check if ZIP cache exists, download if not (but don't extract)
                let date = GTFSDates.date(for: transportOperator) ?? ""
                let gtfsFileName = transportOperator.gtfsFileName
                let cacheKey = date.isEmpty ? "gtfs_\(gtfsFileName).zip" : "gtfs_\(gtfsFileName)_\(date).zip"
                
                if cache.loadData(for: cacheKey) == nil {
                    // Download ZIP file for caching (without extracting)
                    do {
                        let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
                        if !gtfsURL.isEmpty {
                            _ = try await gtfsService.downloadGTFSZipOnly(url: gtfsURL, consumerKey: consumerKey, transportOperator: transportOperator)
                        }
                } catch {
                        print("⚠️ Failed to download GTFS ZIP for \(transportOperator.operatorDisplayName): \(error)")
                    }
                }
                // Don't fetch lines at startup - return empty array
                // Lines will be fetched when user selects this operator
                continue
            }
            
            let cacheKey = transportOperator.fileName
            guard let cachedData = cache.loadData(for: cacheKey) else { 
                continue 
            }
            
            let lines: [TransportationLine] = transportOperator.transportationType == .railway 
                ? (try? ODPTParser.parseRailwayRoutes(cachedData)) ?? []
                : (try? ODPTParser.parseBusRoutes(cachedData)) ?? []
            
            cacheResults.append((transportOperator, lines))
        }
        
        // Process results
        cacheLines = cacheResults.flatMap { $0.1 }
        
        self.allLines = cacheLines
        print("📊 Shared data loaded: \(self.allLines.count) lines from \(cacheResults.count) operators")
    }
    
    // MARK: - Initial Fetch
    // Perform initial data fetch when no cache is available
    private func performInitialFetch() async {
        // MARK: - Parallel Fetch using withTaskGroup
        let results = await withTaskGroup(of: (LocalDataSource, [TransportationLine], Data?).self) { group in
            for transportOperator in LocalDataSource.allCases {
                group.addTask {
                    do {
                        // Handle GTFS operators separately
                        if transportOperator.apiType == .gtfs {
                            // For GTFS, only download ZIP file for caching (don't extract at startup)
                            // Lines will be fetched lazily when user selects the operator
                            let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
                            if !gtfsURL.isEmpty {
                                _ = try await self.gtfsService.downloadGTFSZipOnly(url: gtfsURL, consumerKey: self.consumerKey, transportOperator: transportOperator)
                                print("✅ Downloaded GTFS ZIP for caching: \(transportOperator.operatorDisplayName)")
                            }
                            // Return empty array - lines will be fetched when user selects this operator
                            return (transportOperator, [], nil)
                        }
                        
                        let data = try await self.odptService.fetchIndividualOperatorData(transportOperator, consumerKey: self.consumerKey)
                        
                        let lines: [TransportationLine] = transportOperator.transportationType == .railway 
                            ? (try? ODPTParser.parseRailwayRoutes(data)) ?? []
                            : (try? ODPTParser.parseBusRoutes(data)) ?? []
                        
                        // Write data to file for persistence
                        try? await self.odptService.writeIndividualOperatorDataToFile(data: data, for: transportOperator)
                        
                        // Save data to cache (must be on MainActor)
                        let cacheKey = transportOperator.fileName
                        await MainActor.run {
                            self.cache.saveData(data, for: cacheKey)
                        }
                        
                        // Calculate data size in KB
                        let dataSizeKB = Double(data.count) / 1024.0
                        
                        // Print data size and line count for each operator
                        print("📊 \(transportOperator.operatorDisplayName): \(String(format: "%.2f", dataSizeKB)) KB (\(lines.count) lines)")
                        print("✅ Fetched and saved: \(transportOperator.operatorDisplayName)")
                        
                        return (transportOperator, lines, data)
                    } catch {
                        print("❌ Failed to fetch \(transportOperator.operatorDisplayName): \(error)")
                        return (transportOperator, [], nil)
                    }
                }
            }
            
            var allLines: [TransportationLine] = []
            for await result in group {
                allLines.append(contentsOf: result.1)
            }
            return allLines
        }
        
        // Update data if any operators were fetched
        if !results.isEmpty {
            self.allLines = results
            print("📊 Initial fetch completed: \(results.count) lines")
        } else {
            print("❌ Initial fetch failed - no data retrieved")
        }
    }
    
    // MARK: - Common Update Processing
    // Common function to process updates for both railway and bus operators
    // Only processes operators that have ETag/Last-Modified for conditional GET
    private func processUpdate(
        for operators: [LocalDataSource],
        updateType: String,
        parser: @escaping (Data) throws -> [TransportationLine],
        updateHandler: @escaping (LocalDataSource) async -> Result<Void, Error>
    ) async -> [TransportationLine] {
        print("🔄 Performing \(updateType) update...")
        
        // Filter operators: only process those with ETag/Last-Modified
        let operatorsToUpdate = operators.filter { transportOperator in
            let cacheKey = transportOperator.fileName
            // Check if ETag or Last-Modified exists
            let etagKey = "\(cacheKey)_etag"
            let lastModifiedKey = "\(cacheKey)_last_modified"
            let hasETag = UserDefaults.standard.string(forKey: etagKey) != nil
            let hasLastModified = UserDefaults.standard.string(forKey: lastModifiedKey) != nil
            return hasETag || hasLastModified
        }
        
        guard !operatorsToUpdate.isEmpty else {
            print("ℹ️ \(updateType.capitalized) update: No operators with ETag/Last-Modified found")
            return []
        }
        
        // MARK: - Parallel Update Processing
        // Process all operators in parallel for improved performance
        let results = await withTaskGroup(of: (LocalDataSource, [TransportationLine]).self) { group in
            for transportOperator in operatorsToUpdate {
                group.addTask {
                    let result = await updateHandler(transportOperator)
                    
                    switch result {
                    case .success:
                        // Check if data was actually updated by comparing with current data
                        let cacheKey = transportOperator.fileName
                        // Use MainActor.run to ensure we're on the main actor for cache access
                        return await MainActor.run {
                            if let cachedData = self.cache.loadData(for: cacheKey) {
                                let newLines = (try? parser(cachedData)) ?? []
                                
                                // Get current lines for this operator
                                let currentLines = self.allLines.filter { line in
                                    guard let operatorCode = line.operatorCode else { return false }
                                    return operatorCode == transportOperator.operatorCode && line.kind == transportOperator.transportationType
                                }
                                
                                // Check if data has actually changed
                                if newLines.count != currentLines.count || !newLines.elementsEqual(currentLines, by: { $0.code == $1.code }) {
                                    print("🔄 \(transportOperator.operatorDisplayName): \(updateType) data updated (\(newLines.count) lines)")
                                    return (transportOperator, newLines)
                                } else {
                                    return (transportOperator, []) // Return empty array for unchanged data
                                }
                            }
                            return (transportOperator, [])
                        }
                    case .failure(let error):
                        print("❌ Failed to update \(transportOperator.operatorDisplayName): \(error)")
                        return (transportOperator, [])
                    }
                }
            }
            
            var results: [TransportationLine] = []
            for await result in group {
                results.append(contentsOf: result.1)
            }
            return results
        }
        
        return results
    }
    
    // MARK: - Railway Update
    // Perform railway data update (used for both auto and manual updates)
    func performRailwayUpdate() async {
        let railwayOperators = LocalDataSource.allCases.filter { $0.transportationType == .railway }
        
        let updatedData = await processUpdate(
            for: railwayOperators,
            updateType: "railway",
            parser: { try ODPTParser.parseRailwayRoutes($0) }
        ) { transportOperator in
            await self.odptService.updateIndividualOperator(transportOperator, consumerKey: self.consumerKey)
        }
        
        // Update data on main actor
        if !updatedData.isEmpty {
            await self.mergeUpdatedData(updatedData, updateType: "Railway")
            self.updateRailwayLastUpdateTime() // Record the update time
        } else {
            print("ℹ️ Railway auto update: No data changes detected")
        }
    }
    
    // MARK: - Bus Update
    // Perform bus data update (used for both auto and manual updates)
    func performBusUpdate() async {
        isLoading = true
        
        let busOperators = LocalDataSource.allCases.filter { $0.transportationType == .bus }
        
        // Clear old bus cache files first to force fresh fetch
        for transportOperator in busOperators {
            let cacheKey = transportOperator.fileName
            if cache.loadData(for: cacheKey) != nil {
                cache.saveData(Data(), for: cacheKey)
            }
        }
        
        // Separate GTFS and non-GTFS operators
        let gtfsOperators = busOperators.filter { $0.apiType == .gtfs }
        let nonGtfsOperators = busOperators.filter { $0.apiType != .gtfs }
        
        // Process GTFS operators separately
        var gtfsUpdatedData: [TransportationLine] = []
        for transportOperator in gtfsOperators {
            do {
                let lines = try await gtfsService.fetchGTFSData(transportOperator, consumerKey: consumerKey)
                gtfsUpdatedData.append(contentsOf: lines)
                print("✅ Updated GTFS: \(transportOperator.operatorDisplayName) (\(lines.count) lines)")
            } catch {
                print("❌ Failed to update GTFS \(transportOperator.operatorDisplayName): \(error)")
            }
        }
        
        // Process non-GTFS operators using existing processUpdate
        let updatedData = await processUpdate(
            for: nonGtfsOperators,
            updateType: "bus",
            parser: { try ODPTParser.parseBusRoutes($0) }
        ) { transportOperator in
            do {
                // Force update by bypassing conditional GET
                let data = try await self.odptService.fetchIndividualOperatorData(transportOperator, consumerKey: self.consumerKey)
                
                // Write updated data to JSON file
                try await self.odptService.writeIndividualOperatorDataToFile(data: data, for: transportOperator)
                
                // Update cache with new data
                let cacheKey = transportOperator.fileName
                self.cache.saveData(data, for: cacheKey)

                return .success(())
            } catch {
                print("❌ Failed to fetch \(transportOperator.operatorDisplayName): \(error)")
                return .failure(error)
            }
        }
        
        // Combine GTFS and non-GTFS updated data
        let allUpdatedData = updatedData + gtfsUpdatedData
        
        // Update data on main actor
        if !allUpdatedData.isEmpty {
            await self.mergeUpdatedData(allUpdatedData, updateType: "Bus")
        } else {
            print("ℹ️ Bus manual update: No data changes detected")
        }
        
        isLoading = false
    }
    
    // MARK: - Common Data Merging
    // Merge updated data with existing data
    private func mergeUpdatedData(_ updatedData: [TransportationLine], updateType: String) async {
        // Merge updated data with existing data
        var existingData = self.allLines
        
        // Remove old data for updated operators
        // Use both operatorCode and transportation type to identify specific data
        let updatedOperatorCodes = Set(updatedData.compactMap { $0.operatorCode })
        existingData = existingData.filter { line in
            guard let operatorCode = line.operatorCode else { return true }
            // Only remove lines for updated operators with matching type
            if updatedOperatorCodes.contains(operatorCode) && line.kind == updatedData.first?.kind {
                return false // Remove this line
            }
            return true // Keep all other lines
        }
        
        // Add updated data
        existingData.append(contentsOf: updatedData)
        
        self.allLines = existingData
        self.lastUpdated = Date()
        print("✅ \(updateType) update completed: \(updatedData.count) lines")
        print("📊 Total data after update: \(self.allLines.count) lines")
    }
    
    // MARK: - Update Check
    // Check if railway update is needed (24-hour rule)
    private func shouldPerformRailwayUpdate() -> Bool {
        // Check UserDefaults for last update time
        let lastUpdateKey = "LastRailwayUpdate"
        let lastUpdate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date
        let currentTime = Date()
        
        // If no lastUpdate date, check if we have cached data
        if lastUpdate == nil {
            // Check if we have any cached data
            let hasAnyCache = LocalDataSource.allCases.contains { transportOperator in
                let cacheKey = transportOperator.fileName
                return cache.loadData(for: cacheKey) != nil
            }
            return !hasAnyCache // Only update if no cache exists
        }
        
        // Check if 24 hours have passed since last update
        let timeSinceLastUpdate = currentTime.timeIntervalSince(lastUpdate!)
        let twentyFourHours: TimeInterval = 24 * 60 * 60
        return timeSinceLastUpdate >= twentyFourHours
    }
    
    // MARK: - Update Last Update Time
    // Record the time when railway update was performed
    private func updateRailwayLastUpdateTime() {
        let lastUpdateKey = "LastRailwayUpdate"
        UserDefaults.standard.set(Date(), forKey: lastUpdateKey)
    }
    
    // MARK: - Cache Availability Check
    // Check if any cache exists to determine if we need to fetch data
    // Cache existence indicates that data has been fetched at least once
    func checkCacheAvailability() -> Bool {
        return LocalDataSource.allCases.contains { transportOperator in
            let cacheKey = transportOperator.fileName
            return cache.loadData(for: cacheKey) != nil
        }
    }
    
    // MARK: - Splash Initialization
    // Perform complete initialization for splash screen
    // Handles data loading, fetching, and update checks
    // Note: isLoading should be set to true before calling this method
    func performSplashInitialization() async {
        print("🔄 Starting data initialization...")
        
        // Check if we have any cache (indicates data has been fetched at least once)
        let hasAnyCache = checkCacheAvailability()
        
        if !hasAnyCache {
            // No cache exists: fetch all operators' data
            print("📥 No cache found - fetching all operators' data")
            await performInitialFetch()
        } else {
            // Cache exists: load from cache (data already fetched)
            print("📂 Cache found - loading from cache")
            await loadFromCache()
        }
        
        // Perform update check for operators with ETag/Last-Modified
        // Only operators with ETag/Last-Modified will be checked
        //        await performRailwayUpdate()
        //        await performBusUpdate()
        
        // Ensure isLoading is false after all operations complete
        await MainActor.run {
            isLoading = false
        }
        
        // Small delay to ensure all print statements complete
        try? await Task.sleep(for: .seconds(0.5))
    }
    
}
