//
//  DataTransferObjects.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/08/24.
//
//  MARK: - Overview
//  Data Transfer Objects (DTOs) for handling external data formats.
//  Provides structures for parsing JSON data from local files and ODPT API.
//

import Foundation

// MARK: - Transportation Type DTO
// Base DTO that includes the @type field for distinguishing between railway and bus data
struct TransportationTypeDTO: Decodable {
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
    }
    
    // MARK: - Transportation Type Mapping
    // Maps the @type field to our internal TransportationType enum
    var transportationType: TransportationType? {
        return TransportationType(rawValue: type)
    }
}

// MARK: - Local File Data Transfer Objects
// These structures represent the local JSON data files.
// They provide offline data when ODPT API is unavailable.

// MARK: - Local Railway DTO
// Line data structure for local JSON files.
// Similar to RailwayDTO but with local-specific field mappings.
struct LocalRailwayDTO: Decodable {
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

// MARK: - ODPT JSON Data Transfer Objects
// These structures represent the raw JSON data received from the ODPT API.
// They are used for parsing and converting external data to our internal models.

// MARK: - ODPT Railway DTO
// DTO for railway data from ODPT API.
// Maps external JSON structure to internal data model.
struct RailwayDTO: Decodable {
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
    let busstopPoleOrder: [BusStopPole]?
    let note: String?

    enum CodingKeys: String, CodingKey {
        case title = "dc:title"           // Dublin Core title
        case sameAs = "owl:sameAs"        // OWL sameAs identifier
        case operatorCode = "odpt:operator"       // Bus operator code
        case busRoute = "odpt:busroute"            // Bus route identifier
        case pattern = "odpt:pattern"             // Bus route pattern
        case direction = "odpt:direction"        // Bus direction
        case busstopPoleOrder = "odpt:busstopPoleOrder"  // Bus stop sequence
        case note = "odpt:note"                   // Bus route note/description
    }
}

// MARK: - Local Station DTO
// Station data structure for local JSON files (JR East Japan specific).
// Contains station information and ordering within railway lines.
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
