//
//  LocalDataService.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2025/08/24.
//
//  MARK: - Overview
//  Service for managing local JSON data files.
//  Provides offline data access when ODPT API is unavailable.
//

import Foundation

// MARK: - Local File Parser
// Handles parsing of local JSON data files.
// Supports multiple data formats and provides fallback parsing strategies.
struct LocalFileParser {
    
    // MARK: - Main Parsing Method
    // Parse local data from various sources and formats.
    // Automatically detects data type and applies appropriate parsing strategy.
    static func parseLocalData(from source: LocalDataSource, data: Data) -> [TransportationLine] {
        // Use already loaded data
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            print("❌ Failed to parse JSON for \(source.operatorDisplayName)")
            return []
        }
                
        // MARK: - Data Type Detection
        // Determine the type of data by examining the first item
        if let array = json as? [[String: Any]], let firstItem = array.first {
            let type = firstItem["@type"] as? String ?? ""
            print("🔍 \(source.operatorDisplayName): Data type = '\(type)', items count = \(array.count)")
    
            // MARK: - Format-Based Processing
            // Process based on data type
            switch type {
            case "odpt:Railway":
                // Standard railway data format
                print("🚆 Processing \(source.operatorDisplayName) as railway data")
                return parseRailwaysFromArray(array, source: source)
            case "odpt:BusroutePattern":
                // Bus route pattern data format
                print("🚌 Processing \(source.operatorDisplayName) as bus route pattern data")
                return parseBusRoutesFromArray(array, source: source)
            case "odpt:Station":
                // Station data format (e.g., JR East Japan)
                print("🚉 Processing \(source.operatorDisplayName) as station data")
                return parseStationsToLines(array, source: source)
            default:
                print("⚠️ Unknown data type '\(type)' for \(source.operatorDisplayName), trying fallback parsing")
                // MARK: - Fallback Parsing
                // Fallback parsing when type is not explicitly specified
                // Try processing as railway data
                if let _ = firstItem["dc:title"], let _ = firstItem["odpt:operator"] {
                    print("🔄 Fallback: Processing \(source.operatorDisplayName) as railway data")
                    return parseRailwaysFromArray(array, source: source)
                }
                
                // Try processing as station data
                if let _ = firstItem["title"] as? [String: Any] {
                    print("🔄 Fallback: Processing \(source.operatorDisplayName) as station data")
                    return parseStationsToLines(array, source: source)
                }
                
                print("❌ No suitable parser found for \(source.operatorDisplayName)")
                return []
            }
        }
        
        print("❌ Invalid JSON structure for \(source.operatorDisplayName)")
        return []
    }
    
    // MARK: - Station-Based Line Parsing
    // Parse station data and convert to line information.
    // Used for data sources that provide station-level information.
    static func parseStationsToLines(_ array: [[String: Any]], source: LocalDataSource) -> [TransportationLine] {
        // MARK: - Station Grouping using closures
        // Group stations by line to create line representations
        let lineGroups = array.reduce(into: [String: [String]]()) { result, element in
            guard let title = element["title"] as? [String: Any],
                  let lineName = title["ja"] as? String,
                  let sameAs = element["owl:sameAs"] as? String else { return }
            
            // Extract line identifier from station's sameAs
            let lineId = sameAs.components(separatedBy: ":").last ?? ""
            result[lineId, default: []].append(lineName)
        }
        
        // MARK: - Line Creation using closures
        // Create TransportationLine objects from grouped stations
        return lineGroups.compactMap { lineId, stations in
            guard let firstStation = stations.first else { return nil }
            
            return TransportationLine(
                kind: .railway,
                name: firstStation,
                code: lineId,
                operatorCode: source.operatorCode,
                lineColor: nil,
                startStation: stations.first,
                endStation: stations.last,
                destinationStation: stations.last,
                railwayTitle: RailwayTitle(ja: firstStation, en: nil),
                lineCode: nil,
                lineDirection: nil,
                busRoute: nil,
                pattern: nil,
                busDirection: nil,
                busstopPoleOrder: nil
            )
        }
    }
    
    // MARK: - Railway Array Parsing
    // Parse railway data from array format.
    // Used for standard railway data sources.
    static func parseRailwaysFromArray(_ array: [[String: Any]], source: LocalDataSource) -> [TransportationLine] {
        return array.compactMap { element in
            // Extract common fields using closure
            guard let title = element["dc:title"] as? String,
                  let sameAs = element["owl:sameAs"] as? String else { return nil }
            
            let operatorCode = element["odpt:operator"] as? String ?? source.operatorCode
            let lineColor = element["odpt:color"] as? String
            let lineCode = element["odpt:lineCode"] as? String
            let lineDirection = element["odpt:ascendingRailDirection"] as? String
            
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
            
            // MARK: - Destination Station Information
            let destinationStation: String? = {
                if let destinationArray = element["odpt:destinationStation"] as? [String],
                   let firstDestination = destinationArray.first {
                    return firstDestination
                }
                return nil
            }()
            
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
    
    // MARK: - Bus Route Array Parsing
    // Parse bus route pattern data from array format.
    // Used for bus data sources like Toei Bus and Yokohama Municipal Bus.
    static func parseBusRoutesFromArray(_ array: [[String: Any]], source: LocalDataSource) -> [TransportationLine] {
        print("🚌 Starting bus route parsing for \(source.operatorDisplayName) with \(array.count) items")
        
        // MARK: - Bus Route Grouping using closures
        // Group bus routes by route name to avoid duplicates
        let busRoutes = array.reduce(into: [String: (name: String, operatorCode: String, patterns: Set<String>, directions: Set<String>, busStops: Set<String>, busRouteCode: String)]()) { result, element in
            guard let title = element["dc:title"] as? String else { 
                print("⚠️ Missing dc:title in bus route item")
                return 
            }
            guard let busRouteCode = element["odpt:busroute"] as? String else { 
                print("⚠️ Missing odpt:busroute in bus route item: \(title)")
                return 
            }
            
            let operatorCode = element["odpt:operator"] as? String ?? source.operatorCode
            let pattern = element["odpt:pattern"] as? String
            let direction = element["odpt:direction"] as? String
            
            // Extract bus stop names using closure
            let busStopNames: [String] = (element["odpt:busstopPoleOrder"] as? [[String: Any]])?.compactMap { busStopInfo in
                // Extract English name from busstopPole if available (only for English locale), otherwise use note
                let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
                if currentLanguage != "ja", let busstopPole = busStopInfo["odpt:busstopPole"] as? String {
                    let components = busstopPole.components(separatedBy: ".")
                    let englishName = components.count >= 3 ? components[2] : nil
                    return englishName ?? busStopInfo["odpt:note"] as? String
                } else {
                    return busStopInfo["odpt:note"] as? String
                }
            } ?? []
            
            // Initialize or update route information
            if result[title] == nil {
                result[title] = (name: title, operatorCode: operatorCode, patterns: Set<String>(), directions: Set<String>(), busStops: Set<String>(), busRouteCode: busRouteCode)
                print("✅ Added new bus route: \(title) (code: \(busRouteCode))")
            }
            
            // Add pattern and direction if not already present
            if let pattern = pattern {
                result[title]!.patterns.insert(pattern)
            }
            if let direction = direction {
                result[title]!.directions.insert(direction)
            }
            
            // Add bus stops if not already present
            for busStop in busStopNames {
                result[title]!.busStops.insert(busStop)
            }
        }
        
        print("🚌 Processed \(busRoutes.count) unique bus routes for \(source.operatorDisplayName)")
        
        // MARK: - Object Conversion using closures
        // Convert route information to TransportationLine objects
        let transportationLines = busRoutes.map { routeName, info in
            // Extract English name from odpt:busroute value (e.g., "Mon33" from "odpt.Busroute:Toei.Mon33")
            print("🔍 Processing route: \(routeName), busRouteCode: \(info.busRouteCode)")
            let englishName = extractEnglishNameFromRouteName(info.busRouteCode)
            
            return TransportationLine(
                kind: .bus,
                name: info.name,
                code: "odpt.Busroute:\(routeName)",
                operatorCode: info.operatorCode,
                lineColor: nil,
                startStation: Array(info.busStops).sorted().first,
                endStation: Array(info.busStops).sorted().last,
                destinationStation: Array(info.busStops).sorted().last,
                railwayTitle: RailwayTitle(ja: info.name, en: englishName),
                lineCode: nil,
                lineDirection: nil, // Will be calculated based on station index comparison
                busRoute: info.busRouteCode,
                pattern: Array(info.patterns).first,
                busDirection: Array(info.directions).first,
                busstopPoleOrder: Array(info.busStops).sorted().enumerated().map { 
                    BusStopPole(note: $0.element, busstopPole: "\(routeName)_\($0.offset)", index: $0.offset + 1, busstopPoleTitle: nil) 
                }
            )
        }
        
        print("🚌 Created \(transportationLines.count) TransportationLine objects for \(source.operatorDisplayName)")
        return transportationLines
    }
    
    // MARK: - Helper Functions
    // Extract English name from odpt:busroute value
    private static func extractEnglishNameFromRouteName(_ routeName: String) -> String? {
        // Extract English name from odpt:busroute format (e.g., "Mon33" from "odpt.Busroute:Toei.Mon33")
        // Format: "odpt.Busroute:OperatorName.RouteCode"
        // Similar to: result["odpt:busroute"].split(".")[2]
        
        print("🔍 extractEnglishNameFromRouteName called with routeName: '\(routeName)'")
        
        // Split by "." to get parts
        let parts = routeName.components(separatedBy: ".")
        
        print("🔍 Split parts: \(parts)")
        
        // Check if we have enough parts and the format is correct
        guard parts.count >= 3,
              parts[0] == "odpt",
              parts[1].hasPrefix("Busroute:") else { 
            print("❌ Invalid format for routeName: '\(routeName)'")
            return nil 
        }
        
        // Get the route code (third part, index 2)
        let routeCode = parts[2]
        
        // Validate that the route code contains English characters or numbers
        let englishPattern = "[A-Za-z0-9]"
        guard routeCode.range(of: englishPattern, options: .regularExpression) != nil else { 
            print("❌ Route code '\(routeCode)' does not contain English characters")
            return nil 
        }
        
        print("🔍 Extracted route code '\(routeCode)' from '\(routeName)'")
        return routeCode
    }
}
