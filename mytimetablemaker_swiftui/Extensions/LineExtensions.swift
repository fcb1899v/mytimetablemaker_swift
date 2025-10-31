//
//  LineData.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2020/12/27.
//

import SwiftUI
import Foundation
import Combine

// MARK: - App Constants
// Core application constants and localized strings
let appTitle = "My Transfer Makers".localized
// Array of route direction identifiers
let goorbackarray = ["back1", "go1", "back2", "go2"]

// Route direction constants
let goorbackOptions: [String] = ["back1", "back2", "go1", "go2"]

// Route direction display names (non-localized)
let goorbackDisplayNamesRaw: [String: String] = [
    "back1": "Return Route 1",
    "back2": "Return Route 2",
    "go1": "Outbound Route 1",
    "go2": "Outbound Route 2"
]

// UserDefault Keys for home and office locations
let homeKey = "departurepoint"
let officeKey = "destination"

// ODPT API Key (Open Data for Public Transportation)
// Load from build configuration files (Debug.xcconfig / Release.xcconfig)
let odptAccessKey = Bundle.main.object(forInfoDictionaryKey: "ODPT_ACCESS_TOKEN") as? String ?? ""
let odptChallengeKey = Bundle.main.object(forInfoDictionaryKey: "ODPT_CHALLENGE_TOKEN") as? String ?? ""

// App version and external links
// Application version string from bundle
let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!
// Terms of service URL
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
    /// Validates format and ensures route code contains English characters
    var busRouteEnglishName: String? {
        // Only extract English name for English locale
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        guard currentLanguage != "ja" else { return nil }
        
        // Split by "." to get parts
        let parts = self.components(separatedBy: ".")
        
        // Check if we have enough parts and the format is correct
        guard parts.count >= 3,
              parts[0] == "odpt",
              parts[1].hasPrefix("Busroute:") else {
            return nil
        }
        
        // Get the route code (third part, index 2)
        let routeCode = parts[2]
        
        // Validate that the route code contains English characters or numbers
        let englishPattern = "[A-Za-z0-9]"
        guard routeCode.range(of: englishPattern, options: .regularExpression) != nil else {
            return nil
        }
        
        return routeCode
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
    func timetableKey(_ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int) -> String { return "\(lineNameKey(num))\(calendarType.calendarTag)\(hour.addZeroTime)" }
    func timetableRideTimeKey(_ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int) -> String { return "\(lineNameKey(num))\(calendarType.calendarTag)\(hour.addZeroTime)ridetime" }
    func timetableTrainTypeKey(_ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int) -> String { return "\(lineNameKey(num))\(calendarType.calendarTag)\(hour.addZeroTime)traintype" }
    func trainTypeListKey(_ calendarType: ODPTCalendarType, _ num: Int) -> String { return "\(lineNameKey(num))\(calendarType.calendarTag)traintypelist" }
    func choiceCopyTimeKeyArray(_ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int) -> [String] {
        let oppositeCalendarType: ODPTCalendarType = (calendarType.calendarTag == "weekday") ? .holiday : .weekday
        return [
            "\(lineNameKey(num))\(calendarType.calendarTag)\((hour - 1).addZeroTime)",
            "\(lineNameKey(num))\(calendarType.calendarTag)\((hour + 1).addZeroTime)",
            "\(lineNameKey(num))\(oppositeCalendarType.calendarTag)\(hour.addZeroTime)",
            "\(otherroute.lineNameKey(0))\(calendarType.calendarTag)\(hour.addZeroTime)",
            "\(otherroute.lineNameKey(1))\(calendarType.calendarTag)\(hour.addZeroTime)",
            "\(otherroute.lineNameKey(2))\(calendarType.calendarTag)\(hour.addZeroTime)"
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
    func timetableTime(_ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int) -> String { return timetableKey(calendarType, num, hour).userDefaultsValue("")! }
    func timetableRideTime(_ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int) -> String { return timetableKey(calendarType, num, hour).userDefaultsValue("")! }
    func choiceCopyTime(_ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int, _ i: Int) -> String { return choiceCopyTimeKeyArray(calendarType, num, hour)[i].userDefaultsValue("")! }
    
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
    func loadTransportationTimes(_ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int) -> [any TransportationTime] {
        let timetableKey = self.timetableKey(calendarType, num, hour)
        let timetableRideTimeKey = self.timetableRideTimeKey(calendarType, num, hour)
        let timetableTrainTypeKey = self.timetableTrainTypeKey(calendarType, num, hour)
                
        guard let timetableString = UserDefaults.standard.string(forKey: timetableKey) else {
            return []
        }
        
        let departureTimes = timetableString.components(separatedBy: " ").compactMap { $0.isEmpty ? nil : $0 }
        let rideTimes = UserDefaults.standard.string(forKey: timetableRideTimeKey)?.components(separatedBy: " ").compactMap { Int($0) } ?? []
        let trainTypes = UserDefaults.standard.string(forKey: timetableTrainTypeKey)?.components(separatedBy: " ") ?? []
        let routeRideTimeKey = self.rideTimeKey(num) // Get route-level ride time
        let defaultRideTime = UserDefaults.standard.integer(forKey: routeRideTimeKey) // Get default ride time from route settings
        
        var transportationTimes: [any TransportationTime] = []
        for (index, departureTimeString) in departureTimes.enumerated() {
            // Use specific ride time if available, otherwise use route-level default ride time
            let rideTime = index < rideTimes.count ? rideTimes[index] : defaultRideTime
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
    func saveTransportationTimes(_ transportationTimes: [any TransportationTime], _ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int) {

        let timetableKey = self.timetableKey(calendarType, num, hour)
        let timetableRideTimeKey = self.timetableRideTimeKey(calendarType, num, hour)
        let timetableTrainTypeKey = self.timetableTrainTypeKey(calendarType, num, hour)
        
        if hour < 9 {
            print("💾 saveTransportationTimes: Saving \(transportationTimes.count) TransportationTime objects for hour \(hour) (\(calendarType.displayName))")
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
    func saveTrainTypeList(_ transportationTimes: [any TransportationTime], _ calendarType: ODPTCalendarType, _ num: Int) {
        let trainTypeListKey = self.trainTypeListKey(calendarType, num)
        
        print("💾 saveTrainTypeList: Saving train type list for (\(calendarType.displayName))")
        
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
    func loadTrainTypeList(_ calendarType: ODPTCalendarType, _ num: Int) -> [String] {
        let trainTypeListKey = self.trainTypeListKey(calendarType, num)
        
        if let trainTypeListString = UserDefaults.standard.string(forKey: trainTypeListKey),
           !trainTypeListString.isEmpty {
            let trainTypes = Array(Set(trainTypeListString.components(separatedBy: " ")
                .filter { !$0.isEmpty }))
                .sorted { trainType1, trainType2 in
                    let priority1 = Color.colorForTrainType(trainType1).priorityValue
                    let priority2 = Color.colorForTrainType(trainType2).priorityValue
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

// MARK: - TransportationLine Display Extensions
extension SettingsLineSheetViewModel {
    
    // MARK: - Display Name Helpers
    // Get localized display name for transportation line
    func lineDisplayName(for line: TransportationLine) -> String {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        if line.kind == .bus {
            return currentLanguage == "ja" ? line.title! :
            (line.busRouteEnglishName ?? line.railwayTitle?.en ?? line.name)
        }
        
        guard let railwayTitle = line.railwayTitle else { return line.name }
        return railwayTitle.getLocalizedName(fallbackTo: line.name)
    }
    
    // Get localized display name based on operator code
    func getOperatorDisplayName(for operatorCode: String, lineKind: TransportationLine.Kind? = nil) -> String {
        let operatorName = operatorCode.replacingOccurrences(of: "odpt.Operator:", with: "")
        return NSLocalizedString(operatorName, comment: "Railway operator name")
    }
    
    // MARK: - Data Extraction Helpers
    // Extract bus stops from bus route data
    func extractStopsFromBusRoute(_ busRoute: [String: Any], searchMethod: String, searchValue: String, lineCode: String? = nil) -> [TransportationStop]? {
        guard let busStopData = busRoute["odpt:busstopPoleOrder"] as? [[String: Any]] else { return nil }
        
        let busStops: [TransportationStop] = busStopData.compactMap { busStopInfo -> TransportationStop? in
            let note = busStopInfo["odpt:note"] as? String ?? ""
            let busstopPole = busStopInfo["odpt:busstopPole"] as? String ?? ""
            
            guard !note.isEmpty || !busstopPole.isEmpty else { return nil }
            
            // Check if note contains Japanese characters
            let hasJapaneseInNote = note.contains(where: { $0.isJapanese })
            
            // If note doesn't contain Japanese or is empty, and we have busstopPole, fetch from API
            if (!hasJapaneseInNote || note.isEmpty) && !busstopPole.isEmpty {
                // Japanese name will be fetched later in selectLine
                // For now, use busstopPole as fallback
                let finalNote = note.isEmpty ? busstopPole : note
                let title = String.generateBusStopTitle(note: finalNote, busstopPole: busstopPole)
                let stopName = title?.getLocalizedName(fallbackTo: finalNote) ?? finalNote
                
                return TransportationStop(
                    kind: .bus,
                    name: stopName,
                    code: busstopPole.isEmpty ? nil : busstopPole,
                    index: busStopInfo["odpt:index"] as? Int,
                    lineCode: lineCode,
                    title: title,
                    note: finalNote,
                    busstopPole: busstopPole.isEmpty ? nil : busstopPole
                )
            }
            
            // Use shared bus stop title generation logic for stops with Japanese
            let title = String.generateBusStopTitle(note: note, busstopPole: busstopPole)
            let stopName = title?.getLocalizedName(fallbackTo: note) ?? (note.isEmpty ? busstopPole : note)
            
            return TransportationStop(
                kind: .bus,
                name: stopName,
                code: busstopPole.isEmpty ? nil : busstopPole,
                index: busStopInfo["odpt:index"] as? Int,
                lineCode: lineCode,
                title: title,
                note: note,
                busstopPole: busstopPole.isEmpty ? nil : busstopPole
            )
        }
        
        return busStops.isEmpty ? nil : busStops
    }
    
    // Extract stations from railway data
    func extractStationsFromRailway(_ railway: [String: Any], searchMethod: String, searchValue: String, lineCode: String? = nil) -> [TransportationStop]? {
        let stations: [TransportationStop]? = (railway["odpt:stationOrder"] as? [[String: Any]])?.compactMap { stationInfo in
            (stationInfo["odpt:stationTitle"] as? [String: Any]).map { stationTitle in
                let jaName = stationTitle["ja"] as? String
                let enName = stationTitle["en"] as? String
                let stationCode = stationInfo["odpt:station"] as? String
                let stationIndex = stationInfo["odpt:index"] as? Int
                
                return TransportationStop(
                    kind: .railway,
                    name: jaName ?? enName ?? "Unknown station",
                    code: stationCode,
                    index: stationIndex,
                    lineCode: lineCode,
                    title: LocalizedTitle(ja: jaName, en: enName),
                    note: nil,
                    busstopPole: nil
                )
            }
        }
        return !(stations?.isEmpty ?? true) ? stations : nil
    }
    
    // Load local data from cache or bundle
    func loadLocalData(for filename: String) -> Data? {
        // Try ODPT cache first
        let cache = CacheStore()
        if let data = cache.loadData(for: filename) {
            return data
        }
        
        // Try LineData folder
        if let lineDataURL = Bundle.main.url(forResource: "LineData", withExtension: nil) {
            let jsonURL = lineDataURL.appendingPathComponent(filename)
            if let data = try? Data(contentsOf: jsonURL) {
                return data
            }
        }
        
        // Fallback to bundle
        guard let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json") else {
            print("❌ File not found: \(filename)")
            return nil
        }
        return try? Data(contentsOf: url)
    }
    
    // MARK: - Data Parsing Helpers
    // Parse stations by line code
    // Generic parser for both bus stops and railway stations by line code
    func parseStationsByLineCode(_ data: Data, lineCode: String, isBus: Bool) -> [TransportationStop]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let array = json as? [[String: Any]] else { return nil }
            
            for item in array {
                if isBus != ((item["@type"] as? String) == "odpt:BusroutePattern") { continue }
                
                if let itemCode = item["owl:sameAs"] as? String, itemCode == lineCode {
                    return isBus ? 
                        self.extractStopsFromBusRoute(item, searchMethod: "owl:sameAs", searchValue: lineCode, lineCode: lineCode) :
                        self.extractStationsFromRailway(item, searchMethod: "owl:sameAs", searchValue: lineCode, lineCode: lineCode)
                }
            }
        } catch {
            print("❌ Failed to parse stations by line code: \(error)")
        }
        return nil
    }
}

// MARK: - LocalDataSource Extensions
// File and data loading utilities for transportation operators
extension LocalDataSource {
    /// Load data from Documents/LineData directory for this operator
    /// Returns data from LineData folder in Documents directory
    func loadDataFromDocuments() -> Data? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let lineDataDirectory = documentsDirectory.appendingPathComponent("LineData", isDirectory: true)
        let fileURL = lineDataDirectory.appendingPathComponent(self.fileName)
        
        return try? Data(contentsOf: fileURL)
    }
    
    /// Get file URL for this operator's data in Documents/LineData directory
    func fileURLInDocuments() -> URL? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let lineDataDirectory = documentsDirectory.appendingPathComponent("LineData", isDirectory: true)
        return lineDataDirectory.appendingPathComponent(self.fileName)
    }
}

// MARK: - Dictionary ODPT Extensions
// Utilities for extracting ODPT API data from dictionaries
extension Dictionary where Key == String {
    /// Extract destination station from ODPT data
    /// Handles both String and [String] formats
    func odptDestinationStation() -> String? {
        if let destString = self["odpt:destinationStation"] as? String {
            return destString
        } else if let destArray = self["odpt:destinationStation"] as? [String] {
            return destArray.first
        }
        return nil
    }
    
    /// Extract line color from ODPT data
    /// Supports both odpt:color (local) and odpt:lineColor (API) fields
    func odptLineColor() -> String? {
        return (self["odpt:lineColor"] as? String) ?? (self["odpt:color"] as? String)
    }
    
    /// Extract LocalizedTitle from ODPT railway title dictionary
    func odptRailwayTitle() -> LocalizedTitle? {
        guard let railwayTitleDict = self["odpt:railwayTitle"] as? [String: String] else {
            return nil
        }
        return LocalizedTitle(
            ja: railwayTitleDict["ja"],
            en: railwayTitleDict["en"]
        )
    }
}

