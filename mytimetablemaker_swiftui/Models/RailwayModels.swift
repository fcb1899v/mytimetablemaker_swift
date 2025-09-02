//
//  RailwayModels.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/08/24.
//
//  MARK: - Overview
//  Core data models for railway lines, stations, and related structures.
//  Provides the foundation for all railway data management in the application.
//

import Foundation
import SwiftUI

// MARK: - Transportation Line Model
// Core data structure representing a railway line or transportation route.
// Contains all necessary information for line identification, display, and configuration.
struct TransportationLine: Identifiable, Hashable {
    enum Kind: String { 
        case railway = "Railway"
        case bus = "Bus"
    }
    
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
    let lineCode: String?           // odpt:lineCode (e.g., "JY", "TT", etc.)
    
    // MARK: - Bus-specific properties
    let busRoute: String?           // odpt:busroute - bus route identifier
    let pattern: String?            // odpt:pattern - bus route pattern
    let direction: String?          // odpt:direction - bus direction
    let busstopPoleOrder: [BusStopPole]? // odpt:busstopPoleOrder - bus stop sequence
    
    // MARK: - Bus Route English Name
    // Extract English name from bus route identifier (only for English locale)
    var busRouteEnglishName: String? {
        guard let busRoute = busRoute else { return nil }
        // Only extract English name for English locale
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        guard currentLanguage != "ja" else { return nil }
        
        // Extract the third part after splitting by dots (e.g., "Mon33" from "odpt.Busroute:Toei.Mon33")
        let components = busRoute.components(separatedBy: ".")
        guard components.count >= 3 else { return nil }
        return components[2] // Index 2 should be the English route code
    }
}

// MARK: - Railway Title Model
// Multi-language support structure for railway line names.
// Provides localized display names based on user's language preference.
struct RailwayTitle: Codable, Hashable {
    let ja: String?  // Japanese name
    let en: String?  // English name
    
    enum CodingKeys: String, CodingKey {
        case ja = "ja"
        case en = "en"
    }
    
    // MARK: - Localized Name Retrieval
    // Get localized railway name based on current language.
    // Falls back to English if Japanese is not available, and vice versa.
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
// Data structure representing a railway station.
// Includes station identification, localization, and metadata.
struct Station: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String?
    let title: StationTitle?
    
    // MARK: - Localized Name Retrieval
    // Get localized station name based on current language.
    // Provides fallback to base name if localized title is unavailable.
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
// Multi-language support structure for station names.
// Similar to RailwayTitle but specifically for station localization.
struct StationTitle: Codable, Hashable {
    let ja: String?  // Japanese station name
    let en: String?  // English station name
    
    enum CodingKeys: String, CodingKey {
        case ja = "ja"
        case en = "en"
    }
}

// MARK: - Station Order Information
// Represents the sequence and metadata of stations within a railway line.
struct StationOrder: Decodable {
    let index: Int                    // Position of station in the line sequence
    let station: String               // Station identifier
    let stationTitle: StationTitle?   // Multi-language station name
    
    enum CodingKeys: String, CodingKey {
        case index = "odpt:index"         // Station order index
        case station = "odpt:station"     // Station identifier
        case stationTitle = "odpt:stationTitle"  // Localized station name
    }
}

// MARK: - Bus Stop Pole Model
// Represents a bus stop within a bus route pattern
struct BusStopPole: Codable, Hashable {
    let note: String?               // odpt:note - bus stop description
    let busstopPole: String?        // odpt:busstopPole - bus stop identifier
    let index: Int?                 // odpt:index - bus stop order
    let busstopPoleTitle: BusStopPoleTitle? // odpt:busstopPoleTitle - multi-language bus stop name
    
    enum CodingKeys: String, CodingKey {
        case note = "odpt:note"
        case busstopPole = "odpt:busstopPole"
        case index = "odpt:index"
        case busstopPoleTitle = "odpt:busstopPoleTitle"
    }
    
    // MARK: - Bus Stop English Name
    // Extract English name from bus stop pole identifier (only for English locale)
    var busStopEnglishName: String? {
        guard let busstopPole = busstopPole else { return nil }
        // Only extract English name for English locale
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        guard currentLanguage != "ja" else { return nil }
        
        // Extract the third part after splitting by dots (e.g., "KameidoStation" from "odpt.BusstopPole:Toei.KameidoStation.369.7")
        let components = busstopPole.components(separatedBy: ".")
        guard components.count >= 3 else { return nil }
        return components[2] // Index 2 should be the station name
    }
}

// MARK: - Bus Stop Pole Title Model
// Multi-language support structure for bus stop names
struct BusStopPoleTitle: Codable, Hashable {
    let ja: String?  // Japanese bus stop name
    let en: String?  // English bus stop name
    
    enum CodingKeys: String, CodingKey {
        case ja = "ja"
        case en = "en"
    }
    
    // MARK: - Localized Name Retrieval
    // Get localized bus stop name based on current language
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

// MARK: - Data Statistics Structure
// Structure for managing application statistics and cache status.
// Tracks data freshness, cache availability, and usage metrics.
struct DataStatistics {
    var totalLines: Int = 0           // Total number of available transportation lines
    var railwayLines: Int = 0         // Number of railway lines
    var busLines: Int = 0             // Number of bus lines
    var operators: Int = 0            // Number of transportation operators
    var cacheStatus: [String: Bool] = [:]  // Cache availability for each data source
    
    init() {
        self.totalLines = 0
        self.railwayLines = 0
        self.busLines = 0
        self.operators = 0
        self.cacheStatus = [:]
    }
    
    init(totalLines: Int, railwayLines: Int, busLines: Int, operators: Int, cacheStatus: [String: Bool] = [:]) {
        self.totalLines = totalLines
        self.railwayLines = railwayLines
        self.busLines = busLines
        self.operators = operators
        self.cacheStatus = cacheStatus
    }
}

// MARK: - PreferenceKey for Departure Station Position
// This preference key tracks the position of the departure station input field
// for proper positioning of suggestion overlays and UI elements.
struct DepartureStationPositionKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - PreferenceKey for Arrival Station Position
// This preference key tracks the position of the arrival station input field
// for proper positioning of suggestion overlays and UI elements.
struct ArrivalStationPositionKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

