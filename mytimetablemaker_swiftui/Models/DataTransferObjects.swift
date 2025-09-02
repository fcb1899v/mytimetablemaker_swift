//
//  DataTransferObjects.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/08/24.
//
//  MARK: - Overview
//  Data Transfer Objects (DTOs) for handling external data formats.
//  Provides structures for parsing JSON data from ODPT API.
//

import Foundation

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
    let date: String?

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
    let busstopPoleOrder: [BusStopPole]?
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
