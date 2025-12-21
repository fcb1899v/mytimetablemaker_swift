//
//  TransportationModels.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2025/08/26.
//

import Foundation
import SwiftUI

//  MARK: - Overview
//  Core data models for railway and bus lines, stations, and related structures.
//  Provides the foundation for all railway data management in the application.

// MARK: - Transportation Stop Model
// Unified model for both railway stations and bus stops
struct TransportationStop: Identifiable, Hashable, Codable {
    var id: String { code ?? name }
    let kind: TransportationLine.Kind
    let name: String
    let code: String?
    let index: Int?
    let lineCode: String?
    let title: LocalizedTitle?
    
    // Bus-specific properties (optional for railway stations)
    let note: String?                  // odpt:note - bus stop description from ODPT API
    let busstopPole: String?           // odpt:busstopPole - bus stop identifier
    
    // Computed property for display name
    // Split by ":" and return first component for ODPT format (e.g., "StationA:1887:StationA" -> "StationA")
    var displayName: String {
        // Use localized name based on current language setting
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        var baseName: String
        
        if let title = title {
            let localizedName = title.getLocalizedName()
            if !localizedName.isEmpty {
                baseName = localizedName
            } else {
                baseName = name
            }
        } else {
            // For bus stops, try to extract English from busstopPole for English locale
            if kind == .bus && currentLanguage != "ja" {
                if let busstopPole = busstopPole {
                    let components = busstopPole.components(separatedBy: ".")
                    if components.count > 2 {
                        let englishName = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
                        baseName = englishName
                    } else {
                        baseName = name
                    }
                } else {
                    baseName = name
                }
            } else {
                baseName = name
            }
        }
        
        // Split by ":" and return first component for ODPT format
        let components = baseName.components(separatedBy: ":")
        return components.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? baseName
    }
    
    // Computed property for cleaned name (for bus stops)
    var cleanedName: String {
        if kind == .bus, let note = note, !note.isEmpty {
            // Use entire note field for bus stops
            return note.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return name
    }
    
    // Initialize from Station
    init(from station: Station) {
        self.kind = .railway
        self.name = station.name
        self.code = station.code
        self.index = station.index
        self.lineCode = station.lineCode
        self.title = station.title
        self.note = nil
        self.busstopPole = nil
    }
    
    // Initialize from BusStop
    init(from busStop: BusStop) {
        self.kind = .bus
        // Use original name (Japanese note field) as base name
        self.name = busStop.name
        self.code = busStop.code
        self.index = busStop.index
        self.lineCode = busStop.lineCode
        self.title = busStop.title
        self.note = busStop.note
        self.busstopPole = busStop.busstopPole
    }
    
    // Initialize from BusstopPoleDTO (for API fallback - only dc:title)
    init(
        name: String,
        code: String?,
        index: Int,
        lineCode: String?,
        title: String,
        busstopPole: String?,
        latitude: Double?,
        longitude: Double?,
        kana: String?
    ) {
        self.kind = .bus
        self.name = name
        self.code = code
        self.index = index
        self.lineCode = lineCode
        self.title = LocalizedTitle(ja: title, en: nil)
        self.note = title // Use title as note for bus stops
        self.busstopPole = busstopPole
    }
    
    // Direct initialization
    init(kind: TransportationLine.Kind, name: String, code: String? = nil, index: Int? = nil, lineCode: String? = nil, title: LocalizedTitle? = nil, note: String? = nil, busstopPole: String? = nil) {
        self.kind = kind
        self.name = name
        self.code = code
        self.index = index
        self.lineCode = lineCode
        self.title = title
        self.note = note
        self.busstopPole = busstopPole
    }
    
}

// MARK: - Transportation Line Model
// Core data structure representing a railway and bus line or transportation route.
// Contains all necessary information for line identification, display, and configuration.
struct TransportationLine: Identifiable, Hashable, Codable {
    var id: String { code }
    enum Kind: String, CaseIterable, Codable { 
        case railway = "Railway"
        case bus = "Bus"
        
        var displayName: String {
            switch self {
            case .railway:
                return "Railway".localized
            case .bus:
                return "Bus".localized
            }
        }
    }
    
    let kind: Kind
    let name: String
    let code: String                     // owl:sameAs - unique identifier from ODPT
    let operatorCode: String?            // odpt:operator (e.g., odpt.Operator:JR-East)
    let lineColor: String?               // odpt:lineColor (e.g., #000000)
    let startStation: String?            // odpt:startStation - first station on the line
    let endStation: String?              // odpt:endStation - last station on the line
    let destinationStation: String?      // odpt:destinationStation - destination station (first element from array)
    let railwayTitle: LocalizedTitle?    // odpt:railwayTitle - multi-language support
    let lineCode: String?                // odpt:lineCode (e.g., "JY", "TT", etc.)
    let lineDirection: String?           // Direction information for timetable API calls
    let ascendingRailDirection: String?  // odpt:ascendingRailDirection - ascending direction from JSON
    let descendingRailDirection: String? // odpt:descendingRailDirection - descending direction from JSON
    
    // MARK: - Bus-specific properties
    let busRoute: String?            // odpt:busroute - bus route identifier
    let pattern: String?             // odpt:pattern - bus route pattern
    let busDirection: String?        // odpt:direction - bus direction
    let busstopPoleOrder: [BusStop]? // odpt:busstopPoleOrder - bus stop sequence
    let title: String?               // dc:title - bus route title
    
    // MARK: - Bus Route English Name
    // Extract English name from bus route identifier using LineExtensions
    var busRouteEnglishName: String? {
        guard let busRoute = busRoute else { return nil }
        return busRoute.busRouteEnglishName
    }
}

// MARK: - Localized Title Model
// Common structure for multi-language support across all transportation entities.
// Provides localized display names based on user's language preference.
struct LocalizedTitle: Codable, Hashable {
    let ja: String?  // Japanese name
    let en: String?  // English name
    
    enum CodingKeys: String, CodingKey {
        case ja = "ja"
        case en = "en"
    }
    
    // MARK: - Localized Name Retrieval
    /// Get localized name based on current language
    /// Falls back to English if Japanese is not available, and vice versa
    func getLocalizedName() -> String {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        return currentLanguage.selectLocalizedName(ja: ja, en: en)
    }
    
    /// Get localized name with fallback to a base name if localized title is empty
    func getLocalizedName(fallbackTo baseName: String) -> String {
        let localizedName = getLocalizedName()
        return localizedName.isEmpty ? baseName : localizedName
    }
}


// MARK: - Station Information Model
// Data structure representing a railway station.
// Includes station identification, localization, and metadata.
struct Station: Hashable, Codable {
    let name: String
    let code: String?
    let index: Int?                    // odpt:index - station order in the line
    let lineCode: String?              // Line code that this station belongs to
    let title: LocalizedTitle?
    
    // Computed properties
    // Split by ":" and return first component for ODPT format (e.g., "StationA:1887:StationA" -> "StationA")
    var displayName: String {
        let baseName = title?.getLocalizedName(fallbackTo: name) ?? name
        // Split by ":" and return first component for ODPT format
        let components = baseName.components(separatedBy: ":")
        return components.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? baseName
    }
    
    var cleanedName: String {
        return name
    }
    
    // Initialize with individual parameters
    init(name: String, code: String?, index: Int?, lineCode: String?, title: LocalizedTitle?) {
        self.name = name
        self.code = code
        self.index = index
        self.lineCode = lineCode
        self.title = title
    }
    
    // Initialize from TransportationStop
    init(from transportationStop: TransportationStop) {
        self.name = transportationStop.name
        self.code = transportationStop.code
        self.index = transportationStop.index
        self.lineCode = transportationStop.lineCode
        self.title = transportationStop.title
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case code = "odpt:station"
        case index = "odpt:index"
        case lineCode
        case title = "odpt:stationTitle"
    }
}

// MARK: - Bus Stop Information Model
// Data structure representing a bus stop.
// Includes bus stop identification, localization, and metadata.
struct BusStop: Hashable, Codable {
    let name: String
    let code: String?
    let index: Int?                    // odpt:index - bus stop order in the route
    let lineCode: String?              // Line code that this bus stop belongs to
    let title: LocalizedTitle?         // Multi-language title from note and busstopPole
    
    // Bus-specific properties
    let note: String?                  // odpt:note - bus stop description from ODPT API
    let busstopPole: String?           // odpt:busstopPole - bus stop identifier
    
    // Computed properties
    // Split by ":" and return first component for ODPT format (e.g., "StationA:1887:StationA" -> "StationA")
    var displayName: String {
        // Use localized name based on current language setting
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        var baseName: String
        
        if let title = title {
            let localizedName = title.getLocalizedName()
            if !localizedName.isEmpty {
                baseName = localizedName
            } else {
                baseName = cleanedName
            }
        } else {
            // Fallback: use note (Japanese) for Japanese locale, or try to extract English from busstopPole
            if currentLanguage == "ja" {
                baseName = cleanedName
            } else {
                // For English, try to get English name from busstopPole
                if let busstopPole = busstopPole {
                    let components = busstopPole.components(separatedBy: ".")
                    if components.count > 2 {
                        baseName = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    } else {
                        baseName = cleanedName
                    }
                } else {
                    baseName = cleanedName
                }
            }
        }
        
        // Split by ":" and return first component for ODPT format
        let components = baseName.components(separatedBy: ":")
        return components.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? baseName
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case code
        case index = "odpt:index"
        case lineCode
        case note = "odpt:note"
        case busstopPole = "odpt:busstopPole"
        case title = "odpt:title"
    }
    
    // MARK: - Initialization
    // Initialize with ODPT API data
    init(
        name: String,
        code: String? = nil,
        index: Int? = nil,
        lineCode: String? = nil,
        title: LocalizedTitle? = nil,
        note: String? = nil,
        busstopPole: String? = nil
    ) {
        self.name = name
        self.code = code
        self.index = index
        self.lineCode = lineCode
        self.title = title
        self.note = note
        self.busstopPole = busstopPole
    }
    
    // Initialize from TransportationStop
    init(from transportationStop: TransportationStop) {
        self.name = transportationStop.name
        self.code = transportationStop.code
        self.index = transportationStop.index
        self.lineCode = transportationStop.lineCode
        self.title = transportationStop.title
        self.note = transportationStop.note
        self.busstopPole = transportationStop.busstopPole
    }
    
    // Custom decoder for multi-language title generation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.code = try container.decodeIfPresent(String.self, forKey: .code)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
        self.busstopPole = try container.decodeIfPresent(String.self, forKey: .busstopPole)
        self.index = try container.decodeIfPresent(Int.self, forKey: .index)
        self.lineCode = try container.decodeIfPresent(String.self, forKey: .lineCode)
        
        // Generate multi-language title from note and busstopPole using shared logic
        self.title = String.generateBusStopTitle(note: self.note ?? "", busstopPole: self.busstopPole ?? "")
        
        // Keep original Japanese name as base name (don't localize here)
        self.name = self.note ?? self.busstopPole ?? ""
    }
        
    // MARK: - Cleaned Name
    // Get cleaned name from note field (entire note field)
    var cleanedName: String {
        if let note = note, !note.isEmpty {
            return note.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return name
    }
}


// MARK: - Transportation Time Protocol
// Common protocol for all transportation time data
protocol TransportationTime: Hashable {
    var departureTime: String { get }
    var arrivalTime: String { get }
    var rideTime: Int { get }
    var calculatedRideTime: Int { get }
    var isValid: Bool { get }
}

// MARK: - Train Time Model
// Represents train time information with departure, arrival, and ride time data
struct TrainTime: TransportationTime {
    let departureTime: String      // Departure time in HH:MM format
    let arrivalTime: String        // Arrival time in HH:MM format
    let trainNumber: String?      // Optional train number identifier
    let trainType: String?        // Optional train type identifier
    let rideTime: Int             // Ride time in minutes
    
    // MARK: - Initialization
    // Initialize with all required parameters
    init(
        departureTime: String, 
        arrivalTime: String, 
        trainNumber: String? = nil, 
        trainType: String? = nil, 
        rideTime: Int
    ) {
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.trainNumber = trainNumber
        self.trainType = trainType
        self.rideTime = rideTime
    }
    
    // MARK: - TransportationTime Protocol
    // Calculate ride time from departure and arrival times using TimeExtensions
    var calculatedRideTime: Int {
        return departureTime.calculateRideTime(arrivalTime: arrivalTime)
    }
    
    // Check if this train time has valid data
    var isValid: Bool {
        return !departureTime.isEmpty && !arrivalTime.isEmpty && rideTime > 0
    }
}

// MARK: - Bus Time Model
// Represents bus time information with departure, arrival, and ride time data
struct BusTime: TransportationTime {
    let departureTime: String      // Departure time in HH:MM format
    let arrivalTime: String        // Arrival time in HH:MM format
    let busNumber: String?        // Optional bus number identifier
    let routePattern: String?     // Optional route pattern identifier
    let rideTime: Int             // Ride time in minutes
    
    // MARK: - Initialization
    // Initialize with all required parameters
    init(
        departureTime: String, 
        arrivalTime: String, 
        busNumber: String? = nil, 
        routePattern: String? = nil, 
        rideTime: Int
    ) {
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.busNumber = busNumber
        self.routePattern = routePattern
        self.rideTime = rideTime
    }
    
    // MARK: - TransportationTime Protocol
    // Calculate ride time from departure and arrival times using TimeExtensions
    var calculatedRideTime: Int {
        return departureTime.calculateRideTime(arrivalTime: arrivalTime)
    }
    
    // Check if this bus time has valid data
    var isValid: Bool {
        return !departureTime.isEmpty && !arrivalTime.isEmpty && rideTime > 0
    }
}

// MARK: - TransferType Utilities
// Helper function to convert string labels to TransferType enum values
func transferType(from label: String) -> TransferType {
    switch label {
        case "none", "None", "none".localized, "None".localized: return .none
        case "walking", "Walking", "walking".localized, "Walking".localized: return .walking
        case "bicycle", "Bicycle", "bicycle".localized, "Bicycle".localized: return .bicycle
        case "car", "Car", "car".localized, "Car".localized: return .car
        default: return .walking // Default to walking instead of none
    }
}

// MARK: - ODPT BusstopPole DTO
// DTO for bus stop pole data from ODPT API.
// Only extracts dc:title for Japanese station names.
struct BusstopPoleDTO: Decodable {
    let title: String
    let sameAs: String?
    let busstopPoleTimetable: [String]?
    
    enum CodingKeys: String, CodingKey {
        case title = "dc:title"
        case sameAs = "owl:sameAs"
        case busstopPoleTimetable = "odpt:busstopPoleTimetable"
    }
}

