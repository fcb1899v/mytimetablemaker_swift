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
                // GTFS is paused for now.
                // Restore by uncommenting this block:
                // let date = GTFSDates.date(for: transportOperator) ?? ""
                // let gtfsFileName = transportOperator.gtfsFileName
                // let cacheKey = date.isEmpty ? "gtfs_\(gtfsFileName).zip" : "gtfs_\(gtfsFileName)_\(date).zip"
                // if cache.loadData(for: cacheKey) == nil {
                //     do {
                //         let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
                //         if !gtfsURL.isEmpty {
                //             _ = try await gtfsService.downloadGTFSZipOnly(url: gtfsURL, consumerKey: consumerKey, transportOperator: transportOperator)
                //         }
                //     } catch {
                //         print("⚠️ Failed to download GTFS ZIP for \(transportOperator.operatorDisplayName): \(error)")
                //     }
                // }
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
                // GTFS is paused for now.
                // Restore by uncommenting this block:
                // let date = GTFSDates.date(for: transportOperator) ?? ""
                // let gtfsFileName = transportOperator.gtfsFileName
                // let cacheKey = date.isEmpty ? "gtfs_\(gtfsFileName).zip" : "gtfs_\(gtfsFileName)_\(date).zip"
                // return cache.loadData(for: cacheKey) != nil
                return true
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
                    // GTFS is paused for now.
                    // Restore by uncommenting this block:
                    // let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
                    // if !gtfsURL.isEmpty {
                    //     _ = try await gtfsService.downloadGTFSZipOnly(url: gtfsURL, consumerKey: consumerKey, transportOperator: transportOperator)
                    //     print("✅ Downloaded and extracted GTFS ZIP for caching: \(transportOperator.operatorDisplayName)")
                    // }
                    continue
                }

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
            } catch {
                print("❌ Failed to initialize \(transportOperator.operatorDisplayName): \(error)")
            }
        }
    }
    
    // Save cache for a specific kind
    func saveCacheForKind(_ kind: TransportationLine.Kind) async {
        let operators = LocalDataSource.allCases.filter { $0.transportationType == kind }
        
        for transportOperator in operators {
            // GTFS is paused for now.
            if transportOperator.apiType == .gtfs {
                // Restore by uncommenting GTFS cache key handling.
                continue
            }

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
                // GTFS is paused for now.
                // Restore by uncommenting this block:
                // let date = GTFSDates.date(for: transportOperator) ?? ""
                // let gtfsFileName = transportOperator.gtfsFileName
                // let cacheKey = date.isEmpty ? "gtfs_\(gtfsFileName).zip" : "gtfs_\(gtfsFileName)_\(date).zip"
                // if cache.loadData(for: cacheKey) == nil {
                //     do {
                //         let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
                //         if !gtfsURL.isEmpty {
                //             _ = try await gtfsService.downloadGTFSZipOnly(url: gtfsURL, consumerKey: consumerKey, transportOperator: transportOperator)
                //         }
                //     } catch {
                //         print("⚠️ Failed to download GTFS ZIP for \(transportOperator.operatorDisplayName): \(error)")
                //     }
                // }
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
                            // GTFS is paused for now.
                            // Restore by uncommenting this block:
                            // let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
                            // if !gtfsURL.isEmpty {
                            //     _ = try await self.gtfsService.downloadGTFSZipOnly(url: gtfsURL, consumerKey: self.consumerKey, transportOperator: transportOperator)
                            //     print("✅ Downloaded GTFS ZIP for caching: \(transportOperator.operatorDisplayName)")
                            // }
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
    
    // MARK: - Cache Availability Check
    // Check if any cache exists to determine if we need to fetch data
    // Cache existence indicates that data has been fetched at least once
    func checkCacheAvailability() -> Bool {
        return LocalDataSource.allCases.contains { transportOperator in
            if transportOperator.apiType == .gtfs {
                // GTFS is paused for now.
                // Restore by uncommenting GTFS cache key existence check.
                return false
            }
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
        
        // Ensure isLoading is false after all operations complete
        await MainActor.run {
            isLoading = false
        }
        
        // Small delay to ensure all print statements complete
        try? await Task.sleep(for: .seconds(0.5))
    }
    
}
