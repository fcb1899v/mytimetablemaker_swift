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
        
        // MARK: - DTO to Model Mapping
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

// MARK: - ODPT Data Source Definition
// Defines the source of ODPT data and provides URL construction.
// Currently supports railway data, extensible for other transportation types.
enum ODPTSource: CaseIterable {
    case railways

    // MARK: - URL Construction
    // Constructs the API URL with consumer key for authentication.
    func url(consumerKey: String) -> URL {
        var components = URLComponents(string: "https://api-public.odpt.org/api/v4/odpt:Railway.json")!
        components.queryItems = [URLQueryItem(name: "acl:consumerKey", value: consumerKey)]
        return components.url!
    }

    // MARK: - Cache File Names
    // Cache file name for storing downloaded data.
    var cacheFile: String {
        return "odpt_railways.json"
    }
    
    // Metadata file name for storing cache information.
    var metaFile: String {
        return "odpt_railways.meta.json"
    }
    
    // MARK: - Display Information
    // Display name for UI presentation.
    var displayName: String {
        return "鉄道"
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
            
            // MARK: - Consumer Key Preservation
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
        if let cached, let meta {
            if (serverETag != nil && serverETag == meta.eTag) ||
               (serverETag == nil && serverLastMod != nil && serverLastMod == meta.lastModified) {
                return (cached, false)
            }
        }

        // MARK: - Step 3: Conditional Update
        // If changes detected, send GET with conditional headers for efficient updates
        var getReq = URLRequest(url: source.url(consumerKey: consumerKey))
        if let meta {
            // Add conditional headers for efficient updates
            if let et = meta.eTag { getReq.setValue(et, forHTTPHeaderField: "If-None-Match") }
            if let lm = meta.lastModified { getReq.setValue(lm, forHTTPHeaderField: "If-Modified-Since") }
        }

        // MARK: - Step 4: Data Retrieval and Caching
        // Execute GET request with conditional headers
        let (data, resp) = try await session.data(for: getReq)
        if let http = resp as? HTTPURLResponse, http.statusCode == 304, let cached {
            // Server returned 304 Not Modified - use cached data
            return (cached, false)
        }

        // Cache new data and metadata
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
    // Fetch data for the first time or when cache is empty.
    // No conditional headers - always downloads fresh data.
    func fetchSimple(source: ODPTSource, consumerKey: String) async throws -> Data {
        let (data, resp) = try await session.data(from: source.url(consumerKey: consumerKey))
        
        // MARK: - Data Caching
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
    // Load cached data without network requests.
    func loadCached(source: ODPTSource) -> Data? { cache.loadData(for: source.cacheFile) }
}