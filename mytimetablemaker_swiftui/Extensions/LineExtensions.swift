//
//  LineData.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2020/12/27.
//

import SwiftUI
import Foundation
import Combine

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
    
    // MARK: - Bus English Name Extraction
    // Extract English names from ODPT bus identifiers (only for English locale)
    
    /// Extract English name from bus route identifier
    /// Example: "odpt.Busroute:Toei.Mon33" → "Mon33"
    var busRouteEnglishName: String? {
        // Only extract English name for English locale
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        guard currentLanguage != "ja" else { return nil }
        
        // Extract the third part after splitting by dots
        let components = self.components(separatedBy: ".")
        guard components.count >= 3 else { return nil }
        return components[2] // Index 2 should be the English route code
    }
    
    /// Extract English name from bus stop pole identifier
    /// Example: "odpt.BusstopPole:Toei.KameidoStation.369.7" → "KameidoStation"
    var busStopEnglishName: String? {
        // Only extract English name for English locale
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        guard currentLanguage != "ja" else { return nil }
        
        // Extract the third part after splitting by dots
        let components = self.components(separatedBy: ".")
        guard components.count >= 3 else { return nil }
        return components[2] // Index 2 should be the station name
    }
    
    // MARK: - Bus Stop Multi-language Title Generation
    /// Generate LocalizedTitle for bus stops from note and busstopPole
    /// - Parameters:
    ///   - note: Japanese name from odpt:note field
    ///   - busstopPole: English name from odpt:busstopPole field (3rd component)
    /// - Returns: LocalizedTitle with Japanese and English names
    static func generateBusStopTitle(note: String, busstopPole: String) -> LocalizedTitle? {
        let japaneseName: String? = note.isEmpty ? nil : note.trimmingCharacters(in: .whitespacesAndNewlines)
        let englishName: String?
        
        if !busstopPole.isEmpty {
            let components = busstopPole.components(separatedBy: ".")
            if components.count > 2 {
                englishName = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                englishName = nil
            }
        } else {
            englishName = nil
        }
        
        return (japaneseName != nil || englishName != nil) ? LocalizedTitle(ja: japaneseName, en: englishName) : nil
    }
    
    // MARK: - Localization Helper
    // Helper function for localized name selection
    func selectLocalizedName(ja: String?, en: String?) -> String {
        return self == "ja" ? (ja ?? en ?? "") : (en ?? ja ?? "")
    }
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
    func timetableRideTimeKey(_ isWeekday: Bool, _ num: Int, _ hour: Int) -> String { return "\(lineNameKey(num))\(isWeekday.weekdayTag)\(hour.addZeroTime)ridetime" }
    func timetableTrainTypeKey(_ isWeekday: Bool, _ num: Int, _ hour: Int) -> String { return "\(lineNameKey(num))\(isWeekday.weekdayTag)\(hour.addZeroTime)traintype" }
    func trainTypeListKey(_ isWeekday: Bool, _ num: Int) -> String { return "\(lineNameKey(num))\(isWeekday.weekdayTag)traintypelist" }
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
    func lineColor(_ num: Int ) -> Color { return lineColorKey(num).userDefaultsColor(Color.accentString) }
    func lineCode(_ num: Int ) -> String { return lineCodeKey(num).userDefaultsValue("")! }
    func lineKind(_ num: Int) -> TransportationLine.Kind { 
        let kindString = lineKindKey(num).userDefaultsValue("Railway")!
        return TransportationLine.Kind(rawValue: kindString) ?? .railway
    }
    func lineColorString(_ num: Int) -> String { return lineColorKey(num).userDefaultsValue(Color.accentString)! }
    func rideTime(_ num: Int) -> Int { return rideTimeKey(num).userDefaultsInt(0) }
    func transportation(_ num: Int) -> String { return transportationKey(num).userDefaultsValue(TransferType.walking.rawValue)! }
    func transferTime(_ num: Int) -> Int { return transferTimeKey(num).userDefaultsInt(0) }
    func timetableTime(_ isWeekday: Bool, _ num: Int, _ hour: Int) -> String { return timetableKey(isWeekday, num, hour).userDefaultsValue("")! }
    func timetableRideTime(_ isWeekday: Bool, _ num: Int, _ hour: Int) -> String { return timetableKey(isWeekday, num, hour).userDefaultsValue("")! }
    func choiceCopyTime(_ isWeekday: Bool, _ num: Int, _ hour: Int, _ i: Int) -> String { return choiceCopyTimeKeyArray(isWeekday, num, hour)[i].userDefaultsValue("")! }
    
    // MARK: - Settings View Data Access
    // UserDefaults data retrieval for settings view display
    var settingsDeparturePoint: String { return departurePointKey.userDefaultsValue("Not set".localized)! }
    var settingsDestination: String { return destinationKey.userDefaultsValue("Not set".localized)! }
    func settingsDepartStation(_ num: Int) -> String { return departStationKey(num).userDefaultsValue("Not set".localized)! }
    func settingsArriveStation(_ num: Int) -> String { return arriveStationKey(num).userDefaultsValue("Not set".localized)! }
    func settingsLineName(_ num: Int) -> String { return lineNameKey(num).userDefaultsValue("Not set".localized)! }
    func settingsLineColor(_ num: Int ) -> Color { return lineColorKey(num).userDefaultsColor(Color.grayString) }
    func settingsLineColorString(_ num: Int) -> String { return lineColorKey(num).userDefaultsValue(Color.grayString)! }
    func settingsRideTime(_ num: Int) -> String { return (rideTime(num) == 0) ? "Not set".localized: "\(String(rideTime(num)))\("[min]".localized)"}
    func settingsRideTimeColor(_ num: Int) -> Color { return (rideTime(num) == 0) ? .gray: lineColorArray[num] }
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
    var weekdayLabel: String { return self ? "Weekdays except Public Holidays".localized: "Saturday & Sunday $ Public Holidays".localized }
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

// MARK: - TrainTime Extensions
// Extensions for loading TrainTime objects from UserDefaults
extension String {
    
    // MARK: - TransportationTime Loading Methods
    // Load TransportationTime objects from UserDefaults
    func loadTransportationTimes(_ isWeekday: Bool, _ num: Int, _ hour: Int) -> [any TransportationTime] {
        let timetableKey = self.timetableKey(isWeekday, num, hour)
        let timetableRideTimeKey = self.timetableRideTimeKey(isWeekday, num, hour)
        let timetableTrainTypeKey = self.timetableTrainTypeKey(isWeekday, num, hour)
                
        guard let timetableString = UserDefaults.standard.string(forKey: timetableKey) else {
            return []
        }
        
        let departureTimes = timetableString.components(separatedBy: " ").compactMap { $0.isEmpty ? nil : $0 }
        let rideTimes = UserDefaults.standard.string(forKey: timetableRideTimeKey)?.components(separatedBy: " ").compactMap { Int($0) } ?? []
        let trainTypes = UserDefaults.standard.string(forKey: timetableTrainTypeKey)?.components(separatedBy: " ") ?? []
        
        var transportationTimes: [any TransportationTime] = []
        for (index, departureTimeString) in departureTimes.enumerated() {
            let rideTime = index < rideTimes.count ? rideTimes[index] : 0
            let trainType = index < trainTypes.count && !trainTypes[index].isEmpty ? trainTypes[index] : nil
            
            if trainType == nil {
                // Bus data (no trainType)
                let busTime = BusTime(
                    departureTime: departureTimeString,
                    arrivalTime: "", // Arrival time not stored separately
                    busNumber: nil, // Bus number not stored separately
                    routePattern: nil, // Route pattern not stored separately
                    rideTime: rideTime
                )
                transportationTimes.append(busTime)
            } else {
                // Train data (has trainType)
                let trainTime = TrainTime(
                    departureTime: departureTimeString, // Keep as minutes string for consistency
                    arrivalTime: "", // Arrival time not stored separately
                    trainNumber: nil, // Train number not stored separately
                    trainType: trainType,
                    rideTime: rideTime
                )
                transportationTimes.append(trainTime)
            }
        }
        return transportationTimes
    }
    
    // MARK: - Time Format Conversion
    // Convert HH:MM format to minutes within the hour
    private func convertHHMMToMinutes(_ timeString: String) -> Int {
        let components = timeString.components(separatedBy: ":")
        if components.count == 2, let minute = Int(components[1]) {
            return minute  // Return only minutes within the hour
        }
        return 0
    }
    
    // MARK: - TransportationTime Saving Methods
    // Save TransportationTime objects for a specific hour
    func saveTransportationTimes(_ transportationTimes: [any TransportationTime], _ isWeekday: Bool, _ num: Int, _ hour: Int) {

        let timetableKey = self.timetableKey(isWeekday, num, hour)
        let timetableRideTimeKey = self.timetableRideTimeKey(isWeekday, num, hour)
        let timetableTrainTypeKey = self.timetableTrainTypeKey(isWeekday, num, hour)
        
        if hour < 9 {
            print("💾 saveTransportationTimes: Saving \(transportationTimes.count) TransportationTime objects for hour \(hour) (\(isWeekday ? "weekday" : "weekend"))")
        }
        
        // Clear existing data (always remove to ensure clean state)
        UserDefaults.standard.removeObject(forKey: timetableKey)
        UserDefaults.standard.removeObject(forKey: timetableRideTimeKey)
        UserDefaults.standard.removeObject(forKey: timetableTrainTypeKey)
        
        // Ensure UserDefaults changes are synchronized to disk
        UserDefaults.standard.synchronize()
        
        if transportationTimes.isEmpty { 
            print("⚠️ No TransportationTime objects to save for hour \(hour)")
            return 
        }
        
        // Prepare data arrays
        var departureTimes: [String] = []
        var rideTimes: [String] = []
        var trainTypes: [String] = []
        
        for transportationTime in transportationTimes {
            // Convert HH:MM format to minutes format for consistency with manual editing
            let departureTimeInMinutes = convertHHMMToMinutes(transportationTime.departureTime)
            departureTimes.append(String(departureTimeInMinutes))
            rideTimes.append(String(transportationTime.rideTime))
            
            // Use trainType if available (only for TrainTime), otherwise empty string
            trainTypes.append((transportationTime as? TrainTime)?.trainType ?? "")
        }
        
        // Save to UserDefaults
        let timetableString = departureTimes.joined(separator: " ")
        let timetableRideTimeString = rideTimes.joined(separator: " ")
        let timetableTrainTypeString = trainTypes.joined(separator: " ")
        
        UserDefaults.standard.set(timetableString, forKey: timetableKey)
        UserDefaults.standard.set(timetableRideTimeString, forKey: timetableRideTimeKey)
        UserDefaults.standard.set(timetableTrainTypeString, forKey: timetableTrainTypeKey)
        
        if hour < 9 {
            print("📊 Data: timetable='\(timetableString)', rideTime='\(timetableRideTimeString)', trainType='\(timetableTrainTypeString)'")
            
            // Print detailed ride time information for verification
            print("🚉 Ride Time Details for hour \(hour):")
            for (index, transportationTime) in transportationTimes.enumerated() {
                print("   \(index + 1). \(transportationTime.departureTime) → \(transportationTime.arrivalTime) (\(transportationTime.rideTime)分)")
            }
        }
    }
    
    // MARK: - Save Train Type List
    // Save unique train types list for the entire timetable
    func saveTrainTypeList(_ transportationTimes: [any TransportationTime], _ isWeekday: Bool, _ num: Int) {
        let trainTypeListKey = self.trainTypeListKey(isWeekday, num)
        
        print("💾 saveTrainTypeList: Saving train type list for (\(isWeekday ? "weekday" : "weekend"))")
        
        // Extract all train types from all transportation times
        let allTrainTypes = transportationTimes.compactMap { transportationTime -> String? in
            if let trainTime = transportationTime as? TrainTime {
                return trainTime.trainType
            } else {
                return nil // Bus doesn't have trainType
            }
        }.compactMap { (trainType: String) -> String? in
            guard !trainType.isEmpty else { return nil }
            let components = trainType.components(separatedBy: ".")
            return components.last ?? trainType
        }
        
        // Remove duplicates and sort
        let uniqueTrainTypes = Set<String>(allTrainTypes)
        let trainTypeListString = Array(uniqueTrainTypes).sorted().joined(separator: " ")
        
        UserDefaults.standard.set(trainTypeListString, forKey: trainTypeListKey)
        
        print("📋 saveTrainTypeList: Saved train type list: '\(trainTypeListString)'")
        print("📋 saveTrainTypeList: All train types found: \(Array(uniqueTrainTypes).sorted())")
    }
    
    // MARK: - Load Train Type List
    // Load existing train types from UserDefaults with color-based sorting
    func loadTrainTypeList(_ isWeekday: Bool, _ num: Int) -> [String] {
        let trainTypeListKey = self.trainTypeListKey(isWeekday, num)
        
        if let trainTypeListString = UserDefaults.standard.string(forKey: trainTypeListKey),
           !trainTypeListString.isEmpty {
            let trainTypes = Array(Set(trainTypeListString.components(separatedBy: " ")
                .filter { !$0.isEmpty }))
                .sorted { trainType1, trainType2 in
                    let color1 = Color.colorForTrainType(trainType1)
                    let color2 = Color.colorForTrainType(trainType2)
                    
                    // Define color priority: white, yellow-green, yellow, orange, pink, light blue
                    let colorPriority: [Color: Int] = [
                        .white: 0,
                        .yelwgre: 1,
                        .yellow: 2,
                        .orange: 3,
                        .pink: 4,
                        .ligblue: 5
                    ]
                    
                    let priority1 = colorPriority[color1] ?? 999
                    let priority2 = colorPriority[color2] ?? 999
                    
                    if priority1 != priority2 {
                        return priority1 < priority2
                    } else {
                        return trainType1 < trainType2
                    }
                }
            return trainTypes
        }
        
        return []
    }
    
}

// MARK: - Timetable Data Extensions
// Extensions for timetable data processing and analysis
extension Array where Element == (trainNumber: String, departureTime: String, destinationStation: String, trainType: String) {
    
    // MARK: - Train Type Extraction
    // Extract unique train types from timetable data array
    var uniqueTrainTypes: Set<String> {
        return Set(self.compactMap { record in
            let trainType = record.trainType
            guard !trainType.isEmpty else { return nil }
            
            // Extract the actual train type name from ODPT format
            // Example: "odpt.TrainType:JR-East.Local" -> "Local"
            if trainType.contains(".") {
                let components = trainType.components(separatedBy: ".")
                return components.last ?? trainType
            }
            
            return trainType
        })
    }
    
    // MARK: - Train Type List
    // Get sorted list of unique train types
    var trainTypeList: [String] {
        return uniqueTrainTypes.sorted()
    }
    
    // MARK: - Train Type Count
    // Count occurrences of each train type
    var trainTypeCounts: [String: Int] {
        var counts: [String: Int] = [:]
        
        for record in self {
            let trainType = record.trainType
            guard !trainType.isEmpty else { continue }
            
            // Extract the actual train type name
            let actualTrainType: String
            if trainType.contains(".") {
                let components = trainType.components(separatedBy: ".")
                actualTrainType = components.last ?? trainType
            } else {
                actualTrainType = trainType
            }
            
            counts[actualTrainType, default: 0] += 1
        }
        
        return counts
    }
    
    // MARK: - Filter by Train Type
    // Filter records by specific train type
    func filtered(by trainType: String) -> [Element] {
        return self.filter { record in
            let recordTrainType = record.trainType
            guard !recordTrainType.isEmpty else { return false }
            
            // Extract the actual train type name
            let actualTrainType: String
            if recordTrainType.contains(".") {
                let components = recordTrainType.components(separatedBy: ".")
                actualTrainType = components.last ?? recordTrainType
            } else {
                actualTrainType = recordTrainType
            }
            
            return actualTrainType == trainType
        }
    }
}

// MARK: - Bus Stop Name Extraction Extension
// Extension for extracting station names from bus stop pole codes
extension String {
    
    // MARK: - Bus Stop Name Extraction
    /// Extract station name from bus stop pole code
    /// Example: "odpt.BusstopPole:Toei.TOKYOSKYTREEStation.2028.3" -> "TOKYOSKYTREEStation"
    func extractStationNameFromCode() -> String {
        let components = self.components(separatedBy: ".")
        guard components.count >= 3 else { return self }
        
        // Extract the station name part (usually the 3rd component)
        let stationName = components[2]
        
        // Convert camelCase to readable format
        let readableName = stationName.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
        
        return readableName.isEmpty ? stationName : readableName
    }
    
}

// MARK: - Character Extensions
extension Character {
    /// Check if the character is a Japanese character (Hiragana, Katakana, or Kanji)
    var isJapanese: Bool {
        let unicodeScalar = self.unicodeScalars.first!
        return (0x3040...0x309F).contains(unicodeScalar.value) || // Hiragana
               (0x30A0...0x30FF).contains(unicodeScalar.value) || // Katakana
               (0x4E00...0x9FAF).contains(unicodeScalar.value)    // Kanji
    }
}
