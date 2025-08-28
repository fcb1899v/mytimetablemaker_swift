//
//  EnumSetting.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2020/12/27.
//

import SwiftUI

// MARK: - Transfer Time Enumeration
// Defines the number of transfers for transfer routes
enum TransferTime: String, CaseIterable {
    case zero = "Zero";
    case once = "Once";
    case twice = "Twice";
    var Number: Int {
        switch (self) {
            case .zero: return 0
            case .once: return 1
            case .twice: return 2
        }
    }
}

// MARK: - Transportation Enumeration
// Defines available transportation modes for transfer segments
enum Transportation: String, CaseIterable {
    case walking = "Walking"
    case bicycle = "Bicycle"
    case car = "Car"
}

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
    
    // MARK: - File Name Mapping
    // Get the filename for each data source
    var fileName: String {
        switch self {
        case .jrEast: return "jreast.json"
        case .keikyu: return "keikyu.json"
        case .tokyoMetro: return "tokyometro.json"
        case .toeiMetro: return "toeimetro.json"
        case .odakyu: return "odakyu.json"
        case .yurikamome: return "yurikamome.json"
        case .rinkai: return "rinkai.json"
        case .seibu: return "seibu.json"
        case .sotetsu: return "sotetsu.json"
        case .tama: return "tama.json"
        case .tobu: return "tobu.json"
        case .tokyu: return "tokyu.json"
        case .tsukuba: return "tsukuba.json"
        case .yokohamaMetro: return "yokohamametro.json"
        }
    }
    
    // MARK: - Display Name Mapping
    // Get localized display name for UI presentation
    var displayName: String {
        switch self {
        case .jrEast: return "JR東日本"
        case .keikyu: return "京急電鉄"
        case .tokyoMetro: return "東京メトロ"
        case .toeiMetro: return "都営地下鉄"
        case .odakyu: return "小田急電鉄"
        case .yurikamome: return "ゆりかもめ"
        case .rinkai: return "東京臨海高速鉄道"
        case .seibu: return "西武鉄道"
        case .sotetsu: return "相模鉄道"
        case .tama: return "多摩都市モノレール"
        case .tobu: return "東武鉄道"
        case .tokyu: return "東急電鉄"
        case .tsukuba: return "首都圏新都市鉄道"
        case .yokohamaMetro: return "横浜市営地下鉄"
        }
    }
    
    // MARK: - ODPT Operator Code Mapping
    // Get ODPT operator code for API queries and data matching
    var operatorCode: String {
        switch self {
        case .jrEast: return "odpt.Operator:JR-East"
        case .keikyu: return "odpt.Operator:Keikyu"
        case .tokyoMetro: return "odpt.Operator:TokyoMetro"
        case .toeiMetro: return "odpt.Operator:Toei"
        case .odakyu: return "odpt.Operator:Odakyu"
        case .yurikamome: return "odpt.Operator:Yurikamome"
        case .rinkai: return "odpt.Operator:TWR"
        case .seibu: return "odpt.Operator:Seibu"
        case .sotetsu: return "odpt.Operator:Sotetsu"
        case .tama: return "odpt.Operator:TamaMonorail"
        case .tobu: return "odpt.Operator:Tobu"
        case .tokyu: return "odpt.Operator:Tokyu"
        case .tsukuba: return "odpt.Operator:MIR"
        case .yokohamaMetro: return "odpt.Operator:YokohamaMunicipal"
        }
    }
}

// MARK: - Parser Error Definitions
// Custom error types for data parsing failures.
enum ODPTParserError: Error {
    case invalidDataStructure
}
