//
//  SelectLineView.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2025/08/12.
//  View for selecting railway lines and bus routes
//  This view provides functionality to search, select, and configure transportation lines
//  including both predefined railway data from ODPT API and custom line configurations.
//  Features include multi-language support, station search, and line color customization.
//

import SwiftUI
import Combine
import Foundation

// MARK: - PreferenceKey for departure station position
// This preference key is used to track the position of the departure station input field
// for proper positioning of suggestion overlays and UI elements
struct DepartureStationPositionKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Transportation Line Model
// Core data structure representing a railway line or transportation route
// Contains all necessary information for line identification, display, and configuration
struct TransportationLine: Identifiable, Hashable {
    enum Kind: String { case railway }
    
    let id = UUID()
    let kind: Kind
    let name: String
    let code: String                // owl:sameAs - unique identifier from ODPT
    let operatorCode: String?       // odpt:operator (e.g., odpt.Operator:JR-East)
    let railwayType: String?        // odpt:railwayType (e.g., odpt:RailwayType:JR)
    let lineColor: String?          // odpt:lineColor (e.g., #000000)
    let startStation: String?       // odpt:startStation - first station on the line
    let endStation: String?         // odpt:endStation - last station on the line
    let railwayTitle: RailwayTitle? // odpt:railwayTitle - multi-language support
    let lineCode: String?           // odpt:lineCode (e.g., "線", "ライナー", etc.)
}

// MARK: - Railway Title Model
// Multi-language support structure for railway line names
// Provides localized display names based on user's language preference
struct RailwayTitle: Codable, Hashable {
    let ja: String?  // Japanese name
    let en: String?  // English name
    
    enum CodingKeys: String, CodingKey {
        case ja = "ja"
        case en = "en"
    }
    
    // Get localized railway name based on current language
    // Falls back to English if Japanese is not available, and vice versa
    func getLocalizedName() -> String {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        switch currentLanguage {
        case "ja":
            return ja ?? en ?? ""
        default:
            return en ?? ja ?? ""
        }
    }
}

// MARK: - Station Information Model
// Data structure representing a railway station
// Includes station identification, localization, and metadata
struct Station: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String?
    fileprivate let title: StationTitle?
    
    // Get localized station name based on current language
    // Provides fallback to base name if localized title is unavailable
    func getLocalizedName() -> String {
        if let title = title {
            let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            switch currentLanguage {
            case "ja":
                return title.ja ?? title.en ?? name
            default:
                return title.en ?? title.ja ?? name
            }
        }
        return name
    }
}

// MARK: - Station Title Model
// Multi-language support structure for station names
// Similar to RailwayTitle but specifically for station localization
fileprivate struct StationTitle: Codable, Hashable {
    let ja: String?  // Japanese station name
    let en: String?  // English station name
    
    enum CodingKeys: String, CodingKey {
        case ja = "ja"
        case en = "en"
    }
}

// MARK: - ODPT JSON Data Transfer Objects
// These structures represent the raw JSON data received from the ODPT API
// They are used for parsing and converting external data to our internal models

// --- ODPT JSON (Railway) ---
// DTO for railway data from ODPT API
// Maps external JSON structure to internal data model
private struct RailwayDTO: Decodable {
    let title: String
    let sameAs: String
    let operatorCode: String?
    let railwayType: String?
    let lineColor: String?
    let startStation: String?
    let endStation: String?
    let railwayTitle: RailwayTitle?
    let lineCode: String?

    enum CodingKeys: String, CodingKey {
        case title = "dc:title"           // Dublin Core title
        case sameAs = "owl:sameAs"        // OWL sameAs identifier
        case operatorCode = "odpt:operator"       // Railway operator code
        case railwayType = "odpt:railwayType"     // Type of railway (JR, private, etc.)
        case lineColor = "odpt:lineColor"         // Line color in hex format
        case startStation = "odpt:startStation"   // First station on the line
        case endStation = "odpt:endStation"       // Last station on the line
        case railwayTitle = "odpt:railwayTitle"   // Multi-language line name
        case lineCode = "odpt:lineCode"           // Line identifier code
    }
}

// MARK: - Cache Meta Information
// Metadata for cached ODPT data including ETag and last modified information
// Used for efficient cache validation and updates
private struct CacheMeta: Codable {
    var eTag: String?           // HTTP ETag for cache validation
    var lastModified: String?   // Last-Modified header value
    var downloadedAt: Date      // When the data was cached locally
}

// MARK: - ODPT Data Source Definition
// Defines the source of ODPT data and provides URL construction
// Currently supports railway data, extensible for other transportation types
private enum ODPTSource: CaseIterable {
    case railways

    // Constructs the API URL with consumer key for authentication
    func url(consumerKey: String) -> URL {
        var components = URLComponents(string: "https://api-public.odpt.org/api/v4/odpt:Railway.json")!
        components.queryItems = [URLQueryItem(name: "acl:consumerKey", value: consumerKey)]
        return components.url!
    }

    // Cache file name for storing downloaded data
    var cacheFile: String {
        return "odpt_railways.json"
    }
    
    // Metadata file name for storing cache information
    var metaFile: String {
        return "odpt_railways.meta.json"
    }
    
    // Display name for UI presentation
    var displayName: String {
        return "鉄道"
    }
}

// MARK: - File Cache Management
// Handles local storage of ODPT data and metadata
// Provides efficient data persistence and retrieval for offline access
private final class CacheStore {
    private let dir: URL
    
    init() {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        dir = base.appendingPathComponent("ODPTCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    
    // Get file path for a given filename in the cache directory
    private func path(for file: String) -> URL { dir.appendingPathComponent(file) }

    // Load cached data from file system
    func loadData(for file: String) -> Data? {
        let url = path(for: file)
        return try? Data(contentsOf: url)
    }
    
    // Save data to cache with atomic write for data integrity
    func saveData(_ data: Data, for file: String) {
        let url = path(for: file)
        try? data.write(to: url, options: [.atomic])
    }

    // Load cache metadata for validation and update checking
    func loadMeta(for file: String) -> CacheMeta? {
        guard let data = loadData(for: file) else { return nil }
        return try? JSONDecoder().decode(CacheMeta.self, from: data)
    }
    
    // Save cache metadata for tracking data freshness
    func saveMeta(_ meta: CacheMeta, for file: String) {
        let data = try? JSONEncoder().encode(meta)
        if let data { saveData(data, for: file) }
    }
}

// MARK: - ODPT Network Client
// Handles HTTP communication with the ODPT API
// Manages authentication, caching, and data retrieval
private final class ODPTNetworkClient: NSObject, URLSessionDelegate {
    private var session: URLSession!
    private let cache = CacheStore()
    
    override init() {
        super.init()
        
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
    // Handle HTTP redirects while preserving authentication parameters
    // Ensures consumer key is maintained across redirect chains
    private func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        // Add consumerKey to the redirected URL to maintain authentication
        if var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
            if components.queryItems == nil {
                components.queryItems = []
            }
            
            // Get consumerKey from the original request
            if let originalURL = task.originalRequest?.url,
               let originalComponents = URLComponents(url: originalURL, resolvingAgainstBaseURL: false),
               let consumerKey = originalComponents.queryItems?.first(where: { $0.name == "acl:consumerKey" })?.value {
                
                // Replace existing consumerKey if it exists, otherwise add it
                if let existingIndex = components.queryItems?.firstIndex(where: { $0.name == "acl:consumerKey" }) {
                    components.queryItems?[existingIndex].value = consumerKey
                } else {
                    components.queryItems?.append(URLQueryItem(name: "acl:consumerKey", value: consumerKey))
                }
            }
            
            // Create new request with updated URL containing consumer key
            if let newURL = components.url {
                var newRequest = request
                newRequest.url = newURL
                completionHandler(newRequest)
                return
            }
        }
        
        // Fallback to original request if URL modification fails
        completionHandler(request)
    }

    // MARK: - Data Fetching with Cache Management
    /// Return cached data if available, and check for updates in the background. If updated, return new data.
    /// Implements efficient caching strategy using ETag and Last-Modified headers
    func fetchWithUpdateIfNeeded(source: ODPTSource, consumerKey: String) async throws -> (data: Data, updated: Bool) {
        let cached = cache.loadData(for: source.cacheFile)
        let meta = cache.loadMeta(for: source.metaFile)

        // Step 1: Check ETag / Last-Modified with HEAD request for cache validation
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

        // Step 2: If data unchanged, return cached data immediately
        if let cached, let meta {
            if (serverETag != nil && serverETag == meta.eTag) ||
               (serverETag == nil && serverLastMod != nil && serverLastMod == meta.lastModified) {
                return (cached, false)
            }
        }

        // Step 3: If changes detected, send GET with conditional headers for efficient updates
        var getReq = URLRequest(url: source.url(consumerKey: consumerKey))
        if let meta {
            // Add conditional headers for efficient updates
            if let et = meta.eTag { getReq.setValue(et, forHTTPHeaderField: "If-None-Match") }
            if let lm = meta.lastModified { getReq.setValue(lm, forHTTPHeaderField: "If-Modified-Since") }
        }

        // Execute GET request with conditional headers
        let (data, resp) = try await session.data(for: getReq)
        if let http = resp as? HTTPURLResponse, http.statusCode == 304, let cached {
            // Server returned 304 Not Modified - use cached data
            return (cached, false)
        }

        // Step 4: Cache new data and metadata
        cache.saveData(data, for: source.cacheFile)
        let newMeta = CacheMeta(
            eTag: (resp as? HTTPURLResponse)?.value(forHTTPHeaderField: "ETag"),
            lastModified: (resp as? HTTPURLResponse)?.value(forHTTPHeaderField: "Last-Modified"),
            downloadedAt: Date()
        )
        cache.saveMeta(newMeta, for: source.metaFile)
        return (data, true)
    }

    // MARK: - Simple Data Fetching
    // Fetch data for the first time or when cache is empty
    // No conditional headers - always downloads fresh data
    func fetchSimple(source: ODPTSource, consumerKey: String) async throws -> Data {
        let (data, resp) = try await session.data(from: source.url(consumerKey: consumerKey))
        
        // Cache the downloaded data and metadata
        cache.saveData(data, for: source.cacheFile)
        let meta = CacheMeta(
            eTag: (resp as? HTTPURLResponse)?.value(forHTTPHeaderField: "ETag"),
            lastModified: (resp as? HTTPURLResponse)?.value(forHTTPHeaderField: "Last-Modified"),
            downloadedAt: Date()
        )
        cache.saveMeta(meta, for: source.metaFile)
        return data
    }

    // MARK: - Cache Access
    // Load cached data without network requests
    func loadCached(source: ODPTSource) -> Data? { cache.loadData(for: source.cacheFile) }
}

// MARK: - String Normalization Utilities
// Improves search hit rate by normalizing text input
// Handles variations in Japanese characters and fullwidth/halfwidth differences
private extension String {
    var normalizedForSearch: String {
        var s = self.trimmingCharacters(in: .whitespacesAndNewlines)
        // Absorb variations in katakana and fullwidth characters (adjust as needed)
        if let t = s.applyingTransform(.hiraganaToKatakana, reverse: false) { s = t }
        if let t = s.applyingTransform(.fullwidthToHalfwidth, reverse: false) { s = t }
        return s.lowercased()
    }

    /// Extract the last component from ODPT identifiers
    /// Example: odpt:Operator:JR-East → JR-East
    var odptTail: String { self.components(separatedBy: ":").last ?? self }
}

// MARK: - ODPT Data Parser
// Converts raw JSON data from ODPT API to internal TransportationLine models
private struct ODPTParser {
    // Parse railway data from JSON and convert to TransportationLine objects
    static func parseRailways(_ data: Data) throws -> [TransportationLine] {
        let dec = JSONDecoder()
        let dtos = try dec.decode([RailwayDTO].self, from: data)
        
        // Map DTOs to internal models
        return dtos.map {
            TransportationLine(
                kind: .railway,
                name: $0.title,
                code: $0.sameAs,
                operatorCode: $0.operatorCode,
                railwayType: $0.railwayType,
                lineColor: $0.lineColor,
                startStation: $0.startStation,
                endStation: $0.endStation,
                railwayTitle: $0.railwayTitle,
                lineCode: $0.lineCode
            )
        }
    }
}

// MARK: - Local Data Source Definition
// Defines available local JSON data files for offline operation
// Provides fallback data when ODPT API is unavailable
private enum LocalDataSource: CaseIterable {
    case jrEast        // JR East railway lines
    case keikyu        // Keikyu railway lines
    case tokyoMetro    // Tokyo Metro subway lines
    case toeiMetro     // Toei subway lines
    case odakyu        // Odakyu railway lines
    case yurikamome    // Yurikamome automated transit system
    case rinkai        // Rinkai Line
    case seibu         // Seibu Railway
    case sotetsu       // Sotetsu Railway
    case tama          // Tama Monorail
    case tobu          // Tobu Railway
    case tokyu         // Tokyu Railway 
    case tsukuba       // Tsukuba Express
    case yokohamaMetro // Yokohama Municipal Subway
    
    // Get the filename for each data source
    var fileName: String {
        switch self {
        case .jrEast: return "jreast.json"
        case .keikyu: return "keikyu.json"
        case .tokyoMetro: return "tokyometro.json"
        case .toeiMetro: return "toeimetro.json"
        case .odakyu: return "odakyu.json"
        case .yurikamome: return "yurikamome.json"
        case .rinkai: return "rinkai.json"
        case .seibu: return "seibu.json"
        case .sotetsu: return "sotetsu.json"
        case .tama: return "tama.json"
        case .tobu: return "tobu.json"
        case .tokyu: return "tokyu.json"
        case .tsukuba: return "tsukuba.json"
        case .yokohamaMetro: return "yokohamametro.json"
        }
    }
    
    // Get localized display name for UI presentation
    var displayName: String {
        switch self {
        case .jrEast: return "JR東日本"
        case .keikyu: return "京急電鉄"
        case .tokyoMetro: return "東京メトロ"
        case .toeiMetro: return "都営地下鉄"
        case .odakyu: return "小田急電鉄"
        case .yurikamome: return "ゆりかもめ"
        case .rinkai: return "東京臨海高速鉄道"
        case .seibu: return "西武鉄道"
        case .sotetsu: return "相模鉄道"
        case .tama: return "多摩都市モノレール"
        case .tobu: return "東武鉄道"
        case .tokyu: return "東急電鉄"
        case .tsukuba: return "首都圏新都市鉄道"
        case .yokohamaMetro: return "横浜市営地下鉄"
        }
    }
    
    // Get ODPT operator code for API queries and data matching
    var operatorCode: String {
        switch self {
        case .jrEast: return "odpt.Operator:JR-East"
        case .keikyu: return "odpt.Operator:Keikyu"
        case .tokyoMetro: return "odpt.Operator:TokyoMetro"
        case .toeiMetro: return "odpt.Operator:Toei"
        case .odakyu: return "odpt.Operator:Odakyu"
        case .yurikamome: return "odpt.Operator:Yurikamome"
        case .rinkai: return "odpt.Operator:TWR"
        case .seibu: return "odpt.Operator:Seibu"
        case .sotetsu: return "odpt.Operator:Sotetsu"
        case .tama: return "odpt.Operator:TamaMonorail"
        case .tobu: return "odpt.Operator:Tobu"
        case .tokyu: return "odpt.Operator:Tokyu"
        case .tsukuba: return "odpt.Operator:MIR"
        case .yokohamaMetro: return "odpt.Operator:YokohamaMunicipal"
        }
    }
}

// MARK: - Local File Data Transfer Objects
// These structures represent the local JSON data files
// They provide offline data when ODPT API is unavailable

// --- Local Railway DTO ---
// Line data structure for local JSON files
// Similar to RailwayDTO but with local-specific field mappings
private struct LocalRailwayDTO: Decodable {
    let title: String
    let sameAs: String
    let operatorCode: String?
    let lineColor: String?
    let stationOrder: [StationOrder]?
    let railwayTitle: RailwayTitle?
    let lineCode: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "dc:title"           // Dublin Core title
        case sameAs = "owl:sameAs"        // OWL sameAs identifier
        case operatorCode = "odpt:operator"       // Railway operator code
        case lineColor = "odpt:color"             // Line color (local format)
        case stationOrder = "odpt:stationOrder"   // Station sequence on the line
        case railwayTitle = "odpt:railwayTitle"   // Multi-language line name
        case lineCode = "odpt:lineCode"           // Line identifier code
    }
}

// --- Local Station DTO ---
// Station data structure for local JSON files (JR East Japan specific)
// Contains station information and ordering within railway lines
private struct LocalStationDTO: Decodable {
    let title: String
    let sameAs: String
    let operatorCode: String?
    let lineColor: String?
    let stationOrder: [StationOrder]?
    let railwayTitle: RailwayTitle?
    let lineCode: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "dc:title"           // Dublin Core title
        case sameAs = "owl:sameAs"        // OWL sameAs identifier
        case operatorCode = "odpt:operator"       // Railway operator code
        case lineColor = "odpt:color"             // Line color (local format)
        case stationOrder = "odpt:stationOrder"   // Station sequence on the line
        case railwayTitle = "odpt:railwayTitle"   // Multi-language line name
        case lineCode = "odpt:lineCode"           // Line identifier code
    }
}

// MARK: - Station Order Information
// Represents the sequence and metadata of stations within a railway line
private struct StationOrder: Decodable {
    let index: Int                    // Position of station in the line sequence
    let station: String               // Station identifier
    let stationTitle: StationTitle?   // Multi-language station name
    
    enum CodingKeys: String, CodingKey {
        case index = "odpt:index"         // Station order index
        case station = "odpt:station"     // Station identifier
        case stationTitle = "odpt:stationTitle"  // Localized station name
    }
}

// MARK: - Parser Error Definitions
// Custom error types for data parsing failures
private enum ODPTParserError: Error {
    case invalidDataStructure
}

// MARK: - Local File Parser
// Handles parsing of local JSON data files
// Supports multiple data formats and provides fallback parsing strategies
private struct LocalFileParser {
    // Parse local data from various sources and formats
    // Automatically detects data type and applies appropriate parsing strategy
    static func parseLocalData(from source: LocalDataSource, data: Data) -> [TransportationLine] {
        // Use already loaded data
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            return []
        }
                
        // Determine the type of data by examining the first item
        if let array = json as? [[String: Any]], let firstItem = array.first {
            let type = firstItem["@type"] as? String ?? ""
    
            // Process based on data type
            switch type {
            case "odpt:Railway":
                // Standard railway data format
                let result = parseRailwaysFromArray(array, source: source)
                return result
            case "odpt:Station":
                // Station data format (e.g., JR East Japan)
                let result = parseStationsToLines(array, source: source)
                return result
            default:
                // Fallback parsing when type is not explicitly specified
                // Try processing as railway data
                if let _ = firstItem["dc:title"], let _ = firstItem["odpt:operator"] {
                    let result = parseRailwaysFromArray(array, source: source)
                    return result
                }
                
                // Try processing as station data
                if let _ = firstItem["title"] as? [String: Any] {
                    let result = parseStationsToLines(array, source: source)
                    return result
                }
                
                // If other formats are used, process based on key existence
                if firstItem.keys.contains("dc:title") || firstItem.keys.contains("odpt:operator") {
                    let result = parseRailwaysFromArray(array, source: source)            
                    return result
                }
                
                return []
            }
        }
    
        return []
    }
        
    // MARK: - Station Data to Line Conversion
    // Extract line information from station data (for JR East Japan)
    // Converts station-centric data to line-centric TransportationLine objects
    private static func parseStationsToLines(_ array: [[String: Any]], source: LocalDataSource) -> [TransportationLine] {
        var lines: [TransportationLine] = []
        var seenLines = Set<String>() // For duplicate removal
    
        for element in array {
            // Get line name from multiple possible fields
            var lineName: String?
            
            // Get line name from title field (local format)
            if let title = element["title"] as? [String: Any] {
                lineName = title["ja"] as? String ?? title["en"] as? String
            }
            
            // Get line name from dc:title field (standard format)
            if lineName == nil || lineName!.isEmpty {
                lineName = element["dc:title"] as? String
            }
            
            // Get line name from odpt:railwayTitle field (ODPT format)
            if lineName == nil || lineName!.isEmpty {
                if let railwayTitle = element["odpt:railwayTitle"] as? [String: Any] {
                    lineName = railwayTitle["ja"] as? String ?? railwayTitle["en"] as? String
                }
            }
            
            // Get line code for additional identification
            let lineCode = element["odpt:lineCode"] as? String
            
            // Get operator code from various possible formats
            var operatorCode: String?
            if let operatorValue = element["odpt:operator"] as? String {
                operatorCode = operatorValue
            } else if let operatorArray = element["odpt:operator"] as? [String] {
                operatorCode = operatorArray.first
            }
            
            // Get line color from multiple possible fields
            let lineColor = element["odpt:color"] as? String ?? element["odpt:lineColor"] as? String
            
            // Multi-language support for railway titles
            var railwayTitle: RailwayTitle? = nil
            if let railwayTitleDict = element["odpt:railwayTitle"] as? [String: String] {
                railwayTitle = RailwayTitle(
                    ja: railwayTitleDict["ja"],
                    en: railwayTitleDict["en"]
                )
            }
            
            // Add line if there is a valid line name
            if let name = lineName, !name.isEmpty {
                // Check for duplicates (combination of line name and operator code)
                let duplicateKey = "\(operatorCode ?? "")_\(name)"
                if seenLines.contains(duplicateKey) {
                    continue
                }
                seenLines.insert(duplicateKey)
                
                let line = TransportationLine(
                    kind: .railway,
                    name: name,
                    code: element["owl:sameAs"] as? String ?? "",
                    operatorCode: operatorCode ?? source.operatorCode,
                    railwayType: element["odpt:railwayType"] as? String,
                    lineColor: lineColor,
                    startStation: nil,
                    endStation: nil,
                    railwayTitle: railwayTitle,
                    lineCode: lineCode
                )
                lines.append(line)
                
        
            }
        }
        

        return lines
    }
    
    // Function to process railway data from array
    private static func parseRailwaysFromArray(_ array: [[String: Any]], source: LocalDataSource) -> [TransportationLine] {
        var lines: [TransportationLine] = []
        var seenLines = Set<String>() // For duplicate removal
            
        for element in array {
            // Get line name from multiple fields
            var lineName: String?
            var sameAs: String?
            
            // Get line name from dc:title field (standard format)
            if let title = element["dc:title"] as? String {
                lineName = title
            }
            
            // Get line name from odpt:railwayTitle field (Japanese priority)
            if lineName == nil || lineName!.isEmpty {
                if let railwayTitle = element["odpt:railwayTitle"] as? [String: Any] {
                    lineName = railwayTitle["ja"] as? String ?? railwayTitle["en"] as? String
                }
            }
            
            // Get line name from title field (for JR East Japan format)
            if lineName == nil || lineName!.isEmpty {
                if let title = element["title"] as? [String: Any] {
                    lineName = title["ja"] as? String ?? title["en"] as? String
                }
            }
            
            // Get sameAs value for unique identification
            if let sameAsValue = element["owl:sameAs"] as? String {
                sameAs = sameAsValue
            }
            
            // Get operator code from various possible formats
            var operatorCode: String?
            if let operatorValue = element["odpt:operator"] as? String {
                operatorCode = operatorValue
            } else if let operatorArray = element["odpt:operator"] as? [String] {
                operatorCode = operatorArray.first
            }
            
            // Get line color from multiple possible fields
            let lineColor = element["odpt:color"] as? String ?? element["odpt:lineColor"] as? String
            
            // Get line code for additional identification
            let lineCode = element["odpt:lineCode"] as? String
            
            // Get start and end stations for line boundaries
            let startStation = element["odpt:startStation"] as? String
            let endStation = element["odpt:endStation"] as? String
            
            // Multi-language support for railway titles
            var railwayTitle: RailwayTitle? = nil
            if let railwayTitleDict = element["odpt:railwayTitle"] as? [String: String] {
                railwayTitle = RailwayTitle(
                    ja: railwayTitleDict["ja"],
                    en: railwayTitleDict["en"]
                )
            }
            
            // Add line if there is a valid line name
            if let name = lineName, !name.isEmpty {
                // Check for duplicates (combination of line name and operator code)
                let duplicateKey = "\(operatorCode ?? "")_\(name)"
                if seenLines.contains(duplicateKey) {
                    continue
                }
                seenLines.insert(duplicateKey)
                
                // Create TransportationLine object from parsed data
                let line = TransportationLine(
                    kind: .railway,
                    name: name,
                    code: sameAs ?? "",
                    operatorCode: operatorCode ?? source.operatorCode,
                    railwayType: element["odpt:railwayType"] as? String,
                    lineColor: lineColor,
                    startStation: startStation,
                    endStation: endStation,
                    railwayTitle: railwayTitle,
                    lineCode: lineCode
                )
                lines.append(line)
            }
        }
    
        return lines
    }
    
    // MARK: - Direct Railway Data Parsing
    // Parse line data directly (for Keikyu, Tokyo Metro, Toei Subway, and JR East Japan)
    // Optimized parsing for standard railway data format
    static func parseRailways(_ data: Data, source: LocalDataSource) throws -> [TransportationLine] {
        // Check structure of JSON for confirmation
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        if let array = json as? [[String: Any]] {
            // Extract line information using dictionary for efficient processing
            var railwayLines: [String: (name: String, operatorCode: String, lineColor: String?, railwayTitle: RailwayTitle?, lineCode: String?, startStation: String?, endStation: String?)] = [:]
            
            for element in array {
                // Validate required fields for railway data
                if let title = element["dc:title"] as? String,
                   let sameAs = element["owl:sameAs"] as? String {
                    
                    let operatorCode = element["odpt:operator"] as? String ?? source.operatorCode
                    let lineColor = element["odpt:color"] as? String
                    let lineCode = element["odpt:lineCode"] as? String
                    
                    // Process odpt:railwayTitle for multi-language support
                    var railwayTitle: RailwayTitle? = nil
                    if let railwayTitleDict = element["odpt:railwayTitle"] as? [String: String] {
                        railwayTitle = RailwayTitle(
                            ja: railwayTitleDict["ja"],
                            en: railwayTitleDict["en"]
                        )
                    }
                    
                    // Get start and end stations for line boundaries
                    var startStation: String? = nil
                    var endStation: String? = nil
                    
                    // First, check directly for start and end stations
                    if let directStart = element["odpt:startStation"] as? String {
                        startStation = directStart
                    }
                    if let directEnd = element["odpt:endStation"] as? String {
                        endStation = directEnd
                    }
                                        
                    // Store line information using sameAs as unique key
                    if railwayLines[sameAs] == nil {
                        railwayLines[sameAs] = (name: title, operatorCode: operatorCode, lineColor: lineColor, railwayTitle: railwayTitle, lineCode: lineCode, startStation: startStation, endStation: endStation)
                    }
                }
            }
            
            // Convert line information to TransportationLine objects
            let result = railwayLines.map { sameAs, info in
                TransportationLine(
                    kind: .railway,
                    name: info.name,
                    code: sameAs,
                    operatorCode: info.operatorCode,
                    railwayType: nil,
                    lineColor: info.lineColor,
                    startStation: info.startStation,
                    endStation: info.endStation,
                    railwayTitle: info.railwayTitle,
                    lineCode: info.lineCode
                )
            }
            
            return result
        } else {
            // Try old method as well
            do {
                let dec = JSONDecoder()
                let dtos = try dec.decode([LocalRailwayDTO].self, from: data)
                return dtos.map {
                    TransportationLine(
                        kind: .railway,
                        name: $0.title,
                        code: $0.sameAs,
                        operatorCode: $0.operatorCode ?? source.operatorCode,
                        railwayType: nil,
                        lineColor: $0.lineColor,
                        startStation: $0.stationOrder?.first?.stationTitle?.ja,
                        endStation: $0.stationOrder?.last?.stationTitle?.ja,
                        railwayTitle: $0.railwayTitle,
                        lineCode: $0.lineCode
                    )
                }
            } catch {
                throw error
            }
        }
    }
}

// MARK: - Local File Loader
// Manages loading of local JSON data files from the app bundle
// Provides offline data access when ODPT API is unavailable
private final class LocalFileLoader {
    // Load all available local data sources and combine results
    static func loadLocalData() -> [TransportationLine] {
        var allLines: [TransportationLine] = []
        var fileStats: [String: Int] = [:]
        
        // Process each available data source
        for source in LocalDataSource.allCases {
            if let data = loadFileData(for: source.fileName) {
                // Parse data using appropriate parser for the source
                let lines = LocalFileParser.parseLocalData(from: source, data: data)
                allLines.append(contentsOf: lines)
                fileStats[source.displayName] = lines.count
            } else {
                // Mark source as unavailable
                fileStats[source.displayName] = 0
            }
        }
                
        return allLines
    }
    
    // Load individual file data from LineData folder or app bundle
    private static func loadFileData(for fileName: String) -> Data? {
        // First try to load from LineData folder
        if let lineDataURL = Bundle.main.url(forResource: "LineData", withExtension: nil) {
            let jsonURL = lineDataURL.appendingPathComponent(fileName)
            if let data = try? Data(contentsOf: jsonURL) {
                return data
            }
        }
        
        // Fallback to original bundle search (for backward compatibility)
        let name = fileName.replacingOccurrences(of: ".json", with: "")
        let ext = "json"
    
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            return nil
        }
    }
}

// MARK: - Data Statistics Structure
// Structure for managing application statistics and cache status
// Tracks data freshness, cache availability, and usage metrics
struct DataStatistics {
    var totalRailways: Int = 0        // Total number of available railway lines
    var lastUpdated: Date? = nil      // When data was last refreshed
    var cacheStatus: [String: Bool] = [:]  // Cache availability for each data source
    
    init() {
        self.totalRailways = 0
        self.lastUpdated = nil
        self.cacheStatus = [:]
    }
    
    init(totalRailways: Int, lastUpdated: Date?, cacheStatus: [String: Bool]) {
        self.totalRailways = totalRailways
        self.lastUpdated = lastUpdated
        self.cacheStatus = cacheStatus
    }
}

// MARK: - Select Line View Model
// Main view model for the line selection interface
// Manages data loading, search, selection, and user preferences
@MainActor
final class SelectLineViewModel: ObservableObject {
    
    // MARK: - Published Properties
    // UI state properties that trigger view updates when changed
    @Published var query: String = ""                    // Search query input
    @Published var suggestions: [TransportationLine] = [] // Search results
    @Published var isLoading: Bool = false               // Loading state indicator
    @Published var errorMessage: String = ""             // Error message display
    @Published var showColorSelection: Bool = false      // Color picker visibility
    @Published var showStationSelection: Bool = false    // Station selection visibility
    @Published var statistics: DataStatistics = DataStatistics()  // Data statistics
    
    // MARK: - State Properties
    // Line and station selection state
    @Published var selectedLine: TransportationLine?           // Currently selected railway line
    @Published var lineStations: [Station] = []               // Stations on the selected line
    @Published var selectedDepartureStation: Station?         // Selected departure station
    @Published var selectedArrivalStation: Station?           // Selected arrival station
    
    // User input fields
    @Published var departureStationInput: String = ""         // Departure station search input
    @Published var arrivalStationInput: String = ""           // Arrival station search input
    @Published var selectedRideTime: Int = 0                  // Selected ride time in minutes
    
    // Suggestion and focus state
    @Published var showDepartureSuggestions: Bool = false     // Departure station suggestions visibility
    @Published var departureSuggestions: [Station] = []       // Departure station search results
    @Published var isDepartureFieldFocused: Bool = false      // Departure field focus state
    @Published var showArrivalSuggestions: Bool = false       // Arrival station suggestions visibility
    @Published var arrivalSuggestions: [Station] = []         // Arrival station search results
    @Published var isArrivalFieldFocused: Bool = false        // Arrival field focus state
    
    // MARK: - Computed Properties
    // Convenience properties for UI state checking
    var hasSelectedLine: Bool { selectedLine != nil }
    var hasStations: Bool { !lineStations.isEmpty }
    
    // MARK: - Private Properties
    // Internal data storage and state management
    private var all: [TransportationLine] = []                // All available railway lines
    private var allData: [TransportationLine] = []            // Cached railway data
    var lastUpdated: Date?                                    // Last data update timestamp
    private var cancellables = Set<AnyCancellable>()          // Combine cancellables for cleanup
    private var nameCounts: [String: Int] = [:]               // Name frequency tracking
    
    // Configuration and initialization
    private let consumerKey: String                           // ODPT API access token
    private let goorback: String                              // Direction identifier (go/back)
    private let lineIndex: Int                                // Line index for UserDefaults keys
    private var isFirstLaunch: Bool = true                    // First launch flag for initialization
    
    // MARK: - Network and Data Management
    // ODPT network client for API communication
    private let net = ODPTNetworkClient()
    
    // Line color selection state
    @Published var selectedLineColor: String? = nil            // Selected line color hex value
    
    // MARK: - Initialization
    // Initialize view model with direction and line index
    init(goorback: String = "back1", lineIndex: Int = 0) {
        self.goorback = goorback
        self.lineIndex = lineIndex
        
        // Get ODPT access token from Debug.xcconfig
        self.consumerKey = Bundle.main.infoDictionary?["ODPT_ACCESS_TOKEN"] as? String ?? ""
        print("ODPT_ACCESS_TOKEN: \(consumerKey.isEmpty ? "Not set" : "Set")")
        
        // Check ODPT API access token availability
        if consumerKey.isEmpty {
            print("⚠️ ODPT_ACCESS_TOKEN is not set")
            errorMessage = "ODPT_ACCESS_TOKEN is not set"
        } else {
            print("✅ ODPT_ACCESS_TOKEN is set: \(String(consumerKey.prefix(10)))...")
        }
        
        // MARK: - Search Query Debouncing
        // Input debounce for improved search performance and responsiveness
        // Reduces API calls while user is typing
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] q in Task { await self?.filter(q) } }
            .store(in: &cancellables)
        
        // MARK: - UserDefaults Initialization
        // Restore user preferences and previous selections
        
        // Read selected line color from UserDefaults
        let userDefaultsKey = goorback.lineColorKey(lineIndex)
        if let savedColor = UserDefaults.standard.string(forKey: userDefaultsKey) {
            self.selectedLineColor = savedColor
        } else {
            self.selectedLineColor = nil
        }
        
        // Read line information from UserDefaults
        let lineNameKey = goorback.lineNameKey(lineIndex)
        if let savedLineName = UserDefaults.standard.string(forKey: lineNameKey) {
            self.query = savedLineName
        }
        
        // Read departure station information from UserDefaults
        let departureKey = goorback.departStationKey(lineIndex)
        if let savedDeparture = UserDefaults.standard.string(forKey: departureKey) {
            self.departureStationInput = savedDeparture
        }
        
        // Read arrival station information from UserDefaults
        let arrivalKey = goorback.arriveStationKey(lineIndex)
        if let savedArrival = UserDefaults.standard.string(forKey: arrivalKey) {
            self.arrivalStationInput = savedArrival
        }
        
        // Read ride time information from UserDefaults
        let rideTimeKey = goorback.rideTimeKey(lineIndex)
        self.selectedRideTime = UserDefaults.standard.integer(forKey: rideTimeKey)
        
        // MARK: - Initial Data Loading
        // Load data on initialization and start background updates
        Task { await loadInitialAndUpdate() }
        
        // MARK: - Saved Line Validation
        // Check if the line read from UserDefaults exists in JSON data (initialization)
        Task { await checkSavedLineInData() }
    }
    
    // MARK: - Data Loading and Initialization
    // Read initial data and check for updates from multiple sources
    // Implements a multi-tier data loading strategy: local → cache → API
    func loadInitialAndUpdate() async {
        isLoading = true
        defer { isLoading = false }
        
        // Step 1: Load data from local JSON files (offline fallback)
        let localLines = LocalFileLoader.loadLocalData()

        // Step 2: Load data from ODPT API cache (if available)
        let railways = net.loadCached(source: .railways) != nil ? (try? ODPTParser.parseRailways(net.loadCached(source: .railways)!)) ?? [] : []
        
        // Remove duplicates and combine data sources
        let allRailways = railways
        
        // Combine local file data with ODPT API data for comprehensive coverage
        self.all = localLines + allRailways
        self.allData = self.all
        self.lastUpdated = Date()
        
        // Apply initial filtering and update statistics
        await filter(query)
        await updateStatistics()
        
        // Step 3: Check for updates from ODPT API on first launch
        // Only attempt API update if consumer key is available
        if isFirstLaunch && !consumerKey.isEmpty {
            // Fetch updated data asynchronously while maintaining current data
            async let updatedRailways: [TransportationLine] = fetchAndUpdate(.railways, consumerKey: consumerKey) ?? allRailways
            
            let newR = await updatedRailways
            
            // Remove duplicates and combine updated data
            let finalRailways = newR
            
            // Combine local file data with latest ODPT API data
            self.all = localLines + finalRailways
            self.allData = self.all
            
            // Apply filtering and update statistics with new data
            await filter(query)
            await updateStatistics()
            
            // Set first launch flag to false to prevent repeated API calls
            isFirstLaunch = false
        } 
    }
    
    // MARK: - Statistics Management
    // Update application statistics including data counts and cache status
    private func updateStatistics() async {
        var stats = DataStatistics()
        stats.totalRailways = all.filter { $0.kind == .railway }.count
        stats.lastUpdated = lastUpdated
        
        // Check ODPT API cache status for each data source
        for source in ODPTSource.allCases {
            stats.cacheStatus[source.displayName] = net.loadCached(source: source) != nil
        }
        
        // Check local file availability for each data source
        for source in LocalDataSource.allCases {
            // Check if file exists in LineData folder
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
        
        // Update statistics on main actor for UI updates
        await MainActor.run {
            self.statistics = stats
        }
    }
    
    // MARK: - Manual Data Refresh
    // Force update of data (only executed when data update button is pressed)
    // Provides user control over data freshness
    func refreshAllData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Re-read local file data for latest offline information
        let localLines = LocalFileLoader.loadLocalData()
        
        if !consumerKey.isEmpty {
            // Force update of all ODPT API data when consumer key is available
            async let updatedRailways: [TransportationLine] = fetchAndUpdate(.railways, consumerKey: consumerKey) ?? []
            
            let newR = await updatedRailways
            
            // Remove duplicates and combine updated data
            let allRailways = newR
            
            // Update main data arrays with fresh information
            self.all = localLines + allRailways
            self.allData = self.all // Update all data
            self.lastUpdated = Date()
            await filter(query)
            await updateStatistics()
        } else {
            // If ODPT API is not available, use only local file data
            self.all = localLines
            self.allData = self.all
            self.lastUpdated = Date()
            await filter(query)
            await updateStatistics()
        }
    }
    
    // MARK: - ODPT Data Fetching and Update
    // Fetch and update data from ODPT API with intelligent caching
    private func fetchAndUpdate(_ source: ODPTSource, consumerKey: String) async -> [TransportationLine]? {
        do {
            let result: (Data, Bool)
            if net.loadCached(source: source) != nil {
                // Use conditional update if cache exists
                result = try await net.fetchWithUpdateIfNeeded(source: source, consumerKey: consumerKey)
            } else {
                // Fetch fresh data if no cache exists
                let d = try await net.fetchSimple(source: source, consumerKey: consumerKey)
                result = (d, true)
            }
                
            // Parse the fetched data into TransportationLine objects
            let parsedData: [TransportationLine]? = try ODPTParser.parseRailways(result.0)
            
            return parsedData
        } catch {
            return nil
        }
    }
    
    // MARK: - Search and Filtering
    // Filter railway lines based on search query
    // Implements normalized search for improved matching
    func filter(_ q: String) async {
        let t = q.normalizedForSearch
        guard !t.isEmpty else { suggestions = []; nameCounts = [:]; return }
        
        // Helper function to generate search key for each line
        // Prioritizes localized names when available
        func key(_ p: TransportationLine) -> String { 
            // If odpt:railwayTitle is available, use value based on current language
            if let railwayTitle = p.railwayTitle {
                let localizedName = railwayTitle.getLocalizedName()
                if !localizedName.isEmpty {
                    return localizedName.normalizedForSearch
                }
            }
            return p.name.normalizedForSearch 
        }
        
        // Apply search with priority: exact prefix matches first, then contains matches
        let starts = all.filter { key($0).hasPrefix(t) }
        let contains = all.filter { !key($0).hasPrefix(t) && key($0).contains(t) }
        let list = starts + contains
        suggestions = list
        
        // Count duplicates for display purposes
        // Uses display name for user-friendly duplicate identification
        var counts: [String: Int] = [:]
        list.forEach { 
            let displayName = displayName(for: $0)
            counts[displayName, default: 0] += 1 
        }
        nameCounts = counts
    }
    
    // MARK: - Display Name Generation
    /// Get localized display name for railway line
    /// Prioritizes multi-language support when available
    func displayName(for line: TransportationLine) -> String {
        // If odpt:railwayTitle is available, use value based on current language
        if let railwayTitle = line.railwayTitle {
            let localizedName = railwayTitle.getLocalizedName()
            if !localizedName.isEmpty {
                return localizedName
            }
        }
        
        // Fallback: Use name field from previous versions
        return line.name
    }
    
    // MARK: - Operator Display Name
    /// Get localized display name based on operator code
    /// Provides language-specific operator names for better user experience
    func getOperatorDisplayName(for operatorCode: String, lineKind: TransportationLine.Kind? = nil) -> String {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        // Get operator name based on ODPTSource definition
        // Maps ODPT operator codes to user-friendly names
        if operatorCode == "odpt.Operator:JR-East" {
            return currentLanguage == "ja" ? "JR東" : "JR-East"
        } else if operatorCode == "odpt.Operator:Keikyu" {
            return currentLanguage == "ja" ? "京急" : "Keikyu"
        } else if operatorCode == "odpt.Operator:TokyoMetro" {
            return currentLanguage == "ja" ? "東京メトロ" : "TokyoMetro"
        } else if operatorCode == "odpt.Operator:Toei" {
            return currentLanguage == "ja" ? "都営" : "Toei"
        } else if operatorCode == "odpt.Operator:Odakyu" {
            return currentLanguage == "ja" ? "小田急" : "Odakyu"
        } else if operatorCode == "odpt.Operator:Yurikamome" {
            return currentLanguage == "ja" ? "ゆりかもめ" : "Yurikamome"
        } else if operatorCode == "odpt.Operator:TWR" {
            return currentLanguage == "ja" ? "TWR" : "TWR"
        } else if operatorCode == "odpt.Operator:Seibu" {
            return currentLanguage == "ja" ? "西武" : "Seibu"
        } else if operatorCode == "odpt.Operator:Sotetsu" {
            return currentLanguage == "ja" ? "相鉄" : "Sotetsu"
        } else if operatorCode == "odpt.Operator:TamaMonorail" {
            return currentLanguage == "ja" ? "多摩" : "Tama"
        } else if operatorCode == "odpt.Operator:Tobu" {
            return currentLanguage == "ja" ? "東武" : "Tobu"
        } else if operatorCode == "odpt.Operator:Tokyu" {
            return currentLanguage == "ja" ? "東急" : "Tokyu"
        } else if operatorCode == "odpt.Operator:MIR" {
            return currentLanguage == "ja" ? "TX" : "TX"
        } else if operatorCode == "odpt.Operator:YokohamaMunicipal" {
            return currentLanguage == "ja" ? "横浜市営" : "Yokohama"
        }
        // For other operators, extract the readable part from ODPT identifier
        return operatorCode.odptTail
    }
    
    // MARK: - Station Search and Filtering
    /// Filter candidate departure stations based on search query
    /// Implements intelligent search that considers line context
    func filterDepartureStations(_ query: String) {
        guard !query.isEmpty else {
            departureSuggestions = []
            showDepartureSuggestions = false
            return
        }
        
        // Search for stations with the input query
        var filtered: [Station] = []
        
        if selectedLine != nil, !lineStations.isEmpty {
            // Search for stations on the selected line (most relevant)
            filtered = lineStations.filter { station in
                station.getLocalizedName().localizedCaseInsensitiveContains(query)
            }
        } else if !self.query.isEmpty {
            // If a line name is entered, search for stations on that line
            let lineStations = getStationsForLineName(self.query)
            if !lineStations.isEmpty {
                filtered = lineStations.filter { station in
                    station.getLocalizedName().localizedCaseInsensitiveContains(query)
                }
            } else {
                // If no line is found, search for stations from all lines
                let allStations = getAllAvailableStations()
                filtered = allStations.filter { station in
                    station.getLocalizedName().localizedCaseInsensitiveContains(query)
                }
            }
        } else {
            // If no line name is entered, search for stations from all lines
            let allStations = getAllAvailableStations()
            filtered = allStations.filter { station in
                station.getLocalizedName().localizedCaseInsensitiveContains(query)
            }
        }
        
        // Exclude stations that are the same as the arrival station
        if let selectedArrivalStation = selectedArrivalStation {
            filtered = filtered.filter { station in
                station.getLocalizedName() != selectedArrivalStation.getLocalizedName()
            }
        }
        
        // Update results and show suggestions if available
        departureSuggestions = filtered
        showDepartureSuggestions = !filtered.isEmpty
    }
    
    /// Filter candidate arrival stations
    func filterArrivalStations(_ query: String) {
        guard !query.isEmpty else {
            arrivalSuggestions = []
            showArrivalSuggestions = false
            return
        }
        // Search for stations with the input query
        var filtered: [Station] = []
        
        if selectedLine != nil, !lineStations.isEmpty {
            // Search for stations on the selected line
            filtered = lineStations.filter { station in
                station.getLocalizedName().localizedCaseInsensitiveContains(query)
            }
        } else if !self.query.isEmpty {
            // If a line name is entered, search for stations on that line
            let lineStations = getStationsForLineName(self.query)
            if !lineStations.isEmpty {
                filtered = lineStations.filter { station in
                    station.getLocalizedName().localizedCaseInsensitiveContains(query)
                }
            } else {
                // If no line is found, search for stations from all lines
                let allStations = getAllAvailableStations()
                filtered = allStations.filter { station in
                    station.getLocalizedName().localizedCaseInsensitiveContains(query)
                }
            }
        } else {
            // If no line name is entered, search for stations from all lines
            let allStations = getAllAvailableStations()
            filtered = allStations.filter { station in
                station.getLocalizedName().localizedCaseInsensitiveContains(query)
            }
        }
        // Exclude stations that are the same as the departure station
        // Prevents selecting the same station for both departure and arrival
        if let selectedDepartureStation = selectedDepartureStation {
            filtered = filtered.filter { station in
                station.getLocalizedName() != selectedDepartureStation.getLocalizedName()
            }
        }
        // Update results and show suggestions if available
        arrivalSuggestions = filtered
        showArrivalSuggestions = !filtered.isEmpty
    }
    
    /// Parse station information for a given line code
    private func parseStationsForLine(_ data: Data, lineCode: String) -> [Station]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let array = json as? [[String: Any]] {               
                // Search for lines matching the given line code
                for railway in array {
                    if let railwayLineCode = railway["odpt:lineCode"] as? String {
                    
                        if railwayLineCode == lineCode {
                            // Get station order information for the matching line
                            if let stationOrder = railway["odpt:stationOrder"] as? [[String: Any]] {
                        
                                var stations: [Station] = []
                                
                                // Build station information based on station order
                                // Creates Station objects with multi-language support
                                for (stationIndex, stationInfo) in stationOrder.enumerated() {
                                    if let stationTitle = stationInfo["odpt:stationTitle"] as? [String: Any] {
                                        let jaName = stationTitle["ja"] as? String
                                        let enName = stationTitle["en"] as? String
                                        
                                        // Use Japanese name first, then English name if no Japanese name exists
                                        let stationName = jaName ?? enName ?? "Unknown station"
                                        
                                        let station = Station(
                                            name: stationName,
                                            code: nil,
                                            title: StationTitle(ja: jaName, en: enName)
                                        )
                                        stations.append(station)
                                        
                                        // Log station information for debugging (first 3 and last 3 stations)
                                        if stationIndex < 3 || stationIndex >= stationOrder.count - 3 {
                                            print("  [\(stationIndex)] Station: \(stationName)")
                                        } else if stationIndex == 3 {
                                            print("  ... (omitted) ...")
                                        }
                                    } else {
                                        print("⚠️ Unable to retrieve station title information: \(stationInfo)")
                                    }
                                }
                                return stations
                            } 
                        }
                    }
                }
                return nil
            }
        } catch {
            // Handle JSON parsing errors silently
            // Return nil to indicate parsing failure
        }
        return nil
    }
    
    // MARK: - Line Name Based Station Parsing
    /// Parse station information for a given line name
    /// Searches for stations using line name instead of line code
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
                    
                    // Search by Japanese name of odpt:railwayTitle
                    if let railwayTitle = railway["odpt:railwayTitle"] as? [String: Any],
                       let jaName = railwayTitle["ja"] as? String,
                       jaName == lineName {
                        return extractStationsFromRailway(railway, searchMethod: "odpt:railwayTitle.ja", searchValue: lineName)
                    }
                    
                    // Search by English name of odpt:railwayTitle
                    if let railwayTitle = railway["odpt:railwayTitle"] as? [String: Any],
                       let enName = railwayTitle["en"] as? String,
                       enName == lineName {
                        return extractStationsFromRailway(railway, searchMethod: "odpt:railwayTitle.en", searchValue: lineName)
                    }
                }
                
                // MARK: - Partial Match Search
                // If no exact match is found, search for partial matches
                // This provides more flexible search results for user input
                for railway in array {
                    // Search by partial match of dc:title
                    if let railwayName = railway["dc:title"] as? String,
                       railwayName.contains(lineName) || lineName.contains(railwayName) {
                        if let stations = extractStationsFromRailway(railway, searchMethod: "dc:title partial match", searchValue: railwayName) {
                            return stations
                        }
                    }
                    
                    // Search by partial match of Japanese name of odpt:railwayTitle
                    if let railwayTitle = railway["odpt:railwayTitle"] as? [String: Any],
                       let jaName = railwayTitle["ja"] as? String,
                       jaName.contains(lineName) || lineName.contains(jaName) {
                        if let stations = extractStationsFromRailway(railway, searchMethod: "odpt:railwayTitle.ja partial match", searchValue: jaName) {
                            return stations
                        }
                    }
                    
                    // Search by partial match of English name of odpt:railwayTitle
                    if let railwayTitle = railway["odpt:railwayTitle"] as? [String: Any],
                       let enName = railwayTitle["en"] as? String,
                       enName.contains(lineName) || lineName.contains(enName) {
                        if let stations = extractStationsFromRailway(railway, searchMethod: "odpt:railwayTitle.en partial match", searchValue: enName) {
                            return stations
                        }
                    }
                }
                
                return nil
            }
        } catch {
            // Handle JSON parsing errors silently
            // Return nil to indicate parsing failure
        }
        return nil
    }
    
    /// Extract station information from railway object
    func extractStationsFromRailway(_ railway: [String: Any], searchMethod: String, searchValue: String) -> [Station]? {
        if let stationOrder = railway["odpt:stationOrder"] as? [[String: Any]] {
            var stations: [Station] = []
            
            // Build station information based on station order
            // Creates Station objects with proper localization
            for stationInfo in stationOrder {
                if let stationTitle = stationInfo["odpt:stationTitle"] as? [String: Any] {
                    let jaName = stationTitle["ja"] as? String
                    let enName = stationTitle["en"] as? String
                    
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
            
            if !stations.isEmpty {
                // Return stations if any were successfully extracted
                return stations
            }
        }
        
        return nil
    }
    
    // MARK: - Railway Type Based Station Parsing
    /// Parse station information for a given railway type
    /// Searches for stations based on railway classification (JR, private, etc.)
    func parseStationsByRailwayType(_ data: Data, railwayType: String?) -> [Station]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let array = json as? [[String: Any]] {
                // Search for lines matching the given railway type
                for railway in array {
                    if let rt = railway["odpt:railwayType"] as? String,
                       rt == railwayType {
                        // Get station order information for the matching railway type
                        if let stationOrder = railway["odpt:stationOrder"] as? [[String: Any]] {
                            var stations: [Station] = []
                            
                            // Build station information based on station order
                            // Creates Station objects with multi-language support
                            for stationInfo in stationOrder {
                                if let stationTitle = stationInfo["odpt:stationTitle"] as? [String: Any] {
                                    let jaName = stationTitle["ja"] as? String
                                    let enName = stationTitle["en"] as? String
                                    
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
            // Handle JSON parsing errors silently
            // Return nil to indicate parsing failure
        }
        return nil
    }
        
    // MARK: - Line Name Based Station Retrieval
    /// Get station information based on line name
    /// Searches across multiple data sources to find stations for a specific line
    func getStationsForLineName(_ lineName: String) -> [Station] {
        var stations: [Station] = []
        
        // Get station information from files of each operator
        // Searches across all available railway operators for comprehensive coverage
        let stationDataFiles = [
            "jreast.json", 
            "tokyometro.json", 
            "toeimetro.json", 
            "keikyu.json", 
            "odakyu.json", 
            "yurikamome.json", 
            "rinkai.json", 
            "seibu.json", 
            "sotetsu.json", 
            "tama.json", 
            "tobu.json", 
            "tokyu.json",
            "tsukuba.json", 
            "yokohamametro.json"]
        
        for filename in stationDataFiles {
            if let data = loadLocalData(for: filename) {
                // Search by line name in the current data file
                if let foundStations = parseStationsByLineName(data, lineName: lineName) {
                    stations = foundStations
                    break
                }
            }
        }
        
        return stations
    }
    
    // MARK: - Local Data Loading
    /// Load local data from LineData folder
    /// Retrieves JSON data files for offline operation
    func loadLocalData(for filename: String) -> Data? {
        // First try to load from LineData folder
        if let lineDataURL = Bundle.main.url(forResource: "LineData", withExtension: nil) {
            let jsonURL = lineDataURL.appendingPathComponent(filename)
            if let data = try? Data(contentsOf: jsonURL) {
                return data
            }
        }
        
        // Fallback to original bundle search (for backward compatibility)
        guard let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: url)
    }
    
    // MARK: - State Reset and Management
    /// Reset station selection and clear all related state
    /// Provides clean slate for new line selection
    func resetStationSelection() {
        // Clear line selection
        selectedLine = nil
        showStationSelection = false
        lineStations = []
        
        // Clear station selections
        selectedDepartureStation = nil
        selectedArrivalStation = nil
        selectedRideTime = 0
        
        // Clear candidate suggestions and focus states
        showDepartureSuggestions = false
        departureSuggestions = []
        showArrivalSuggestions = false
        arrivalSuggestions = []
        isDepartureFieldFocused = false
        isArrivalFieldFocused = false
    }
    
    // MARK: - Display Update
    /// Update all line information at once
    /// Synchronizes UI state with selected line data
    func updateDisplay() {
        // Update line name display
        if let line = selectedLine {
            query = displayName(for: line)
        }
        
        // Update line color selection
        if let line = selectedLine, let lineColor = line.lineColor {
            selectedLineColor = lineColor
        }
        
        // Update departure station input field
        if let departureStation = selectedDepartureStation {
            departureStationInput = departureStation.getLocalizedName()
        }
        
        // Update arrival station input field
        if let arrivalStation = selectedArrivalStation {
            arrivalStationInput = arrivalStation.getLocalizedName()
        }
    }
    
    // MARK: - Custom Line Validation
    /// Check if custom line station input is complete
    /// Validates that both departure and arrival stations are specified
    func isCustomLineStationInputComplete() -> Bool {
        return !departureStationInput.isEmpty && !arrivalStationInput.isEmpty
    }
    
    // MARK: - Line Color Management
    /// Set line color (do not save to UserDefaults)
    /// Updates UI state without persisting changes
    func setLineColor(_ color: String) {
        selectedLineColor = color
        showColorSelection = false
    }
    
    // MARK: - Line Save Processing
    /// Common save processing for all line types
    /// Handles data persistence and UI updates
    func handleLineSave(dismiss: DismissAction) {
        saveAllDataToUserDefaults()
        updateDisplay()
        errorMessage = ""
        dismiss()
    }
    
    /// Save selected line from predefined data
    /// Handles saving of lines selected from ODPT or local data
    func handleSelectedLineSave(_ line: TransportationLine, dismiss: DismissAction) {
        // Set selected line and proceed with save
        selectedLine = line
        handleLineSave(dismiss: dismiss)
    }
    
    /// Save custom line with user-defined stations
    /// Validates input before saving custom line configuration
    func handleCustomLineSave(dismiss: DismissAction) {
        guard isCustomLineStationInputComplete() else {
            setCustomLineError()
            return
        }
        handleLineSave(dismiss: dismiss)
    }
    
    // MARK: - Error Handling
    /// Set error message for custom line validation failures
    /// Provides user feedback for incomplete input
    func setCustomLineError() {
        if departureStationInput.isEmpty && arrivalStationInput.isEmpty {
            errorMessage = "Please enter both departure and arrival stations"
        } else if departureStationInput.isEmpty {
            errorMessage = "Please enter departure station"
        } else if arrivalStationInput.isEmpty {
            errorMessage = "Please enter arrival station"
        }
    }
    
    // MARK: - Saved Line Validation
    /// Check if line read from UserDefaults exists in JSON data
    /// Validates that saved preferences are still valid
    func checkSavedLineInData() async {
        // Wait for data loading to complete before validation
        while all.isEmpty {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds wait
        }
        
        // Check only if query is not empty
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Check saved line selection status from UserDefaults
        let lineSelectedKey = goorback.lineSelectedKey(lineIndex)
        let wasLineSelected = UserDefaults.standard.bool(forKey: lineSelectedKey)
        
        if wasLineSelected {
            // If previously selected from JSON data, search for lines matching the query
            // Attempts to restore the previously selected line
            if let foundLine = all.first(where: { line in
                line.name == query || 
                line.railwayTitle?.getLocalizedName() == query
            }) {
                selectedLine = foundLine
                showStationSelection = true
            }
        }
    }
    
    // MARK: - Data Persistence
    /// Update and save all information when save button is pressed
    /// Persists user selections to UserDefaults for future restoration
    func saveAllDataToUserDefaults() {
        var savedItems: [String] = []
        
        // Update line information (if selected from JSON data)
        if let line = self.selectedLine {
            // Update line name (if odpt:railwayTitle is available, use value based on current language)
            let lineNameToSave: String
            if let railwayTitle = line.railwayTitle {
                let localizedName = railwayTitle.getLocalizedName()
                lineNameToSave = localizedName.isEmpty ? line.name : localizedName
            } else {
                lineNameToSave = line.name
            }
            
            // Update query with the name to save
            self.query = lineNameToSave
            
            // Update line color (if color is available from ODPT)
            if let lineColor = line.lineColor {
                self.selectedLineColor = lineColor
            }
        }
        
        // Save line name (only if not empty)
        if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lineNameKey = goorback.lineNameKey(lineIndex)
            UserDefaults.standard.set(query, forKey: lineNameKey)
            savedItems.append("Line name: \(query)")
        }
        
        // Save line color (only if set)
        if let lineColor = selectedLineColor, !lineColor.isEmpty {
            let lineColorKey = goorback.lineColorKey(lineIndex)
            UserDefaults.standard.set(lineColor, forKey: lineColorKey)
            savedItems.append("Line color: \(lineColor)")
        }
        
        // Save selected station information (if selected from JSON data)
        if self.selectedLine != nil, !self.lineStations.isEmpty {
            // Save selected departure station
            if let departureStation = self.selectedDepartureStation {
                let departureKey = goorback.departStationKey(lineIndex)
                let departureName = departureStation.getLocalizedName()
                UserDefaults.standard.set(departureName, forKey: departureKey)
                savedItems.append("Departure station: \(departureName)")
                
                // Also update variable for display
                self.departureStationInput = departureName
            }
            
            // Save selected arrival station
            if let arrivalStation = self.selectedArrivalStation {
                let arrivalKey = goorback.arriveStationKey(lineIndex)
                let arrivalName = arrivalStation.getLocalizedName()
                UserDefaults.standard.set(arrivalName, forKey: arrivalKey)
                savedItems.append("Arrival station: \(arrivalName)")
                
                // Also update variable for display
                self.arrivalStationInput = arrivalName
            }
            
            // Save ride time
            let rideTimeKey = goorback.rideTimeKey(lineIndex)
            UserDefaults.standard.set(selectedRideTime, forKey: rideTimeKey)
            savedItems.append("Ride time: \(selectedRideTime) minutes")
        } else {
            // MARK: - Custom Line Data Persistence
            // If custom input is used (no predefined line selected)
            // Save departure station (only if not empty)
            if !departureStationInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let departureKey = goorback.departStationKey(lineIndex)
                UserDefaults.standard.set(departureStationInput, forKey: departureKey)
                savedItems.append("Departure station: \(departureStationInput)")
            }
            
            // Save arrival station (only if not empty)
            if !arrivalStationInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let arrivalKey = goorback.arriveStationKey(lineIndex)
                UserDefaults.standard.set(arrivalStationInput, forKey: arrivalKey)
                savedItems.append("Arrival station: \(arrivalStationInput)")
            }
            
            // Save ride time
            let rideTimeKey = goorback.rideTimeKey(lineIndex)
            UserDefaults.standard.set(selectedRideTime, forKey: rideTimeKey)
            savedItems.append("Ride time: \(selectedRideTime) minutes")
        }
        
        // MARK: - Line Selection Status Persistence
        // Save line selection status (true if selected from JSON data, false otherwise)
        // This helps distinguish between predefined and custom lines on next launch
        let lineSelectedKey = goorback.lineSelectedKey(lineIndex)
        let isLineSelected = self.selectedLine != nil
        UserDefaults.standard.set(isLineSelected, forKey: lineSelectedKey)
        savedItems.append("Line selection status: \(isLineSelected ? "Selected from JSON data" : "Custom input")")
    }
    
    // MARK: - Station Data Retrieval
    /// Get all stations (regardless of line selection)
    /// Provides comprehensive station list for search and selection
    func getAllAvailableStations() -> [Station] {
        var allStations: [Station] = []
        
        // Get station information from files of each operator
        // Searches across all available data sources for comprehensive coverage
        let stationDataFiles = [
            "jreast.json", 
            "tokyometro.json", 
            "toeimetro.json", 
            "keikyu.json", 
            "odakyu.json", 
            "yurikamome.json", 
            "rinkai.json", 
            "seibu.json", 
            "sotetsu.json", 
            "tama.json", 
            "tobu.json", 
            "tokyu.json",
            "tsukuba.json", 
            "yokohamametro.json"]
        
        for filename in stationDataFiles {
            if let data = loadLocalData(for: filename) {
                if let stations = parseAllStationsFromFile(data) {
                    allStations.append(contentsOf: stations)
                }
            }
        }
        // Remove duplicates and sort alphabetically for consistent display
        let uniqueStations = Array(Set(allStations)).sorted { $0.getLocalizedName() < $1.getLocalizedName() }
        return uniqueStations
    }
    
    // MARK: - File Station Parsing
    /// Extract all stations from file
    /// Parses station data from JSON files and creates Station objects
    func parseAllStationsFromFile(_ data: Data) -> [Station]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let array = json as? [[String: Any]] {
                var stations: [Station] = []
                
                // Process each railway line in the file
                for railway in array {
                    if let stationOrder = railway["odpt:stationOrder"] as? [[String: Any]] {
                        // Extract stations from each line's station order
                        for stationInfo in stationOrder {
                            if let stationTitle = stationInfo["odpt:stationTitle"] as? [String: Any] {
                                let jaName = stationTitle["ja"] as? String
                                let enName = stationTitle["en"] as? String
                                
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
            
        }
        
        return nil
    }
}

// MARK: - UI Components
// Small tag display component for showing metadata
struct Tag: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(Capsule().fill(Color(.secondarySystemFill)))
    }
}

// MARK: - Main View
// Main view for selecting railway lines and configuring line settings
struct SelectLineView: View {
    
    // MARK: - State Management
    @StateObject private var vm: SelectLineViewModel
    @FocusState private var focused: Bool
    @State private var selected: TransportationLine?
    @State private var showColorSelect = false
    @State private var shouldClearText = false
    @State private var showTimetableSettings = false
    @State private var departureStationPosition: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Configuration
    // Integration with lineInfomation.swift
    private let goorback: String
    private let lineIndex: Int
    
    init(goorback: String, lineIndex: Int) {
        self.goorback = goorback
        self.lineIndex = lineIndex
        self._vm = StateObject(wrappedValue: SelectLineViewModel(goorback: goorback, lineIndex: lineIndex))
    }
    
    // MARK: - Data Processing
    /// Remove duplicates based on operator and line name combination
    /// Ensures unique line representation in the UI
    private func removeDuplicates(from lines: [TransportationLine]) -> [TransportationLine] {
        var seen = Set<String>()
        var result: [TransportationLine] = []
        
        for line in lines {
            // Create unique key combining operator code and display name
            let key = "\(line.operatorCode ?? "")_\(vm.displayName(for: line))"
            if !seen.contains(key) {
                seen.insert(key)
                result.append(line)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 20) {
                    // Hide suggestion lists when tapping the screen
                    
                    HStack {
                        Text("路線名")
                            .font(.headline)
                            .foregroundColor(Color.primaryColor)

                        TextField("路線名・バス路線名を入力", text: $vm.query)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
                            .focused($focused)
                            .onSubmit {
                                // Handle enter key press
                                Task { await vm.filter(vm.query) }
                            }
                            .onTapGesture {
                                vm.showDepartureSuggestions = false
                            }
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(vm.query.isEmpty ? Color.gray: Color.accentColor)
                    }
                    
                    .onChange(of: vm.query) { newValue in
                        // Clear error message on input
                        vm.errorMessage = ""
                        
                        // Reset station selection when query changes
                        let currentLineName = vm.selectedLine?.name ?? ""
                        let currentDisplayName = vm.selectedLine != nil ? vm.displayName(for: vm.selectedLine!) : ""
                        
                        if newValue != currentLineName && newValue != currentDisplayName {
                            vm.resetStationSelection()
                            selected = nil
                            // Show station selection UI for custom line input
                            if !newValue.isEmpty {
                                vm.showStationSelection = true
                            }
                        }
                    }
                    
                    // MARK: - Line Color Display
                    // Display and manage line color selection
                    HStack {
                        Text("Line Color".localized)
                            .font(.headline)
                            .foregroundColor(Color.primaryColor)

                        // Display selected color as a circle
                        Circle()
                            .fill(Color((selected?.lineColor ?? vm.selectedLineColor ?? "#03DAC5").colorInt))
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(Color.primaryColor, lineWidth: 1))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))


                        Spacer()

                        if !vm.showColorSelection {
                            // Line color change button
                            Button("カラー変更") {
                                vm.showColorSelection = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.primaryColor)
                        }
                    }
                    
                    // MARK: - Station Selection Section
                    // Input fields for departure and arrival stations
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("駅の入力：\(vm.hasSelectedLine && vm.hasStations ? "\(vm.lineStations.first?.name ?? "")〜\(vm.lineStations.last?.name ?? "")": "")")
                            .font(.headline)
                            .foregroundColor(Color.black)
                        
                        // MARK: - Departure Station Input
                        // Input field for departure station
                        VStack(spacing: 12) {

                            HStack {
                                Text("乗車駅")
                                    .font(.headline)
                                    .foregroundColor(Color.primaryColor)
                                
                                TextField("乗車駅を入力", text: $vm.departureStationInput)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
                                    .onChange(of: vm.departureStationInput) { newValue in
                                        // Clear error message on input
                                        vm.errorMessage = ""
                                        // Set focus state
                                        vm.isDepartureFieldFocused = true
                                        // Clear input if same station as arrival station is entered
                                        if let selectedArrivalStation = vm.selectedArrivalStation,
                                           newValue == selectedArrivalStation.getLocalizedName() {
                                            vm.departureStationInput = ""
                                            vm.selectedDepartureStation = nil
                                            vm.errorMessage = "乗車駅と降車駅は同じ駅にできません"
                                        } else {
                                            // Filter suggestions
                                            vm.filterDepartureStations(newValue)
                                        }
                                    }
                                    .onChange(of: vm.selectedDepartureStation) { _ in
                                        // Re-filter arrival station suggestions after departure station selection
                                        if !vm.arrivalStationInput.isEmpty {
                                            vm.filterArrivalStations(vm.arrivalStationInput)
                                        }
                                    }
                                    .onTapGesture {
                                        // Show suggestions on tap
                                        vm.isDepartureFieldFocused = true
                                        if !vm.departureStationInput.isEmpty {
                                            vm.filterDepartureStations(vm.departureStationInput)
                                        }
                                    }
                                    .onSubmit {
                                        // Hide suggestions on input completion
                                        vm.showDepartureSuggestions = false
                                        vm.isDepartureFieldFocused = false
                                    }
                                    .background(
                                        GeometryReader { geometry in
                                            Color.clear
                                                .preference(key: DepartureStationPositionKey.self, value: geometry.frame(in: .named("scrollView")).minY)
                                        }
                                    )
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(vm.departureStationInput.isEmpty ? Color.gray: Color.accentColor)
                            }
                            
                            // MARK: - Arrival Station Input
                            // Input field for arrival station
                            HStack {
                                Text("降車駅")
                                    .font(.headline)
                                    .foregroundColor(Color.primaryColor)

                                TextField("降車駅を入力", text: $vm.arrivalStationInput)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
                                    .onChange(of: vm.arrivalStationInput) { newValue in
                                        // Clear error message on input
                                        vm.errorMessage = ""
                                        // Set focus state
                                        vm.isArrivalFieldFocused = true
                                        // Clear input if same station as departure station is entered
                                        if let selectedDepartureStation = vm.selectedDepartureStation,
                                           newValue == selectedDepartureStation.getLocalizedName() {
                                            vm.arrivalStationInput = ""
                                            vm.selectedArrivalStation = nil
                                            vm.errorMessage = "乗車駅と降車駅は同じ駅にできません"
                                        } else {
                                            // Filter arrival station suggestions
                                            vm.filterArrivalStations(newValue)
                                        }
                                    }
                                    .onChange(of: vm.selectedArrivalStation) { _ in
                                        // Re-filter departure station suggestions after arrival station selection
                                        if !vm.departureStationInput.isEmpty {
                                            vm.filterDepartureStations(vm.departureStationInput)
                                        }
                                    }
                                    .onTapGesture {
                                        // Show suggestions on tap
                                        vm.isArrivalFieldFocused = true
                                        if !vm.arrivalStationInput.isEmpty {
                                            vm.filterArrivalStations(vm.arrivalStationInput)
                                        }
                                    }
                                    .onSubmit {
                                        // Hide suggestions on input completion
                                        vm.showArrivalSuggestions = false
                                        vm.isArrivalFieldFocused = false
                                    }

                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(vm.arrivalStationInput.isEmpty ? Color.gray: Color.accentColor)
                            }
                            
                        }
                    }
                    
                    // MARK: - Ride Time Selection
                    // Common ride time selection for all line types
                    HStack(alignment: .center) {
                        Text("乗車時間")
                            .font(.headline)
                            .foregroundColor(Color.primaryColor)
                        
                        HStack {
                            Text("\(vm.selectedRideTime)\(" min".localized)")
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
                            
                            Menu {
                                ForEach(0...99, id: \.self) { minute in
                                    Button("\(minute)分") {
                                        vm.selectedRideTime = minute
                                        vm.errorMessage = ""
                                    }
                                }
                            } label: {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.black)
                                    .padding(.leading, 8)
                            }
                        }
                    }
                    
                    // MARK: - Data Management and Control Buttons
                    // Buttons for data management and form control
                    HStack(spacing: 12) {

                        Button("データ更新") {
                            Task { await vm.refreshAllData() }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.gray)
                        .help("初回起動以外では、このボタンを押すことで最新のデータを取得できます")

                        if vm.isLoading { ProgressView().scaleEffect(0.9) }
                        
                        
                        if let updated = vm.lastUpdated {
                            Text("更新: \(updated.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        
                        // MARK: - Clear Button
                        // Clear button (small size, positioned on the right)
                        Button(action: {
                            // Clear line name
                            vm.query = ""
                            selected = nil
                            
                            // Reset station selection
                            vm.resetStationSelection()
                            
                            // Clear departure and arrival station input fields
                            vm.departureStationInput = ""
                            vm.arrivalStationInput = ""
                            
                            // Reset ride time to 0 minutes
                            vm.selectedRideTime = 0
                            
                            // Reset line color to accent (not saved to UserDefaults)
                            vm.selectedLineColor = "#03DAC5"
                            
                            // Hide color selection UI
                            vm.showColorSelection = false
                        }) {
                            Text("クリア")
                                .buttonStyle(.borderedProminent)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    
                    // MARK: - Action Buttons
                    // Save button and timetable settings button displayed at the bottom
                    VStack(spacing: 16) {
                        // MARK: - Save Button
                        // Save button for line configuration
                        Button(action: {
                            if let sel = selected {
                                // When line is selected from JSON data
                                vm.handleSelectedLineSave(sel, dismiss: dismiss)
                            } else if !vm.query.isEmpty {
                                // When custom line input is used
                                vm.handleCustomLineSave(dismiss: dismiss)
                            }
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down.fill")
                                    .font(.title3)
                                Text("保存")
                                    .font(.title3)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selected == nil && (vm.query.isEmpty || (!vm.query.isEmpty && !vm.isCustomLineStationInputComplete())) ? Color.gray : Color.accentColor)
                            )
                        }
                        .disabled(selected == nil && (vm.query.isEmpty || (!vm.query.isEmpty && !vm.isCustomLineStationInputComplete())))
                        .padding(.horizontal, 20)
                        
                        // MARK: - Timetable Settings Button
                        // Button to open timetable configuration
                        Button(action: {
                            showTimetableSettings = true
                        }) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .font(.title3)
                                Text("時刻表の設定")
                                    .font(.title3)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.primaryColor)
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Add space below buttons
                        Spacer(minLength: 20)
                    }
                }
                .coordinateSpace(name: "scrollView")
                .onPreferenceChange(DepartureStationPositionKey.self) { value in
                    departureStationPosition = value
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .animation(.default, value: vm.showStationSelection)
                .sheet(isPresented: $showTimetableSettings) {
                    NavigationStack {
                        TimetableContentView(goorback, lineIndex)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }

                // MARK: - Departure Station Suggestions
                // Display departure station suggestions when available
                if vm.showDepartureSuggestions && !vm.departureSuggestions.isEmpty {
                    VStack(alignment: .leading) {
                        ScrollView {
                            ForEach(vm.departureSuggestions, id: \.id) { station in
                                if station == vm.departureSuggestions.first {
                                    Color.clear.frame(height: 0)
                                }
                                Button {
                                    // Clear input if same station as arrival station is selected
                                    if let selectedArrivalStation = vm.selectedArrivalStation,
                                       station.getLocalizedName() == selectedArrivalStation.getLocalizedName() {
                                        vm.departureStationInput = ""
                                        vm.selectedDepartureStation = nil
                                        vm.errorMessage = "乗車駅と降車駅は同じ駅にできません"
                                    } else {
                                        vm.departureStationInput = station.getLocalizedName()
                                        vm.selectedDepartureStation = station
                                        vm.errorMessage = ""
                                    }
                                    vm.showDepartureSuggestions = false
                                    vm.isDepartureFieldFocused = false
                                    // Clear suggestion list
                                    vm.departureSuggestions = []
                                    // Ensure suggestions are hidden
                                    DispatchQueue.main.async {
                                        vm.showDepartureSuggestions = false
                                        vm.departureSuggestions = []
                                    }
                                    // Re-filter arrival station suggestions after departure station selection
                                    if !vm.arrivalStationInput.isEmpty {
                                        vm.filterArrivalStations(vm.arrivalStationInput)
                                    }
                                } label: {
                                    HStack(alignment: .center, spacing: 8) {
                                        Text(station.getLocalizedName())
                                            .lineLimit(1)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                }
                                .buttonStyle(.plain)
                                if station != vm.departureSuggestions.last { Divider() }
                            }
                        }
                    }
                    .frame(maxHeight: min(CGFloat(vm.departureSuggestions.count) * 50, 500))
                    .background(RoundedRectangle(cornerRadius: 10).fill(.background))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
                    .animation(.default, value: vm.departureSuggestions)
                    .shadow(radius: 6)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding()
                    .offset(y: 205) // Adjust position to match departure station input field
                    .zIndex(100)
                }

                // MARK: - Arrival Station Suggestions
                // Display arrival station suggestions when available
                if vm.showArrivalSuggestions && !vm.arrivalSuggestions.isEmpty {
                    VStack(alignment: .leading) {
                        ScrollView {
                            ForEach(vm.arrivalSuggestions, id: \.id) { station in
                                if station == vm.arrivalSuggestions.first {
                                    Color.clear.frame(height: 0)
                                }
                                Button {
                                    // Clear input if same station as departure station is selected
                                    if let selectedDepartureStation = vm.selectedDepartureStation,
                                       station.getLocalizedName() == selectedDepartureStation.getLocalizedName() {
                                        vm.arrivalStationInput = ""
                                        vm.selectedArrivalStation = nil
                                        vm.errorMessage = "乗車駅と降車駅は同じ駅にできません"
                                    } else {
                                        vm.arrivalStationInput = station.getLocalizedName()
                                        vm.selectedArrivalStation = station
                                        vm.errorMessage = ""
                                    }
                                    vm.showArrivalSuggestions = false
                                    vm.isArrivalFieldFocused = false
                                    // Clear suggestion list
                                    vm.arrivalSuggestions = []
                                    // Ensure suggestions are hidden
                                    DispatchQueue.main.async {
                                        vm.showArrivalSuggestions = false
                                        vm.arrivalSuggestions = []
                                    }
                                    // Re-filter departure station suggestions after arrival station selection
                                    if !vm.departureStationInput.isEmpty {
                                        vm.filterDepartureStations(vm.departureStationInput)
                                    }
                                } label: {
                                    HStack(alignment: .center, spacing: 8) {
                                        Text(station.getLocalizedName())
                                            .lineLimit(1)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                }
                                .buttonStyle(.plain)
                                if station != vm.arrivalSuggestions.last { Divider() }
                            }
                        }
                    }
                    .frame(maxHeight: min(CGFloat(vm.arrivalSuggestions.count) * 50, 500))
                    .background(RoundedRectangle(cornerRadius: 10).fill(.background))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
                    .animation(.default, value: vm.arrivalSuggestions)
                    .shadow(radius: 6)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding()
                    .offset(y: 280) // Adjust position to match arrival station input field
                    .zIndex(100)
                }

                // MARK: - Line Suggestions
                // Display line suggestions when search field is focused
                if focused, !vm.suggestions.isEmpty {
                    VStack(alignment: .leading) {
                        ScrollView {
                            ForEach(removeDuplicates(from: vm.suggestions)) { line in
                                if line == removeDuplicates(from: vm.suggestions).first {
                                    Color.clear.frame(height: 0)
                                }
                                Button {
                                    selected = line
                                    // Update display name with operator information on selection
                                    vm.query = vm.displayName(for: line)
                                    focused = false
                                    // Clear station fields when line is selected
                                    vm.departureStationInput = ""
                                    vm.arrivalStationInput = ""
                                    vm.selectedDepartureStation = nil
                                    vm.selectedArrivalStation = nil
                                    // Clear suggestion displays
                                    vm.showDepartureSuggestions = false
                                    vm.departureSuggestions = []
                                    vm.showArrivalSuggestions = false
                                    vm.arrivalSuggestions = []
                                    vm.isDepartureFieldFocused = false
                                    vm.isArrivalFieldFocused = false
                                    // If line color is available, set it to selectedLineColor
                                    if let lineColor = line.lineColor {
                                        vm.selectedLineColor = lineColor
                                    }
                                } label: {
                                     HStack(alignment: .top, spacing: 8) {
                                         Text(line.kind == .railway ? (line.lineCode ?? "鉄道") : "バス")
                                             .font(.caption2)
                                             .padding(.vertical, 2)
                                             .padding(.horizontal, 6)
                                             .background(Capsule().fill(Color(line.lineColor?.colorInt ?? 0xAAAAAA).opacity(0.5)))
                                         
                                         Text(vm.displayName(for: line)).lineLimit(1)
                                         
                                         if let operatorCode = line.operatorCode {
                                             let displayText = vm.getOperatorDisplayName(for: operatorCode, lineKind: line.kind)
                                             Tag(text: displayText)
                                         }
                                         
                                         Spacer()
                                     }
                                     .contentShape(Rectangle())
                                     .padding(.vertical, 8)
                                     .padding(.horizontal, 12)
                                 }
                                .buttonStyle(.plain)
                                if line != vm.suggestions.last { Divider() }
                            }
                        }
                        Spacer()
                    }
                    .frame(maxHeight: min(CGFloat(vm.suggestions.count) * 50, 500))
                    .background(RoundedRectangle(cornerRadius: 10).fill(.background))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
                    .animation(.default, value: vm.suggestions)
                    .shadow(radius: 6)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding()
                    .offset(y: 50)
                    .zIndex(100)
                    .onTapGesture {
                        if vm.showDepartureSuggestions {
                            vm.showDepartureSuggestions = false
                            vm.isDepartureFieldFocused = false
                        }
                        if vm.showArrivalSuggestions {
                            vm.showArrivalSuggestions = false
                            vm.isArrivalFieldFocused = false
                        }
                    }
                }
                
                // MARK: - Color Selection Section
                // Integrated if statement for managing color selection display
                if (vm.showColorSelection || (!vm.query.isEmpty && (vm.selectedLineColor == nil) && (selected == nil || selected?.lineColor == nil))) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("路線カラーの選択")
                                .font(.headline)
                                .foregroundColor(Color.primaryColor)
                            Spacer()
                            // Cancel button (only shown during manual color selection)
                            if vm.showColorSelection {
                                Button("キャンセル") {
                                    vm.showColorSelection = false
                                }
                                .tint(.gray)
                            }
                        }
                        .padding()

                        ColorSelectView(goorback: goorback, lineIndex: lineIndex, onColorSelected: { color in
                            vm.setLineColor(color)
                            vm.showColorSelection = false
                        })
                    }
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
                    .padding()
                    .offset(y: 105)
                    .zIndex(100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            
            // Departure station suggestion list
        }
    }
}

#Preview {
    SelectLineView(goorback: "back1", lineIndex: 0)
        .environment(\.locale, .init(identifier: "ja_JP"))
}

// MARK: - Color Selection View
// Custom view for selecting line colors from predefined color palette
struct ColorSelectView: View {
    let goorback: String
    let lineIndex: Int
    let onColorSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Grid layout for color selection buttons
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(CustomColor.allCases, id: \.self) { color in
                    Button(action: {
                        // Call back when color is selected
                        onColorSelected(color.RGB)
                    }) {
                        VStack {
                            Circle()
                                .fill(Color(color.RGB.colorInt))
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.primaryColor, lineWidth: 1))
                            
                            Text(color.rawValue.localized)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}

// MARK: - File Summary
// This file implements a comprehensive line selection interface for the MyTimeTableMaker app.
// Key components include:
// - TransportationLine data model with multi-language support
// - ODPT API integration for railway data
// - Local file parsing for custom configurations
// - Advanced search and filtering capabilities
// - Station selection with intelligent suggestions
// - Line color customization
// - Data persistence and management
// - Responsive UI with proper state management
