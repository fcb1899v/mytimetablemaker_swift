//
//  EnumSetting.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2020/12/27.
//

import SwiftUI

// MARK: - Custom Color Enumeration
// Defines color options for line customization
enum CustomColor: String, CaseIterable {
    case red     = "RED"          // Pure red - #E60012
    case darkred = "DARK RED"     // Dark red - #A22041
    case orange  = "ORANGE"       // Orange - #FF6600
    case brown   = "BROWN"        // Brown - #8F4C38
    case yellow  = "YELLOW"       // Bright yellow - #FFD400
    case beige   = "BEIGE"        // Beige - #C1A470
    case orive   = "ORIVE"        // Olive green - #9FB01C
    case yelwgre = "YELLOW GREEN" // Yellow green - #9ACD32
    case green   = "GREEN"        // Green - #009739
    case darkgre = "DARK GREEN"   // Dark green - #004E2E
    case bluegre = "BLUE GREEN"   // Blue green - #00AC9A
    case ligblue = "LIGHT BLUE"   // Light blue - #00BFFF
    case blue    = "BLUE"         // Pure blue - #0000FF
    case navblue = "NAVY BLUE"    // Navy blue - #003580
    case primary = "INDIGO"       // Indigo - #3700B3
    case lavend  = "LAVENDER"     // Lavender - #8F76D6
    case purple  = "PURPLE"       // Purple - #B22C8D
    case magenta = "MAGENTA"      // Magenta - #E4007F
    case pink    = "PINK"         // Pink - #E85298
    case gray    = "GRAY"         // Gray - #9C9C9C
    case silver  = "SILVER"       // Silver - #89A1AD
    case gold    = "GOLD"         // Gold - #C5C544
    case black   = "BLACK"        // Black - #000000
    case accent  = "DEFAULT"      // Default accent color - #03DAC5
}

// MARK: - Data Source Definitions
// Defines available data sources for railway information
enum LocalDataSource: CaseIterable {
    case jrEast        // JR East railway lines
    case keikyu        // Keikyu railway lines
    case tokyoMetro    // Tokyo Metro subway lines
    case toeiMetro     // Toei subway lines
    case odakyu        // Odakyu railway lines
    case yurikamome    // Yurikamomey line
    case rinkai        // Rinkai Line
    case seibu         // Seibu Railway
    case sotetsu       // Sotetsu Railway
    case tama          // Tama Monorail
    case tobu          // Tobu Railway
    case tokyu         // Tokyu Railway
    case tsukuba       // Tsukuba Express
    case yokohamaMetro // Yokohama Municipal Subway
    case toeiBus       // Toei Bus
    case yokohamaBus   // Yokohama Municipal Bus
    case sotetsuBus    // Sotetsu Bus
    case kokusaiKogyo  // Kokusai Kogyo Bus
    case kanachuBus    // Kanachu Bus
    case seibuBus      // Seibu Bus
    case tokyuBus      // Tokyu Bus
    case odakyuBus     // Odakyu Bus
    case keioBus       // Keio Bus
    case nishitokyoBus // Nishitokyo Bus
    
    // MARK: - File Name Mapping
    // Generate filename dynamically from operatorCode with transportation type included
    var fileName: String {
        // Extract operator name from operatorCode (remove "odpt.Operator:" prefix)
        guard let operatorCode = operatorCode else {
            return ""
        }
        let operatorName = operatorCode.replacingOccurrences(of: "odpt.Operator:", with: "")
        // Convert to lowercase and keep hyphens
        let normalizedName = operatorName.lowercased().replacingOccurrences(of: " ", with: "")
        // Add transportation type suffix
        return "\(normalizedName)_\(transportationType.rawValue.lowercased()).json"
    }
    
    // MARK: - Operator Display Name Mapping
    // Get localized display name for operator selection UI
    var operatorDisplayName: String {
        let isJa = Locale.current.language.languageCode?.identifier == "ja"
        
        switch self {
        case .jrEast: return isJa ? "JR東日本" : "JR-East"
        case .tokyoMetro: return isJa ? "東京メトロ" : "TokyoMetro"
        case .toeiMetro: return isJa ? "都営地下鉄" : "ToeiMetro"
        case .tokyu: return isJa ? "東急電鉄" : "Tokyu"
        case .keikyu: return isJa ? "京急電鉄" : "Keikyu"
        case .odakyu: return isJa ? "小田急電鉄" : "Odakyu"
        case .tobu: return isJa ? "東武鉄道" : "Tobu"
        case .seibu: return isJa ? "西武鉄道" : "Seibu"
        case .sotetsu: return isJa ? "相模鉄道" : "Sotetsu"
        case .yokohamaMetro: return isJa ? "横浜市営地下鉄" : "YokohamaMetro"
        case .rinkai: return isJa ? "東京臨海高速鉄道" : "TWR"
        case .yurikamome: return isJa ? "ゆりかもめ" : "Yurikamome"
        case .tsukuba: return isJa ? "首都圏新都市鉄道" : "MIR"
        case .tama: return isJa ? "多摩都市モノレール" : "TamaMonorail"
        case .toeiBus: return isJa ? "都営バス" : "Toei"
        case .yokohamaBus: return isJa ? "横浜市営バス" : "Yokohama"
        case .tokyuBus: return isJa ? "東急バス" : "Tokyu"
        case .seibuBus: return isJa ? "西武バス" : "Seibu"
        case .sotetsuBus: return isJa ? "相鉄バス" : "Sotetsu"
        case .kanachuBus: return isJa ? "神奈中バス" : "Kanachu"
        case .kokusaiKogyo: return isJa ? "国際興業" : "KokusaiKogyo"
        case .odakyuBus: return isJa ? "小田急バス" : "Odakyu"
        case .keioBus: return isJa ? "京王バス" : "Keio"
        case .nishitokyoBus: return isJa ? "西東京バス" : "Nishitokyo"
        }
    }
    
    // MARK: - Operator Short Display Name Mapping
    // Get short display name for CustomTag (compact version)
    var operatorShortDisplayName: String {
        let isJa = Locale.current.language.languageCode?.identifier == "ja"
        
        switch self {
        case .jrEast: return isJa ? "JR東" : "JR-E"
        case .tokyoMetro: return isJa ? "東京メトロ" : "Metro"
        case .toeiMetro: return isJa ? "都営" : "Toei"
        case .tokyu: return isJa ? "東急" : "Tokyu"
        case .keikyu: return isJa ? "京急" : "Keikyu"
        case .odakyu: return isJa ? "小田急" : "Odakyu"
        case .tobu: return isJa ? "東武" : "Tobu"
        case .seibu: return isJa ? "西武" : "Seibu"
        case .sotetsu: return isJa ? "相鉄" : "Sotetsu"
        case .yokohamaMetro: return isJa ? "横浜市" : "Yokohama"
        case .rinkai: return isJa ? "TWR" : "TWR"
        case .yurikamome: return isJa ? "ゆりかもめ" : "Yurikamome"
        case .tsukuba: return isJa ? "MIR" : "MIR"
        case .tama: return isJa ? "多摩" : "Tama"
        case .toeiBus: return isJa ? "都営" : "Toei"
        case .yokohamaBus: return isJa ? "横浜市" : "Yokohama"
        case .tokyuBus: return isJa ? "東急" : "Tokyu"
        case .seibuBus: return isJa ? "西武" : "Seibu"
        case .sotetsuBus: return isJa ? "相鉄" : "Sotetsu"
        case .kanachuBus: return isJa ? "神奈中" : "Kanachu"
        case .kokusaiKogyo: return isJa ? "国際興業" : "Kokusai"
        case .odakyuBus: return isJa ? "小田急" : "Odakyu"
        case .keioBus: return isJa ? "京王" : "Keio"
        case .nishitokyoBus: return isJa ? "西東京" : "Nishitokyo"
        }
    }
    
    // MARK: - ODPT Operator Code Mapping
    // Get ODPT operator code for API queries and data matching
    var operatorCode: String? {
        switch self {
        case .jrEast: return "odpt.Operator:JR-East"
        case .tokyoMetro: return "odpt.Operator:TokyoMetro"
        case .toeiMetro: return "odpt.Operator:Toei"
        case .tokyu: return "odpt.Operator:Tokyu"
        case .keikyu: return "odpt.Operator:Keikyu"
        case .odakyu: return "odpt.Operator:Odakyu"
        case .tobu: return "odpt.Operator:Tobu"
        case .seibu: return "odpt.Operator:Seibu"
        case .sotetsu: return "odpt.Operator:Sotetsu"
        case .yokohamaMetro: return "odpt.Operator:YokohamaMunicipal"
        case .rinkai: return "odpt.Operator:TWR"
        case .yurikamome: return "odpt.Operator:Yurikamome"
        case .tsukuba: return "odpt.Operator:MIR"
        case .tama: return "odpt.Operator:TamaMonorail"
        case .toeiBus: return "odpt.Operator:Toei"
        case .yokohamaBus: return "odpt.Operator:YokohamaMunicipal"
        case .tokyuBus: return "odpt.Operator:TokyuBus"
        case .seibuBus: return "odpt.Operator:SeibuBus"
        case .sotetsuBus: return "odpt.Operator:SotetsuBus"
        case .kanachuBus: return "odpt.Operator:Kanachu"
        case .kokusaiKogyo: return "odpt.Operator:KokusaiKogyoBus"
        case .odakyuBus: return nil
        case .keioBus: return nil
        case .nishitokyoBus: return nil
        }
    }
    
    // MARK: - Transportation Type
    // Get transportation type (railway or bus) for data processing
    var transportationType: TransportationLine.Kind {
        switch self {
        case .jrEast, .tokyoMetro, .toeiMetro, .tokyu, .keikyu, .odakyu, .tobu,
             .seibu, .sotetsu, .yokohamaMetro, .rinkai, .yurikamome, .tsukuba, .tama:
            return .railway
        case .toeiBus, .yokohamaBus, .tokyuBus, .seibuBus, .sotetsuBus,
             .kanachuBus, .kokusaiKogyo, .odakyuBus, .keioBus, .nishitokyoBus:
            return .bus
        }
    }
    
    // MARK: - API Type Determination
    // Determine the appropriate API type for this operator
    var apiType: ODPTAPIType {
        switch self {
        case .toeiMetro, .toeiBus:
            return .publicAPI
        case .tokyoMetro, .yokohamaMetro, .tsukuba, .tama, .yurikamome, .rinkai,
             .yokohamaBus, .tokyuBus, .seibuBus, .sotetsuBus:
            return .standard
        case .jrEast, .tokyu, .odakyu, .keikyu, .tobu, .seibu, .sotetsu,
             .kanachuBus, .kokusaiKogyo:
            return .challenge
        case .odakyuBus, .keioBus, .nishitokyoBus:
            return .gtfs
        }
    }

    // Indicates if this operator provides train timetables.
    var hasTrainTimeTable: Bool {
        switch self {
        case .jrEast, .tobu, .sotetsu, .tokyoMetro, .toeiMetro, .yokohamaMetro, .rinkai, .tsukuba, .tama:
            return true
        default:
            return false
        }
    }

    // Indicates if this operator provides bus timetables.
    var hasBusTimeTable: Bool {
        switch self {
        case .toeiBus, .yokohamaBus, .tokyuBus, .seibuBus, .sotetsuBus, .kanachuBus, .kokusaiKogyo:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Train Type Mapping
    // Get available train types for each operator
    var operatorTrainType: [String] {
        switch self {
        case .jrEast: return [
            "odpt.TrainType:JR-East.ChuoSpecialRapid",
            "odpt.TrainType:JR-East.CommuterRapid",
            "odpt.TrainType:JR-East.CommuterSpecialRapid",
            "odpt.TrainType:JR-East.Express",
            "odpt.TrainType:JR-East.LimitedExpress",
            "odpt.TrainType:JR-East.Liner",
            "odpt.TrainType:JR-East.Local",
            "odpt.TrainType:JR-East.OmeSpecialRapid",
            "odpt.TrainType:JR-East.Rapid",
            "odpt.TrainType:JR-East.SpecialRapid"
        ]
        case .tokyoMetro: return [
            "odpt.TrainType:TokyoMetro.CommuterExpress",
            "odpt.TrainType:TokyoMetro.CommuterLimitedExpress",
            "odpt.TrainType:TokyoMetro.CommuterRapid",
            "odpt.TrainType:TokyoMetro.Express",
            "odpt.TrainType:TokyoMetro.F-Liner",
            "odpt.TrainType:TokyoMetro.LimitedExpress",
            "odpt.TrainType:TokyoMetro.Local",
            "odpt.TrainType:TokyoMetro.RapidExpress",
            "odpt.TrainType:TokyoMetro.Rapid",
            "odpt.TrainType:TokyoMetro.S-TRAIN",
            "odpt.TrainType:TokyoMetro.SemiExpress",
            "odpt.TrainType:TokyoMetro.TH-LINER"
        ]
        case .toeiMetro: return [
            "odpt.TrainType:Toei.AccessExpress",
            "odpt.TrainType:Toei.AirportRapidLimitedExpress",
            "odpt.TrainType:Toei.CommuterLimitedExpress",
            "odpt.TrainType:Toei.Express",
            "odpt.TrainType:Toei.LimitedExpress",
            "odpt.TrainType:Toei.Local",
            "odpt.TrainType:Toei.RapidLimitedExpress",
            "odpt.TrainType:Toei.Rapid"
        ]
        case .tokyu: return [
            "odpt.TrainType:Tokyu.CommuterLimitedExpress",
            "odpt.TrainType:Tokyu.Express",
            "odpt.TrainType:Tokyu.F-Liner",
            "odpt.TrainType:Tokyu.LimitedExpress",
            "odpt.TrainType:Tokyu.Local",
            "odpt.TrainType:Tokyu.S-TRAIN",
            "odpt.TrainType:Tokyu.SemiExpress"
        ]
        case .keikyu: return [
            "odpt.TrainType:Keikyu.AccessExpress",
            "odpt.TrainType:Keikyu.AirportRapidLimitedExpress",
            "odpt.TrainType:Keikyu.CommuterLimitedExpress",
            "odpt.TrainType:Keikyu.EveningWing",
            "odpt.TrainType:Keikyu.Express",
            "odpt.TrainType:Keikyu.LimitedExpress",
            "odpt.TrainType:Keikyu.Local",
            "odpt.TrainType:Keikyu.MorningWing",
            "odpt.TrainType:Keikyu.RapidLimitedExpress",
            "odpt.TrainType:Keikyu.Rapid"
        ]
        case .odakyu: return [
            "odpt.TrainType:Odakyu.CommuterExpress",
            "odpt.TrainType:Odakyu.CommuterSemiExpress",
            "odpt.TrainType:Odakyu.Express",
            "odpt.TrainType:Odakyu.LimitedExpress",
            "odpt.TrainType:Odakyu.Local",
            "odpt.TrainType:Odakyu.RapidExpress",
            "odpt.TrainType:Odakyu.SemiExpress"
        ]
        case .tobu: return [
            "odpt.TrainType:Tobu.Express",
            "odpt.TrainType:Tobu.F-Liner",
            "odpt.TrainType:Tobu.KawagoeLimitedExpress",
            "odpt.TrainType:Tobu.LimitedExpress",
            "odpt.TrainType:Tobu.Local",
            "odpt.TrainType:Tobu.RapidExpress",
            "odpt.TrainType:Tobu.Rapid",
            "odpt.TrainType:Tobu.SL-Taiju",
            "odpt.TrainType:Tobu.SectionExpress",
            "odpt.TrainType:Tobu.SectionSemiExpress",
            "odpt.TrainType:Tobu.SemiExpress",
            "odpt.TrainType:Tobu.TH-LINER",
            "odpt.TrainType:Tobu.TJ-Liner"
        ]
        case .seibu: return [
            "odpt.TrainType:Seibu.CommuterExpress",
            "odpt.TrainType:Seibu.CommuterSemiExpress",
            "odpt.TrainType:Seibu.Express",
            "odpt.TrainType:Seibu.F-Liner",
            "odpt.TrainType:Seibu.HaijimaLiner",
            "odpt.TrainType:Seibu.LimitedExpress",
            "odpt.TrainType:Seibu.Local",
            "odpt.TrainType:Seibu.RapidExpress",
            "odpt.TrainType:Seibu.Rapid",
            "odpt.TrainType:Seibu.S-TRAIN",
            "odpt.TrainType:Seibu.SemiExpress"
        ]
        case .sotetsu: return [
            "odpt.TrainType:Sotetsu.CommuterExpress",
            "odpt.TrainType:Sotetsu.CommuterLimitedExpress",
            "odpt.TrainType:Sotetsu.Express",
            "odpt.TrainType:Sotetsu.LimitedExpress",
            "odpt.TrainType:Sotetsu.Local",
            "odpt.TrainType:Sotetsu.Rapid"
        ]
        case .yokohamaMetro: return [
            "odpt.TrainType:YokohamaMunicipal.Local",
            "odpt.TrainType:YokohamaMunicipal.Rapid"
        ]
        case .rinkai: return [
            "odpt.TrainType:TWR.CommuterRapid",
            "odpt.TrainType:TWR.Local",
            "odpt.TrainType:TWR.Rapid"
        ]
        case .yurikamome: return [
            "odpt.TrainType:Yurikamome.Local"
        ]
        case .tsukuba: return [
            "odpt.TrainType:MIR.CommuterRapid",
            "odpt.TrainType:MIR.Local",
            "odpt.TrainType:MIR.Rapid",
            "odpt.TrainType:MIR.SemiRapid"
        ]
        case .tama: return [
            "odpt.TrainType:TamaMonorail.Local"
        ]
        // Bus operators don't have train types
        default:
            return []
        }
    }
        
    // MARK: - Train Type Helper Methods
    // Get display name for a specific train type using localization
    func getDisplayName(for trainType: String?) -> String {
        guard let trainType = trainType else { 
            return NSLocalizedString("Unknown", comment: "Unknown train type")
        }
        let components = trainType.components(separatedBy: ".")
        guard let lastComponent = components.last else {
            return NSLocalizedString("Unknown", comment: "Unknown train type")
        }
        return NSLocalizedString(lastComponent, comment: "Train type display name")
    }
    
    // MARK: - Unified API Link Generation
    // Generate API links using clean enum-based approach
    func apiLink(for dataType: APIDataType, transportationKind: TransportationLine.Kind = .railway) -> String {
        guard let operatorCode = operatorCode else {
            return ""
        }
        let odptDataType = transportationKind == .railway ?
            dataType.railwayOdpTDataType :
            dataType.busOdpTDataType
        return operatorCode.odptURL(dataType: odptDataType, apiType: apiType)
    }
}

// MARK: - API Data Type Enum
// Defines the type of data to request from the API
enum APIDataType {
    case line               // Railway line or bus route information
    case timetable          // Train timetable data
    case stopTimetable      // Station timetable data
    case stop               // Bus stop pole data
    
    // Maps APIDataType to ODPTDataType for railway context.
    var railwayOdpTDataType: ODPTDataType {
        switch self {
        case .line: return .railway
        case .timetable: return .trainTimetable
        case .stopTimetable: return .stationTimetable
        case .stop: return .trainStation  // Fallback for railway
        }
    }
    
    // Maps APIDataType to ODPTDataType for bus context.
    var busOdpTDataType: ODPTDataType {
        switch self {
        case .line: return .busRoutePattern
        case .timetable: return .busTimetable
        case .stopTimetable: return .busTimetable
        case .stop: return .busstopPole
        }
    }
}

// MARK: - Display Train Type Enum
// Common train type categories for color mapping
enum DisplayTrainType: String, CaseIterable {
    // MARK: - Default Train Types
    case defaultLocal = "defaultLocal"
    case defaultExpress = "defaultExpress"
    case defaultRapid = "defaultRapid"
    case defaultSpecialRapid = "defaultSpecialRapid"
    case defaultLimitedExpress = "defaultLimitedExpress"
    
    // MARK: - Standard Train Types
    case local = "Local"
    case rapid = "Rapid"
    case semiExpress = "SemiExpress"
    case express = "Express"
    case commuterExpress = "CommuterExpress"
    case commuterSemiExpress = "CommuterSemiExpress"
    case commuterRapid = "CommuterRapid"
    case commuterLimitedExpress = "CommuterLimitedExpress"
    case rapidExpress = "RapidExpress"
    case rapidLimitedExpress = "RapidLimitedExpress"
    case limitedExpress = "LimitedExpress"
    case accessExpress = "AccessExpress"
    case airportRapidLimitedExpress = "AirportRapidLimitedExpress"
    case kawagoeLimitedExpress = "KawagoeLimitedExpress"
    case specialRapid = "SpecialRapid"
    case commuterSpecialRapid = "CommuterSpecialRapid"
    case chuoSpecialRapid = "ChuoSpecialRapid"
    case omeSpecialRapid = "OmeSpecialRapid"
    case sectionExpress = "SectionExpress"
    case sectionSemiExpress = "SectionSemiExpress"
    case semiRapid = "SemiRapid"
    case liner = "Liner"
    case fLiner = "FLiner"
    case thLiner = "ThLiner"
    case tjLiner = "TjLiner"
    case haijimaLiner = "HaijimaLiner"
    case sTrain = "STrain"
    case slTaiju = "SlTaiju"
    case eveningWing = "EveningWing"
    case morningWing = "MorningWing"
    case unknown = "Unknown"
}

// MARK: - ODPT Error Types
// Custom error types for ODPT operations
enum ODPTError: Error, LocalizedError {
    case dateExtractionFailed
    case networkError(String)
    case invalidData
    
    // Human-readable error description for UI and logs.
    // Keeps messages concise and localized where applicable.
    var errorDescription: String? {
        switch self {
        case .dateExtractionFailed:
            return "Failed to extract date from API response"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidData:
            return "Invalid data structure"
        }
    }
}

// MARK: - ODPT Calendar Type Enumeration
// Defines calendar types used in ODPT API for timetable scheduling
enum ODPTCalendarType: CaseIterable, Equatable, Hashable {
    case weekday                                            // Weekdays (Monday to Friday, excluding holidays)
    case holiday                                            // Holidays (Sunday, national holidays, holidays, substitute holidays)
    case saturdayHoliday                                    // Saturday holidays (Saturday or holidays)
    case sunday                                             // Sunday
    case monday                                             // Monday
    case tuesday                                            // Tuesday
    case wednesday                                          // Wednesday
    case thursday                                           // Thursday
    case friday                                             // Friday
    case saturday                                           // Saturday
    case specific(String)                                   // Special calendar types (e.g., "odpt.Calendar:Specific.Toei.81-170")

    // MARK: - Raw Value
    // String representation of calendar type for API and storage
    var rawValue: String {
        switch self {
        case .weekday: return "odpt.Calendar:Weekday"
        case .holiday: return "odpt.Calendar:Holiday"
        case .saturdayHoliday: return "odpt.Calendar:SaturdayHoliday"
        case .sunday: return "odpt.Calendar:Sunday"
        case .monday: return "odpt.Calendar:Monday"
        case .tuesday: return "odpt.Calendar:Tuesday"
        case .wednesday: return "odpt.Calendar:Wednesday"
        case .thursday: return "odpt.Calendar:Thursday"
        case .friday: return "odpt.Calendar:Friday"
        case .saturday: return "odpt.Calendar:Saturday"
        case .specific(let value): return value
        }
    }
    
    // MARK: - Custom Initializer
    // Initialize from raw value string, handling special calendar types
    init?(rawValue: String) {
        switch rawValue {
        case "odpt.Calendar:Weekday": self = .weekday
        case "odpt.Calendar:Holiday": self = .holiday
        case "odpt.Calendar:SaturdayHoliday": self = .saturdayHoliday
        case "odpt.Calendar:Sunday": self = .sunday
        case "odpt.Calendar:Monday": self = .monday
        case "odpt.Calendar:Tuesday": self = .tuesday
        case "odpt.Calendar:Wednesday": self = .wednesday
        case "odpt.Calendar:Thursday": self = .thursday
        case "odpt.Calendar:Friday": self = .friday
        case "odpt.Calendar:Saturday": self = .saturday
        default:
            // Handle special calendar types (keep original rawValue for API calls)
            if rawValue.hasPrefix("odpt.Calendar:Specific.") {
                self = .specific(rawValue)
            } else {
                return nil  // Unknown calendar type
            }
        }
    }
    
    // MARK: - Case Iterable
    // Include all static calendar types, excluding .specific case
    // .specific has associated value and cannot be included in allCases
    static var allCases: [ODPTCalendarType] {
        return [.weekday, .holiday, .saturdayHoliday, .sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    }
    
}

// MARK: - ODPT Data Type Enum
// Enumeration for different ODPT data types with associated values
enum ODPTDataType: CaseIterable {
    case railway
    case trainTimetable
    case stationTimetable
    case trainStation
    case busRoutePattern
    case busTimetable
    case busstopPole
    
    // MARK: - API Endpoint
    var apiEndpoint: String {
        switch self {
        case .railway: return "odpt:Railway"
        case .trainTimetable: return "odpt:TrainTimetable"
        case .stationTimetable: return "odpt:StationTimetable"
        case .trainStation: return "odpt:Station"
        case .busRoutePattern: return "odpt:BusroutePattern"
        case .busTimetable: return "odpt:BusTimetable"
        case .busstopPole: return "odpt:BusstopPole"
        }
    }
}

// MARK: - ODPT API Type Enum
// Enumeration for different ODPT API endpoints
enum ODPTAPIType: CaseIterable {
    case standard    // Standard API with access key
    case publicAPI   // Public API without access key
    case challenge   // Challenge API with challenge key
    case gtfs        // No API (Use GTFS Data)
}

// MARK: - Transfer Type Enumeration
// Enumeration of available transportation methods for transfer.
enum TransferType: String, CaseIterable {
    case car = "car"            // Car transportation
    case bicycle = "bicycle"    // Bicycle transportation
    case walking = "walking"    // Walking between stations
    case none = "none"          // No transfer required
    
    // MARK: - Transportation Method Display Name
    // Localized display name for each transportation method
    var transportationDisplayName: String {
        switch self {
            case .none: return "None".localized
            case .walking: return "Walking".localized
            case .bicycle: return "Bicycle".localized
            case .car: return "Car".localized
        }
    }
    
    // MARK: - Icon Properties
    // SF Symbol icon name for each transportation method
    var iconName: String {
        switch self {
            case .none: return "xmark.circle"
            case .walking: return "figure.walk"
            case .bicycle: return "bicycle"
            case .car: return "car"
        }
    }
}

