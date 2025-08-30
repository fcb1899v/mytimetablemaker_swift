//
//  LineData.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2020/12/27.
//

import SwiftUI
import Foundation
import Combine

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
    var isRoute1: Bool { return (self == "back1" || self == "go1") }
    var isShowRoute2Key: String { return "\(self)route2flag" }
    var changeLineKey: String { return "\(self)changeline" }
    var departurePointKey: String { return isBack ? "destination": "departurepoint" }
    var destinationKey: String { return isBack ? "departurepoint" : "destination" }
    func departStationKey(_ num: Int) -> String { return "\(self)departstation\(num + 1)" }
    func arriveStationKey(_ num: Int) -> String { return "\(self)arrivestation\(num + 1)" }
    var stationKeyArray: Array<String> { return [departurePointKey, destinationKey] + (0..<3).flatMap { i in [departStationKey(i), arriveStationKey(i)] } }
    func lineNameKey(_ num: Int) -> String { return "\(self)linename\(num + 1)" }
    func lineSelectedKey(_ num: Int) -> String { return "\(self)lineSelected\(num + 1)" }
    func lineColorKey(_ num: Int) -> String { return "\(self)linecolor\(num + 1)" }
    func lineCodeKey(_ num: Int) -> String { return "\(self)linecode\(num + 1)" }
    func lastUpdatedKey(_ num: Int) -> String { return "\(self)lastupdated\(num + 1)" }
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
    var departurePointDefault: String { return isBack ? textHome: textOffice }
    var destinationDefault: String { return isBack ? textOffice: textHome }
    
    
    // MARK: - Main View Data Access
    // UserDefaults data retrieval for main view display
    var isShowRoute2: Bool { return isShowRoute2Key.userDefaultsBool(false) }
    var changeLineInt: Int { return changeLineKey.userDefaultsInt(0) }
    var departurePoint: String { return departurePointKey.userDefaultsValue(departurePointDefault)! }
    var destination: String { return destinationKey.userDefaultsValue(destinationDefault)! }
    func departStation(_ num: Int) -> String { return departStationKey(num).userDefaultsValue(departStationDefault(num))! }
    func arriveStation(_ num: Int) -> String { return arriveStationKey(num).userDefaultsValue(arriveStationDefault(num))! }
    func lineName(_ num: Int) -> String { return lineNameKey(num).userDefaultsValue(lineNameDefault(num))! }
    func lineColor(_ num: Int ) -> Color { return lineColorKey(num).userDefaultsColor(accentColorString) }
    func lineCode(_ num: Int ) -> String { return lineCodeKey(num).userDefaultsValue("")! }
    func lineColorString(_ num: Int) -> String { return lineColorKey(num).userDefaultsValue(accentColorString)! }
    func rideTime(_ num: Int) -> Int { return rideTimeKey(num).userDefaultsInt(0) }
    func transportation(_ num: Int) -> String { return transportationKey(num).userDefaultsValue(TransportationType.walking.rawValue)! }
    func transferTime(_ num: Int) -> Int { return transferTimeKey(num).userDefaultsInt(0) }
    func timetableTime(_ isWeekday: Bool, _ num: Int, _ hour: Int) -> String { return timetableKey(isWeekday, num, hour).userDefaultsValue("")! }
    func choiceCopyTime(_ isWeekday: Bool, _ num: Int, _ hour: Int, _ i: Int) -> String { return choiceCopyTimeKeyArray(isWeekday, num, hour)[i].userDefaultsValue("")! }


    // MARK: - Settings View Data Access
    // UserDefaults data retrieval for settings view display
    var settingsDeparturePoint: String { return departurePointKey.userDefaultsValue(textNotSet)! }
    var settingsDestination: String { return destinationKey.userDefaultsValue(textNotSet)! }
    func settingsDepartStation(_ num: Int) -> String { return departStationKey(num).userDefaultsValue(textNotSet)! }
    func settingsArriveStation(_ num: Int) -> String { return arriveStationKey(num).userDefaultsValue(textNotSet)! }
    func settingsLineName(_ num: Int) -> String { return lineNameKey(num).userDefaultsValue(textNotSet)! }
    func settingsLineColor(_ num: Int ) -> Color { return lineColorKey(num).userDefaultsColor(grayColorString) }
    func settingsLineColorString(_ num: Int) -> String { return lineColorKey(num).userDefaultsValue(grayColorString)! }
    func settingsRideTime(_ num: Int) -> String { return (rideTime(num) == 0) ? textNotSet: "\(String(rideTime(num)))\("[min]".localized)"}
    func settingsRideTimeColor(_ num: Int) -> Color { return (rideTime(num) == 0) ? Color.grayColor: lineColorArray[num] }
    func settingsTransportation(_ num: Int) -> String { return transportationKey(num).userDefaultsValue(textNotSet)! }
    func settingsTransferTime(_ num: Int) -> String { return (transferTime(num) == 0) ? textNotSet: "\(transferTime(num))\("[min]".localized)"}
    
    
    // MARK: - Main View Data Arrays
    // Array generation for main view display
    var departStationArray: Array<String> { return (0..<3).map { i in departStation(i)} }
    var arriveStationArray: Array<String> { return (0..<3).map { i in arriveStation(i)} }
    var stationArray: Array<String> { return (0..<3).flatMap { i in [departStation(i), arriveStation(i)] } }
    var lineNameArray: Array<String> { return (0..<3).map { i in lineName(i) } }
    var lineColorArray: Array<Color> { return (0..<3).map { i in lineColor(i)} }
    var lineCodeArray: Array<String> { return (0..<3).map { i in lineCode(i) } }
    var lineColorStringArray: Array<String> { return (0..<3).map { i in lineColorString(i)} }
    var rideTimeArray: Array<Int> { return (0..<3).map { i in rideTime(i) } }
    var transportationArray: Array<String> { return (0..<4).map { i in transportation(i) } }
    var transferTimeArray: Array<Int> { return (0..<4).map { i in transferTime(i) } }
    var transferTimeStringArray: Array<String> { return (0..<4).map { i in settingsTransferTime(i) } }
    
    
    // MARK: - Settings View Data Arrays
    // Array generation for settings view display
    var departStationSettingsArray: Array<String> { return (0..<3).map {i in settingsDepartStation(i)} }
    var arriveStationSettingsArray: Array<String> { return (0..<3).map {i in settingsArriveStation(i)} }
    var stationSettingsArray: Array<String> { return [settingsDestination, settingsDeparturePoint] + (0..<3).flatMap { i in [settingsDepartStation(i), settingsArriveStation(i)] } }
    var lineNameSettingsArray: Array<String> { return (0..<3).map { i in settingsLineName(i) } }
    var lineColorSettingsArray: Array<Color> { return (0..<3).map {i in settingsLineColor(i)} }
    var lineColorStringSettingsArray: Array<String> { return (0..<3).map {i in settingsLineColorString(i)} }
    var rideTimeStringSettingsArray: Array<String> { return (0..<3).map { i in settingsRideTime(i) } }
    var rideTimeColorSettingsArray: Array<Color> { return (0..<3).map { i in settingsRideTimeColor(i) } }
    var transportationSettingsArray: Array<String> { return (0..<4).map { i in settingsTransportation(i) } }
    
    
    // MARK: - Label Generation
    // Dynamic label generation for UI display
    var departurePointLabel: String { return isBack ? textDestination: textDepartPoint }
    var destinationLabel: String { return isBack ? textDepartPoint: textDestination }
    var stationLabelArray: Array<String> { return [departurePointLabel, destinationLabel] + (0..<3).flatMap { i in [departStationDefault(i), arriveStationDefault(i)] } }
    func transferDepartNum(_ num: Int) -> Int { return (num == 0) ? changeLineInt: num - 2 }
    func transferDepartStation(_ num: Int) -> String { return (num == 1) ? departurePoint.localized: arriveStation(transferDepartNum(num)).localized }
    func transferArriveStation(_ num: Int) -> String { return (num == 0) ? destination.localized: departStation(num - 1).localized }
    func transferFromDepartStation(_ num: Int) -> String { return "\("From ".localized)\(transferDepartStation(num))\(" to ".localized)"}
    func transferToArriveStation(_ num: Int) -> String { return "\("To ".localized)\(transferArriveStation(num))\("he".localized)" }
    func transportationLabel(_ num: Int) -> String { return (num == 1) ? transferFromDepartStation(num): transferToArriveStation(num) }
    
    
    // MARK: - Alert Message Generation
    // Dynamic alert title and message generation
    func rideTimeAlertMessage(_ num: Int) -> String { return  "\("on ".localized)\(lineNameArray[num])" }
    func transportationMessage(_ num: Int) -> String { return "\(transferFromDepartStation(num))\(transferArriveStation(num))" }
    func timetableAlertMessage(_ num: Int, _ hour: Int) -> String { return "\(lineNameArray[num]) (\(hour)\("Hour".localized))" }
    func timetableAlertTitle(_ num: Int) -> String { return "(\(lineNameArray[num])\(" for ".localized)\(stationArray[2 * num + 1])\("houmen".localized))"}
    var routeTitle: String { return
        (self == "back1") ? "Setting home route 1".localized:
        (self == "back2") ? "Setting home route 2".localized:
        (self == "go1") ? "Setting outgoing route 1".localized:
        "Setting outgoing route 2".localized
    }
    var changeLineString: String {
        switch(changeLineInt) {
            case 0: return TransferTime.zero.rawValue.localized
            case 1: return TransferTime.once.rawValue.localized
            case 2: return TransferTime.twice.rawValue.localized
            default: return textNotSet
        }
    }
    var otherroute: String { return self.prefix(self.count - 1) + ((self.suffix(1) == "1") ? "2": "1") }

    
    // MARK: - Timetable Management
    // Timetable data processing and manipulation
    func timetable(_ isWeekday: Bool, _ num: Int) -> [Int] { 
        return  (4...25).flatMap { hour in timetableTime(isWeekday, num, hour).timeString
            .components(separatedBy: CharacterSet(charactersIn: " "))
            .compactMap { Int($0) }
            .map { $0 + hour * 100 }
            .filter { $0 >= 0 && $0 < 2700 }
            .sorted()
        }
    }
    func timetableArray(_ isWeekday: Bool) -> [[Int]] {
        return (0...2).map { num in timetable(isWeekday, num) }
    }
    // MARK: - Time Array Generation
    // Generate departure and arrival times for current route
    func timeArray(_ isWeekday: Bool, _ currenttime: Int) -> [Int] {
        // Depart time of line 1
        var timeArray = [timetableArray(isWeekday)[0].first { $0 > (currenttime/100).plusHHMM(transferTimeArray[1]) } ?? 2700]
        // Arrive time of line 1
        timeArray.append(timeArray[0].plusHHMM(rideTimeArray[0]).overTime(timeArray[0]))
        // Depart time from depart point
        timeArray.insert(timeArray[0].minusHHMM(transferTimeArray[1]).overTime(timeArray[0]), at: 0)
        if (changeLineInt > 0) {
            for i in 1...changeLineInt {
                // Depart time of line i
                timeArray.append(timetableArray(isWeekday)[i].first { $0 > timeArray[2 * i].plusHHMM(transferTimeArray[i + 1]) } ?? 2700)
                // Arrive time of line 1
                timeArray.append(timeArray[2 * i + 1].plusHHMM(rideTimeArray[i]).overTime(timeArray[2 * i + 1]))
            }
        }
        // Arrive time to destination
        timeArray.insert(timeArray[2 * changeLineInt + 2].plusHHMM(transferTimeArray[0]).overTime(timeArray[2 * changeLineInt + 2]), at: 0)
        return timeArray
    }
    // MARK: - Timetable Modification
    // Add time to timetable
    func addTimeFromTimetable(_ inputText: String, _ isWeekday: Bool, _ num: Int, _ hour: Int) -> String {
        return timetableTime(isWeekday, num, hour)
            .addInputTime(inputText)
            .timeSorting(charactersin: " ")
            .joined(separator: " ")
    }
    // Delete time from timetable
    func deleteTimeFromTimetable(_ inputText: String, _ isWeekday: Bool, _ num: Int, _ hour: Int) -> String {
        return timetableTime(isWeekday, num, hour)
            .trimmingCharacters(in: .whitespaces)
            .timeSorting(charactersin: " ")
            .filter{$0 != inputText}
            .joined(separator: " ")
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
    var weekdayLabel: String { return self ? "Weekday".localized: "Weekend".localized }
    var weekendLabel: String { return self ? "Weekend".localized: "Weekday".localized }
}
