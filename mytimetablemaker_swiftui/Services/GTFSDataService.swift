//
//  GTFSDataService.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/11/23.
//
//  MARK: - Overview
//  Service for managing GTFS data processing and parsing.
//  Handles GTFS ZIP download, extraction, and timetable data processing.

import Foundation
import ZipArchive  // SPM: import ZipArchive, CocoaPods: import SSZipArchive

// MARK: - GTFS Data Service
// Handles GTFS data processing, parsing, and timetable generation
final class GTFSDataService {
    private let cache = CacheStore()
    // In-memory cache for loaded GTFS files (key: directory.path + filename)
    private var fileCache: [String: Data] = [:]
    
    // MARK: - Translation Data Structure
    // Structure to hold GTFS translation data
    private struct TranslationEntry {
        let tableName: String
        let fieldName: String
        let language: String
        let translation: String
        let recordId: String?
        let fieldValue: String?
    }
    
    // MARK: - Load Translations
    // Load translations.txt from GTFS data and return a dictionary for quick lookup
    // Key format: "tableName|fieldName|recordId|language" or "tableName|fieldName|fieldValue|language"
    // Loads English translations for non-Japanese languages
    private func loadTranslations(from extractedDir: URL) -> [String: String] {
        guard let translationsData = try? loadGTFSFile(from: extractedDir, filename: "translations.txt") else {
            return [:]
        }
        
        guard let translations = try? parseGTFSCSV(from: translationsData) else {
            return [:]
        }
        
        var translationDict: [String: String] = [:]
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        // Only load translations for non-Japanese languages
        guard currentLanguage != "ja" else {
            return [:]
        }
        
        // Load English translations (most GTFS feeds only have English translations)
        // Try current language first, then fallback to English
        let targetLanguages = currentLanguage == "en" ? ["en"] : [currentLanguage, "en"]
        
        for row in translations {
            guard let tableName = row["table_name"],
                  let fieldName = row["field_name"],
                  let language = row["language"],
                  let translation = row["translation"],
                  targetLanguages.contains(language) else {
                continue
            }
            
            // Create key based on record_id and/or field_value
            // GTFS translations.txt can have both record_id and field_value, or just one of them
            // Create keys for both to ensure we can find translations regardless of which is used
            if let recordId = row["record_id"], !recordId.isEmpty {
                let key = "\(tableName)|\(fieldName)|\(recordId)"
                // Prefer current language, but allow English as fallback
                if language == currentLanguage || translationDict[key] == nil {
                    translationDict[key] = translation
                }
            }
            if let fieldValue = row["field_value"], !fieldValue.isEmpty {
                let key = "\(tableName)|\(fieldName)|\(fieldValue)"
                // Prefer current language, but allow English as fallback
                if language == currentLanguage || translationDict[key] == nil {
                    translationDict[key] = translation
                }
            }
        }
        
        return translationDict
    }
    
    // MARK: - Convert Fullwidth to Halfwidth
    // Convert fullwidth numbers and alphabets to halfwidth
    private func convertFullwidthToHalfwidth(_ text: String) -> String {
        // Convert fullwidth numbers (０-９) to halfwidth (0-9)
        // Convert fullwidth alphabets (Ａ-Ｚ, ａ-ｚ) to halfwidth (A-Z, a-z)
        var result = text
        let fullwidthNumbers = "０１２３４５６７８９"
        let halfwidthNumbers = "0123456789"
        let fullwidthUpper = "ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ"
        let halfwidthUpper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let fullwidthLower = "ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ"
        let halfwidthLower = "abcdefghijklmnopqrstuvwxyz"
        
        // Replace fullwidth numbers
        for (index, char) in fullwidthNumbers.enumerated() {
            result = result.replacingOccurrences(of: String(char), with: String(halfwidthNumbers[halfwidthNumbers.index(halfwidthNumbers.startIndex, offsetBy: index)]))
        }
        
        // Replace fullwidth uppercase letters
        for (index, char) in fullwidthUpper.enumerated() {
            result = result.replacingOccurrences(of: String(char), with: String(halfwidthUpper[halfwidthUpper.index(halfwidthUpper.startIndex, offsetBy: index)]))
        }
        
        // Replace fullwidth lowercase letters
        for (index, char) in fullwidthLower.enumerated() {
            result = result.replacingOccurrences(of: String(char), with: String(halfwidthLower[halfwidthLower.index(halfwidthLower.startIndex, offsetBy: index)]))
        }
        
        return result
    }
    
    // MARK: - Get Localized Text
    // Get localized text from translations, or return original if Japanese or no translation found
    // Also converts fullwidth numbers and alphabets to halfwidth
    private func getLocalizedText(
        original: String,
        tableName: String,
        fieldName: String,
        recordId: String?,
        translations: [String: String]
    ) -> String {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        var result: String
        
        // Return original for Japanese
        if currentLanguage == "ja" {
            result = original
        } else {
            // Try to get translation
            if let recordId = recordId, !recordId.isEmpty {
                let key = "\(tableName)|\(fieldName)|\(recordId)"
                if let translation = translations[key], !translation.isEmpty {
                    result = translation
                } else {
                    // Try field_value as fallback
                    let key2 = "\(tableName)|\(fieldName)|\(original)"
                    if let translation = translations[key2], !translation.isEmpty {
                        result = translation
                    } else {
                        result = original
                    }
                }
            } else {
                // Try field_value as fallback
                let key = "\(tableName)|\(fieldName)|\(original)"
                if let translation = translations[key], !translation.isEmpty {
                    result = translation
                } else {
                    result = original
                }
            }
        }
        
        // Convert fullwidth numbers and alphabets to halfwidth
        return convertFullwidthToHalfwidth(result)
    }
    
    // MARK: - GTFS Data Processing
    // Download and process GTFS data for operators that use GTFS format.
    // Returns TransportationLine models directly (no intermediate GTFS models).
    // For routes with multiple trip_headsigns (round trips), creates separate lines for each direction.
    func fetchGTFSData(_ transportOperator: LocalDataSource, consumerKey: String) async throws -> [TransportationLine] {
        // Get GTFS URL using apiLink
        let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
        guard !gtfsURL.isEmpty else {
            throw ODPTError.invalidData
        }
        
        // Get extracted directory (uses cache if available)
        let extractedDir = try await getExtractedGTFSDirectory(transportOperator: transportOperator, consumerKey: consumerKey, gtfsURL: gtfsURL)
        
        // Load translations.txt for localization
        let translations = loadTranslations(from: extractedDir)
        
        // Parse routes.txt to get basic route information
        let routesData = try loadGTFSFile(from: extractedDir, filename: "routes.txt")
        let routes = try parseGTFSCSV(from: routesData)
        
        // Parse trips.txt to get trip_headsign and direction_id information for each route
        let tripsData = try loadGTFSFile(from: extractedDir, filename: "trips.txt")
        let trips = try parseGTFSCSV(from: tripsData)
        
        // Group trips by route_id and get unique (trip_headsign, direction_id) combinations for each route
        // Use a struct to represent direction information
        struct DirectionInfo: Hashable {
            let headsign: String?
            let directionId: Int?
            let firstStopId: String?  // First stop_id from stop_times.txt (for routes without headsign/direction_id)
            let lastStopId: String?   // Last stop_id from stop_times.txt (for routes without headsign/direction_id)
        }
        
        // If trip_headsign and direction_id are missing, use stop_times.txt to determine directions
        // Load stop_times.txt to get first and last stop_id for each trip
        // Also load stops.txt to get stop names from stop_id
        var tripEndpoints: [String: (firstStopId: String, lastStopId: String)] = [:]
        var stopsDict: [String: String] = [:]  // stop_id -> stop_name mapping
        
        // Load stops.txt to get stop names
        let stopsData = try? loadGTFSFile(from: extractedDir, filename: "stops.txt")
        if let stopsData = stopsData {
            let stopsRows = try parseGTFSCSV(from: stopsData)
            for row in stopsRows {
                if let stopId = row["stop_id"],
                   let stopName = row["stop_name"] {
                    // Apply translation to stop name
                    let localizedStopName = getLocalizedText(
                        original: stopName,
                        tableName: "stops",
                        fieldName: "stop_name",
                        recordId: stopId,
                        translations: translations
                    )
                    stopsDict[stopId] = localizedStopName
                }
            }
        }
        
        let stopTimesData = try? loadGTFSFile(from: extractedDir, filename: "stop_times.txt")
        if let stopTimesData = stopTimesData {
            let stopTimesRows = try parseGTFSCSV(from: stopTimesData)
            var tripStopSequences: [String: [(stopId: String, sequence: Int)]] = [:]
            
            for row in stopTimesRows {
                guard let tripId = row["trip_id"],
                      let stopId = row["stop_id"],
                      let sequenceStr = row["stop_sequence"],
                      let sequence = Int(sequenceStr) else {
                    continue
                }
                
                if tripStopSequences[tripId] == nil {
                    tripStopSequences[tripId] = []
                }
                tripStopSequences[tripId]?.append((stopId: stopId, sequence: sequence))
            }
            
            // Get first and last stop_id for each trip
            for (tripId, stops) in tripStopSequences {
                let sortedStops = stops.sorted { $0.sequence < $1.sequence }
                if let first = sortedStops.first, let last = sortedStops.last {
                    tripEndpoints[tripId] = (firstStopId: first.stopId, lastStopId: last.stopId)
                }
            }
        }
        
        var routeDirections: [String: Set<DirectionInfo>] = [:]
        for trip in trips {
            guard let routeId = trip["route_id"],
                  let tripId = trip["trip_id"] else {
                continue
            }
            var headsign = trip["trip_headsign"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            // Apply translation to trip_headsign
            if let originalHeadsign = headsign, !originalHeadsign.isEmpty {
                headsign = getLocalizedText(
                    original: originalHeadsign,
                    tableName: "trips",
                    fieldName: "trip_headsign",
                    recordId: tripId,
                    translations: translations
                )
            }
            let directionId = Int(trip["direction_id"] ?? "")
            
            // Get first and last stop_id if available (for routes without headsign/direction_id)
            let endpoints = tripEndpoints[tripId]
            let directionInfo = DirectionInfo(
                headsign: headsign?.isEmpty == false ? headsign : nil,
                directionId: directionId,
                firstStopId: endpoints?.firstStopId,
                lastStopId: endpoints?.lastStopId
            )
            
            if routeDirections[routeId] == nil {
                routeDirections[routeId] = Set<DirectionInfo>()
            }
            routeDirections[routeId]?.insert(directionInfo)
        }
        
        // Create TransportationLine for each route and (trip_headsign, direction_id) combination
        var transportationLines: [TransportationLine] = []
        for route in routes {
            guard let routeId = route["route_id"] else {
                continue
            }
            
            // Get direction info for this route (if any)
            let directions = routeDirections[routeId] ?? []
            
            if directions.isEmpty {
                // No trip information - create single line without direction info
                if let line = try createTransportationLine(from: route, routeId: routeId, tripHeadsign: nil, directionId: nil, directionCode: nil, operatorCode: transportOperator.operatorCode, translations: translations) {
                    transportationLines.append(line)
                }
            } else if directions.count == 1 {
                // Only one direction - create single line
                let direction = directions.first!
                // Use lastStopId's stop name as headsign if headsign is not available (for display)
                let displayHeadsign: String?
                if let headsign = direction.headsign, !headsign.isEmpty {
                    displayHeadsign = headsign
                } else if let lastStopId = direction.lastStopId, let stopName = stopsDict[lastStopId] {
                    // Use stop name from stops.txt instead of stop_id
                    displayHeadsign = stopName
                } else {
                    displayHeadsign = nil
                }
                
                let directionCode: String?
                if let dirId = direction.directionId {
                    directionCode = "\(dirId)"
                } else if let first = direction.firstStopId, let last = direction.lastStopId {
                    directionCode = "\(first)|\(last)"
                } else {
                    directionCode = nil
                }
                
                if let line = try createTransportationLine(from: route, routeId: routeId, tripHeadsign: displayHeadsign, directionId: direction.directionId, directionCode: directionCode, operatorCode: transportOperator.operatorCode, translations: translations) {
                    transportationLines.append(line)
                }
            } else {
                // Multiple directions - create separate line for each direction
                // Sort by direction_id first, then by headsign, then by firstStopId/lastStopId for consistent ordering
                let sortedDirections = directions.sorted { d1, d2 in
                    // First: sort by direction_id if available
                    if let id1 = d1.directionId, let id2 = d2.directionId {
                        return id1 < id2
                    } else if d1.directionId != nil {
                        return true
                    } else if d2.directionId != nil {
                        return false
                    }
                    
                    // Second: sort by headsign if available
                    let headsign1 = d1.headsign ?? ""
                    let headsign2 = d2.headsign ?? ""
                    if !headsign1.isEmpty && !headsign2.isEmpty {
                        return headsign1 < headsign2
                    } else if !headsign1.isEmpty {
                        return true
                    } else if !headsign2.isEmpty {
                        return false
                    }
                    
                    // Third: sort by firstStopId/lastStopId (for routes without headsign/direction_id)
                    if let first1 = d1.firstStopId, let first2 = d2.firstStopId {
                        if first1 != first2 {
                            return first1 < first2
                        }
                        // If first stop is same, compare last stop
                        if let last1 = d1.lastStopId, let last2 = d2.lastStopId {
                            return last1 < last2
                        }
                    }
                    return false
                }
                
                for direction in sortedDirections {
                    // Use lastStopId's stop name as headsign if headsign is not available (for display)
                    // Get stop name from stopsDict if lastStopId is available
                    let displayHeadsign: String?
                    if let headsign = direction.headsign, !headsign.isEmpty {
                        displayHeadsign = headsign
                    } else if let lastStopId = direction.lastStopId, let stopName = stopsDict[lastStopId] {
                        // Use stop name from stops.txt instead of stop_id
                        displayHeadsign = stopName
                    } else {
                        displayHeadsign = nil
                    }
                    
                    // Create unique code: use directionId if available, otherwise use firstStopId/lastStopId
                    let directionCode: String
                    if let dirId = direction.directionId {
                        directionCode = "\(dirId)"
                    } else if let first = direction.firstStopId, let last = direction.lastStopId {
                        // Use first and last stop_id to create unique code (hash or simple combination)
                        directionCode = "\(first)|\(last)"
                    } else {
                        directionCode = ""
                    }
                    
                    if let line = try createTransportationLine(from: route, routeId: routeId, tripHeadsign: displayHeadsign, directionId: direction.directionId, directionCode: directionCode.isEmpty ? nil : directionCode, operatorCode: transportOperator.operatorCode, translations: translations) {
                        transportationLines.append(line)
                    }
                }
            }
        }
        
        // Don't remove tempDir - it may be reused by other functions (e.g., fetchGTFSStopsForRoute, fetchGTFSBusTimetable)
        
        return transportationLines
    }
    
    // MARK: - GTFS ZIP Download (Public)
    // Download GTFS ZIP file and extract it for caching at startup.
    // This is used to pre-download and extract ZIP files at startup for faster access later.
    func downloadGTFSZipOnly(url: String, consumerKey: String, transportOperator: LocalDataSource) async throws -> Data {
        return try await downloadGTFSZip(url: url, consumerKey: consumerKey, transportOperator: transportOperator)
    }
    
    // MARK: - GTFS ZIP Download
    // Download GTFS ZIP file from ODPT API with consumer key authentication.
    // Uses cache to avoid re-downloading the same file.
    // For operators with date in GTFSDates, cache key includes date.
    // For Toei Bus (no date), uses ETag/Last-Modified for conditional GET to detect updates.
    private func downloadGTFSZip(url: String, consumerKey: String, transportOperator: LocalDataSource? = nil) async throws -> Data {
        // transportOperator must be provided for GTFS
        guard let transportOp = transportOperator else {
            throw ODPTError.invalidData
        }
        
        // Generate cache key from transport operator
        // cacheKey includes date, so if cached file exists, it's already for the correct date
        // For Toei Bus, date is empty, so use different cache key format
        let date = GTFSDates.date(for: transportOp) ?? ""
        let gtfsFileName = transportOp.gtfsFileName
        let cacheKey = date.isEmpty ? "gtfs_\(gtfsFileName).zip" : "gtfs_\(gtfsFileName)_\(date).zip"
        
        // Check if cached file exists
        if let cachedData = cache.loadData(for: cacheKey) {
            // Check if extracted directory is also cached
            let extractedCacheDirName = cacheKey.replacingOccurrences(of: ".zip", with: "_extracted")
            if !cache.directoryExists(for: extractedCacheDirName) {
                // ZIP is cached but extracted directory is not, extract it now
                print("📦 ZIP cached but extracted directory not found, extracting...")
                try await extractAndCacheGTFSZip(data: cachedData, transportOperator: transportOp, cacheKey: cacheKey)
            }
            
            // For Toei Bus, check if server has updated file using conditional GET
            // For other operators with date, cache key includes date, so cached file is already for the correct date
            if transportOp == .toeiBus {
                // Toei Bus: Use conditional GET to check if file has been updated
                if let updatedData = try await checkForToeiBusGTFSUpdate(urlString: url, cacheKey: cacheKey) {
                    // File was updated, return new data
                    return updatedData
                } else {
                    // File not modified, return cached data
                    print("📦 Using cached GTFS ZIP (not modified): \(cacheKey) (\(cachedData.count) bytes)")
                    return cachedData
                }
            } else {
                // Operator with date: cache key includes date, so cached file is already for the correct date
                print("📦 Using cached GTFS ZIP: \(cacheKey) (\(cachedData.count) bytes, date: \(date))")
                return cachedData
            }
        }
        
        // No cache exists, download new file
        return try await downloadNewGTFSZip(url: url, consumerKey: consumerKey, transportOperator: transportOp, cacheKey: cacheKey)
    }
    
    // MARK: - Check for Toei Bus GTFS Update (Conditional GET)
    // Check if Toei Bus GTFS ZIP file has been updated on the server using conditional GET.
    // This function is only for Toei Bus (operators without date in GTFSDates).
    // Returns new data if updated, nil if not modified.
    private func checkForToeiBusGTFSUpdate(urlString: String, cacheKey: String) async throws -> Data? {
        guard let url = URL(string: urlString) else {
            throw ODPTError.invalidData
        }
        
        // Get ETag and Last-Modified from UserDefaults
        let etagKey = "\(cacheKey)_etag"
        let lastModifiedKey = "\(cacheKey)_last_modified"
        let etag = UserDefaults.standard.string(forKey: etagKey)
        let lastModified = UserDefaults.standard.string(forKey: lastModifiedKey)
        
        // If no ETag/Last-Modified, can't use conditional GET, so download new file
        guard etag != nil || lastModified != nil else {
            print("⚠️ No ETag/Last-Modified for \(cacheKey), downloading new file")
            return try await downloadNewGTFSZip(url: urlString, consumerKey: "", transportOperator: .toeiBus, cacheKey: cacheKey)
        }
        
        var request = URLRequest(url: url)
        // Toei Bus uses public API, no access token needed
        request.setValue("application/zip", forHTTPHeaderField: "Accept")
        
        // Add conditional headers
        if let etag = etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }
        if let lastModified = lastModified {
            request.setValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
        }
        
        print("🔍 Checking for GTFS update using conditional GET: \(url.absoluteString)")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ODPTError.networkError("Invalid response")
        }
        
        // Handle 304 Not Modified
        if httpResponse.statusCode == 304 {
            print("✅ GTFS ZIP not modified (304), using cached file")
            return nil // File not modified, use cached data
        }
        
        // Handle 200 OK (file was updated)
        guard httpResponse.statusCode == 200 else {
            throw ODPTError.networkError("HTTP \(httpResponse.statusCode)")
        }
        
        print("🔄 GTFS ZIP updated on server, downloading new file")
        
        // Save ETag and Last-Modified for future conditional GET
        if let newEtag = httpResponse.value(forHTTPHeaderField: "ETag") {
            UserDefaults.standard.set(newEtag, forKey: etagKey)
        }
        if let newLastModified = httpResponse.value(forHTTPHeaderField: "Last-Modified") {
            UserDefaults.standard.set(newLastModified, forKey: lastModifiedKey)
        }
        
        // Save new data to cache
        cache.saveData(data, for: cacheKey)
        print("✅ Downloaded and cached updated GTFS ZIP: \(data.count) bytes")
        
        // Extract and cache the extracted directory
        try await extractAndCacheGTFSZip(data: data, transportOperator: .toeiBus, cacheKey: cacheKey)
        
        return data
    }
    
    // MARK: - Download New GTFS ZIP
    // Download a new GTFS ZIP file from the server.
    private func downloadNewGTFSZip(url: String, consumerKey: String, transportOperator: LocalDataSource, cacheKey: String) async throws -> Data {
        guard let url = URL(string: url) else {
            throw ODPTError.invalidData
        }
        
        var request = URLRequest(url: url)
        // Toei Bus uses public API, no access token needed
        if transportOperator != .toeiBus {
            request.setValue(consumerKey, forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/zip", forHTTPHeaderField: "Accept")
        
        print("🔗 Downloading GTFS ZIP from: \(url.absoluteString)")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ODPTError.networkError("Invalid response")
        }
        
        // Handle redirects
        if httpResponse.statusCode == 301 || httpResponse.statusCode == 302 {
            if let location = httpResponse.value(forHTTPHeaderField: "Location"),
               let redirectURL = URL(string: location) {
                print("🔄 Redirecting to: \(location)")
                let (redirectData, redirectResponse) = try await URLSession.shared.data(from: redirectURL)
                guard let redirectHttpResponse = redirectResponse as? HTTPURLResponse,
                      redirectHttpResponse.statusCode == 200 else {
                    throw ODPTError.networkError("Failed to download from redirect URL")
                }
                
                // Save ETag and Last-Modified for future conditional GET
                let etagKey = "\(cacheKey)_etag"
                let lastModifiedKey = "\(cacheKey)_last_modified"
                if let etag = redirectHttpResponse.value(forHTTPHeaderField: "ETag") {
                    UserDefaults.standard.set(etag, forKey: etagKey)
                }
                if let lastModified = redirectHttpResponse.value(forHTTPHeaderField: "Last-Modified") {
                    UserDefaults.standard.set(lastModified, forKey: lastModifiedKey)
                }
                
                // Save to cache
                cache.saveData(redirectData, for: cacheKey)
                print("✅ Downloaded and cached GTFS ZIP: \(redirectData.count) bytes")
                
                // Extract and cache the extracted directory
                try await extractAndCacheGTFSZip(data: redirectData, transportOperator: transportOperator, cacheKey: cacheKey)
                
                return redirectData
            }
        }
        
        guard httpResponse.statusCode == 200 else {
            throw ODPTError.networkError("HTTP \(httpResponse.statusCode)")
        }
        
        // Save ETag and Last-Modified for future conditional GET
        let etagKey = "\(cacheKey)_etag"
        let lastModifiedKey = "\(cacheKey)_last_modified"
        if let etag = httpResponse.value(forHTTPHeaderField: "ETag") {
            UserDefaults.standard.set(etag, forKey: etagKey)
        }
        if let lastModified = httpResponse.value(forHTTPHeaderField: "Last-Modified") {
            UserDefaults.standard.set(lastModified, forKey: lastModifiedKey)
        }
        
        // Save to cache
        cache.saveData(data, for: cacheKey)
        print("✅ Downloaded and cached GTFS ZIP: \(data.count) bytes")
        
        // Extract and cache the extracted directory
        try await extractAndCacheGTFSZip(data: data, transportOperator: transportOperator, cacheKey: cacheKey)
        
        return data
    }
    
    // MARK: - Extract and Cache GTFS ZIP
    // Extract GTFS ZIP file and save the extracted directory to cache.
    private func extractAndCacheGTFSZip(data: Data, transportOperator: LocalDataSource, cacheKey: String) async throws {
        // Generate cache directory name from cache key
        let extractedCacheDirName = cacheKey.replacingOccurrences(of: ".zip", with: "_extracted")
        
        // Check if extracted directory is already cached
        if cache.directoryExists(for: extractedCacheDirName) {
            print("✅ Extracted directory already cached: \(extractedCacheDirName)")
            return
        }
        
        // Extract to temporary directory first
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("gtfs_extract_temp_\(UUID().uuidString)", isDirectory: true)
        let extractedDir = try extractGTFSZipToTemp(data: data, to: tempDir)
        
        // Copy extracted directory to cache
        try cache.saveDirectory(from: extractedDir, for: extractedCacheDirName)
        print("✅ Cached extracted GTFS directory: \(extractedCacheDirName)")
        
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    // MARK: - Extract GTFS ZIP to Temporary Directory
    // Extract GTFS ZIP file to a temporary directory (for caching purposes).
    private func extractGTFSZipToTemp(data: Data, to directory: URL) throws -> URL {
        let fileManager = FileManager.default
        let extractedDir = directory.appendingPathComponent("extracted", isDirectory: true)
        
        let zipURL = directory.appendingPathComponent("gtfs.zip")
        
        // Create directory if needed
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        
        // Write ZIP data to file
        try data.write(to: zipURL)
        
        // Extract using ZipArchive library
        try fileManager.createDirectory(at: extractedDir, withIntermediateDirectories: true, attributes: nil)
        
        let success = SSZipArchive.unzipFile(atPath: zipURL.path, toDestination: extractedDir.path)
        guard success else {
            throw ODPTError.networkError("Failed to extract ZIP file using ZipArchive")
        }
        
        // Remove temporary ZIP file
        try? fileManager.removeItem(at: zipURL)
        
        return extractedDir
    }
    
    // MARK: - Get Extracted GTFS Directory
    // Get extracted GTFS directory, using cache if available, otherwise download and extract.
    // Returns URL of extracted directory.
    // Uses cached directory directly if available (no copying needed since it's read-only).
    private func getExtractedGTFSDirectory(transportOperator: LocalDataSource, consumerKey: String, gtfsURL: String) async throws -> URL {
        let date = GTFSDates.date(for: transportOperator) ?? ""
        let gtfsFileName = transportOperator.gtfsFileName
        let cacheKey = date.isEmpty ? "gtfs_\(gtfsFileName).zip" : "gtfs_\(gtfsFileName)_\(date).zip"
        let extractedCacheDirName = cacheKey.replacingOccurrences(of: ".zip", with: "_extracted")
        
        // Check if extracted directory is already cached
        if let cachedExtractedDir = cache.loadDirectoryPath(for: extractedCacheDirName) {
            // Verify that routes.txt exists (valid extracted directory)
            let routesFile = cachedExtractedDir.appendingPathComponent("routes.txt")
            if FileManager.default.fileExists(atPath: routesFile.path) {
                // Use cached directory directly (read-only access, no copying needed)
                print("📂 Using cached GTFS directory: \(cachedExtractedDir.path)")
                return cachedExtractedDir
            }
        }
        
        // Cache not available or invalid, download and extract
        // downloadGTFSZip() will call extractAndCacheGTFSZip() to cache the extracted directory
        print("📦 Extracted directory not in cache, downloading and extracting ZIP")
        _ = try await downloadGTFSZip(url: gtfsURL, consumerKey: consumerKey, transportOperator: transportOperator)
        
        // After download and extraction, the directory should be in cache
        guard let cachedExtractedDir = cache.loadDirectoryPath(for: extractedCacheDirName) else {
            throw ODPTError.networkError("Failed to cache extracted GTFS directory")
        }
        
        // Verify that routes.txt exists (valid extracted directory)
        let routesFile = cachedExtractedDir.appendingPathComponent("routes.txt")
        guard FileManager.default.fileExists(atPath: routesFile.path) else {
            throw ODPTError.networkError("Extracted GTFS directory is invalid")
        }
        
        print("📂 Using cached GTFS directory: \(cachedExtractedDir.path)")
        return cachedExtractedDir
    }
    
    // MARK: - Load GTFS File
    // Load a GTFS file from extracted directory.
    // Uses in-memory cache to avoid reading the same file multiple times.
    private func loadGTFSFile(from directory: URL, filename: String) throws -> Data {
        let cacheKey = "\(directory.path)/\(filename)"
        
        // Check cache first
        if let cachedData = fileCache[cacheKey] {
            print("📄 Using cached GTFS file: \(filename) from \(directory.path)")
            return cachedData
        }
        
        // Load from disk
        let fileURL = directory.appendingPathComponent(filename)
        print("📄 Loading GTFS file: \(filename) from \(directory.path)")
        let data = try Data(contentsOf: fileURL)
        
        // Cache for future use
        fileCache[cacheKey] = data
        
        return data
    }
    
    // MARK: - Fetch GTFS Stops for Route
    // Fetch bus stops for a specific GTFS route.
    // Process: route_id + direction_id -> trip_id list -> stop_id list (from first trip) -> stop names
    // Downloads and parses GTFS data to get stop information for the selected route.
    func fetchGTFSStopsForRoute(_ routeId: String, transportOperator: LocalDataSource, consumerKey: String) async throws -> [TransportationStop] {
        // Get GTFS URL using apiLink
        let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
        guard !gtfsURL.isEmpty else {
            throw ODPTError.invalidData
        }
        
        // Extract route_id and direction info from code
        // Format: "route_id" or "route_id_directionId" or "route_id_directionCode"
        // Note: route_id itself never contains "|", so "|" in the code indicates directionCode format
        // directionCode uses "|" as separator between firstStopId and lastStopId
        // route_id and directionCode are separated by a single "_" (code = "route_id_directionCode")
        let originalRouteId: String
        var targetDirectionId: Int? = nil
        var targetFirstStopId: String? = nil
        var targetLastStopId: String? = nil
        
        // Check if code contains "|" (indicates directionCode format, since route_id never contains "|")
        if routeId.contains("|") {
            // Format: "route_id_directionCode" where directionCode = "firstStopId|lastStopId"
            // route_id and directionCode are separated by a single "_"
            // Find the first "_" to separate route_id and directionCode
            if let firstUnderscoreIndex = routeId.firstIndex(of: "_") {
                originalRouteId = String(routeId[..<firstUnderscoreIndex])
                let directionCode = String(routeId[routeId.index(after: firstUnderscoreIndex)...])
                // Parse directionCode: "firstStopId|lastStopId"
                let directionCodeParts = directionCode.split(separator: "|")
                if directionCodeParts.count >= 2 {
                    targetFirstStopId = String(directionCodeParts[0])
                    targetLastStopId = directionCodeParts[1..<directionCodeParts.count].joined(separator: "|")
                }
            } else {
                originalRouteId = routeId
            }
        } else {
            // No "|" found, so it's either "route_id" or "route_id_directionId" format
            let parts = routeId.split(separator: "_")
            originalRouteId = String(parts[0])
            
            if parts.count >= 2 {
                // Check if second part is a number (direction_id)
                if let dirId = Int(String(parts[1])) {
                    // It's a direction_id (single digit: 0 or 1)
                    targetDirectionId = dirId
                }
            }
        }
        
        // Get extracted directory (uses cache if available)
        let extractedDir = try await getExtractedGTFSDirectory(transportOperator: transportOperator, consumerKey: consumerKey, gtfsURL: gtfsURL)
        
        // Load translations.txt for localization
        let translations = loadTranslations(from: extractedDir)
        
        // Step 1: Get trips for the selected route_id and direction info from trips.txt
        // Create trip_id list filtered by route_id and direction_id or firstStopId/lastStopId
        let tripsData = try loadGTFSFile(from: extractedDir, filename: "trips.txt")
        let allTrips = try parseGTFSTripsForRoute(from: tripsData, routeId: originalRouteId)
        
        // Load stop_times.txt once (needed for both filtering and getting stop list)
        let stopTimesData = try loadGTFSFile(from: extractedDir, filename: "stop_times.txt")
        let stopTimesRows = try parseGTFSCSV(from: stopTimesData)
        
        // If direction_id is specified, filter by direction_id
        // Otherwise, if firstStopId/lastStopId is specified, filter by matching trip endpoints
        var filteredTrips = allTrips
        if let targetDirId = targetDirectionId {
            // Filter by direction_id
            filteredTrips = allTrips.filter { trip in
                trip.directionId == targetDirId
            }
        } else if let firstStopId = targetFirstStopId, let lastStopId = targetLastStopId {
            // Filter by firstStopId/lastStopId: need to check stop_times.txt for each trip
            // Get first and last stop_id for each trip
            var tripEndpoints: [String: (firstStopId: String, lastStopId: String)] = [:]
            var tripStopSequences: [String: [(stopId: String, sequence: Int)]] = [:]
            
            for row in stopTimesRows {
                guard let tripId = row["trip_id"],
                      let stopId = row["stop_id"],
                      let sequenceStr = row["stop_sequence"],
                      let sequence = Int(sequenceStr) else {
                    continue
                }
                
                if tripStopSequences[tripId] == nil {
                    tripStopSequences[tripId] = []
                }
                tripStopSequences[tripId]?.append((stopId: stopId, sequence: sequence))
            }
            
            // Get first and last stop_id for each trip
            for (tripId, stops) in tripStopSequences {
                let sortedStops = stops.sorted { $0.sequence < $1.sequence }
                if let first = sortedStops.first, let last = sortedStops.last {
                    tripEndpoints[tripId] = (firstStopId: first.stopId, lastStopId: last.stopId)
                }
            }
            
            // Filter trips that match the target firstStopId/lastStopId
            filteredTrips = allTrips.filter { trip in
                if let endpoints = tripEndpoints[trip.tripId] {
                    return endpoints.firstStopId == firstStopId && endpoints.lastStopId == lastStopId
                }
                return false
            }
        }
        
        guard !filteredTrips.isEmpty else {
            print("⚠️ fetchGTFSStopsForRoute: No trips found for routeId=\(routeId), originalRouteId=\(originalRouteId), targetDirectionId=\(targetDirectionId?.description ?? "nil"), targetFirstStopId=\(targetFirstStopId ?? "nil"), targetLastStopId=\(targetLastStopId ?? "nil"), allTrips.count=\(allTrips.count)")
            // Don't remove tempDir - it may be reused by other functions
            return []
        }
        
        // Step 2: Get stop_times for the trip (1st trip_id, or 0th if 1st doesn't exist) to get stop_id list
        // Use 1st trip_id if available, otherwise use 0th (to skip depot-only trips)
        let selectedTrip = filteredTrips[filteredTrips.count > 1 ? 1 : 0]
        
        // stopTimesRows is already loaded above
        // Filter stop_times for the selected trip and sort by stop_sequence
        let tripStopTimes = stopTimesRows
            .filter { $0["trip_id"] == selectedTrip.tripId }  // Extract only matching 1st trip_id (or 0th)
            .compactMap { row -> (stopId: String, sequence: Int)? in
                guard let stopId = row["stop_id"],
                      let sequenceStr = row["stop_sequence"],
                      let sequence = Int(sequenceStr) else {
                    return nil
                }
                return (stopId: stopId, sequence: sequence)
            }
            .sorted { $0.sequence < $1.sequence }
        
        // Step 3: Get stops information from stops.txt
        // Create a dictionary of stop_id -> stop_name
        let stopsData = try loadGTFSFile(from: extractedDir, filename: "stops.txt")
        let stopsRows = try parseGTFSCSV(from: stopsData)
        
        var stopsDict: [String: String] = [:]
        for row in stopsRows {
            if let stopId = row["stop_id"],
               let stopName = row["stop_name"] {
                // Apply translation to stop name
                let localizedStopName = getLocalizedText(
                    original: stopName,
                    tableName: "stops",
                    fieldName: "stop_name",
                    recordId: stopId,
                    translations: translations
                )
                stopsDict[stopId] = localizedStopName
            }
        }
        
        // Convert to TransportationStop models
        // First stop_id is departure stop, last is destination
        let transportationStops = tripStopTimes.enumerated().compactMap { index, stopTime -> TransportationStop? in
            guard let stopName = stopsDict[stopTime.stopId] else {
                return nil
            }
            
            return TransportationStop(
                kind: .bus,
                name: stopName,
                code: stopTime.stopId,
                index: index,
                lineCode: originalRouteId,
                title: LocalizedTitle(ja: stopName, en: nil),
                note: stopName,
                busstopPole: stopTime.stopId
            )
        }
        
        // Don't remove tempDir - it may be reused by other functions (e.g., fetchGTFSBusTimetable, fetchGTFSCalendarTypes)
        
        return transportationStops
    }
    
    // MARK: - Parse GTFS CSV File
    // Parse a GTFS CSV file and return array of dictionaries.
    private func parseGTFSCSV(from data: Data) throws -> [[String: String]] {
        guard let content = String(data: data, encoding: .utf8) else {
            throw ODPTError.invalidData
        }
        
        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard !lines.isEmpty else {
            return []
        }
        
        // Parse header
        let header = parseCSVLine(lines[0])
        guard !header.isEmpty else {
            throw ODPTError.invalidData
        }
        
        // Parse data rows
        var results: [[String: String]] = []
        for i in 1..<lines.count {
            let values = parseCSVLine(lines[i])
            guard values.count == header.count else {
                continue // Skip malformed rows
            }
            
            var row: [String: String] = [:]
            for (index, key) in header.enumerated() {
                row[key] = index < values.count ? values[index] : ""
            }
            results.append(row)
        }
        
        return results
    }
    
    // MARK: - Parse CSV Line
    // Parse a single CSV line, handling quoted fields.
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)
        
        return result.map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    // MARK: - Create Transportation Line from Route
    // Creates a TransportationLine from a route row, optionally including trip_headsign and direction_id for direction distinction.
    // directionCode: Additional code for direction distinction (used when directionId is nil, e.g., "firstStopId_lastStopId")
    private func createTransportationLine(from route: [String: String], routeId: String, tripHeadsign: String?, directionId: Int?, directionCode: String?, operatorCode: String?, translations: [String: String] = [:]) throws -> TransportationLine? {
        // Get route name: prioritize route_short_name, fallback to route_long_name
        // Some operators (like Keisei Transit Bus) may have empty route_short_name
        var routeShortName = route["route_short_name"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        var routeLongName = route["route_long_name"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Apply translations to route names
        if let originalShortName = routeShortName, !originalShortName.isEmpty {
            routeShortName = getLocalizedText(
                original: originalShortName,
                tableName: "routes",
                fieldName: "route_short_name",
                recordId: routeId,
                translations: translations
            )
        }
        if let originalLongName = routeLongName, !originalLongName.isEmpty {
            routeLongName = getLocalizedText(
                original: originalLongName,
                tableName: "routes",
                fieldName: "route_long_name",
                recordId: routeId,
                translations: translations
            )
        }
        
        let shortName = (routeShortName?.isEmpty == false ? routeShortName : nil) ?? (routeLongName?.isEmpty == false ? routeLongName : nil)
        guard let shortName = shortName else {
            return nil // Skip routes without both route_short_name and route_long_name
        }
        
        // Use trip_headsign as destination if available, otherwise extract from route_long_name
        var destinationStop: String? = nil
        var departureStop: String? = nil
        
        if let headsign = tripHeadsign, !headsign.isEmpty {
            // Use trip_headsign as destination
            destinationStop = headsign
        } else if let longName = routeLongName, longName.contains("〜") {
            // Extract destination stop from route_long_name (format: "発車停〜到着停")
            let components = longName.components(separatedBy: "〜")
            if components.count >= 2 {
                // Get the first component as departure stop
                departureStop = components.first?.trimmingCharacters(in: .whitespaces)
                // Get the last component as destination stop
                let rawDestination = components.last?.trimmingCharacters(in: .whitespaces)
                
                // Clean destination: remove parentheses and extra info
                if let dest = rawDestination {
                    // Remove content in parentheses (including the parentheses)
                    if let parenRange = dest.range(of: "（") {
                        destinationStop = String(dest[..<parenRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                    } else if let parenRange = dest.range(of: "(") {
                        destinationStop = String(dest[..<parenRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                    } else {
                        // Remove trailing "）" or ")" if present
                        var cleaned = dest.trimmingCharacters(in: .whitespaces)
                        if cleaned.hasSuffix("）") {
                            cleaned = String(cleaned.dropLast())
                        } else if cleaned.hasSuffix(")") {
                            cleaned = String(cleaned.dropLast())
                        }
                        destinationStop = cleaned.isEmpty ? nil : cleaned
                    }
                }
            }
        }
        
        // Build route name: add destination if route_short_name exists (not fallback)
        // If trip_headsign is available, use it as destination
        let destinationPrefix = "Route destination prefix".localized
        let destinationSuffix = "Route destination suffix".localized
        let routeName: String
        if let headsign = tripHeadsign, !headsign.isEmpty {
            // Use trip_headsign as destination
            let destination = "\(headsign)\(destinationSuffix)".replacingOccurrences(of: "行 行", with: "行", options: [], range: nil)
            routeName = "\(shortName)\(destinationPrefix)\(destination)"
        } else if routeShortName?.isEmpty == false && destinationStop?.isEmpty == false {
            let destination = "\(destinationStop!)\(destinationSuffix)".replacingOccurrences(of: "行 行", with: "行", options: [], range: nil)
            routeName = "\(shortName)\(destinationPrefix)\(destination)"
        } else {
            routeName = shortName
        }
        
        // Convert fullwidth numbers and alphabets to halfwidth
        let cleanedRouteName = convertFullwidthToHalfwidth(routeName)
        
        // Create unique code: route_id + direction_id or directionCode (trip_headsign is only for display)
        // Format: "route_id_directionId" or "route_id_directionCode" or "route_id"
        let code: String
        if let dirId = directionId {
            code = "\(routeId)_\(dirId)"
        } else if let dirCode = directionCode, !dirCode.isEmpty {
            code = "\(routeId)_\(dirCode)"
        } else {
            code = routeId
        }
        
        return TransportationLine(
            kind: .bus,
            name: cleanedRouteName,
            code: code,
            operatorCode: operatorCode,
            lineColor: route["route_color"],
            startStation: departureStop,  // Store departure stop in startStation
            endStation: destinationStop,  // Store destination stop in endStation
            destinationStation: destinationStop,  // Also store in destinationStation
            railwayTitle: LocalizedTitle(ja: cleanedRouteName, en: nil),
            lineCode: nil,  // GTFS routes don't use lineCode
            lineDirection: nil,
            ascendingRailDirection: nil,
            descendingRailDirection: nil,
            busRoute: routeId,  // Keep original route_id for trip lookup
            pattern: nil,
            busDirection: nil,
            busstopPoleOrder: nil,
            title: cleanedRouteName
        )
    }
    
    // MARK: - Get Available Calendar Types from GTFS
    // Get all available calendar types from GTFS calendar.txt file.
    // Returns all calendar types that exist in the GTFS data (weekday, saturday, sunday, holiday).
    func getAvailableGTFSCalendarTypes(from data: Data) throws -> [ODPTCalendarType] {
        let rows = try parseGTFSCSV(from: data)
        
        var calendarTypes: Set<ODPTCalendarType> = []
        
        for row in rows {
            
            // Skip service_ids with all days set to 0 (they only run on dates in calendar_dates.txt)
            let allDaysZero = row.weekdayCount == 0 && !row.saturday && !row.sunday
            if allDaysZero {
                continue
            }

            // Determine calendar type for this service_id (one type per service_id)
            let calendarType: ODPTCalendarType? =
                row.weekdayCount == 0 && row.saturday && row.sunday ? .saturdayHoliday:
                row.weekdayCount == 0 && row.saturday && !row.sunday ? .saturday:
                row.weekdayCount == 0 && !row.saturday && row.sunday ? .sunday:
                row.weekdayCount == 1 && row.monday ? .monday: 
                row.weekdayCount == 1 && row.tuesday ? .tuesday: 
                row.weekdayCount == 1 && row.wednesday ? .wednesday: 
                row.weekdayCount == 1 && row.thursday ? .thursday: 
                row.weekdayCount == 1 && row.friday ? .friday:
                row.weekdayCount >= 2 ? .weekday:
                nil
            
            if let calendarType = calendarType {
                calendarTypes.insert(calendarType)
            }
        }
        
        return Array(calendarTypes)
    }
    
    // MARK: - Fetch GTFS Calendar Types
    // Download GTFS ZIP and extract calendar types for a specific route from calendar.txt and calendar_dates.txt.
    func fetchGTFSCalendarTypes(routeId: String, transportOperator: LocalDataSource, consumerKey: String) async throws -> [ODPTCalendarType] {
        // Get GTFS URL using apiLink
        let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
        guard !gtfsURL.isEmpty else {
            throw ODPTError.invalidData
        }
        
        // Get extracted directory (uses cache if available)
        let extractedDir = try await getExtractedGTFSDirectory(transportOperator: transportOperator, consumerKey: consumerKey, gtfsURL: gtfsURL)
        
        // Extract original route_id from code (code may be "route_id_directionId" or "route_id_firstStopId|lastStopId" format)
        let parts = routeId.split(separator: "_")
        let originalRouteId = String(parts[0])
        
        // Get trips for the selected route_id to get service_ids for this route
        let tripsData = try loadGTFSFile(from: extractedDir, filename: "trips.txt")
        let trips = try parseGTFSTripsForRoute(from: tripsData, routeId: originalRouteId)
        
        guard !trips.isEmpty else {
            // Don't remove tempDir - it may be reused by other functions
            print("⚠️ No trips found for routeId: \(routeId)")
            return [.weekday, .saturday, .holiday]
        }
        
        // Get unique service_ids for this route
        let routeServiceIds = Set(trips.map { $0.serviceId })
        print("🔍 GTFS Calendar Types Debug - routeId: \(routeId), found \(routeServiceIds.count) unique service_ids: \(routeServiceIds)")
        
        let calendarFileURL = extractedDir.appendingPathComponent("calendar.txt")
        
        let calendarExists = FileManager.default.fileExists(atPath: calendarFileURL.path)
        
        var calendarTypes: Set<ODPTCalendarType> = []
        
        // Case 1 & 2: calendar.txt exists - filter by route service_ids
        if calendarExists {
            let calendarData = try loadGTFSFile(from: extractedDir, filename: "calendar.txt")
            let rows = try parseGTFSCSV(from: calendarData)
            
            for row in rows {
                guard let serviceId = row["service_id"],
                      routeServiceIds.contains(serviceId) else {
                    continue
                }
                
                // Skip service_ids with all days set to 0
                let allDaysZero = row.weekdayCount == 0 && !row.saturday && !row.sunday
                if allDaysZero {
                    continue
                }
                
                // Determine calendar type for this service_id
                let calendarType: ODPTCalendarType? =
                    row.weekdayCount == 0 && row.saturday && row.sunday ? .saturdayHoliday:
                    row.weekdayCount == 0 && !row.saturday && row.sunday ? .holiday:
                    row.weekdayCount == 0 && row.saturday && !row.sunday ? .saturday:
                    row.weekdayCount == 1 && row.monday && !row.saturday && !row.sunday ? .monday:
                    row.weekdayCount == 1 && row.tuesday && !row.saturday && !row.sunday ? .tuesday:
                    row.weekdayCount == 1 && row.wednesday && !row.saturday && !row.sunday ? .wednesday:
                    row.weekdayCount == 1 && row.thursday && !row.saturday && !row.sunday ? .thursday:
                    row.weekdayCount == 1 && row.friday && !row.saturday && !row.sunday ? .friday:
                    row.weekdayCount >= 2 && !row.saturday && !row.sunday ? .weekday:
                    nil
                
                if let calendarType = calendarType {
                    calendarTypes.insert(calendarType)
                }
            }
        } 
        
        // Don't remove tempDir - it may be reused by other functions (e.g., fetchGTFSBusTimetable)
        
        // Case 3: calendar.txt doesn't exist, return default types
        if calendarTypes.isEmpty {
            print("⚠️ calendar.txt not found or no matching service_ids for routeId: \(routeId) - using default calendar types")
            return [.weekday, .holiday]
        }
        
        print("📅 GTFS Calendar Types for routeId \(routeId): \(Array(calendarTypes).map { $0.displayName }.joined(separator: ", "))")
        return Array(calendarTypes)
    }
    
    // MARK: - Parse GTFS Trips for Route
    // Parse trips.txt to get trip information for a specific route.
    func parseGTFSTripsForRoute(from data: Data, routeId: String) throws -> [(tripId: String, serviceId: String, directionId: Int?, tripHeadsign: String?)] {
        let rows = try parseGTFSCSV(from: data)
        
        return rows.compactMap { row in
            guard let tripRouteId = row["route_id"],
                  tripRouteId == routeId,
                  let tripId = row["trip_id"],
                  let serviceId = row["service_id"] else {
                return nil
            }
            
            return (
                tripId: tripId,
                serviceId: serviceId,
                directionId: Int(row["direction_id"] ?? ""),
                tripHeadsign: row["trip_headsign"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
    }
    
    // MARK: - Check Calendar Type Match from calendar.txt Row
    // Check if a calendar.txt row matches the requested calendar type.
    // This is a helper function to avoid code duplication.
    private func calendarRowMatchesCalendarType(
        row: [String: String],
        calendarType: ODPTCalendarType
    ) -> Bool {
        switch calendarType {
        case .saturdayHoliday:  return row.weekdayCount == 0 && row.saturday && row.sunday
        case .holiday:          return row.weekdayCount == 0 && !row.saturday && row.sunday
        case .saturday:         return row.weekdayCount == 0 && row.saturday && !row.sunday
        case .monday:           return row.weekdayCount == 1 && row.monday && !row.saturday && !row.sunday
        case .tuesday:          return row.weekdayCount == 1 && row.tuesday && !row.saturday && !row.sunday
        case .wednesday:        return row.weekdayCount == 1 && row.wednesday && !row.saturday && !row.sunday
        case .thursday:         return row.weekdayCount == 1 && row.thursday && !row.saturday && !row.sunday
        case .friday:           return row.weekdayCount == 1 && row.friday && !row.saturday && !row.sunday
        case .sunday:           return row.weekdayCount == 0 && !row.saturday && row.sunday
        case .weekday:          return row.weekdayCount >= 2 && !row.saturday && !row.sunday
        case .specific:         return false
        }
    }
    
    // MARK: - Check if Service ID Matches Calendar Type
    // Check if a specific service_id matches the requested calendar type.
    // This method is used when we have trips with known service_ids and need to filter them.
    private func serviceIdMatchesCalendarType(
        serviceId: String,
        calendarData: Data?,
        calendarDatesData: Data?,
        calendarType: ODPTCalendarType
    ) throws -> Bool {
        // If calendar.txt exists, check if service_id matches calendar type
        if let calendarData = calendarData {
            let rows = try parseGTFSCSV(from: calendarData)
            
            if let row = rows.first(where: { $0["service_id"] == serviceId }) {
                let allDaysZero = row.weekdayCount == 0 && !row.saturday && !row.sunday

                if allDaysZero {
                    // Check calendar_dates.txt for this service_id
                    return try checkCalendarDatesExceptions(
                        serviceId: serviceId,
                        calendarDatesData: calendarDatesData,
                        calendarType: calendarType,
                        baseMatches: false
                    )
                }
                
                let matches = calendarRowMatchesCalendarType(row: row, calendarType: calendarType)
                
                // If calendar.txt says it matches, check calendar_dates.txt for exceptions
                if matches {
                    return try checkCalendarDatesExceptions(
                        serviceId: serviceId,
                        calendarDatesData: calendarDatesData,
                        calendarType: calendarType,
                        baseMatches: true
                    )
                } else {
                    // Even if calendar.txt says it doesn't match, check calendar_dates.txt for added service
                    return try checkCalendarDatesExceptions(
                        serviceId: serviceId,
                        calendarDatesData: calendarDatesData,
                        calendarType: calendarType,
                        baseMatches: false
                    )
                }
            }
        }
        
        // If calendar.txt doesn't exist, check calendar_dates.txt only
        if calendarData == nil {
            return try checkCalendarDatesExceptions(
                serviceId: serviceId,
                calendarDatesData: calendarDatesData,
                calendarType: calendarType,
                baseMatches: false
            )
        }
        
        return false
    }
    
    // MARK: - Check Calendar Dates Exceptions
    // Check if service_id has service based on calendar_dates.txt exceptions.
    // ODPT approach: directly apply exceptions without date calculation.
    private func checkCalendarDatesExceptions(
        serviceId: String,
        calendarDatesData: Data?,
        calendarType: ODPTCalendarType,
        baseMatches: Bool
    ) throws -> Bool {
        guard let calendarDatesData = calendarDatesData else {
            return baseMatches
        }
        
        let rows = try parseGTFSCSV(from: calendarDatesData)
        
        // Check if this service_id has any exceptions in calendar_dates.txt
        // ODPT approach: apply exceptions directly without date matching
        var hasServiceOnMatchingDate = baseMatches
        
        for row in rows {
            guard row["service_id"] == serviceId,
                  let exceptionType = row["exception_type"] else {
                continue
            }
            
            if exceptionType == "1" {
                // Service added on this date
                hasServiceOnMatchingDate = true
            } else if exceptionType == "2" {
                // Service removed on this date
                hasServiceOnMatchingDate = false
            }
        }
        
        return hasServiceOnMatchingDate
    }
    
    // MARK: - Parse GTFS Date
    // Parse date string from GTFS format (yyyyMMdd) to Date
    private func parseGTFSDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current
        return dateFormatter.date(from: dateString)
    }
    
    // MARK: - Check if Date Matches Calendar Type
    // Check if a specific date matches the requested calendar type
    private func dateMatchesCalendarType(date: Date, calendarType: ODPTCalendarType) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current
        
        let weekday = calendar.component(.weekday, from: date)
        let isWeekday = weekday >= 2 && weekday <= 6
        let isSaturday = weekday == 7
        let isSunday = weekday == 1
        let isHoliday = date.isJapaneseHoliday
        
        switch calendarType {
        case .weekday:
            return isWeekday && !isHoliday
        case .saturday:
            return isSaturday && !isHoliday
        case .sunday:
            return isSunday && !isHoliday
        case .holiday:
            return isHoliday
        case .saturdayHoliday:
            return isSaturday || isHoliday
        case .monday, .tuesday, .wednesday, .thursday, .friday, .specific:
            // Individual weekday types and specific types are not used in GTFS
            return false
        }
    }
    
    // MARK: - Fetch GTFS Bus Timetable for All Calendar Types
    // Fetch bus timetable data from GTFS files for all calendar types at once for better performance.
    // This avoids reading the same files multiple times.
    func fetchGTFSBusTimetableForAllCalendarTypes(
        routeId: String,
        departureStop: TransportationStop,
        arrivalStop: TransportationStop,
        calendarTypes: [ODPTCalendarType],
        transportOperator: LocalDataSource,
        consumerKey: String
    ) async throws -> [ODPTCalendarType: [BusTime]] {
        // Get GTFS URL using apiLink
        let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
        guard !gtfsURL.isEmpty else {
            throw ODPTError.invalidData
        }
        
        // Get extracted directory (uses cache if available)
        let extractedDir = try await getExtractedGTFSDirectory(transportOperator: transportOperator, consumerKey: consumerKey, gtfsURL: gtfsURL)
        
        // Get stop_id from departure and arrival stops
        guard let departureStopId = departureStop.code,
              let arrivalStopId = arrivalStop.code else {
            print("⚠️ GTFS Timetable Debug - Missing stop IDs: departure=\(departureStop.code ?? "nil"), arrival=\(arrivalStop.code ?? "nil")")
            return [:]
        }
        
        print("🔍 GTFS Timetable Debug - departureStopId: \(departureStopId), arrivalStopId: \(arrivalStopId)")
        
        // Load all required files once
        let stopTimesData = try loadGTFSFile(from: extractedDir, filename: "stop_times.txt")
        let stopTimesRows = try parseGTFSCSV(from: stopTimesData)
        
        // Extract original route_id and direction info from code
        // Format: "route_id" or "route_id_directionId" or "route_id_directionCode"
        // Note: route_id itself never contains "|", so "|" in the code indicates directionCode format
        // directionCode uses "|" as separator between firstStopId and lastStopId
        // route_id and directionCode are separated by a single "_" (code = "route_id_directionCode")
        let originalRouteId: String
        var targetDirectionId: Int? = nil
        var targetFirstStopId: String? = nil
        var targetLastStopId: String? = nil
        
        // Check if code contains "|" (indicates directionCode format, since route_id never contains "|")
        if routeId.contains("|") {
            // Format: "route_id_directionCode" where directionCode = "firstStopId|lastStopId"
            // route_id and directionCode are separated by a single "_"
            // Find the first "_" to separate route_id and directionCode
            if let firstUnderscoreIndex = routeId.firstIndex(of: "_") {
                originalRouteId = String(routeId[..<firstUnderscoreIndex])
                let directionCode = String(routeId[routeId.index(after: firstUnderscoreIndex)...])
                // Parse directionCode: "firstStopId|lastStopId"
                let directionCodeParts = directionCode.split(separator: "|")
                if directionCodeParts.count >= 2 {
                    targetFirstStopId = String(directionCodeParts[0])
                    targetLastStopId = directionCodeParts[1..<directionCodeParts.count].joined(separator: "|")
                }
            } else {
                originalRouteId = routeId
            }
        } else {
            // No "|" found, so it's either "route_id" or "route_id_directionId" format
            let parts = routeId.split(separator: "_")
            originalRouteId = String(parts[0])
            
            if parts.count >= 2 {
                if let dirId = Int(String(parts[1])) {
                    targetDirectionId = dirId
                }
            }
        }
        
        // Get trip_ids for this route_id from trips.txt
        let tripsData = try loadGTFSFile(from: extractedDir, filename: "trips.txt")
        let trips = try parseGTFSTripsForRoute(from: tripsData, routeId: originalRouteId)
        
        // Filter trips by direction_id or firstStopId/lastStopId
        var filteredTrips = trips
        if let targetDirId = targetDirectionId {
            filteredTrips = trips.filter { trip in
                trip.directionId == targetDirId
            }
        } else if let firstStopId = targetFirstStopId, let lastStopId = targetLastStopId {
            var tripEndpoints: [String: (firstStopId: String, lastStopId: String)] = [:]
            var tripStopSequences: [String: [(stopId: String, sequence: Int)]] = [:]
            
            for row in stopTimesRows {
                guard let tripId = row["trip_id"],
                      let stopId = row["stop_id"],
                      let sequenceStr = row["stop_sequence"],
                      let sequence = Int(sequenceStr) else {
                    continue
                }
                
                if tripStopSequences[tripId] == nil {
                    tripStopSequences[tripId] = []
                }
                tripStopSequences[tripId]?.append((stopId: stopId, sequence: sequence))
            }
            
            for (tripId, stops) in tripStopSequences {
                let sortedStops = stops.sorted { $0.sequence < $1.sequence }
                if let first = sortedStops.first, let last = sortedStops.last {
                    tripEndpoints[tripId] = (firstStopId: first.stopId, lastStopId: last.stopId)
                }
            }
            
            filteredTrips = trips.filter { trip in
                if let endpoints = tripEndpoints[trip.tripId] {
                    return endpoints.firstStopId == firstStopId && endpoints.lastStopId == lastStopId
                }
                return false
            }
        }
        
        let routeTripIds = Set(filteredTrips.map { $0.tripId })
        print("🔍 GTFS Timetable Debug - routeId: \(originalRouteId), found \(filteredTrips.count) trips")
        
        // Group stop_times by trip_id
        var tripStopTimesMap: [String: [(stopId: String, departureTime: String, arrivalTime: String, sequence: Int)]] = [:]
        
        for row in stopTimesRows {
            guard let tripId = row["trip_id"],
                  routeTripIds.contains(tripId),
                  let stopId = row["stop_id"],
                  let departureTime = row["departure_time"],
                  let arrivalTime = row["arrival_time"],
                  let sequenceStr = row["stop_sequence"],
                  let sequence = Int(sequenceStr) else {
                continue
            }
            
            if tripStopTimesMap[tripId] == nil {
                tripStopTimesMap[tripId] = []
            }
            tripStopTimesMap[tripId]?.append((stopId: stopId, departureTime: departureTime, arrivalTime: arrivalTime, sequence: sequence))
        }
        
        // Load calendar files once
        let calendarData = try? loadGTFSFile(from: extractedDir, filename: "calendar.txt")
        let calendarDatesData = try? loadGTFSFile(from: extractedDir, filename: "calendar_dates.txt")
        print("🔍 GTFS Timetable Debug - calendar.txt: \(calendarData != nil ? "found" : "not found"), calendar_dates.txt: \(calendarDatesData != nil ? "found" : "not found")")
        
        // Process all trips and group by calendar type
        var result: [ODPTCalendarType: [BusTime]] = [:]
        
        for calendarType in calendarTypes {
            var busTimes: [BusTime] = []
            
            for trip in filteredTrips {
                // Filter by calendar type
                let matches = try serviceIdMatchesCalendarType(
                    serviceId: trip.serviceId,
                    calendarData: calendarData,
                    calendarDatesData: calendarDatesData,
                    calendarType: calendarType
                )
                
                if !matches {
                    continue
                }
                
                // Get stop_times for this trip_id
                guard let tripStopTimes = tripStopTimesMap[trip.tripId] else {
                    continue
                }
                
                let sortedStopTimes = tripStopTimes.sorted { $0.sequence < $1.sequence }
                
                // Find departure and arrival stops
                guard let departureStopTime = sortedStopTimes.first(where: { $0.stopId == departureStopId }),
                      let arrivalStopTime = sortedStopTimes.first(where: { $0.stopId == arrivalStopId }),
                      departureStopTime.sequence < arrivalStopTime.sequence else {
                    continue
                }
                
                let departureTime = departureStopTime.departureTime.components(separatedBy: ":").prefix(2).joined(separator: ":")
                let arrivalTime = arrivalStopTime.arrivalTime.components(separatedBy: ":").prefix(2).joined(separator: ":")
                
                let adjustedDepartureTime = departureTime.adjustedForTimetable
                let adjustedArrivalTime = arrivalTime.adjustedForTimetable
                let rideTime = adjustedDepartureTime.calculateRideTime(arrivalTime: adjustedArrivalTime)
                
                busTimes.append(BusTime(
                    departureTime: adjustedDepartureTime,
                    arrivalTime: adjustedArrivalTime,
                    busNumber: trip.tripId,
                    routePattern: routeId,
                    rideTime: rideTime
                ))
            }
            
            // Sort by departure time
            result[calendarType] = busTimes.sorted { first, second in
                let firstMinutes = first.departureTime.timeToMinutes
                let secondMinutes = second.departureTime.timeToMinutes
                return firstMinutes < secondMinutes
            }
            
            print("✅ Fetched \(busTimes.count) GTFS bus times for \(calendarType.displayName)")
        }
        
        return result
    }
    
    // MARK: - Fetch GTFS Bus Timetable
    // Fetch bus timetable data from GTFS files for a specific route, stops, and calendar type.
    func fetchGTFSBusTimetable(
        routeId: String,
        departureStop: TransportationStop,
        arrivalStop: TransportationStop,
        calendarType: ODPTCalendarType,
        transportOperator: LocalDataSource,
        consumerKey: String
    ) async throws -> [BusTime] {
        // Get GTFS URL using apiLink
        let gtfsURL = transportOperator.apiLink(for: .line, transportationKind: .bus)
        guard !gtfsURL.isEmpty else {
            throw ODPTError.invalidData
        }
        
        // Get extracted directory (uses cache if available)
        let extractedDir = try await getExtractedGTFSDirectory(transportOperator: transportOperator, consumerKey: consumerKey, gtfsURL: gtfsURL)
        
        // Get stop_id from departure and arrival stops
        guard let departureStopId = departureStop.code,
              let arrivalStopId = arrivalStop.code else {
            print("⚠️ GTFS Timetable Debug - Missing stop IDs: departure=\(departureStop.code ?? "nil"), arrival=\(arrivalStop.code ?? "nil")")
            // Don't remove tempDir - it may be reused by other functions
            return []
        }
        
        print("🔍 GTFS Timetable Debug - departureStopId: \(departureStopId), arrivalStopId: \(arrivalStopId)")
        
        // Load stop_times.txt - this is the main file for timetable data
        let stopTimesData = try loadGTFSFile(from: extractedDir, filename: "stop_times.txt")
        
        // Parse stop_times.txt first
        let stopTimesRows = try parseGTFSCSV(from: stopTimesData)
        
        // Extract original route_id and direction info from code
        // Format: "route_id" or "route_id_directionId" or "route_id_directionCode"
        // Note: route_id itself never contains "|", so "|" in the code indicates directionCode format
        // directionCode uses "|" as separator between firstStopId and lastStopId
        // route_id and directionCode are separated by a single "_" (code = "route_id_directionCode")
        let originalRouteId: String
        var targetDirectionId: Int? = nil
        var targetFirstStopId: String? = nil
        var targetLastStopId: String? = nil
        
        // Check if code contains "|" (indicates directionCode format, since route_id never contains "|")
        if routeId.contains("|") {
            // Format: "route_id_directionCode" where directionCode = "firstStopId|lastStopId"
            // route_id and directionCode are separated by a single "_"
            // Find the first "_" to separate route_id and directionCode
            if let firstUnderscoreIndex = routeId.firstIndex(of: "_") {
                originalRouteId = String(routeId[..<firstUnderscoreIndex])
                let directionCode = String(routeId[routeId.index(after: firstUnderscoreIndex)...])
                // Parse directionCode: "firstStopId|lastStopId"
                let directionCodeParts = directionCode.split(separator: "|")
                if directionCodeParts.count >= 2 {
                    targetFirstStopId = String(directionCodeParts[0])
                    targetLastStopId = directionCodeParts[1..<directionCodeParts.count].joined(separator: "|")
                }
            } else {
                originalRouteId = routeId
            }
        } else {
            // No "|" found, so it's either "route_id" or "route_id_directionId" format
            let parts = routeId.split(separator: "_")
            originalRouteId = String(parts[0])
            
            if parts.count >= 2 {
                // Check if second part is a number (direction_id)
                if let dirId = Int(String(parts[1])) {
                    // It's a direction_id (single digit: 0 or 1)
                    targetDirectionId = dirId
                }
            }
        }
        
        // Get trip_ids for this route_id from trips.txt (needed because stop_times.txt doesn't have route_id)
        let tripsData = try loadGTFSFile(from: extractedDir, filename: "trips.txt")
        let trips = try parseGTFSTripsForRoute(from: tripsData, routeId: originalRouteId)
        
        // Filter trips by direction_id or firstStopId/lastStopId
        var filteredTrips = trips
        if let targetDirId = targetDirectionId {
            // Filter by direction_id
            filteredTrips = trips.filter { trip in
                trip.directionId == targetDirId
            }
        } else if let firstStopId = targetFirstStopId, let lastStopId = targetLastStopId {
            // Filter by firstStopId/lastStopId: need to check stop_times.txt for each trip
            // Get first and last stop_id for each trip
            var tripEndpoints: [String: (firstStopId: String, lastStopId: String)] = [:]
            var tripStopSequences: [String: [(stopId: String, sequence: Int)]] = [:]
            
            for row in stopTimesRows {
                guard let tripId = row["trip_id"],
                      let stopId = row["stop_id"],
                      let sequenceStr = row["stop_sequence"],
                      let sequence = Int(sequenceStr) else {
                    continue
                }
                
                if tripStopSequences[tripId] == nil {
                    tripStopSequences[tripId] = []
                }
                tripStopSequences[tripId]?.append((stopId: stopId, sequence: sequence))
            }
            
            // Get first and last stop_id for each trip
            for (tripId, stops) in tripStopSequences {
                let sortedStops = stops.sorted { $0.sequence < $1.sequence }
                if let first = sortedStops.first, let last = sortedStops.last {
                    tripEndpoints[tripId] = (firstStopId: first.stopId, lastStopId: last.stopId)
                }
            }
            
            // Filter trips that match the target firstStopId/lastStopId
            filteredTrips = trips.filter { trip in
                if let endpoints = tripEndpoints[trip.tripId] {
                    return endpoints.firstStopId == firstStopId && endpoints.lastStopId == lastStopId
                }
                return false
            }
        }
        
        let routeTripIds = Set(filteredTrips.map { $0.tripId })
        print("🔍 GTFS Timetable Debug - routeId: \(originalRouteId), found \(filteredTrips.count) trips")
        
        // Group stop_times by trip_id, filtered by selected route (routeTripIds)
        var tripStopTimesMap: [String: [(stopId: String, departureTime: String, arrivalTime: String, sequence: Int)]] = [:]
        
        for row in stopTimesRows {
            guard let tripId = row["trip_id"],
                  routeTripIds.contains(tripId),  // Filter by selected route
                  let stopId = row["stop_id"],
                  let departureTime = row["departure_time"],
                  let arrivalTime = row["arrival_time"],
                  let sequenceStr = row["stop_sequence"],
                  let sequence = Int(sequenceStr) else {
                continue
            }
            
            if tripStopTimesMap[tripId] == nil {
                tripStopTimesMap[tripId] = []
            }
            tripStopTimesMap[tripId]?.append((stopId: stopId, departureTime: departureTime, arrivalTime: arrivalTime, sequence: sequence))
        }
        
        // Load calendar files for filtering by calendar type
        let calendarData = try? loadGTFSFile(from: extractedDir, filename: "calendar.txt")
        let calendarDatesData = try? loadGTFSFile(from: extractedDir, filename: "calendar_dates.txt")
        print("🔍 GTFS Timetable Debug - calendar.txt: \(calendarData != nil ? "found" : "not found"), calendar_dates.txt: \(calendarDatesData != nil ? "found" : "not found")")
        
        // Process all trip_ids: For each trip_id, get departure_time and arrival_time for selected stops
        // After selecting departure and arrival stops, process all trip_ids in the list
        var busTimes: [BusTime] = []
        
        for trip in filteredTrips {
            // Filter by calendar type (check if this trip's service_id matches the calendar type)
            let matches = try serviceIdMatchesCalendarType(
                serviceId: trip.serviceId,
                calendarData: calendarData,
                calendarDatesData: calendarDatesData,
                calendarType: calendarType
            )
            
            if !matches {
                continue
            }
            
            // Get stop_times for this trip_id from the parsed stop_times.txt
            guard let tripStopTimes = tripStopTimesMap[trip.tripId] else {
                continue
            }
            
            // Sort by stop_sequence to ensure correct order
            let sortedStopTimes = tripStopTimes.sorted { $0.sequence < $1.sequence }
            
            // Find departure and arrival stops in this trip
            // Get departure_time for the selected departure stop's stop_id
            // Get arrival_time for the selected arrival stop's stop_id
            guard let departureStopTime = sortedStopTimes.first(where: { $0.stopId == departureStopId }),
                  let arrivalStopTime = sortedStopTimes.first(where: { $0.stopId == arrivalStopId }),
                  departureStopTime.sequence < arrivalStopTime.sequence else {
                continue
            }
            
            // Extract time in HH:MM format (GTFS uses HH:MM:SS)
            // departureStopTime.departureTime is the time displayed in the timetable
            let departureTime = departureStopTime.departureTime.components(separatedBy: ":").prefix(2).joined(separator: ":")
            let arrivalTime = arrivalStopTime.arrivalTime.components(separatedBy: ":").prefix(2).joined(separator: ":")
            
            // Apply timetableHour extension for 0-3 AM times (add 24 hours for previous day)
            // Similar to TrainTimetable logic
            let adjustedDepartureTime = departureTime.adjustedForTimetable
            let adjustedArrivalTime = arrivalTime.adjustedForTimetable
            
            // Calculate ride time: difference between arrival_time and departure_time
            let rideTime = adjustedDepartureTime.calculateRideTime(arrivalTime: adjustedArrivalTime)
            
            // Add to list
            // adjustedDepartureTime will be displayed in the timetable
            busTimes.append(BusTime(
                departureTime: adjustedDepartureTime,  // This is displayed in the timetable
                arrivalTime: adjustedArrivalTime,
                busNumber: trip.tripId,  // trip_id is equivalent to trainNumber
                routePattern: routeId,
                rideTime: rideTime
            ))
        }
        
        // Don't remove tempDir - it may be reused by other functions (e.g., fetchGTFSCalendarTypes)
        
        // Sort by departure time (similar to TrainTimetable)
        return busTimes.sorted { first, second in
            let firstMinutes = first.departureTime.timeToMinutes
            let secondMinutes = second.departureTime.timeToMinutes
            return firstMinutes < secondMinutes
        }
    }
}

// MARK: - Dictionary Extension for GTFS Calendar Row
// Extension to extract calendar day flags from GTFS calendar.txt row
private extension Dictionary where Key == String, Value == String {
    var monday: Bool { self["monday"] == "1" }
    var tuesday: Bool { self["tuesday"] == "1" }
    var wednesday: Bool { self["wednesday"] == "1" }
    var thursday: Bool { self["thursday"] == "1" }
    var friday: Bool { self["friday"] == "1" }
    var saturday: Bool { self["saturday"] == "1" }
    var sunday: Bool { self["sunday"] == "1" }
    var weekdayCount: Int {
        [monday, tuesday, wednesday, thursday, friday].filter { $0 }.count
    }
}
