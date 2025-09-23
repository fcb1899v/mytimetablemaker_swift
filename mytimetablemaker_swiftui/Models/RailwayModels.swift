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
    enum Kind: String, CaseIterable { 
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
    
    let id = UUID()
    let kind: Kind
    let name: String
    let code: String                    // owl:sameAs - unique identifier from ODPT
    let operatorCode: String?           // odpt:operator (e.g., odpt.Operator:JR-East)
    let lineColor: String?              // odpt:lineColor (e.g., #000000)
    let startStation: String?           // odpt:startStation - first station on the line
    let endStation: String?             // odpt:endStation - last station on the line
    let destinationStation: String?     // odpt:destinationStation - destination station (first element from array)
    let railwayTitle: RailwayTitle?     // odpt:railwayTitle - multi-language support
    let lineCode: String?               // odpt:lineCode (e.g., "JY", "TT", etc.)
    let lineDirection: String?          // Calculated direction based on station index comparison
    
    // MARK: - Bus-specific properties
    let busRoute: String?           // odpt:busroute - bus route identifier
    let pattern: String?            // odpt:pattern - bus route pattern
    let busDirection: String?       // odpt:direction - bus direction
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
    
    func getEnglishName() -> String {
        return en ?? ""
    }
}

// MARK: - Station Information Model
// Data structure representing a railway station.
// Includes station identification, localization, and metadata.
struct Station: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String?
    let index: Int?                    // odpt:index - station order in the line
    let lineCode: String?              // Line code that this station belongs to
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
    
    func getEnglishName() -> String {
        if let title = title {
            return title.en ?? name
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
    
    func getEnName() -> String {
        return en ?? ""
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

// MARK: - Train Time Model
// Represents train time information with departure, arrival, and ride time data
struct TrainTime {
    let departureTime: String      // Departure time in HH:MM format
    let arrivalTime: String        // Arrival time in HH:MM format
    let trainNumber: String?      // Optional train number identifier
    let trainType: String?        // Optional train type identifier
    let rideTime: Int             // Ride time in minutes
    
    // MARK: - Initialization
    // Initialize with all required parameters
    init(departureTime: String, arrivalTime: String, trainNumber: String? = nil, trainType: String? = nil, rideTime: Int) {
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.trainNumber = trainNumber
        self.trainType = trainType
        self.rideTime = rideTime
    }
    
    // MARK: - Computed Properties
    // Calculate ride time from departure and arrival times
    var calculatedRideTime: Int {
        let departureComponents = departureTime.components(separatedBy: ":")
        let arrivalComponents = arrivalTime.components(separatedBy: ":")
        
        guard departureComponents.count == 2,
              arrivalComponents.count == 2,
              let departureHour = Int(departureComponents[0]),
              let departureMinute = Int(departureComponents[1]),
              let arrivalHour = Int(arrivalComponents[0]),
              let arrivalMinute = Int(arrivalComponents[1]) else {
            return 0
        }
        
        let departureTotalMinutes = departureHour * 60 + departureMinute
        let arrivalTotalMinutes = arrivalHour * 60 + arrivalMinute
        
        // Handle day rollover (arrival time is next day)
        return arrivalTotalMinutes >= departureTotalMinutes ?
            arrivalTotalMinutes - departureTotalMinutes :
            (24 * 60) - departureTotalMinutes + arrivalTotalMinutes
    }
    
    // MARK: - Utility Methods
    // Check if this train time has valid data
    var isValid: Bool {
        return !departureTime.isEmpty && !arrivalTime.isEmpty && rideTime > 0
    }
    
    // Get formatted display string for ride time
    var formattedRideTime: String {
        let hours = rideTime / 60
        let minutes = rideTime % 60
        
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        } else {
            return "\(minutes)分"
        }
    }
}

// MARK: - Extensions
// Additional functionality for TrainTime
extension TrainTime: Equatable {
    static func == (lhs: TrainTime, rhs: TrainTime) -> Bool {
        return lhs.departureTime == rhs.departureTime &&
               lhs.arrivalTime == rhs.arrivalTime &&
               lhs.trainNumber == rhs.trainNumber &&
               lhs.trainType == rhs.trainType &&
               lhs.rideTime == rhs.rideTime
    }
}

extension TrainTime: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(departureTime)
        hasher.combine(arrivalTime)
        hasher.combine(trainNumber)
        hasher.combine(trainType)
        hasher.combine(rideTime)
    }
}

extension TrainTime: CustomStringConvertible {
    var description: String {
        let trainInfo = trainNumber != nil ? " (列車番号: \(trainNumber!))" : ""
        let typeInfo = trainType != nil ? " (種別: \(trainType!))" : ""
        return "\(departureTime) → \(arrivalTime) (\(formattedRideTime))\(trainInfo)\(typeInfo)"
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
