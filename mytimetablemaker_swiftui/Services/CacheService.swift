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

    // MARK: - Metadata Operations
    // Load cache metadata for validation and update checking.
    func loadMeta(for file: String) -> CacheMeta? {
        guard let data = loadData(for: file) else { return nil }
        return try? JSONDecoder().decode(CacheMeta.self, from: data)
    }
    
    // Save cache metadata for tracking data freshness.
    func saveMeta(_ meta: CacheMeta, for file: String) {
        let data = try? JSONEncoder().encode(meta)
        if let data { saveData(data, for: file) }
    }
}

// MARK: - Cache Meta Information
// Metadata for cached ODPT data including ETag and last modified information.
// Used for efficient cache validation and updates.
struct CacheMeta: Codable {
    var eTag: String?           // HTTP ETag for cache validation
    var lastModified: String?   // Last-Modified header value
    var downloadedAt: Date      // When the data was cached locally
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
    @Published var statistics: DataStatistics = DataStatistics()
    
    // MARK: - Private Properties
    // Internal state management
    private var isInitialized = false
    private var initializationTask: Task<Void, Never>?
    private let cache = CacheStore()
    private let net = ODPTNetworkClient()
    private let consumerKey: String
    
    // MARK: - Initialization
    // Private initializer for singleton pattern
    private init() {
        self.consumerKey = Bundle.main.infoDictionary?["ODPT_ACCESS_TOKEN"] as? String ?? ""
    }
    
    // MARK: - Data Access
    // Get all transportation lines, initializing if necessary
    func getAllLines() async -> [TransportationLine] {
        if !isInitialized {
            await initializeData()
        }
        return allLines
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
            let hasData = cache.loadData(for: cacheKey) != nil
            if !hasData {
                print("🔍 Cache not found for: \(cacheKey)")
            }
            return hasData
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
        
        await updateStatistics()
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
        var cachedOperators = 0
        var operatorDetails: [String] = []
        
        // MARK: - Cache Loading using map and reduce
        let cacheResults = LocalDataSource.allCases.compactMap { transportOperator -> (LocalDataSource, [TransportationLine])? in
            let cacheKey = transportOperator.fileName
            guard let cachedData = cache.loadData(for: cacheKey) else { 
                print("❌ Cache not found for: \(cacheKey)")
                return nil 
            }
            
            let lines: [TransportationLine] = transportOperator.transportationType == .railway 
                ? (try? ODPTParser.parseLocalRailways(cachedData)) ?? []
                : (try? ODPTParser.parseBusRoutes(cachedData)) ?? []
            
            print("📁 Loading from cache: \(cacheKey) (\(cachedData.count) bytes): Parsed \(lines.count) lines for \(transportOperator.operatorDisplayName)")
            
            return (transportOperator, lines)
        }
        
        // Process results
        cacheLines = cacheResults.flatMap { $0.1 }
        cachedOperators = cacheResults.count
        operatorDetails = cacheResults.map { "\($0.0.operatorDisplayName): \($0.1.count) lines" }
        
        self.allLines = cacheLines
        print("📊 Shared data loaded: \(self.allLines.count) lines from \(cachedOperators) operators")
        print("📋 Operator details: \(operatorDetails.joined(separator: ", "))")
        
        // MARK: - Duplicate Check using closure
        let duplicateCheck = Dictionary(grouping: cacheLines) { line in
            "\(line.operatorCode ?? "unknown")_\(line.kind.rawValue)_\(line.code)"
        }
        let duplicates = duplicateCheck.filter { $0.value.count > 1 }
        if !duplicates.isEmpty {
            print("⚠️ Found \(duplicates.count) duplicate entries:")
            for (key, lines) in duplicates.prefix(5) {
                print("   \(key): \(lines.count) duplicates")
            }
        }
    }
    
    // MARK: - Initial Fetch
    // Perform initial data fetch when no cache is available
    private func performInitialFetch() async {
        // MARK: - Parallel Fetch using withTaskGroup
        let results = await withTaskGroup(of: (LocalDataSource, [TransportationLine]).self) { group in
            for transportOperator in LocalDataSource.allCases {
                group.addTask {
                    do {
                        let data = try await self.net.fetchIndividualOperatorData(transportOperator, consumerKey: self.consumerKey)
                        
                        let lines: [TransportationLine] = transportOperator.transportationType == .railway 
                            ? (try? ODPTParser.parseLocalRailways(data)) ?? []
                            : (try? ODPTParser.parseBusRoutes(data)) ?? []
                        
                        return (transportOperator, lines)
                    } catch {
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
    private func processUpdate(
        for operators: [LocalDataSource],
        updateType: String,
        parser: @escaping (Data) throws -> [TransportationLine],
        updateHandler: @escaping (LocalDataSource) async -> Result<Void, Error>
    ) async -> [TransportationLine] {
        print("🔄 Performing \(updateType) update...")
        
        // MARK: - Parallel Update Processing
        let results = await withTaskGroup(of: (LocalDataSource, [TransportationLine]).self) { group in
            for transportOperator in operators {
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
                                    print("ℹ️ \(transportOperator.operatorDisplayName): \(updateType) data unchanged (\(newLines.count) lines)")
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
            parser: { try ODPTParser.parseLocalRailways($0) }
        ) { transportOperator in
            await self.net.updateIndividualOperator(transportOperator, consumerKey: self.consumerKey)
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
        print("🔄 Performing bus update via shared manager...")
        
        isLoading = true
        
        let busOperators = LocalDataSource.allCases.filter { $0.transportationType == .bus }
        
        let updatedData = await processUpdate(
            for: busOperators,
            updateType: "bus",
            parser: { try ODPTParser.parseBusRoutes($0) }
        ) { transportOperator in
            do {
                // Use checkIndividualOperatorForUpdates for 304 conditional GET support
                let needsUpdate = try await self.net.checkIndividualOperatorForUpdates(transportOperator, consumerKey: self.consumerKey)
                
                if needsUpdate {
                    let data = try await self.net.fetchIndividualOperatorData(transportOperator, consumerKey: self.consumerKey)
                    
                    // Write updated data to JSON file
                    try await self.net.writeIndividualOperatorDataToFile(data: data, for: transportOperator)
                    
                    // Update cache with new data
                    let cacheKey = transportOperator.fileName
                    self.cache.saveData(data, for: cacheKey)

                    return .success(())
                } else {
                    print("✅ \(transportOperator.operatorDisplayName): No update needed (304 or content unchanged)")
                    return .success(())
                }
            } catch {
                print("❌ Failed to check \(transportOperator.operatorDisplayName): \(error)")
                return .failure(error)
            }
        }
        
        // Update data on main actor
        if !updatedData.isEmpty {
            await self.mergeUpdatedData(updatedData, updateType: "Bus")
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
        
        // MARK: - Duplicate Check using closure
        let duplicateCheck = Dictionary(grouping: self.allLines) { line in
            "\(line.operatorCode ?? "unknown")_\(line.kind.rawValue)_\(line.code)"
        }
        let duplicates = duplicateCheck.filter { $0.value.count > 1 }
        if !duplicates.isEmpty {
            print("⚠️ Found \(duplicates.count) duplicate entries after \(updateType.lowercased()) update:")
            for (key, lines) in duplicates.prefix(5) {
                print("   \(key): \(lines.count) duplicates")
            }
        }
    }
    
    // MARK: - Statistics Update
    // Update data statistics using reduce
    private func updateStatistics() async {
        let stats = allLines.reduce(into: (total: 0, railway: 0, bus: 0, operators: Set<String>())) { result, line in
            result.total += 1
            if line.kind == .railway {
                result.railway += 1
            } else {
                result.bus += 1
            }
            if let operatorCode = line.operatorCode {
                result.operators.insert(operatorCode)
            }
        }
        
        self.statistics = DataStatistics(
            totalLines: stats.total,
            railwayLines: stats.railway,
            busLines: stats.bus,
            operators: stats.operators.count
        )
    }
    
    // MARK: - Update Check
    // Check if railway update is needed (24-hour rule)
    private func shouldPerformRailwayUpdate() -> Bool {
        // Check UserDefaults for last update time
        let lastUpdateKey = "LastRailwayUpdate"
        let lastUpdate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date
        let currentTime = Date()
        
        // Format dates for display
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let currentTimeString = dateFormatter.string(from: currentTime)
        
        // If no lastUpdate date, check if we have cached data
        if lastUpdate == nil {
            // Check if we have any cached data
            let hasAnyCache = LocalDataSource.allCases.contains { transportOperator in
                let cacheKey = transportOperator.fileName
                return cache.loadData(for: cacheKey) != nil
            }
            if hasAnyCache {
                print("ℹ️ Railway auto update skipped - cache exists, no previous update record")
                print("📅 Current time: \(currentTimeString)")
            } else {
                print("🔄 Railway auto update needed - no cache exists")
                print("📅 Current time: \(currentTimeString)")
            }
            return !hasAnyCache // Only update if no cache exists
        }
        
        // Check if 24 hours have passed since last update
        let timeSinceLastUpdate = currentTime.timeIntervalSince(lastUpdate!)
        let twentyFourHours: TimeInterval = 24 * 60 * 60
        let shouldUpdate = timeSinceLastUpdate >= twentyFourHours
        
        let lastUpdateString = dateFormatter.string(from: lastUpdate!)
        
        if shouldUpdate {
            print("🔄 Railway auto update needed - \(Int(timeSinceLastUpdate / 3600)) hours since last update")
            print("📅 Last update: \(lastUpdateString)")
            print("📅 Current time: \(currentTimeString)")
        } else {
            let remainingHours = Int((twentyFourHours - timeSinceLastUpdate) / 3600)
            print("ℹ️ Railway auto update skipped - \(Int(timeSinceLastUpdate / 3600)) hours since last update (\(remainingHours) hours remaining)")
            print("📅 Last update: \(lastUpdateString)")
            print("📅 Current time: \(currentTimeString)")
        }
        
        return shouldUpdate
    }
    
    // MARK: - Update Last Update Time
    // Record the time when railway update was performed
    private func updateRailwayLastUpdateTime() {
        let lastUpdateKey = "LastRailwayUpdate"
        UserDefaults.standard.set(Date(), forKey: lastUpdateKey)
    }
    
    // MARK: - Data Refresh
    // Force refresh of all data
    func refreshData() async {
        isInitialized = false
        initializationTask = nil
        await initializeData()
    }
    
    // MARK: - Memory Management
    // Clear data when memory is low
    func clearData() {
        allLines = []
        isInitialized = false
        initializationTask = nil
    }
}

