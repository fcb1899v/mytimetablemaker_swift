//
//  DateAndTime.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2020/12/27.
//

import SwiftUI

// MARK: - Int Time Extensions
// Time format conversions and calculations
extension Int {
    
    // MARK: - Time Format Conversions
    // Convert time formats between HHMM, MMSS, HHMMSS and minutes/seconds
    var HHMMtoMM: Int { self / 100 * 60 + self % 100 }
    var MMtoHHMM: Int { self / 60 * 100 + self % 60 }
    var MMSStoSS: Int { self / 100 * 60 + self % 100 }
    var SStoMMSS: Int { self / 60 * 100 + self % 60 }
    var HHMMSStoSS: Int { self / 10000 * 3600 + (self % 10000) / 100 * 60 + self % 100 }
    var SStoHHMMSS: Int { self / 3600 * 10000 + (self % 3600) / 60 * 100 + self % 60 }
    var HHMMSStoMMSS: Int { (self / 10000 * 60 + (self % 10000) / 100) * 100 + self % 100 }
    
    // MARK: - Time Arithmetic
    // Addition and subtraction operations for time format calculations
    func plusHHMM(_ time: Int) -> Int { (HHMMtoMM + time.HHMMtoMM).MMtoHHMM }
    func plusHHMMSS(_ time: Int) -> Int { (HHMMSStoSS + time.HHMMSStoSS).SStoHHMMSS }
    func plusMMSS(_ time: Int) -> Int { (MMSStoSS + time.MMSStoSS).SStoMMSS }
    func minusHHMM(_ time: Int) -> Int { (HHMMtoMM < time.HHMMtoMM) ?
        ((self + 2400).HHMMtoMM - time.HHMMtoMM).MMtoHHMM:
        (HHMMtoMM - time.HHMMtoMM).MMtoHHMM }
    func minusHHMMSS(_ time: Int) -> Int { (self.HHMMSStoSS < time.HHMMSStoSS) ?
        ((self + 240000).HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS:
        (HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS }
    func minusMMSS(_ time: Int) -> Int { (self.MMSStoSS - time.MMSStoSS).SStoMMSS }
    
    // MARK: - Time Display Formatting
    // Format time values for display with leading zeros and time conversion
    var addZeroTime: String { (0...9 ~= self) ? "0\(self)": "\(self)" }
    func overTime(_ beforeTime: Int) -> Int { (beforeTime == 2700) ? 2700: (self > 2700) ? 2700: self }
    var timeHH: String { (self / 100 + (self % 100) / 60).addZeroTime }
    var timeMM: String { (self % 100 % 60).addZeroTime }
    var stringTime: String { ("\(timeHH):\(timeMM)" != "27:00") ? "\(timeHH):\(timeMM)": "--:--" }
    var timetableHour: Int { (self > 3) ? self: self + 24 }
    
    // MARK: - Countdown
    // Format countdown timer display from MMSS format
    var countdown: String{ (0...9999 ~= self) ? "\((self / 100).addZeroTime):\((self % 100).addZeroTime)": "--:--" }
    func countdownTime(_ departtime: Int) -> String { (departtime * 100).minusHHMMSS(self).HHMMSStoMMSS.countdown }

    // MARK: - ODPT Calendar Type
    // Determine calendar type based on weekday number with fallback to available types
    func odpTCalendarType(fallbackTo availableTypes: [ODPTCalendarType]) -> ODPTCalendarType {
        return Date().isJapaneseHoliday && availableTypes.contains(.holiday) ? .holiday:
               self == 0 && availableTypes.contains(.sunday) ? .sunday:
               self == 6 && availableTypes.contains(.saturday) ? .saturday:
               (Date().isJapaneseHoliday || self == 0 || self == 6) && availableTypes.contains(.saturdayHoliday) ? .saturdayHoliday:
               self == 1 && availableTypes.contains(.monday) ? .monday:
               self == 2 && availableTypes.contains(.tuesday) ? .tuesday:
               self == 3 && availableTypes.contains(.wednesday) ? .wednesday:
               self == 4 && availableTypes.contains(.thursday) ? .thursday:
               self == 5 && availableTypes.contains(.friday) ? .friday:
               availableTypes.contains(.weekday) ? .weekday:
               .allday
    }
    
    // MARK: - Choice Copy Time List
    // Generate list of time copy options for timetable editing
    var choiceCopyTimeList: [String] {
        [
            "\(self - 1)\("Hour".localized)",
            "\(self + 1)\("Hour".localized)",
            "Other route of line 1".localized,
            "Other route of line 2".localized,
            "Other route of line 3".localized
        ]
    }
}


// MARK: - Date Extensions
extension Date {

    // MARK: - Date Formatting
    // Format date and time for display
    var setDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d, yyyy".localized
        return formatter.string(from: self)
    }
    var setTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
    
    // MARK: - Current Time
    // Convert current date to HHMMSS format integer
    var currentTime: Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        let second = calendar.component(.second, from: self)
        return hour * 10000 + minute * 100 + second
    }
    
    // MARK: - ODPT Calendar Type
    // Determine calendar type based on date with fallback to available types
    func odpTCalendarType(fallbackTo availableTypes: [ODPTCalendarType]) -> ODPTCalendarType {
        return isJapaneseHoliday && availableTypes.contains(.holiday) ? .holiday:
               isWeekMatch(enWeek: "Sun", jaWeek: "日") && availableTypes.contains(.sunday) ? .sunday:
               isWeekMatch(enWeek: "Sat", jaWeek: "土") && availableTypes.contains(.saturday) ? .saturday:
               isSaturdayHoloday && availableTypes.contains(.saturdayHoliday) ? .saturdayHoliday:
               isWeekMatch(enWeek: "Mon", jaWeek: "月") && availableTypes.contains(.monday) ? .monday:
               isWeekMatch(enWeek: "Tue", jaWeek: "火") && availableTypes.contains(.tuesday) ? .tuesday:
               isWeekMatch(enWeek: "Wed", jaWeek: "水") && availableTypes.contains(.wednesday) ? .wednesday:
               isWeekMatch(enWeek: "Thu", jaWeek: "木") && availableTypes.contains(.thursday) ? .thursday:
               isWeekMatch(enWeek: "Fri", jaWeek: "金") && availableTypes.contains(.friday) ? .friday:
               availableTypes.contains(.weekday) ? .weekday:
               .allday
    }   
    
    // MARK: - Japanese Holiday Detection
    // Check for Japanese holidays and weekday matching
    var isJapaneseHoliday: Bool { isRegularHoliday || isSubstituteHoliday || isNationalHoliday }
    func isWeekMatch(enWeek: String, jaWeek: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        let dayOfWeek = formatter.string(from: self)
        return dayOfWeek == enWeek || dayOfWeek == jaWeek
    }
    var isSaturdayHoloday: Bool { isJapaneseHoliday || isWeekMatch(enWeek: "Sun", jaWeek: "日") || isWeekMatch(enWeek: "Sat", jaWeek: "土")}
    
    // MARK: - Holiday Calculation
    // Calculate Japanese public holidays including fixed, variable, substitute and national holidays
    private var isRegularHoliday: Bool {
        let year = Calendar.current.component(.year, from: self)
        let holidays = getAllHolidaysForYear(year)
        // Check if this date matches any regular holiday
        return holidays.contains { holiday in
            Calendar.current.isDate(self, inSameDayAs: holiday)
        }
    }
    
    private var isSubstituteHoliday: Bool {
        let year = Calendar.current.component(.year, from: self)
        let substituteHolidays = getSubstituteHolidaysForYear(year)
        // Check if this date matches any substitute holiday
        return substituteHolidays.contains { holiday in
            Calendar.current.isDate(self, inSameDayAs: holiday)
        }
    }
    
    private var isNationalHoliday: Bool {
        let year = Calendar.current.component(.year, from: self)
        let nationalHolidays = getNationalHolidaysForYear(year)
        // Check if this date matches any national holiday
        return nationalHolidays.contains { holiday in
            Calendar.current.isDate(self, inSameDayAs: holiday)
        }
    }
    
    // Get all holidays for a specific year including fixed and variable holidays
    private func getAllHolidaysForYear(_ year: Int) -> [Date] {
        let calendar = Calendar.current
        var holidays: [Date] = []
        // Fixed holidays (updated for current era)
        let fixedHolidays = [
            (1, 1),   // New Year's Day
            (2, 11),  // National Foundation Day
            (2, 23),  // Emperor's Birthday (new)
            (4, 29),  // Showa Day
            (5, 3),   // Constitution Memorial Day
            (5, 4),   // Greenery Day
            (5, 5),   // Children's Day
            (8, 11),  // Mountain Day
            (11, 3),  // Culture Day
            (11, 23)  // Labor Thanksgiving Day
        ]
        
        // Add fixed holidays
        for (month, day) in fixedHolidays {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                holidays.append(date)
            }
        }
        // Add variable holidays
        holidays.append(contentsOf: getVariableHolidaysForYear(year))
        // Sort holidays by date
        return holidays.sorted()
    }
    
    // Calculate variable holidays (equinox days and Monday-based holidays)
    private func getVariableHolidaysForYear(_ year: Int) -> [Date] {
        let calendar = Calendar.current
        var holidays: [Date] = []
        // Vernal Equinox Day (around March 20-21)
        if let date = calendar.date(from: DateComponents(year: year, month: 3, day: 20)) {
            holidays.append(date)
        }
        // Autumnal Equinox Day (around September 22-23)
        if let date = calendar.date(from: DateComponents(year: year, month: 9, day: 22)) {
            holidays.append(date)
        }
        // Marine Day (3rd Monday of July)
        if let firstMonday = calendar.date(from: DateComponents(year: year, month: 7, day: 1)) {
            let weekday = calendar.component(.weekday, from: firstMonday)
            let daysToAdd = weekday == 2 ? 14 : (9 - weekday) % 7
            if let thirdMonday = calendar.date(byAdding: .day, value: daysToAdd, to: firstMonday) {
                holidays.append(thirdMonday)
            }
        }
        // Respect for the Aged Day (3rd Monday of September)
        if let firstMonday = calendar.date(from: DateComponents(year: year, month: 9, day: 1)) {
            let weekday = calendar.component(.weekday, from: firstMonday)
            let daysToAdd = weekday == 2 ? 14 : (9 - weekday) % 7
            if let thirdMonday = calendar.date(byAdding: .day, value: daysToAdd, to: firstMonday) {
                holidays.append(thirdMonday)
            }
        }
        // Sports Day (2nd Monday of October)
        if let firstMonday = calendar.date(from: DateComponents(year: year, month: 10, day: 1)) {
            let weekday = calendar.component(.weekday, from: firstMonday)
            let daysToAdd = weekday == 2 ? 7 : (9 - weekday) % 7
            if let secondMonday = calendar.date(byAdding: .day, value: daysToAdd, to: firstMonday) {
                holidays.append(secondMonday)
            }
        }
        return holidays
    }
    
    // Calculate substitute holidays when holidays fall on Sunday
    private func getSubstituteHolidaysForYear(_ year: Int) -> [Date] {
        let calendar = Calendar.current
        let holidays = getAllHolidaysForYear(year)
        var substituteHolidays: [Date] = []
        // Check if any holiday falls on Sunday
        for holiday in holidays {
            if calendar.component(.weekday, from: holiday) == 1 { // Sunday
                // Calculate substitute holiday (next Monday)
                if let substituteHoliday = calendar.date(byAdding: .day, value: 1, to: holiday) {
                    substituteHolidays.append(substituteHoliday)
                }
            }
        }
        
        return substituteHolidays
    }
    
    // Calculate national holidays (days between consecutive holidays)
    private func getNationalHolidaysForYear(_ year: Int) -> [Date] {
        let calendar = Calendar.current
        let holidays = getAllHolidaysForYear(year)
        var nationalHolidays: [Date] = []
        // Check if this date is between two holidays
        for i in 0..<holidays.count - 1 {
            let currentHoliday = holidays[i]
            let nextHoliday = holidays[i + 1]
            // Check if there's exactly one day between holidays
            if let dayBetween = calendar.date(byAdding: .day, value: 1, to: currentHoliday),
               calendar.isDate(dayBetween, inSameDayAs: nextHoliday) {
                // There's no day between, so check next pair
                continue
            }
            // Check if there's a day between two holidays
            if let dayBetween = calendar.date(byAdding: .day, value: 1, to: currentHoliday) {
                nationalHolidays.append(dayBetween)
            }
        }
        return nationalHolidays
    }
}

// MARK: - String Time Extensions
extension String {
    
    // MARK: - Number Parsing
    // Parse integer from string within specified range
    func intText(min: Int, max: Int) -> Int {
        let intText: Int = Int(self) ?? min - 1
        return (intText > min - 1 && intText < max + 1) ? intText: min - 1
    }
    
    // MARK: - Date Parsing
    // Parse date from localized string format
    var dateFromDate: Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "E, MMM d, yyyy".localized
        return formatter.date(from: self)!
    }

    // MARK: - Time Parsing
    // Parse time string (HH:MM:SS) to integer format (HHMMSS)
    var currentTime: Int {
        let timeHH = Int(self.components(separatedBy: ":")[0]) ?? 0
        let timemm = Int(self.components(separatedBy: ":")[1]) ?? 0
        let timess = Int(self.components(separatedBy: ":")[2]) ?? 0
        return timeHH * 10000 + timemm * 100 + timess
    }
    
    // MARK: - Calendar Type
    // Get calendar type for route based on date with cached available types
    func calendarType(for date: Date) -> ODPTCalendarType {
        let routeCacheKey = "\(self)_calendarTypes"
        var availableTypes: [ODPTCalendarType] = []
        if let cachedTypes = UserDefaults.standard.stringArray(forKey: routeCacheKey),
           !cachedTypes.isEmpty {
            availableTypes = cachedTypes.compactMap { ODPTCalendarType(rawValue: $0) }
        }
        if availableTypes.isEmpty {
            availableTypes = [.weekday, .holiday, .saturdayHoliday]
        }
        return date.odpTCalendarType(fallbackTo: availableTypes)
    }
    
    // Remove leading space and format minutes with leading zero
    var timeString: String { (self.prefix(1) == " ") ? String(self.suffix(self.count - 1)): self }
    var minutesOnly: String {
        // Check if string contains ":" (HH:MM format)
        if self.contains(":") {
            let components = self.components(separatedBy: ":")
            if components.count == 2, let minutes = components.last {
                // Add leading zero if minutes < 10
                if let minutesInt = Int(minutes), minutesInt < 10 {
                    return String(format: "%02d", minutesInt)
                }
                return minutes
            }
        }
        
        // Handle minutes-only format (e.g., "5", "05", "24")
        if let minutesInt = Int(self) {
            return String(format: "%02d", minutesInt)
        }
        
        return self
    }
    // Remove leading zero and combine time strings for timetable
    var trimmingLeadingZero: String { (self.count > 1 && self.hasPrefix("0")) ? String(self.dropFirst()): self }
    func addInputTime(_ inputText: String) -> String { return (self != "") ? "\(self) \(inputText)": inputText}
    
    // MARK: - Time Calculation
    // Calculate ride time in minutes between departure and arrival times
    func calculateRideTime(arrivalTime: String) -> Int {
        let departureComponents = self.components(separatedBy: ":")
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
        let rideTimeMinutes = arrivalTotalMinutes >= departureTotalMinutes ?
            arrivalTotalMinutes - departureTotalMinutes :
            (24 * 60) - departureTotalMinutes + arrivalTotalMinutes
        
        return rideTimeMinutes
    }
    // Convert HH:MM format to total minutes for sorting
    var timeToMinutes: Int {
        let components = self.components(separatedBy: ":")
        if components.count == 2,
           let hour = Int(components[0]),
           let minute = Int(components[1]) {
            return hour.timetableHour * 60 + minute
        }
        return 0
    }
    // Adjust hour for timetable display (0-3 AM becomes 24-27)
    var adjustedForTimetable: String {
        let components = self.components(separatedBy: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return self
        }
        
        // Use timetableHour extension to add 24 for 0-3 AM times
        let adjustedHour = hour.timetableHour
        return String(format: "%02d:%02d", adjustedHour, minute)
    }
    // Sort time values from string separated by specified characters
    func timeSorting(charactersin: String) -> [String] {
        Array(Set(self.components(separatedBy: CharacterSet(charactersIn: charactersin))
            .map{Int($0) ?? 60}
            .filter{$0 < 60}
            .filter{$0 > -1}
        ))
        .sorted()
        .map{String($0)}
    }
    
    // MARK: - Route Titles
    // Generate localized route and timetable titles
    func timetableLineTitle(_ num: Int) -> String { "\(lineNameArray[num])\(" for ".localized)\(stationArray[2 * num + 1])\("houmen".localized)" }
    var routeTitle: String {
        (self == "back1") ? "Setting Return Route 1".localized:
        (self == "back2") ? "Setting Return Route 2".localized:
        (self == "go1") ? "Setting Outbound Route 1".localized:
        "Setting Outbound Route 2".localized
    }
    // Get opposite route identifier (go1 <-> go2, back1 <-> back2)
    var otherroute: String { self.prefix(self.count - 1) + ((self.suffix(1) == "1") ? "2": "1") }

    // MARK: - Timetable Data Processing
    // Process and convert timetable data for specific calendar type and line number
    func timetable(_ calendarType: ODPTCalendarType, _ num: Int) -> [Int] {
        (4...25).flatMap { hour in timetableTime(calendarType, num, hour).timeString
            .components(separatedBy: CharacterSet(charactersIn: " "))
            .compactMap { Int($0) }
            .map { $0 + hour * 100 }
            .filter { $0 >= 0 && $0 < 2700 }
            .sorted()
        }
    }
    // Generate timetable arrays for all lines (0-2)
    func timetableArray(_ calendarType: ODPTCalendarType) -> [[Int]] { (0...2).map { num in timetable(calendarType, num) } }
    // Calculate departure and arrival times for current route based on current time
    func timeArray(_ calendarType: ODPTCalendarType, _ currenttime: Int) -> [Int] {
        // Depart time of line 1
        var timeArray = [timetableArray(calendarType)[0].first { $0 > (currenttime/100).plusHHMM(transferTimeArray[1]) } ?? 2700]
        // Arrive time of line 1
        timeArray.append(timeArray[0].plusHHMM(rideTimeArray[0]).overTime(timeArray[0]))
        // Depart time from depart point
        timeArray.insert(timeArray[0].minusHHMM(transferTimeArray[1]).overTime(timeArray[0]), at: 0)
        if (changeLineInt > 0) {
            for i in 1...changeLineInt {
                // Depart time of line i
                timeArray.append(timetableArray(calendarType)[i].first { $0 > timeArray[2 * i].plusHHMM(transferTimeArray[i + 1]) } ?? 2700)
                // Arrive time of line 1
                timeArray.append(timeArray[2 * i + 1].plusHHMM(rideTimeArray[i]).overTime(timeArray[2 * i + 1]))
            }
        }
        // Arrive time to destination
        timeArray.insert(timeArray[2 * changeLineInt + 2].plusHHMM(transferTimeArray[0]).overTime(timeArray[2 * changeLineInt + 2]), at: 0)
        return timeArray
    }
    
    // MARK: - Timetable Modification
    // Add or delete time entries from timetable for specific hour and calendar type
    func addTimeFromTimetable(_ inputText: String, _ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int) -> String {
        timetableTime(calendarType, num, hour)
            .addInputTime(inputText)
            .timeSorting(charactersin: " ")
            .joined(separator: " ")
    }
    // Remove time entry from timetable
    func deleteTimeFromTimetable(_ inputText: String, _ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int) -> String {
        timetableTime(calendarType, num, hour)
            .trimmingCharacters(in: .whitespaces)
            .timeSorting(charactersin: " ")
            .filter{$0 != inputText}
            .joined(separator: " ")
    }
    
    // MARK: - Valid Hour Range Calculation
    // Calculate the range of hours with timetable data for specific calendar type and line
    func validHourRange(calendarType: ODPTCalendarType, num: Int) -> [Int] {
        let allHours = Array(4...25)
        
        // Find hours with train times
        let hoursWithData = allHours.filter { hour in
            !self.loadTransportationTimes(calendarType, num, hour).isEmpty
        }
        
        // Return range from first to last hour with data
        guard let firstHour = hoursWithData.min(),
              let lastHour = hoursWithData.max() else {
            return [] // No data found
        }
        
        return Array(firstHour...lastHour)
    }
    
    // MARK: - Train Times Counts
    // Get train times count for each hour in the valid range
    func getTrainTimesCounts(calendarType: ODPTCalendarType, num: Int) -> [Int] {
        let hours = validHourRange(calendarType: calendarType, num: num)
        var counts: [Int] = []
        for hour in hours {
            let transportationTimes = self.loadTransportationTimes(calendarType, num, hour)
            counts.append(transportationTimes.count)
        }
        return counts
    }
    
    // MARK: - Timetable Data Existence Check
    // Check if timetable data exists for the specified calendar type and line
    func hasTimetableDataForType(_ calendarType: ODPTCalendarType, num: Int) -> Bool {
        // Check all hours (4-25) to see if data exists
        for hour in 4...25 {
            let key = self.timetableKey(calendarType, num, hour)
            if UserDefaults.standard.string(forKey: key) != nil {
                return true
            }
        }
        return false
    }
    
    // MARK: - Calendar Type Detection from Data
    // Detect available calendar types by checking actual timetable data
    func detectAvailableCalendarTypesFromData(num: Int) -> [ODPTCalendarType] {
        var detectedTypes: Set<ODPTCalendarType> = []
        
        // Check all possible calendar types
        for calendarType in ODPTCalendarType.allCases {
            if hasTimetableDataForType(calendarType, num: num) {
                detectedTypes.insert(calendarType)
            }
        }
        
        return Array(detectedTypes).sorted { $0.rawValue < $1.rawValue }
    }
    
    // MARK: - Available Calendar Types Loading
    // Load available calendar types from cache or detect from data
    func loadAvailableCalendarTypes(num: Int) -> [ODPTCalendarType] {
        // Always try to detect from actual data first to ensure we have the most up-to-date information
        let detectedTypes = detectAvailableCalendarTypesFromData(num: num)
        if !detectedTypes.isEmpty {
            return detectedTypes
        }
        
        // Try to get cached calendar types for the current route
        let routeCacheKey = "\(self)_calendarTypes"
        if let cachedTypes = UserDefaults.standard.stringArray(forKey: routeCacheKey),
           !cachedTypes.isEmpty {
            let cachedCalendarTypes = cachedTypes.compactMap { ODPTCalendarType(rawValue: $0) }
            if !cachedCalendarTypes.isEmpty {
                return cachedCalendarTypes
            }
        }
        
        // Try to find any cached calendar types by searching all keys
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in allKeys {
            if key.contains("calendarTypes") {
                if let cachedTypes = UserDefaults.standard.stringArray(forKey: key),
                   !cachedTypes.isEmpty {
                    let cachedCalendarTypes = cachedTypes.compactMap { ODPTCalendarType(rawValue: $0) }
                    if !cachedCalendarTypes.isEmpty {
                        return cachedCalendarTypes
                    }
                }
            }
        }
        
        // Final fallback to default calendar types
        return [.weekday, .saturdayHoliday]
    }
    
    // MARK: - Time String Comparison
    // Compare two time strings (in minutes format) as integers for sorting
    func isTimeLessThan(_ other: String) -> Bool {
        let time1 = Int(self) ?? 0
        let time2 = Int(other) ?? 0
        return time1 < time2
    }
    
    // MARK: - Timetable String Parsing
    // Parse space-separated timetable string into array of non-empty strings
    var timetableComponents: [String] {
        self.components(separatedBy: " ").compactMap { $0.isEmpty ? nil : $0 }
    }
    
    // MARK: - Time Format Validation
    // Check if timetable string contains time in both single and double digit formats
    func containsTimeInAnyFormat(_ departureTime: Int) -> Bool {
        let existingTimes = self.timetableComponents
        let singleDigitTime = String(departureTime)
        let doubleDigitTime = departureTime.addZeroTime
        return existingTimes.contains(singleDigitTime) || existingTimes.contains(doubleDigitTime)
    }
}

