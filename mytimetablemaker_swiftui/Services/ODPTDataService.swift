//
//  ODPTDataService.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2025/08/24.
//
//  MARK: - Overview
//  Service for managing ODPT API communication and data parsing.
//  Handles data fetching, caching, and conversion from external API format.
//

import Foundation

// MARK: - ODPT Data Transfer Objects
// DTOs for handling external data formats from ODPT API.

// MARK: - ODPT Railway DTO
// DTO for railway data from ODPT API.
// Maps external JSON structure to internal data model.
struct RailwayDTO: Decodable {
    let title: String
    let sameAs: String
    let operatorCode: String?
    let lineColor: String?
    let startStation: String?
    let endStation: String?
    let destinationStation: String?
    let railwayTitle: LocalizedTitle?
    let lineCode: String?
    let date: String?

    enum CodingKeys: String, CodingKey {
        case title = "dc:title"                   // Dublin Core title
        case sameAs = "owl:sameAs"                // OWL sameAs identifier
        case operatorCode = "odpt:operator"       // Railway operator code
        case lineColor = "odpt:lineColor"         // Line color in hex format
        case startStation = "odpt:startStation"   // First station on the line
        case endStation = "odpt:endStation"       // Last station on the line
        case destinationStation = "odpt:destinationStation" // Destination station (first element from array)
        case railwayTitle = "odpt:railwayTitle"   // Multi-language line name
        case lineCode = "odpt:lineCode"           // Line identifier code
        case date = "dc:date"                     // Data update date
    }
}

// MARK: - ODPT Bus Route Pattern DTO
// DTO for bus route pattern data from ODPT API.
// Maps external JSON structure to internal bus data model.
struct BusRoutePatternDTO: Decodable {
    let title: String
    let sameAs: String
    let operatorCode: String?
    let busRoute: String?
    let pattern: String?
    let direction: String?
    let busstopPoleOrder: [BusStop]?
    let note: String?
    let date: String?

    enum CodingKeys: String, CodingKey {
        case title = "dc:title"           // Dublin Core title
        case sameAs = "owl:sameAs"        // OWL sameAs identifier
        case operatorCode = "odpt:operator"       // Bus operator code
        case busRoute = "odpt:busroute"            // Bus route identifier
        case pattern = "odpt:pattern"             // Bus route pattern
        case direction = "odpt:direction"        // Bus direction
        case busstopPoleOrder = "odpt:busstopPoleOrder"  // Bus stop sequence
        case note = "odpt:note"                   // Bus route note/description
        case date = "dc:date"                     // Data update date
    }
}

// MARK: - ODPT Data Parser
// Converts raw JSON data from ODPT API to internal TransportationLine models.
struct ODPTParser {
    
    // MARK: - Bus Data Parsing
    // Parse bus route pattern data from JSON and convert to TransportationLine objects.
    static func parseBusRoutes(_ data: Data) throws -> [TransportationLine] {
        
        // Parse JSON and filter bus route patterns
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let array = json as? [[String: Any]] else {
            throw ODPTError.invalidData
        }
        
        // Filter out railway data - only process odpt:BusroutePattern
        let busOnlyData = array.filter { item in
            if let itemType = item["@type"] as? String {
                return itemType == "odpt:BusroutePattern"
            }
            return false
        }
        
        // If no bus data found, skip it
        if busOnlyData.isEmpty {
            return []
        }
        
        // Convert filtered data back to Data for decoding
        let filteredJson = busOnlyData
        let filteredJsonData = try JSONSerialization.data(withJSONObject: filteredJson)
        
        let dec = JSONDecoder()
        let dtos = try dec.decode([BusRoutePatternDTO].self, from: filteredJsonData)
        
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
                railwayTitle: LocalizedTitle(ja: dto.title, en: englishName),
                lineCode: nil,
                lineDirection: nil,
                ascendingRailDirection: nil,
                descendingRailDirection: nil,
                busRoute: dto.busRoute,
                pattern: dto.pattern,
                busDirection: dto.direction,
                busstopPoleOrder: dto.busstopPoleOrder,
                title: dto.title
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
    static func parseRailwayRoutes(_ data: Data) throws -> [TransportationLine] {
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
                    let railwayTitle: LocalizedTitle? = {
                        guard let railwayTitleDict = element["odpt:railwayTitle"] as? [String: String] else { return nil }
                        return LocalizedTitle(
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
                    let ascendingRailDirection = element["odpt:ascendingRailDirection"] as? String
                    let descendingRailDirection = element["odpt:descendingRailDirection"] as? String
                    let lineDirection = ascendingRailDirection // Keep for backward compatibility
                    
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
                        ascendingRailDirection: ascendingRailDirection,
                        descendingRailDirection: descendingRailDirection,
                        busRoute: nil,
                        pattern: nil,
                        busDirection: nil,
                        busstopPoleOrder: nil,
                        title: nil
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
    
    // MARK: - Individual Operator Data Fetching
    // Fetch data for individual transportation operators using their specific API endpoints
    func fetchIndividualOperatorData(_ transportOperator: LocalDataSource, consumerKey: String) async throws -> Data {
        let urlString = transportOperator.apiLink(for: .line, transportationKind: transportOperator.transportationType)
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
            let urlString = transportOperator.apiLink(for: .line, transportationKind: transportOperator.transportationType)
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

