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
                lineColor: dto.lineColor,
                startStation: dto.startStation,
                endStation: dto.endStation,
                destinationStation: dto.destinationStation,
                railwayTitle: dto.railwayTitle,
                lineCode: dto.lineCode,
                lineDirection: nil,
                busRoute: nil,
                pattern: nil,
                busDirection: nil,
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
                lineColor: nil,
                startStation: nil,
                endStation: nil,
                destinationStation: nil,
                railwayTitle: RailwayTitle(ja: dto.title, en: englishName),
                lineCode: nil,
                lineDirection: nil,
                busRoute: dto.busRoute,
                pattern: dto.pattern,
                busDirection: dto.direction,
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
                return array.compactMap { element -> TransportationLine? in
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
                    let startStation = element["odpt:startStation"] as? String
                    let endStation = element["odpt:endStation"] as? String
                    
                    // MARK: - Destination Station Information
                    let destinationStation: String? = {
                        if let destinationArray = element["odpt:destinationStation"] as? [String],
                           let firstDestination = destinationArray.first {
                            return firstDestination
                        }
                        return nil
                    }()
                    
                    // MARK: - Rail Direction Information
                    let lineDirection = element["odpt:ascendingRailDirection"] as? String
                    
                    // MARK: - Line Creation
                    return TransportationLine(
                        kind: .railway,
                        name: title,
                        code: sameAs,
                        operatorCode: operatorCode,
                        lineColor: lineColor,
                        startStation: startStation,
                        endStation: endStation,
                        destinationStation: destinationStation,
                        railwayTitle: railwayTitle,
                        lineCode: lineCode,
                        lineDirection: lineDirection,
                        busRoute: nil,
                        pattern: nil,
                        busDirection: nil,
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
    
    // MARK: - Individual Operator Data Fetching
    // Fetch data for individual transportation operators using their specific API endpoints
    func fetchIndividualOperatorData(_ transportOperator: LocalDataSource, consumerKey: String) async throws -> Data {
        let urlString = transportOperator.apiLink(for: .lineInfo)
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
                        print("✅ Successfully fetched data for \(transportOperator.operatorDisplayName)")
                        return (transportOperator, .success(data))
                    } catch {
                        print("❌ Failed to fetch data for \(transportOperator.operatorDisplayName): \(error)")
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
        print("💾 \(transportOperator.operatorDisplayName): Saved ETag: \(etag)")
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
        print("💾 \(transportOperator.operatorDisplayName): Saved Last-Modified: \(lastModified)")
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
            let urlString = transportOperator.apiLink(for: .lineInfo)
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
                    print("✅ \(transportOperator.operatorDisplayName): 304 Not Modified - No update needed")
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
                        print("✅ \(transportOperator.operatorDisplayName): ETag matches - No update needed")
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
                    let dataMatches = cachedData != nil && data == cachedData!
                    print(dataMatches ? "✅ \(transportOperator.operatorDisplayName): Data content is identical - No update needed" : "🔄 \(transportOperator.operatorDisplayName): Data content has changed - Update needed")
                    return !dataMatches
                } else {
                    print("❌ \(transportOperator.operatorDisplayName): Unexpected response status: \(httpResponse.statusCode)")
                    return false // Don't update on error
                }
            } else {
                print("❌ \(transportOperator.operatorDisplayName): Invalid HTTP response")
                return false // Don't update on error
            }
        } catch {
            print("❌ \(transportOperator.operatorDisplayName): Request failed: \(error)")
            return false // Don't update on error
        }
    }
    
    // MARK: - Common Operator Update Processing
    // Common function to process operator updates
    private func processOperatorUpdate(_ transportOperator: LocalDataSource, consumerKey: String) async throws -> (data: Data, updated: Bool) {
        let needsUpdate = try await checkIndividualOperatorForUpdates(transportOperator, consumerKey: consumerKey)
            if needsUpdate {
                print("📥 \(transportOperator.operatorDisplayName): Fetching updated data...")
                let data = try await fetchIndividualOperatorData(transportOperator, consumerKey: consumerKey)
                
                // Write updated data to JSON file
                try await writeIndividualOperatorDataToFile(data: data, for: transportOperator)
                
                // Update cache with new data
                let cacheKey = transportOperator.fileName
                cache.saveData(data, for: cacheKey)
                
                print("✅ \(transportOperator.operatorDisplayName): Successfully updated data (\(data.count) bytes)")
                return (data, true)
            } else {
                print("✅ \(transportOperator.operatorDisplayName): No update needed")
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
                        print("❌ Failed to update \(transportOperator.operatorDisplayName): \(error)")
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
                        print("Error checking updates for \(transportOperator.operatorDisplayName): \(error)")
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
            print("❌ \(transportOperator.operatorDisplayName): Failed to update data: \(error)")
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
