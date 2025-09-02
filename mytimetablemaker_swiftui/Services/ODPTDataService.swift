//
//  ODPTDataService.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/08/24.
//
//  MARK: - Overview
//  Service for managing ODPT API communication and data parsing.
//  Handles data fetching, caching, and conversion from external API format.
//

import Foundation

// MARK: - ODPT Data Parser
// Converts raw JSON data from ODPT API to internal TransportationLine models.
struct ODPTParser {
    
    // MARK: - Railway Data Parsing
    // Parse railway data from JSON and convert to TransportationLine objects.
    static func parseRailways(_ data: Data) throws -> [TransportationLine] {
        let dec = JSONDecoder()
        let dtos = try dec.decode([RailwayDTO].self, from: data)
        
        // MARK: - DTO to Model Mapping using closures
        return dtos.map { dto in
            TransportationLine(
                kind: .railway,
                name: dto.title,
                code: dto.sameAs,
                operatorCode: dto.operatorCode,
                railwayType: dto.railwayType,
                lineColor: dto.lineColor,
                startStation: dto.startStation,
                endStation: dto.endStation,
                railwayTitle: dto.railwayTitle,
                lineCode: dto.lineCode,
                busRoute: nil,
                pattern: nil,
                direction: nil,
                busstopPoleOrder: nil
            )
        }
    }
    
    // MARK: - Bus Data Parsing
    // Parse bus route pattern data from JSON and convert to TransportationLine objects.
    static func parseBusRoutes(_ data: Data) throws -> [TransportationLine] {
        
        let dec = JSONDecoder()
        let dtos = try dec.decode([BusRoutePatternDTO].self, from: data)
        
        // MARK: - DTO to Model Mapping using closures
        let transportationLines = dtos.map { dto in
            
            // Extract English name from odpt:busroute value
            let englishName = extractEnglishNameFromRouteName(dto.busRoute ?? "")
            
            return TransportationLine(
                kind: .bus,
                name: dto.title,
                code: dto.sameAs,
                operatorCode: dto.operatorCode,
                railwayType: nil,
                lineColor: nil,
                startStation: nil,
                endStation: nil,
                railwayTitle: RailwayTitle(ja: dto.title, en: englishName),
                lineCode: nil,
                busRoute: dto.busRoute,
                pattern: dto.pattern,
                direction: dto.direction,
                busstopPoleOrder: dto.busstopPoleOrder
            )
        }
        
        return transportationLines
    }
    
    // MARK: - Helper Functions
    // Extract English name from odpt:busroute value
    private static func extractEnglishNameFromRouteName(_ routeName: String) -> String? {
        // Extract English name from odpt:busroute format (e.g., "Mon33" from "odpt.Busroute:Toei.Mon33")
        // Format: "odpt.Busroute:OperatorName.RouteCode"
        // Similar to: result["odpt:busroute"].split(".")[2]
                
        // Split by "." to get parts
        let parts = routeName.components(separatedBy: ".")
        
        // Check if we have enough parts and the format is correct
        guard parts.count >= 3,
              parts[0] == "odpt",
              parts[1].hasPrefix("Busroute:") else { 
            print("❌ ODPTParser: Invalid format for routeName: '\(routeName)'")
            return nil 
        }
        
        // Get the route code (third part, index 2)
        let routeCode = parts[2]
        
        // Validate that the route code contains English characters or numbers
        let englishPattern = "[A-Za-z0-9]"
        guard routeCode.range(of: englishPattern, options: .regularExpression) != nil else { 
            print("❌ ODPTParser: Route code '\(routeCode)' does not contain English characters")
            return nil 
        }
        
        return routeCode
    }
    
    // MARK: - Local File Railway Parsing
    // Parse railway data from local JSON files with odpt:color field support
    static func parseLocalRailways(_ data: Data) throws -> [TransportationLine] {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let array = json as? [[String: Any]] {
                // MARK: - Array Processing using closures
                return array.compactMap { element in
                    // MARK: - Required Field Validation using closure
                    guard let title = element["dc:title"] as? String,
                          let sameAs = element["owl:sameAs"] as? String else { return nil }
                    
                    let operatorCode = element["odpt:operator"] as? String
                    // Support both odpt:color (local) and odpt:lineColor (API) fields
                    let lineColor = element["odpt:color"] as? String ?? element["odpt:lineColor"] as? String
                    let lineCode = element["odpt:lineCode"] as? String
                    
                    // MARK: - Multi-Language Title Processing using closure
                    let railwayTitle: RailwayTitle? = {
                        guard let railwayTitleDict = element["odpt:railwayTitle"] as? [String: String] else { return nil }
                        return RailwayTitle(
                            ja: railwayTitleDict["ja"],
                            en: railwayTitleDict["en"]
                        )
                    }()
                    
                    // MARK: - Station Boundary Information using closure
                    let (startStation, endStation) = {
                        let start = element["odpt:startStation"] as? String
                        let end = element["odpt:endStation"] as? String
                        return (start, end)
                    }()
                    
                    // MARK: - Line Creation
                    return TransportationLine(
                        kind: .railway,
                        name: title,
                        code: sameAs,
                        operatorCode: operatorCode,
                        railwayType: nil,
                        lineColor: lineColor,
                        startStation: startStation,
                        endStation: endStation,
                        railwayTitle: railwayTitle,
                        lineCode: lineCode,
                        busRoute: nil,
                        pattern: nil,
                        direction: nil,
                        busstopPoleOrder: nil
                    )
                }
            }
        } catch {
            throw ODPTError.invalidData
        }
        
        return []
    }
}

// MARK: - ODPT Data Source Definition
// Defines the source of ODPT data and provides URL construction.
// Currently supports railway data, extensible for other transportation types.
enum ODPTSource: CaseIterable {
    case railways
    case busRoutes

    // MARK: - URL Construction
    // Constructs the API URL with consumer key for authentication.
    func url(consumerKey: String) -> URL {
        switch self {
        case .railways:
            var components = URLComponents(string: "https://api-public.odpt.org/api/v4/odpt:Railway.json")!
            components.queryItems = [URLQueryItem(name: "acl:consumerKey", value: consumerKey)]
            return components.url!
        case .busRoutes:
            var components = URLComponents(string: "https://api.odpt.org/api/v4/odpt:BusroutePattern")!
            components.queryItems = [
                URLQueryItem(name: "odpt:operator", value: "odpt.Operator:YokohamaMunicipal"),
                URLQueryItem(name: "acl:consumerKey", value: consumerKey)
            ]
            return components.url!
        }
    }

    // MARK: - Cache File Names
    // Cache file name for storing downloaded data.
    var cacheFile: String {
        switch self {
        case .railways:
            return "odpt_railways.json"
        case .busRoutes:
            return "odpt_bus_routes.json"
        }
    }
    
    // Metadata file name for storing cache information.
    var metaFile: String {
        switch self {
        case .railways:
            return "odpt_railways.meta.json"
        case .busRoutes:
            return "odpt_bus_routes.meta.json"
        }
    }
    
    // MARK: - Display Information
    // Display name for UI presentation.
    var displayName: String {
        switch self {
        case .railways:
            return "鉄道"
        case .busRoutes:
            return "バス路線"
        }
    }
}

// MARK: - ODPT Network Client
// Handles HTTP communication with the ODPT API.
// Manages authentication, caching, and data retrieval.
final class ODPTNetworkClient: NSObject, URLSessionDelegate {
    private var session: URLSession!
    private let cache = CacheStore()
    
    override init() {
        super.init()
        
        // MARK: - Session Configuration
        // Configure URL session with appropriate timeouts and settings
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30    // 30 seconds for individual requests
        config.timeoutIntervalForResource = 60   // 60 seconds for entire resource transfer
        // Automatically handle redirects
        config.httpShouldSetCookies = false      // Disable cookie handling for API requests
        config.httpCookieAcceptPolicy = .never   // Never accept cookies
        
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    // MARK: - URL Session Delegate Methods
    // Handle HTTP redirects while preserving authentication parameters.
    // Ensures consumer key is maintained across redirect chains.
    private func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        // MARK: - Redirect URL Modification
        // Add consumerKey to the redirected URL to maintain authentication
        if var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
            if components.queryItems == nil {
                components.queryItems = []
            }
            
            // MARK: - Consumer Key Preservation using closure
            let consumerKey: String? = {
                guard let originalURL = task.originalRequest?.url,
                      let originalComponents = URLComponents(url: originalURL, resolvingAgainstBaseURL: false) else { return nil }
                return originalComponents.queryItems?.first(where: { $0.name == "acl:consumerKey" })?.value
            }()
            
            if let consumerKey = consumerKey {
                // Replace existing consumerKey if it exists, otherwise add it
                if let existingIndex = components.queryItems?.firstIndex(where: { $0.name == "acl:consumerKey" }) {
                    components.queryItems?[existingIndex].value = consumerKey
                } else {
                    components.queryItems?.append(URLQueryItem(name: "acl:consumerKey", value: consumerKey))
                }
            }
            
            // MARK: - New Request Creation
            // Create new request with updated URL containing consumer key
            if let newURL = components.url {
                var newRequest = request
                newRequest.url = newURL
                completionHandler(newRequest)
                return
            }
        }
        
        // MARK: - Fallback Handling
        // Fallback to original request if URL modification fails
        completionHandler(request)
    }

    // MARK: - Common Request Configuration
    // Common function to configure request headers
    private func configureRequest(_ request: inout URLRequest, consumerKey: String, conditionalHeaders: (etag: String?, lastModified: String?)? = nil) {
        request.setValue(consumerKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let headers = conditionalHeaders {
            if let etag = headers.etag {
                request.setValue(etag, forHTTPHeaderField: "If-None-Match")
            }
            if let lastModified = headers.lastModified {
                request.setValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
            }
        }
    }
    
    // MARK: - Common Cache Metadata Creation
    // Common function to create cache metadata from response
    private func createCacheMeta(from response: URLResponse) -> CacheMeta {
        let httpResponse = response as? HTTPURLResponse
        return CacheMeta(
            eTag: httpResponse?.value(forHTTPHeaderField: "ETag"),
            lastModified: httpResponse?.value(forHTTPHeaderField: "Last-Modified"),
            downloadedAt: Date()
        )
    }

    // MARK: - Data Fetching with Cache Management
    /// Return cached data if available, and check for updates in the background. If updated, return new data.
    /// Implements efficient caching strategy using ETag and Last-Modified headers.
    func fetchWithUpdateIfNeeded(source: ODPTSource, consumerKey: String) async throws -> (data: Data, updated: Bool) {
        let cached = cache.loadData(for: source.cacheFile)
        let meta = cache.loadMeta(for: source.metaFile)

        // MARK: - Step 1: Cache Validation
        // Check ETag / Last-Modified with HEAD request for cache validation
        var headReq = URLRequest(url: source.url(consumerKey: consumerKey))
        headReq.httpMethod = "HEAD"
        let headResp: HTTPURLResponse?
        do {
            let (_, resp) = try await session.data(for: headReq)
            headResp = resp as? HTTPURLResponse
        } catch {
            headResp = nil
        }
        let serverETag = headResp?.value(forHTTPHeaderField: "ETag")
        let serverLastMod = headResp?.value(forHTTPHeaderField: "Last-Modified")

        // MARK: - Step 2: Cache Hit Check
        // If data unchanged, return cached data immediately
        if let cached = cached, let meta = meta {
            if (serverETag != nil && serverETag == meta.eTag) ||
               (serverETag == nil && serverLastMod != nil && serverLastMod == meta.lastModified) {
                return (cached, false)
            }
        }

        // MARK: - Step 3: Conditional Update
        // If changes detected, send GET with conditional headers for efficient updates
        var getReq = URLRequest(url: source.url(consumerKey: consumerKey))
        configureRequest(&getReq, consumerKey: consumerKey, conditionalHeaders: (meta?.eTag, meta?.lastModified))

        // MARK: - Step 4: Data Retrieval and Caching
        // Execute GET request with conditional headers
        let (data, resp) = try await session.data(for: getReq)
        if let http = resp as? HTTPURLResponse, http.statusCode == 304, let cached = cached {
            return (cached, false)
        }

        // Cache new data and metadata
        cache.saveData(data, for: source.cacheFile)
        cache.saveMeta(createCacheMeta(from: resp), for: source.metaFile)
        return (data, true)
    }

    // MARK: - Simple Data Fetching
    // Fetch data for the first time or when cache is empty.
    // No conditional headers - always downloads fresh data.
    func fetchSimple(source: ODPTSource, consumerKey: String) async throws -> Data {
        var request = URLRequest(url: source.url(consumerKey: consumerKey))
        configureRequest(&request, consumerKey: consumerKey)
        
        let (data, resp) = try await session.data(for: request)
        
        // MARK: - Data Caching
        // Cache the downloaded data and metadata
        cache.saveData(data, for: source.cacheFile)
        cache.saveMeta(createCacheMeta(from: resp), for: source.metaFile)
        return data
    }

    // MARK: - Cache Access
    // Load cached data without network requests.
    func loadCached(source: ODPTSource) -> Data? { cache.loadData(for: source.cacheFile) }
    
    // Load cached data by custom key
    func loadCachedData(for key: String) -> Data? { cache.loadData(for: key) }
    
    // MARK: - Date Extraction Helper
    // Common function to extract latest date from JSON data
    private func extractLatestDate(from data: Data) -> String? {
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            return json?.compactMap { $0["dc:date"] as? String }.max()
        } catch {
            print("Error extracting date: \(error)")
            return nil
        }
    }
    
    // MARK: - Local Date Extraction Helper
    // Common function to extract latest date from local files
    private func extractLocalLatestDate(for source: ODPTSource) -> String? {
        let fileName = source.cacheFile.replacingOccurrences(of: "odpt_", with: "").replacingOccurrences(of: ".json", with: "")
        
        // First try Documents directory for updated files
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let lineDataPath = documentsPath.appendingPathComponent("LineData", isDirectory: true)
        let updatedFileName = fileName + "_updated.json"
        let documentsURL = lineDataPath.appendingPathComponent(updatedFileName)
        
        if let data = try? Data(contentsOf: documentsURL) {
            return extractLatestDate(from: data)
        }
        
        // Fallback to Bundle.main for original files
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return extractLatestDate(from: data)
    }
    
    // MARK: - Date-based Update Check
    // Check if data needs to be updated based on dc:date comparison
    func checkForDateUpdates(source: ODPTSource, consumerKey: String) async throws -> Bool {
        do {
            // Fetch minimal data from API for date comparison
            let (data, _) = try await session.data(from: source.url(consumerKey: consumerKey))
            
            // Extract latest date from API
            guard let apiLatestDate = extractLatestDate(from: data) else {
                throw ODPTError.dateExtractionFailed
            }
            
            // Get local latest date
            guard let localLatestDate = extractLocalLatestDate(for: source) else {
                return true // No local data, update needed
            }
            
            // Compare dates
            return apiLatestDate > localLatestDate
            
        } catch {
            throw ODPTError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Common Update Processing
    // Common function to process updates for a source
    private func processUpdate(for source: ODPTSource, consumerKey: String) async throws -> (data: Data, updated: Bool) {
        let needsUpdate = try await checkForDateUpdates(source: source, consumerKey: consumerKey)
        if needsUpdate {
            // Fetch full data from API
            let (data, _) = try await session.data(from: source.url(consumerKey: consumerKey))
            
            // Write updated data to JSON file
            try await writeDataToFile(data: data, for: source)
            
            // Update cache
            cache.saveData(data, for: source.cacheFile)
            let meta = CacheMeta(
                eTag: nil,
                lastModified: nil,
                downloadedAt: Date()
            )
            cache.saveMeta(meta, for: source.metaFile)
            
            print("Successfully updated \(source.displayName) data and wrote to JSON file")
            return (data, true)
        } else {
            print("No update needed for \(source.displayName) data")
            return (Data(), false)
        }
    }
    
    // MARK: - Unified Update Check
    // Check for updates across all data sources
    func checkAllForUpdates(consumerKey: String) async -> [ODPTSource: Bool] {
        return await withTaskGroup(of: (ODPTSource, Bool).self) { group in
            for source in ODPTSource.allCases {
                group.addTask {
                    do {
                        let needsUpdate = try await self.checkForDateUpdates(source: source, consumerKey: consumerKey)
                        print("\(source.displayName): \(needsUpdate ? "Update needed" : "No update needed")")
                        return (source, needsUpdate)
                    } catch {
                        print("Error checking updates for \(source.displayName): \(error)")
                        return (source, false)
                    }
                }
            }
            
            var results: [ODPTSource: Bool] = [:]
            for await (source, needsUpdate) in group {
                results[source] = needsUpdate
            }
            return results
        }
    }
    
    // MARK: - Update Single Source
    // Update a single data source if needed
    func updateSingleSource(_ source: ODPTSource, consumerKey: String) async -> Result<Void, Error> {
        do {
            let (_, _) = try await processUpdate(for: source, consumerKey: consumerKey)
            return .success(())
        } catch {
            print("Failed to update \(source.displayName) data: \(error)")
            return .failure(error)
        }
    }
    
    // MARK: - Perform Updates
    // Perform updates for all sources that need them and write to JSON files
    func performUpdates(consumerKey: String) async -> [ODPTSource: Result<Void, Error>] {
        return await withTaskGroup(of: (ODPTSource, Result<Void, Error>).self) { group in
            for source in ODPTSource.allCases {
                group.addTask {
                    do {
                        let (_, _) = try await self.processUpdate(for: source, consumerKey: consumerKey)
                        return (source, .success(()))
                    } catch {
                        print("Failed to update \(source.displayName) data: \(error)")
                        return (source, .failure(error))
                    }
                }
            }
            
            var results: [ODPTSource: Result<Void, Error>] = [:]
            for await (source, result) in group {
                results[source] = result
            }
            return results
        }
    }
    
    // MARK: - Write Data to JSON File
    // Write downloaded data to local JSON file in Documents directory
    private func writeDataToFile(data: Data, for source: ODPTSource) async throws {
        // Get Documents directory path for writable JSON files
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let lineDataPath = documentsPath.appendingPathComponent("LineData", isDirectory: true)
        
        // Create LineData directory if it doesn't exist
        try FileManager.default.createDirectory(at: lineDataPath, withIntermediateDirectories: true, attributes: nil)
        
        // Determine the target file name based on source
        let fileName: String
        switch source {
        case .railways:
            fileName = "railways_updated.json"
        case .busRoutes:
            fileName = "yokohamabus_updated.json"
        }
        
        let fileURL = lineDataPath.appendingPathComponent(fileName)
        
        // Write data to file with atomic operation
        try data.write(to: fileURL, options: [.atomic])
        print("Successfully wrote \(source.displayName) data to \(fileName) in Documents directory")
    }

    // MARK: - Individual Operator Data Fetching
    // Fetch data for individual transportation operators using their specific API endpoints
    func fetchIndividualOperatorData(_ transportOperator: LocalDataSource, consumerKey: String) async throws -> Data {
                    let urlString = transportOperator.lineInfomationLink
        guard let url = URL(string: urlString) else {
            throw ODPTError.invalidData
        }
        
        var request = URLRequest(url: url)
        configureRequest(&request, consumerKey: consumerKey)
        
        let (data, response) = try await session.data(for: request)
        
        // Check for successful response
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw ODPTError.networkError("HTTP \(httpResponse.statusCode)")
            }
        }
        
        return data
    }
    
    // MARK: - All Operators Data Fetching
    // Fetch data for all 22 transportation operators
    func fetchAllOperatorsData(consumerKey: String) async -> [LocalDataSource: Result<Data, Error>] {
        return await withTaskGroup(of: (LocalDataSource, Result<Data, Error>).self) { group in
            for transportOperator in LocalDataSource.allCases {
                group.addTask {
                    do {
                        let data = try await self.fetchIndividualOperatorData(transportOperator, consumerKey: consumerKey)
                        print("✅ Successfully fetched data for \(transportOperator.displayName)")
                        return (transportOperator, .success(data))
                    } catch {
                        print("❌ Failed to fetch data for \(transportOperator.displayName): \(error)")
                        return (transportOperator, .failure(error))
                    }
                }
            }
            
            var results: [LocalDataSource: Result<Data, Error>] = [:]
            for await (transportOperator, result) in group {
                results[transportOperator] = result
            }
            return results
        }
    }
    
    // MARK: - ETag Management Helper Methods
    // Helper methods for efficient ETag management
    
    /// Get ETag for a specific operator from UserDefaults
    private func getETag(for transportOperator: LocalDataSource) -> String? {
        let etagKey = "\(transportOperator.fileName)_etag"
        return UserDefaults.standard.string(forKey: etagKey)
    }
    
    /// Save ETag for a specific operator to UserDefaults
    private func saveETag(_ etag: String, for transportOperator: LocalDataSource) {
        let etagKey = "\(transportOperator.fileName)_etag"
        UserDefaults.standard.set(etag, forKey: etagKey)
        print("💾 \(transportOperator.displayName): Saved ETag: \(etag)")
    }
    
    /// Get Last-Modified for a specific operator from UserDefaults
    private func getLastModified(for transportOperator: LocalDataSource) -> String? {
        let lastModifiedKey = "\(transportOperator.fileName)_last_modified"
        return UserDefaults.standard.string(forKey: lastModifiedKey)
    }
    
    /// Save Last-Modified for a specific operator to UserDefaults
    private func saveLastModified(_ lastModified: String, for transportOperator: LocalDataSource) {
        let lastModifiedKey = "\(transportOperator.fileName)_last_modified"
        UserDefaults.standard.set(lastModified, forKey: lastModifiedKey)
        print("💾 \(transportOperator.displayName): Saved Last-Modified: \(lastModified)")
    }
    
    // MARK: - Conditional GET Request Check (ODPT API Optimized)
    // Check if individual operator data needs updating using conditional GET requests
    func checkIndividualOperatorForUpdates(_ transportOperator: LocalDataSource, consumerKey: String) async throws -> Bool {
        
        // MARK: - Cache-Based Update Check
        // Check if we have cached data and its age
        let cacheKey = transportOperator.fileName
        
        // MARK: - Conditional GET Request Check
        // Use conditional GET request with ETag and Last-Modified headers
        do {
            let urlString = transportOperator.lineInfomationLink
            guard let url = URL(string: urlString) else {
                throw ODPTError.invalidData
            }
            
            var request = URLRequest(url: url)
            configureRequest(&request, consumerKey: consumerKey, conditionalHeaders: (getETag(for: transportOperator), getLastModified(for: transportOperator)))
            
            // Load cached data for conditional headers and comparison
            let cachedData = cache.loadData(for: cacheKey)
            
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                
                // Handle 304 Not Modified response
                if httpResponse.statusCode == 304 {
                    print("✅ \(transportOperator.displayName): 304 Not Modified - No update needed")
                    return false // No update needed - server confirms data hasn't changed
                }
                
                // Handle 200 OK response
                if httpResponse.statusCode == 200 {
                    
                    // Get current ETag from UserDefaults
                    let currentEtag = getETag(for: transportOperator)
                    
                    // Get new ETag from response
                    let newEtag = httpResponse.value(forHTTPHeaderField: "ETag")
                    
                    // MARK: - ETag Comparison (Fast Path)
                    // If ETags match, no update is needed (fastest check)
                    if let currentEtag = currentEtag, let newEtag = newEtag, currentEtag == newEtag {
                        print("✅ \(transportOperator.displayName): ETag matches - No update needed")
                        return false // No update needed - ETag confirms no change
                    }
                    
                    // Save ETag and Last-Modified headers for future conditional requests
                    if let etag = newEtag {
                        saveETag(etag, for: transportOperator)
                    }
                    
                    if let lastModified = httpResponse.value(forHTTPHeaderField: "Last-Modified") {
                        saveLastModified(lastModified, for: transportOperator)
                    }
                    
                    // MARK: - Data Content Comparison (Fallback)
                    // Compare actual data content to determine if update is needed
                    if let cachedData = cachedData, data == cachedData {
                        print("✅ \(transportOperator.displayName): Data content is identical - No update needed")
                        return false // No update needed - content is the same
                    } else {
                        print("🔄 \(transportOperator.displayName): Data content has changed - Update needed")
                        return true // Update needed - content has changed
                    }
                } else {
                    print("❌ \(transportOperator.displayName): Unexpected response status: \(httpResponse.statusCode)")
                    return false // Don't update on error
                }
            } else {
                print("❌ \(transportOperator.displayName): Invalid HTTP response")
                return false // Don't update on error
            }
        } catch {
            print("❌ \(transportOperator.displayName): Request failed: \(error)")
            return false // Don't update on error
        }
    }
    
    // MARK: - Common Operator Update Processing
    // Common function to process operator updates
    private func processOperatorUpdate(_ transportOperator: LocalDataSource, consumerKey: String) async throws -> (data: Data, updated: Bool) {
                    let needsUpdate = try await checkIndividualOperatorForUpdates(transportOperator, consumerKey: consumerKey)
            if needsUpdate {
                print("📥 \(transportOperator.displayName): Fetching updated data...")
                let data = try await fetchIndividualOperatorData(transportOperator, consumerKey: consumerKey)
                
                // Write updated data to JSON file
                try await writeIndividualOperatorDataToFile(data: data, for: transportOperator)
                
                // Update cache with new data
                let cacheKey = transportOperator.fileName
                cache.saveData(data, for: cacheKey)
                
                print("✅ \(transportOperator.displayName): Successfully updated data (\(data.count) bytes)")
                return (data, true)
            } else {
                print("✅ \(transportOperator.displayName): No update needed")
                return (Data(), false)
            }
    }
    
    // MARK: - Railway Operators Update
    // Update only railway operators (exclude bus operators)
    func updateRailwayOperators(consumerKey: String) async -> [LocalDataSource: Bool] {
        // Filter only railway operators
        let railwayOperators = LocalDataSource.allCases.filter { $0.transportationType == .railway }
        
        return await withTaskGroup(of: (LocalDataSource, Bool).self) { group in
            for transportOperator in railwayOperators {
                group.addTask {
                    do {
                        let (_, updated) = try await self.processOperatorUpdate(transportOperator, consumerKey: consumerKey)
                        return (transportOperator, updated)
                    } catch {
                        print("❌ Failed to update \(transportOperator.displayName): \(error)")
                        return (transportOperator, false)
                    }
                }
            }
            
            var results: [LocalDataSource: Bool] = [:]
            for await (transportOperator, updated) in group {
                results[transportOperator] = updated
            }
            return results
        }
    }
    
    // MARK: - All Operators Update Check
    // Check all 22 operators for updates
    func checkAllOperatorsForUpdates(consumerKey: String) async -> [LocalDataSource: Bool] {
        return await withTaskGroup(of: (LocalDataSource, Bool).self) { group in
            for transportOperator in LocalDataSource.allCases {
                group.addTask {
                    do {
                        let needsUpdate = try await self.checkIndividualOperatorForUpdates(transportOperator, consumerKey: consumerKey)
                        return (transportOperator, needsUpdate)
                    } catch {
                        print("Error checking updates for \(transportOperator.displayName): \(error)")
                        return (transportOperator, false)
                    }
                }
            }
            
            var results: [LocalDataSource: Bool] = [:]
            for await (transportOperator, needsUpdate) in group {
                results[transportOperator] = needsUpdate
            }
            return results
        }
    }
    
    // MARK: - Individual Operator Update
    // Update individual operator data and save to Documents directory
    func updateIndividualOperator(_ transportOperator: LocalDataSource, consumerKey: String) async -> Result<Void, Error> {
        do {
            let (_, _) = try await processOperatorUpdate(transportOperator, consumerKey: consumerKey)
            return .success(())
        } catch {
            print("❌ \(transportOperator.displayName): Failed to update data: \(error)")
            return .failure(error)
        }
    }
    
    // MARK: - Write Individual Operator Data to File
    // Write individual operator data to Documents directory
    func writeIndividualOperatorDataToFile(data: Data, for transportOperator: LocalDataSource) async throws {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ODPTError.invalidData
        }
        
        let lineDataDirectory = documentsDirectory.appendingPathComponent("LineData", isDirectory: true)
        
        // Create LineData directory (will create automatically if needed)
        try fileManager.createDirectory(at: lineDataDirectory, withIntermediateDirectories: true, attributes: nil)
        
        // Use consistent file naming with LocalDataSource.fileName
        let fileName = transportOperator.fileName
        let fileURL = lineDataDirectory.appendingPathComponent(fileName)
        
        // Write data to file atomically for safety
        try data.write(to: fileURL, options: .atomicWrite)
    }
}

// MARK: - ODPT Error Types
// Custom error types for ODPT operations
enum ODPTError: Error, LocalizedError {
    case dateExtractionFailed
    case networkError(String)
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .dateExtractionFailed:
            return "Failed to extract date from API response"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidData:
            return "Invalid data structure"
        }
    }
}
