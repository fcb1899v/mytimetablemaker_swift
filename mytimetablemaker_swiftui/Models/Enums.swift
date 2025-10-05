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
        switch self {
        case .jrEast: return "JR東日本"
        case .tokyoMetro: return "東京メトロ"
        case .toeiMetro: return "都営地下鉄"
        case .tokyu: return "東急電鉄"
        case .keikyu: return "京急電鉄"
        case .odakyu: return "小田急電鉄"
        case .tobu: return "東武鉄道"
        case .seibu: return "西武鉄道"
        case .sotetsu: return "相模鉄道"
        case .yokohamaMetro: return "横浜市営地下鉄"
        case .rinkai: return "東京臨海高速鉄道"
        case .yurikamome: return "ゆりかもめ"
        case .tsukuba: return "首都圏新都市鉄道"
        case .tama: return "多摩都市モノレール"
        case .toeiBus: return "都営バス"
        case .yokohamaBus: return "横浜市営バス"
        case .tokyuBus: return "東急バス"
        case .seibuBus: return "西武バス"
        case .sotetsuBus: return "相鉄バス"
        case .kanachuBus: return "神奈中バス"
        case .kokusaiKogyo: return "国際興業"
        case .odakyuBus: return "小田急バス"
        case .keioBus: return "京王バス"
        case .nishitokyoBus: return "西東京バス"
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

    var hasTrainTimeTable: Bool {
        switch self {
        case .jrEast, .tobu, .sotetsu, .tokyoMetro, .toeiMetro, .yokohamaMetro, .rinkai, .tsukuba, .tama:
            return true
        default:
            return false
        }
    }

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
        case .toeiBus, .yokohamaBus, .tokyuBus, .seibuBus, .sotetsuBus,
            .kanachuBus, .kokusaiKogyo, .odakyuBus, .keioBus, .nishitokyoBus:
            return []
        }
    }
        
    // MARK: - Train Type Helper Methods
    // Get display name for a specific train type using localization
    func getDisplayName(for trainType: String?) -> String {
        guard let trainType = trainType else { 
            return NSLocalizedString("Unknown", comment: "Unknown train type")
        }
        
        // Split by "." and get the last component
        let components = trainType.components(separatedBy: ".")
        guard let lastComponent = components.last else {
            return NSLocalizedString("Unknown", comment: "Unknown train type")
        }
        
        return NSLocalizedString(lastComponent, comment: "Train type display name")
    }
    
    // MARK: - Unified API Link Generation
    // Generate API links using clean enum-based approach
    func apiLink(for dataType: APIDataType) -> String {
        guard let operatorCode = operatorCode else {
            return ""
        }
        let odptDataType = transportationType == .railway ?
            dataType.railwayOdpTDataType :
            dataType.busOdpTDataType
        return operatorCode.odptURL(dataType: odptDataType, apiType: apiType)
    }
}

// MARK: - API Data Type Enum
// Defines the type of data to request from the API
enum APIDataType {
    case lineInfo           // Railway line or bus route information
    case timetable          // Train timetable data
    case stationTimetable   // Station timetable data
    
    var railwayOdpTDataType: ODPTDataType {
        switch self {
        case .lineInfo: return .railway
        case .timetable: return .trainTimetable
        case .stationTimetable: return .stationTimetable
        }
    }
    
    var busOdpTDataType: ODPTDataType {
        switch self {
        case .lineInfo: return .busRoutePattern
        case .timetable: return .busTimetable
        case .stationTimetable: return .busTimetable
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


// MARK: - Station Data Files
// Get railway data files dynamically from LocalDataSource
// Using the fileName property for consistent naming convention
let stationDataFiles: [String] = LocalDataSource.allCases
    .filter { $0.transportationType == .railway }
    .map { $0.fileName }

// MARK: - Parser Error Definitions
// Custom error types for data parsing failures.
enum ODPTParserError: Error {
    case invalidDataStructure
}
