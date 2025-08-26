//
//  LocalDataService.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/08/24.
//
//  MARK: - Overview
//  Service for managing local JSON data files.
//  Provides offline data access when ODPT API is unavailable.
//

import Foundation

// MARK: - Local File Loader
// Manages loading of local JSON data files from the app bundle.
// Provides offline data access when ODPT API is unavailable.
private final class LocalFileLoader {
    
    // MARK: - Main Data Loading
    // Load all available local data sources and combine results.
    static func loadLocalData() -> [TransportationLine] {
        var allLines: [TransportationLine] = []
        var fileStats: [String: Int] = [:]
        
        // MARK: - Source Processing
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
    
    // MARK: - Individual File Loading
    // Load individual file data from LineData folder or app bundle.
    private static func loadFileData(for fileName: String) -> Data? {
        // MARK: - Primary Data Source
        // First try to load from LineData folder
        if let lineDataURL = Bundle.main.url(forResource: "LineData", withExtension: nil) {
            let jsonURL = lineDataURL.appendingPathComponent(fileName)
            if let data = try? Data(contentsOf: jsonURL) {
                return data
            }
        }
        
        // MARK: - Fallback Data Source
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

// MARK: - Local File Parser
// Handles parsing of local JSON data files.
// Supports multiple data formats and provides fallback parsing strategies.
private struct LocalFileParser {
    
    // MARK: - Main Parsing Method
    // Parse local data from various sources and formats.
    // Automatically detects data type and applies appropriate parsing strategy.
    static func parseLocalData(from source: LocalDataSource, data: Data) -> [TransportationLine] {
        // Use already loaded data
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            return []
        }
                
        // MARK: - Data Type Detection
        // Determine the type of data by examining the first item
        if let array = json as? [[String: Any]], let firstItem = array.first {
            let type = firstItem["@type"] as? String ?? ""
    
            // MARK: - Format-Based Processing
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
                // MARK: - Fallback Parsing
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
                
                return []
            }
        }
        
        return []
    }
    
    // MARK: - Station-Based Line Parsing
    // Parse station data and convert to line information.
    // Used for data sources that provide station-level information.
    private static func parseStationsToLines(_ array: [[String: Any]], source: LocalDataSource) -> [TransportationLine] {
        var lines: [TransportationLine] = []
        
        // MARK: - Station Grouping
        // Group stations by line to create line representations
        var lineGroups: [String: [String]] = [:]
        
        for element in array {
            if let title = element["title"] as? [String: Any],
               let lineName = title["ja"] as? String,
               let sameAs = element["owl:sameAs"] as? String {
                
                // Extract line identifier from station's sameAs
                let lineId = sameAs.components(separatedBy: ":").last ?? ""
                
                if lineGroups[lineId] == nil {
                    lineGroups[lineId] = []
                }
                lineGroups[lineId]?.append(lineName)
            }
        }
        
        // MARK: - Line Creation
        // Create TransportationLine objects from grouped stations
        for (lineId, stations) in lineGroups {
            if let firstStation = stations.first {
                let line = TransportationLine(
                    kind: .railway,
                    name: firstStation,
                    code: lineId,
                    operatorCode: source.operatorCode,
                    railwayType: nil,
                    lineColor: nil,
                    startStation: stations.first,
                    endStation: stations.last,
                    railwayTitle: RailwayTitle(ja: firstStation, en: nil),
                    lineCode: nil
                )
                lines.append(line)
            }
        }
    
        return lines
    }
    
    // MARK: - Direct Railway Data Parsing
    // Parse line data directly (for Keikyu, Tokyo Metro, Toei Subway, and JR East Japan).
    // Optimized parsing for standard railway data format.
    static func parseRailways(_ data: Data, source: LocalDataSource) throws -> [TransportationLine] {
        // Check structure of JSON for confirmation
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        if let array = json as? [[String: Any]] {
            // MARK: - Line Information Dictionary
            // Extract line information using dictionary for efficient processing
            var railwayLines: [String: (name: String, operatorCode: String, lineColor: String?, railwayTitle: RailwayTitle?, lineCode: String?, startStation: String?, endStation: String?)] = [:]
            
            for element in array {
                // MARK: - Required Field Validation
                // Validate required fields for railway data
                if let title = element["dc:title"] as? String,
                   let sameAs = element["owl:sameAs"] as? String {
                    
                    let operatorCode = element["odpt:operator"] as? String ?? source.operatorCode
                    let lineColor = element["odpt:color"] as? String
                    let lineCode = element["odpt:lineCode"] as? String
                    
                    // MARK: - Multi-Language Title Processing
                    // Process odpt:railwayTitle for multi-language support
                    var railwayTitle: RailwayTitle? = nil
                    if let railwayTitleDict = element["odpt:railwayTitle"] as? [String: String] {
                        railwayTitle = RailwayTitle(
                            ja: railwayTitleDict["ja"],
                            en: railwayTitleDict["en"]
                        )
                    }
                    
                    // MARK: - Station Boundary Information
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
                                        
                    // MARK: - Line Storage
                    // Store line information using sameAs as unique key
                    if railwayLines[sameAs] == nil {
                        railwayLines[sameAs] = (name: title, operatorCode: operatorCode, lineColor: lineColor, railwayTitle: railwayTitle, lineCode: lineCode, startStation: startStation, endStation: endStation)
                    }
                }
            }
            
            // MARK: - Object Conversion
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
            // MARK: - Fallback Parsing
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
