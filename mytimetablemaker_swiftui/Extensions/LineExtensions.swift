//
//  LineData.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2020/12/27.
//

import SwiftUI
import Foundation
import Combine

// MARK: - ODPT Data Type Enum
// Enumeration for different ODPT data types with associated values
enum ODPTDataType: CaseIterable {
    case railwayLine
    case busRoutePattern
    case railwayTimetable
    case busTimetable
    
    // MARK: - API Endpoint
    var apiEndpoint: String {
        switch self {
        case .railwayLine: return "odpt:Railway"
        case .busRoutePattern: return "odpt:BusroutePattern"
        case .railwayTimetable: return "odpt:StationTimetable"
        case .busTimetable: return "odpt:BusTimetable"
        }
    }
}

// MARK: - ODPT API Type Enum
// Enumeration for different ODPT API endpoints
enum ODPTAPIType: CaseIterable {
    case standard    // Standard API with access key
    case publicAPI   // Public API without access key
    case challenge   // Challenge API with challenge key
}

// MARK: - App Constants
// Core application constants and localized strings
let appTitle = "My Transfer Makers".localized
let goorbackarray = ["back1", "go1", "back2", "go2"]

// UserDefault Key
let homeKey = "departurepoint"
let officeKey = "destination"

// ODPT API Key (Open Data for Public Transportation)
// Load from build configuration files (Debug.xcconfig / Release.xcconfig)
let odptAccessKey = Bundle.main.object(forInfoDictionaryKey: "ODPT_ACCESS_TOKEN") as? String ?? ""
let odptChallengeKey = Bundle.main.object(forInfoDictionaryKey: "ODPT_CHALLENGE_TOKEN") as? String ?? ""

// App version and external links
let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!
let termslink = "https://nakajimamasao-appstudio.web.app/terms".localized

// MARK: - Localization Extension
// Multi-language support for string localization
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: self)
    }
    
    /// Check if string contains hiragana characters
    var containsHiragana: Bool {
        return self.range(of: "[ぁ-ん]", options: .regularExpression) != nil
    }
    
    var normalizedForSearch: String {
        var s = self.trimmingCharacters(in: .whitespacesAndNewlines)
        // Absorb variations in katakana and fullwidth characters (adjust as needed)
        if let t = s.applyingTransform(.hiraganaToKatakana, reverse: false) { s = t }
        if let t = s.applyingTransform(.fullwidthToHalfwidth, reverse: false) { s = t }
        return s.lowercased()
    }

    /// Extract the last component from ODPT identifiers
    /// Example: odpt:Operator:JR-East → JR-East
    var odptTail: String { self.components(separatedBy: ":").last ?? self }
}

// MARK: - Route Data Extension
// Extension for managing route-specific data and UserDefaults operations
extension String{
    
    // MARK: - UserDefaults Data Access
    // Helper methods for retrieving UserDefaults values with default fallbacks
    func userDefaultsValue(_ defaultValue: String) -> String? { return (UserDefaults.standard.object(forKey: self) != nil) ? UserDefaults.standard.string(forKey: self): defaultValue }
    func userDefaultsInt(_ defaultValue: Int) -> Int { return (UserDefaults.standard.object(forKey: self) != nil) ? UserDefaults.standard.integer(forKey: self): defaultValue }
    func userDefaultsBool(_ defaultValue: Bool) -> Bool { return (UserDefaults.standard.object(forKey: self) != nil) ? UserDefaults.standard.bool(forKey: self): defaultValue }
    func userDefaultsColor(_ defaultValue: String) -> Color { return Color(userDefaultsValue(defaultValue)!.colorInt) }
    
    // MARK: - UserDefaults Key Generation
    // Route-specific key generation for UserDefaults storage
    var isBack: Bool { return (self == "back1" || self == "back2") }
    var isShowRoute2Key: String { return "\(self)route2flag" }
    var changeLineKey: String { return "\(self)changeline" }
    var departurePointKey: String { return isBack ? "destination": "departurepoint" }
    var destinationKey: String { return isBack ? "departurepoint" : "destination" }
    func departStationKey(_ num: Int) -> String { return "\(self)departstation\(num + 1)" }
    func arriveStationKey(_ num: Int) -> String { return "\(self)arrivestation\(num + 1)" }
    func departStationCodeKey(_ num: Int) -> String { return "\(self)departstationcode\(num + 1)" }
    func arriveStationCodeKey(_ num: Int) -> String { return "\(self)arrivestationcode\(num + 1)" }
    func lineNameKey(_ num: Int) -> String { return "\(self)linename\(num + 1)" }
    func lineSelectedKey(_ num: Int) -> String { return "\(self)lineSelected\(num + 1)" }
    func lineColorKey(_ num: Int) -> String { return "\(self)linecolor\(num + 1)" }
    func lineDirectionKey(_ num: Int) -> String { return "\(self)linedirection\(num + 1)" }
    func lineCodeKey(_ num: Int) -> String { return "\(self)linecode\(num + 1)" }
    func lineKindKey(_ num: Int) -> String { return "\(self)linekind\(num + 1)" }
    func rideTimeKey(_ num: Int) -> String { return "\(self)ridetime\(num + 1)" }
    func transportationKey(_ num: Int) ->  String { return (num == 0) ? "\(self)transporte": "\(self)transport\(num)" }
    func transferTimeKey(_ num: Int) ->  String { return (num == 0) ? "\(self)transfertimee": "\(self)transfertime\(num)" }
    func timetableKey(_ isWeekday: Bool, _ num: Int, _ hour: Int) -> String { return "\(lineNameKey(num))\(isWeekday.weekdayTag)\(hour.addZeroTime)" }
    func choiceCopyTimeKeyArray(_ isWeekday: Bool, _ num: Int, _ hour: Int) -> [String] {
        return [
            "\(lineNameKey(num))\(isWeekday.weekdayTag)\((hour - 1).addZeroTime)",
            "\(lineNameKey(num))\(isWeekday.weekdayTag)\((hour + 1).addZeroTime)",
            "\(lineNameKey(num))\(isWeekday.weekendTag)\(hour.addZeroTime)",
            "\(otherroute.lineNameKey(0))\(isWeekday.weekdayTag)\(hour.addZeroTime)",
            "\(otherroute.lineNameKey(1))\(isWeekday.weekdayTag)\(hour.addZeroTime)",
            "\(otherroute.lineNameKey(2))\(isWeekday.weekdayTag)\(hour.addZeroTime)"
        ]
    }

    // MARK: - Default Data Definitions
    // Default values for route configuration
    var departurePointDefault: String { return isBack ? "Home".localized: "Office".localized }
    var destinationDefault: String { return isBack ? "Office".localized: "Home".localized }
    
    // MARK: - Main View Data Access
    // UserDefaults data retrieval for main view display
    var isShowRoute2: Bool { return isShowRoute2Key.userDefaultsBool(false) }
    var changeLineInt: Int { return changeLineKey.userDefaultsInt(0) }
    var departurePoint: String { return departurePointKey.userDefaultsValue(departurePointDefault)! }
    var destination: String { return destinationKey.userDefaultsValue(destinationDefault)! }
    func departStation(_ num: Int) -> String { return departStationKey(num).userDefaultsValue(num.departStationDefault)! }
    func arriveStation(_ num: Int) -> String { return arriveStationKey(num).userDefaultsValue(num.arriveStationDefault)! }
    func lineName(_ num: Int) -> String { return lineNameKey(num).userDefaultsValue(num.lineNameDefault)! }
    func lineColor(_ num: Int ) -> Color { return lineColorKey(num).userDefaultsColor(accentColorString) }
    func lineCode(_ num: Int ) -> String { return lineCodeKey(num).userDefaultsValue("")! }
    func lineKind(_ num: Int) -> TransportationLine.Kind { 
        let kindString = lineKindKey(num).userDefaultsValue("Railway")!
        return TransportationLine.Kind(rawValue: kindString) ?? .railway
    }
    func lineColorString(_ num: Int) -> String { return lineColorKey(num).userDefaultsValue(accentColorString)! }
    func rideTime(_ num: Int) -> Int { return rideTimeKey(num).userDefaultsInt(0) }
    func transportation(_ num: Int) -> String { return transportationKey(num).userDefaultsValue(TransportationType.walking.rawValue)! }
    func transferTime(_ num: Int) -> Int { return transferTimeKey(num).userDefaultsInt(0) }
    func timetableTime(_ isWeekday: Bool, _ num: Int, _ hour: Int) -> String { return timetableKey(isWeekday, num, hour).userDefaultsValue("")! }
    func choiceCopyTime(_ isWeekday: Bool, _ num: Int, _ hour: Int, _ i: Int) -> String { return choiceCopyTimeKeyArray(isWeekday, num, hour)[i].userDefaultsValue("")! }
    
    // MARK: - Settings View Data Access
    // UserDefaults data retrieval for settings view display
    var settingsDeparturePoint: String { return departurePointKey.userDefaultsValue("Not set".localized)! }
    var settingsDestination: String { return destinationKey.userDefaultsValue("Not set".localized)! }
    func settingsDepartStation(_ num: Int) -> String { return departStationKey(num).userDefaultsValue("Not set".localized)! }
    func settingsArriveStation(_ num: Int) -> String { return arriveStationKey(num).userDefaultsValue("Not set".localized)! }
    func settingsLineName(_ num: Int) -> String { return lineNameKey(num).userDefaultsValue("Not set".localized)! }
    func settingsLineColor(_ num: Int ) -> Color { return lineColorKey(num).userDefaultsColor(grayColorString) }
    func settingsLineColorString(_ num: Int) -> String { return lineColorKey(num).userDefaultsValue(grayColorString)! }
    func settingsRideTime(_ num: Int) -> String { return (rideTime(num) == 0) ? "Not set".localized: "\(String(rideTime(num)))\("[min]".localized)"}
    func settingsRideTimeColor(_ num: Int) -> Color { return (rideTime(num) == 0) ? Color.grayColor: lineColorArray[num] }
    func settingsTransportation(_ num: Int) -> String { return transportationKey(num).userDefaultsValue("Not set".localized)! }
    func settingsTransferTime(_ num: Int) -> String { return (transferTime(num) == 0) ? "Not set".localized: "\(transferTime(num))\("[min]".localized)"}
    
    // MARK: - Main View Data Arrays
    // Array generation for main view display
    var departStationArray: Array<String> { return (0..<3).map { i in departStation(i)} }
    var arriveStationArray: Array<String> { return (0..<3).map { i in arriveStation(i)} }
    var stationArray: Array<String> { return (0..<3).flatMap { i in [departStation(i), arriveStation(i)] } }
    var lineNameArray: Array<String> { return (0..<3).map { i in lineName(i) } }
    var lineColorArray: Array<Color> { return (0..<3).map { i in lineColor(i)} }
    var lineCodeArray: Array<String> { return (0..<3).map { i in lineCode(i) } }
    var lineKindArray: Array<TransportationLine.Kind> { return (0..<3).map { i in lineKind(i) } }
    var lineColorStringArray: Array<String> { return (0..<3).map { i in lineColorString(i)} }
    var rideTimeArray: Array<Int> { return (0..<3).map { i in rideTime(i) } }
    var transportationArray: Array<String> { return (0..<4).map { i in transportation(i) } }
    var transferTimeArray: Array<Int> { return (0..<4).map { i in transferTime(i) } }
    
    // MARK: - Label Generation
    // Dynamic label generation for UI display
    var departurePointLabel: String { return isBack ? "Destination".localized: "Departure place".localized }
    var destinationLabel: String { return isBack ? "Departure place".localized: "Destination".localized }
    var stationLabelArray: Array<String> { return [departurePointLabel, destinationLabel] + (0..<3).flatMap { i in [i.departStationDefault, i.arriveStationDefault] } }
    func transferDepartNum(_ num: Int) -> Int { return (num == 0) ? changeLineInt: num - 2 }
    func transferDepartStation(_ num: Int) -> String { return (num == 1) ? departurePoint.localized: arriveStation(transferDepartNum(num)).localized }
    func transferArriveStation(_ num: Int) -> String { return (num == 0) ? destination.localized: departStation(num - 1).localized }
    func transferFromDepartStation(_ num: Int) -> String { return "\("From ".localized)\(transferDepartStation(num))\(" to ".localized)"}
    func transferToArriveStation(_ num: Int) -> String { return "\("To ".localized)\(transferArriveStation(num))\("he".localized)" }
    func transportationLabel(_ num: Int) -> String { return (num == 1) ? transferFromDepartStation(num): transferToArriveStation(num) }
    
    // MARK: - ODPT API URL Generation
    // Generate ODPT API URLs for different data types and API endpoints
    func odptURL(dataType: ODPTDataType, apiType: ODPTAPIType = .standard) -> String {
        return (apiType == .publicAPI) ? "https://api-public.odpt.org/api/v4/\(dataType.apiEndpoint)?odpt:operator=\(self)":
               (apiType == .standard) ? "https://api.odpt.org/api/v4/\(dataType.apiEndpoint)?odpt:operator=\(self)&acl:consumerKey=\(odptAccessKey)":
               "https://api-challenge.odpt.org/api/v4/\(dataType.apiEndpoint)?odpt:operator=\(self)&acl:consumerKey=\(odptChallengeKey)"
    }
}

// MARK: - Boolean Extensions
// Extensions for boolean values to provide route and weekday information
extension Bool {
    
    // MARK: - Route Direction Extensions
    // self = isBack
    var goOrBack1: String { return self ? "back1": "go1" }
    var goOrBack2: String { return self ? "back2": "go2" }

    // MARK: - Weekday Extensions
    // self = isWeekDay
    var weekdayTag: String { return self ? "weekday": "weekend" }
    var weekendTag: String { return self ? "weekend": "weekday" }
    var weekdayLabel: String { return self ? "Weekdays (Except Public Holidays)".localized: "Saturday & Sunday $ Public Holidays".localized }
    var weekendLabel: String { return self ? "Sat/Sun/PH".localized: "Weekdays".localized }
}

// MARK: - Integer Extensions
// Extensions for integer values to provide station and line default names
extension Int {
    
    // MARK: - Station and Line Default Functions
    // Provides default values for station and line names
    var departStationDefault: String { return "\("Dep. St. ".localized)\(self + 1)" }
    var arriveStationDefault: String { return "\("Arr. St. ".localized)\(self + 1)" }
    var lineNameDefault: String { return "\("Line ".localized)\(self + 1)" }
}
