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
    
    enum CodingKeys: String, CodingKey {
        case note = "odpt:note"
        case busstopPole = "odpt:busstopPole"
        case index = "odpt:index"
    }
}

// MARK: - Data Statistics Structure
// Structure for managing application statistics and cache status.
// Tracks data freshness, cache availability, and usage metrics.
struct DataStatistics {
    var totalRailways: Int = 0        // Total number of available railway lines
    var lastUpdated: String? = nil    // When data was last refreshed (as formatted string)
    var cacheStatus: [String: Bool] = [:]  // Cache availability for each data source
    
    init() {
        self.totalRailways = 0
        self.lastUpdated = nil
        self.cacheStatus = [:]
    }
    
    init(totalRailways: Int, lastUpdated: String?, cacheStatus: [String: Bool]) {
        self.totalRailways = totalRailways
        self.lastUpdated = lastUpdated
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
