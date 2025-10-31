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
    private let net = ODPTNetworkClient()
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
            cache.loadData(for: transportOperator.fileName) != nil
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
            // Check if cache exists
            let cacheKey = transportOperator.fileName
            if cache.loadData(for: cacheKey) != nil {
                continue
            }
            
            // Fetch data
            do {
                let data = try await net.fetchIndividualOperatorData(transportOperator, consumerKey: consumerKey)
                
                // Write to file
                try await net.writeIndividualOperatorDataToFile(data: data, for: transportOperator)
                
                // Don't save to cache here - only load from cache
                // Cache will be saved when user presses save button
                
                print("✅ Fetched: \(transportOperator.operatorDisplayName)")
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
        let cacheResults = LocalDataSource.allCases.compactMap { transportOperator -> (LocalDataSource, [TransportationLine])? in
            let cacheKey = transportOperator.fileName
            guard let cachedData = cache.loadData(for: cacheKey) else { 
                return nil 
            }
            
            let lines: [TransportationLine] = transportOperator.transportationType == .railway 
                ? (try? ODPTParser.parseRailwayRoutes(cachedData)) ?? []
                : (try? ODPTParser.parseBusRoutes(cachedData)) ?? []
            
            return (transportOperator, lines)
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
        let results = await withTaskGroup(of: (LocalDataSource, [TransportationLine]).self) { group in
            for transportOperator in LocalDataSource.allCases {
                group.addTask {
                    do {
                        let data = try await self.net.fetchIndividualOperatorData(transportOperator, consumerKey: self.consumerKey)
                        
                        let lines: [TransportationLine] = transportOperator.transportationType == .railway 
                            ? (try? ODPTParser.parseRailwayRoutes(data)) ?? []
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
        // Process all operators in parallel for improved performance
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
        isLoading = true
        
        let busOperators = LocalDataSource.allCases.filter { $0.transportationType == .bus }
        
        // Clear old bus cache files first to force fresh fetch
        for transportOperator in busOperators {
            let cacheKey = transportOperator.fileName
            if cache.loadData(for: cacheKey) != nil {
                cache.saveData(Data(), for: cacheKey)
            }
        }
        
        let updatedData = await processUpdate(
            for: busOperators,
            updateType: "bus",
            parser: { try ODPTParser.parseBusRoutes($0) }
        ) { transportOperator in
            do {
                // Force update by bypassing conditional GET
                let data = try await self.net.fetchIndividualOperatorData(transportOperator, consumerKey: self.consumerKey)
                
                // Write updated data to JSON file
                try await self.net.writeIndividualOperatorDataToFile(data: data, for: transportOperator)
                
                // Update cache with new data
                let cacheKey = transportOperator.fileName
                self.cache.saveData(data, for: cacheKey)

                return .success(())
            } catch {
                print("❌ Failed to fetch \(transportOperator.operatorDisplayName): \(error)")
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
    
}
