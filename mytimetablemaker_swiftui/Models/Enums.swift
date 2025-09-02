//
//  EnumSetting.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2020/12/27.
//

import SwiftUI

// MARK: - Custom Color Enumeration
// Defines color options for line customization with RGB values
enum CustomColor: String, CaseIterable {
    case accent = "DEFAULT"
    case red    = "RED"
    case orange = "ORANGE"
    case yellow = "YELLOW"
    case yelgre = "YELLOW GREEN"
    case green  = "GREEN"
    case orive  = "ORIVE"
    case blugre = "BLUE GREEN"
    case ligblr = "LIGHT BLUE"
    case blue   = "BLUE"
    case navblu = "NAVY BLUE"
    case purple = "PURPLE"
    case pink   = "PINK"
    case beige  = "BEIGE"
    case darred = "DARK RED"
    case brown  = "BROWN"
    case gold   = "GOLD"
    case silver = "SILVER"
    case gray   = "GRAY"
    case black  = "BLACK"
    var RGB: String {
        switch self {
            case .accent: return "#03DAC5"
            case .red   : return "#FF0000"
            case .orange: return "#F68B1E"
            case .yellow: return "#FFD400"
            case .yelgre: return "#99CC00"
            case .orive : return "#9FB01C"
            case .green : return "#009933"
            case .blugre: return "#00AC9A"
            case .ligblr: return "#00BAE8"
            case .blue  : return "#0000FF"
            case .navblu: return "#003686"
            case .purple: return "#A757A8"
            case .pink  : return "#E85298"
            case .beige : return "#C1A470"
            case .darred: return "#C9252F"
            case .brown : return "#BB6633"
            case .gold  : return "#C5C544"
            case .silver: return "#89A1AD"
            case .gray  : return "#9E9E9F"
            case .black : return "#000000"
        }
    }
}

// MARK: - Data Source Definitions
// Defines available data sources for railway information

// MARK: - Local Data Source Definition
// Defines available local JSON data files for offline operation.
// Provides fallback data when ODPT API is unavailable.
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
    case odakyuBus     // Odakyu Bus
    case seibuBus      // Seibu Bus
    case tokyuBus      // Tokyu Bus
    
    // MARK: - File Name Mapping
    // Generate filename dynamically from operatorCode with transportation type included
    var fileName: String {
        // Extract operator name from operatorCode (remove "odpt.Operator:" prefix)
        let operatorName = operatorCode.replacingOccurrences(of: "odpt.Operator:", with: "")
        // Convert to lowercase and keep hyphens
        let normalizedName = operatorName.lowercased().replacingOccurrences(of: " ", with: "")
        // Add transportation type suffix
        return "\(normalizedName)_\(transportationType.rawValue.lowercased()).json"
    }
    
    // MARK: - Display Name Mapping
    // Get localized display name for UI presentation
    var displayName: String {
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
        case .odakyuBus: return "小田急バス"
        case .seibuBus: return "西武バス"
        case .sotetsuBus: return "相鉄バス"
        case .kanachuBus: return "神奈中バス"
        case .kokusaiKogyo: return "国際興業"
        }
    }
    
    // MARK: - ODPT Operator Code Mapping
    // Get ODPT operator code for API queries and data matching
    var operatorCode: String {
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
        case .odakyuBus: return "odpt.Operator:OdakyuBus"
        case .seibuBus: return "odpt.Operator:SeibuBus"
        case .sotetsuBus: return "odpt.Operator:SotetsuBus"
        case .kanachuBus: return "odpt.Operator:Kanachu"
        case .kokusaiKogyo: return "odpt.Operator:KokusaiKogyoBus"
        }
    }
    
    // MARK: - Transportation Type
    // Get transportation type (railway or bus) for data processing
    var transportationType: TransportationLine.Kind {
        switch self {
        case .jrEast, .tokyoMetro, .toeiMetro, .tokyu, .keikyu, .odakyu, .tobu,
             .seibu, .sotetsu, .yokohamaMetro, .rinkai, .yurikamome, .tsukuba, .tama:
            return .railway
        case .toeiBus, .yokohamaBus, .tokyuBus, .odakyuBus, .seibuBus, .sotetsuBus,
             .kanachuBus, .kokusaiKogyo:
            return .bus
        }
    }
    
    // MARK: - API Link
    var lineInfomationLink: String {
        switch self {
        case .toeiMetro:
            return operatorCode.odptPublicURL(isRailway: true)
        case .tokyoMetro, .yokohamaMetro, .tsukuba, .tama, .yurikamome, .rinkai:
            return operatorCode.odptURL(isRailway: true)
        case .jrEast, .tokyu, .odakyu, .keikyu, .tobu, .seibu, .sotetsu:
            return operatorCode.odptChallengeURL(isRailway: true)
        case .toeiBus:
            return operatorCode.odptPublicURL(isRailway: false)
        case .odakyuBus, .yokohamaBus, .tokyuBus, .seibuBus, .sotetsuBus:
            return operatorCode.odptURL(isRailway: false)
        case .kanachuBus, .kokusaiKogyo:
            return operatorCode.odptChallengeURL(isRailway: false)
        }
    }
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
