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
    
    // MARK: - API Type Determination
    // Determine the appropriate API type for this operator
    var apiType: ODPTAPIType {
        switch self {
        case .toeiMetro, .toeiBus:
            return .publicAPI
        case .tokyoMetro, .yokohamaMetro, .tsukuba, .tama, .yurikamome, .rinkai,
             .odakyuBus, .yokohamaBus, .tokyuBus, .seibuBus, .sotetsuBus:
            return .standard
        case .jrEast, .tokyu, .odakyu, .keikyu, .tobu, .seibu, .sotetsu,
             .kanachuBus, .kokusaiKogyo:
            return .challenge
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
        case .toeiBus, .yokohamaBus, .tokyuBus, .odakyuBus, .seibuBus, .sotetsuBus,
             .kanachuBus, .kokusaiKogyo:
            return []
        }
    }
    
    // MARK: - API Data Type Enum
    // Defines the type of data to request from the API
    enum APIDataType {
        case lineInfo       // Railway line or bus route information
        case timetable      // Timetable data
        
        var railwayOdpTDataType: ODPTDataType {
            switch self {
            case .lineInfo: return .railwayLine
            case .timetable: return .railwayTimetable
            }
        }
        
        var busOdpTDataType: ODPTDataType {
            switch self {
            case .lineInfo: return .busRoutePattern
            case .timetable: return .busTimetable
            }
        }
    }
    
    // MARK: - Unified API Link Generation
    // Generate API links using clean enum-based approach
    func apiLink(for dataType: APIDataType) -> String {
        let odptDataType = transportationType == .railway ? 
            dataType.railwayOdpTDataType : 
            dataType.busOdpTDataType
        return operatorCode.odptURL(dataType: odptDataType, apiType: apiType)
    }
}

// MARK: - Train Type Enumeration
// Comprehensive enumeration of all train types from ODPT API data
enum TrainType: String, CaseIterable {
    // Sotetsu Railway
    case sotetsuCommuterExpress = "odpt.TrainType:Sotetsu.CommuterExpress"
    case sotetsuCommuterLimitedExpress = "odpt.TrainType:Sotetsu.CommuterLimitedExpress"
    case sotetsuExpress = "odpt.TrainType:Sotetsu.Express"
    case sotetsuLimitedExpress = "odpt.TrainType:Sotetsu.LimitedExpress"
    case sotetsuLocal = "odpt.TrainType:Sotetsu.Local"
    case sotetsuRapid = "odpt.TrainType:Sotetsu.Rapid"
    
    // Odakyu Railway
    case odakyuCommuterExpress = "odpt.TrainType:Odakyu.CommuterExpress"
    case odakyuCommuterSemiExpress = "odpt.TrainType:Odakyu.CommuterSemiExpress"
    case odakyuExpress = "odpt.TrainType:Odakyu.Express"
    case odakyuLimitedExpress = "odpt.TrainType:Odakyu.LimitedExpress"
    case odakyuLocal = "odpt.TrainType:Odakyu.Local"
    case odakyuRapidExpress = "odpt.TrainType:Odakyu.RapidExpress"
    case odakyuSemiExpress = "odpt.TrainType:Odakyu.SemiExpress"
    
    // Keikyu Railway
    case keikyuAccessExpress = "odpt.TrainType:Keikyu.AccessExpress"
    case keikyuAirportRapidLimitedExpress = "odpt.TrainType:Keikyu.AirportRapidLimitedExpress"
    case keikyuCommuterLimitedExpress = "odpt.TrainType:Keikyu.CommuterLimitedExpress"
    case keikyuEveningWing = "odpt.TrainType:Keikyu.EveningWing"
    case keikyuExpress = "odpt.TrainType:Keikyu.Express"
    case keikyuLimitedExpress = "odpt.TrainType:Keikyu.LimitedExpress"
    case keikyuLocal = "odpt.TrainType:Keikyu.Local"
    case keikyuMorningWing = "odpt.TrainType:Keikyu.MorningWing"
    case keikyuRapidLimitedExpress = "odpt.TrainType:Keikyu.RapidLimitedExpress"
    case keikyuRapid = "odpt.TrainType:Keikyu.Rapid"
    
    // Seibu Railway
    case seibuCommuterExpress = "odpt.TrainType:Seibu.CommuterExpress"
    case seibuCommuterSemiExpress = "odpt.TrainType:Seibu.CommuterSemiExpress"
    case seibuExpress = "odpt.TrainType:Seibu.Express"
    case seibuFLiner = "odpt.TrainType:Seibu.F-Liner"
    case seibuHaijimaLiner = "odpt.TrainType:Seibu.HaijimaLiner"
    case seibuLimitedExpress = "odpt.TrainType:Seibu.LimitedExpress"
    case seibuLocal = "odpt.TrainType:Seibu.Local"
    case seibuRapidExpress = "odpt.TrainType:Seibu.RapidExpress"
    case seibuRapid = "odpt.TrainType:Seibu.Rapid"
    case seibuSTrain = "odpt.TrainType:Seibu.S-TRAIN"
    case seibuSemiExpress = "odpt.TrainType:Seibu.SemiExpress"
    
    // Tokyu Railway
    case tokyuCommuterLimitedExpress = "odpt.TrainType:Tokyu.CommuterLimitedExpress"
    case tokyuExpress = "odpt.TrainType:Tokyu.Express"
    case tokyuFLiner = "odpt.TrainType:Tokyu.F-Liner"
    case tokyuLimitedExpress = "odpt.TrainType:Tokyu.LimitedExpress"
    case tokyuLocal = "odpt.TrainType:Tokyu.Local"
    case tokyuSTrain = "odpt.TrainType:Tokyu.S-TRAIN"
    case tokyuSemiExpress = "odpt.TrainType:Tokyu.SemiExpress"
    
    // Tobu Railway
    case tobuExpress = "odpt.TrainType:Tobu.Express"
    case tobuFLiner = "odpt.TrainType:Tobu.F-Liner"
    case tobuKawagoeLimitedExpress = "odpt.TrainType:Tobu.KawagoeLimitedExpress"
    case tobuLimitedExpress = "odpt.TrainType:Tobu.LimitedExpress"
    case tobuLocal = "odpt.TrainType:Tobu.Local"
    case tobuRapidExpress = "odpt.TrainType:Tobu.RapidExpress"
    case tobuRapid = "odpt.TrainType:Tobu.Rapid"
    case tobuSLTaiju = "odpt.TrainType:Tobu.SL-Taiju"
    case tobuSectionExpress = "odpt.TrainType:Tobu.SectionExpress"
    case tobuSectionSemiExpress = "odpt.TrainType:Tobu.SectionSemiExpress"
    case tobuSemiExpress = "odpt.TrainType:Tobu.SemiExpress"
    case tobuTHLiner = "odpt.TrainType:Tobu.TH-LINER"
    case tobuTJLiner = "odpt.TrainType:Tobu.TJ-Liner"
    
    // JR-East
    case jrEastChuoSpecialRapid = "odpt.TrainType:JR-East.ChuoSpecialRapid"
    case jrEastCommuterRapid = "odpt.TrainType:JR-East.CommuterRapid"
    case jrEastCommuterSpecialRapid = "odpt.TrainType:JR-East.CommuterSpecialRapid"
    case jrEastExpress = "odpt.TrainType:JR-East.Express"
    case jrEastLimitedExpress = "odpt.TrainType:JR-East.LimitedExpress"
    case jrEastLiner = "odpt.TrainType:JR-East.Liner"
    case jrEastLocal = "odpt.TrainType:JR-East.Local"
    case jrEastOmeSpecialRapid = "odpt.TrainType:JR-East.OmeSpecialRapid"
    case jrEastRapid = "odpt.TrainType:JR-East.Rapid"
    case jrEastSpecialRapid = "odpt.TrainType:JR-East.SpecialRapid"
    
    // Toei Subway
    case toeiAccessExpress = "odpt.TrainType:Toei.AccessExpress"
    case toeiAirportRapidLimitedExpress = "odpt.TrainType:Toei.AirportRapidLimitedExpress"
    case toeiCommuterLimitedExpress = "odpt.TrainType:Toei.CommuterLimitedExpress"
    case toeiExpress = "odpt.TrainType:Toei.Express"
    case toeiLimitedExpress = "odpt.TrainType:Toei.LimitedExpress"
    case toeiLocal = "odpt.TrainType:Toei.Local"
    case toeiRapidLimitedExpress = "odpt.TrainType:Toei.RapidLimitedExpress"
    case toeiRapid = "odpt.TrainType:Toei.Rapid"
    
    // Yokohama Municipal Subway
    case yokohamaMunicipalLocal = "odpt.TrainType:YokohamaMunicipal.Local"
    case yokohamaMunicipalRapid = "odpt.TrainType:YokohamaMunicipal.Rapid"
    
    // Yurikamome
    case yurikamomeLocal = "odpt.TrainType:Yurikamome.Local"
    
    // MIR (Tsukuba Express)
    case mirCommuterRapid = "odpt.TrainType:MIR.CommuterRapid"
    case mirLocal = "odpt.TrainType:MIR.Local"
    case mirRapid = "odpt.TrainType:MIR.Rapid"
    case mirSemiRapid = "odpt.TrainType:MIR.SemiRapid"
    
    // Tama Monorail
    case tamaMonorailLocal = "odpt.TrainType:TamaMonorail.Local"
    
    // Tokyo Metro
    case tokyoMetroCommuterExpress = "odpt.TrainType:TokyoMetro.CommuterExpress"
    case tokyoMetroCommuterLimitedExpress = "odpt.TrainType:TokyoMetro.CommuterLimitedExpress"
    case tokyoMetroCommuterRapid = "odpt.TrainType:TokyoMetro.CommuterRapid"
    case tokyoMetroExpress = "odpt.TrainType:TokyoMetro.Express"
    case tokyoMetroFLiner = "odpt.TrainType:TokyoMetro.F-Liner"
    case tokyoMetroLimitedExpress = "odpt.TrainType:TokyoMetro.LimitedExpress"
    case tokyoMetroLocal = "odpt.TrainType:TokyoMetro.Local"
    case tokyoMetroRapidExpress = "odpt.TrainType:TokyoMetro.RapidExpress"
    case tokyoMetroRapid = "odpt.TrainType:TokyoMetro.Rapid"
    case tokyoMetroSTrain = "odpt.TrainType:TokyoMetro.S-TRAIN"
    case tokyoMetroSemiExpress = "odpt.TrainType:TokyoMetro.SemiExpress"
    case tokyoMetroTHLiner = "odpt.TrainType:TokyoMetro.TH-LINER"
    
    // TWR (Rinkai Line)
    case twrCommuterRapid = "odpt.TrainType:TWR.CommuterRapid"
    case twrLocal = "odpt.TrainType:TWR.Local"
    case twrRapid = "odpt.TrainType:TWR.Rapid"
    
    // MARK: - Display Name
    // Get localized display name for train type
    var displayName: String {
        switch self {
        // Sotetsu
        case .sotetsuCommuterExpress: return "CommuterExpress".localized
        case .sotetsuCommuterLimitedExpress: return "CommuterLimitedExpress".localized
        case .sotetsuExpress: return "Express".localized
        case .sotetsuLimitedExpress: return "LimitedExpress".localized
        case .sotetsuLocal: return "Local".localized
        case .sotetsuRapid: return "Rapid".localized
        
        // Odakyu
        case .odakyuCommuterExpress: return "CommuterExpress".localized
        case .odakyuCommuterSemiExpress: return "CommuterSemiExpress".localized
        case .odakyuExpress: return "Express".localized
        case .odakyuLimitedExpress: return "LimitedExpress".localized
        case .odakyuLocal: return "Local".localized
        case .odakyuRapidExpress: return "RapidExpress".localized
        case .odakyuSemiExpress: return "SemiExpress".localized
        
        // Keikyu
        case .keikyuAccessExpress: return "AccessExpress".localized
        case .keikyuAirportRapidLimitedExpress: return "AirportRapidLimitedExpress".localized
        case .keikyuCommuterLimitedExpress: return "CommuterLimitedExpress".localized
        case .keikyuEveningWing: return "EveningWing".localized
        case .keikyuExpress: return "Express".localized
        case .keikyuLimitedExpress: return "LimitedExpress".localized
        case .keikyuLocal: return "Local".localized
        case .keikyuMorningWing: return "MorningWing".localized
        case .keikyuRapidLimitedExpress: return "RapidLimitedExpress".localized
        case .keikyuRapid: return "Rapid".localized
        
        // Seibu
        case .seibuCommuterExpress: return "CommuterExpress".localized
        case .seibuCommuterSemiExpress: return "CommuterSemiExpress".localized
        case .seibuExpress: return "Express".localized
        case .seibuFLiner: return "FLiner".localized
        case .seibuHaijimaLiner: return "HaijimaLiner".localized
        case .seibuLimitedExpress: return "LimitedExpress".localized
        case .seibuLocal: return "Local".localized
        case .seibuRapidExpress: return "RapidExpress".localized
        case .seibuRapid: return "Rapid".localized
        case .seibuSTrain: return "STrain".localized
        case .seibuSemiExpress: return "SemiExpress".localized
        
        // Tokyu
        case .tokyuCommuterLimitedExpress: return "CommuterLimitedExpress".localized
        case .tokyuExpress: return "Express".localized
        case .tokyuFLiner: return "FLiner".localized
        case .tokyuLimitedExpress: return "LimitedExpress".localized
        case .tokyuLocal: return "Local".localized
        case .tokyuSTrain: return "STrain".localized
        case .tokyuSemiExpress: return "SemiExpress".localized
        
        // Tobu
        case .tobuExpress: return "Express".localized
        case .tobuFLiner: return "FLiner".localized
        case .tobuKawagoeLimitedExpress: return "KawagoeLimitedExpress".localized
        case .tobuLimitedExpress: return "LimitedExpress".localized
        case .tobuLocal: return "Local".localized
        case .tobuRapidExpress: return "RapidExpress".localized
        case .tobuRapid: return "Rapid".localized
        case .tobuSLTaiju: return "SLTaiju".localized
        case .tobuSectionExpress: return "SectionExpress".localized
        case .tobuSectionSemiExpress: return "SectionSemiExpress".localized
        case .tobuSemiExpress: return "SemiExpress".localized
        case .tobuTHLiner: return "THLiner".localized
        case .tobuTJLiner: return "TJLiner".localized
        
        // JR-East
        case .jrEastChuoSpecialRapid: return "ChuoSpecialRapid".localized
        case .jrEastCommuterRapid: return "CommuterRapid".localized
        case .jrEastCommuterSpecialRapid: return "CommuterSpecialRapid".localized
        case .jrEastExpress: return "Express".localized
        case .jrEastLimitedExpress: return "LimitedExpress".localized
        case .jrEastLiner: return "Liner".localized
        case .jrEastLocal: return "Local".localized
        case .jrEastOmeSpecialRapid: return "OmeSpecialRapid".localized
        case .jrEastRapid: return "Rapid".localized
        case .jrEastSpecialRapid: return "SpecialRapid".localized
        
        // Toei
        case .toeiAccessExpress: return "AccessExpress".localized
        case .toeiAirportRapidLimitedExpress: return "AirportRapidLimitedExpress".localized
        case .toeiCommuterLimitedExpress: return "CommuterLimitedExpress".localized
        case .toeiExpress: return "Express".localized
        case .toeiLimitedExpress: return "LimitedExpress".localized
        case .toeiLocal: return "Local".localized
        case .toeiRapidLimitedExpress: return "RapidLimitedExpress".localized
        case .toeiRapid: return "Rapid".localized
        
        // Yokohama Municipal
        case .yokohamaMunicipalLocal: return "Local".localized
        case .yokohamaMunicipalRapid: return "Rapid".localized
        
        // Yurikamome
        case .yurikamomeLocal: return "Local".localized
        
        // MIR
        case .mirCommuterRapid: return "CommuterRapid".localized
        case .mirLocal: return "Local".localized
        case .mirRapid: return "Rapid".localized
        case .mirSemiRapid: return "SemiRapid".localized
        
        // Tama Monorail
        case .tamaMonorailLocal: return "Local".localized
        
        // Tokyo Metro
        case .tokyoMetroCommuterExpress: return "CommuterExpress".localized
        case .tokyoMetroCommuterLimitedExpress: return "CommuterLimitedExpress".localized
        case .tokyoMetroCommuterRapid: return "CommuterRapid".localized
        case .tokyoMetroExpress: return "Express".localized
        case .tokyoMetroFLiner: return "FLiner".localized
        case .tokyoMetroLimitedExpress: return "LimitedExpress".localized
        case .tokyoMetroLocal: return "Local".localized
        case .tokyoMetroRapidExpress: return "RapidExpress".localized
        case .tokyoMetroRapid: return "Rapid".localized
        case .tokyoMetroSTrain: return "STrain".localized
        case .tokyoMetroSemiExpress: return "SemiExpress".localized
        case .tokyoMetroTHLiner: return "THLiner".localized
        
        // TWR
        case .twrCommuterRapid: return "CommuterRapid".localized
        case .twrLocal: return "Local".localized
        case .twrRapid: return "Rapid".localized
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
