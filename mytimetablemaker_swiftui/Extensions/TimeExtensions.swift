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
               .weekday
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
    // For .specific types, check their displayCalendarType for matching
    func odpTCalendarType(fallbackTo availableTypes: [ODPTCalendarType]) -> ODPTCalendarType {
        // Helper function to check if a type or its displayCalendarType is available
        func isAvailable(_ type: ODPTCalendarType) -> Bool {
            availableTypes.contains(type) || availableTypes.contains { $0.displayCalendarType == type }
        }
        
        // Helper function to find matching .specific type for a display type
        func findSpecificType(for displayType: ODPTCalendarType) -> ODPTCalendarType? {
            return availableTypes.first { $0.displayCalendarType == displayType }
        }
        
        // Check date properties
        let isHoliday = isJapaneseHoliday
        let isSunday = isWeekMatch(enWeek: "Sun", jaWeek: "日")
        let isSaturday = isWeekMatch(enWeek: "Sat", jaWeek: "土")
        let isSatHoliday = isSaturdayHoloday
        
        // Check if it's a weekday (Monday-Friday, not a holiday)
        let isWeekdayDate = !isHoliday && !isSunday && !isSaturday
        
        // If it's a weekday date, prioritize weekday calendar types
        if isWeekdayDate {
            // Check for specific weekday types first
            if isWeekMatch(enWeek: "Mon", jaWeek: "月") && isAvailable(.monday) {
                return findSpecificType(for: .monday) ?? .monday
            }
            if isWeekMatch(enWeek: "Tue", jaWeek: "火") && isAvailable(.tuesday) {
                return findSpecificType(for: .tuesday) ?? .tuesday
            }
            if isWeekMatch(enWeek: "Wed", jaWeek: "水") && isAvailable(.wednesday) {
                return findSpecificType(for: .wednesday) ?? .wednesday
            }
            if isWeekMatch(enWeek: "Thu", jaWeek: "木") && isAvailable(.thursday) {
                return findSpecificType(for: .thursday) ?? .thursday
            }
            if isWeekMatch(enWeek: "Fri", jaWeek: "金") && isAvailable(.friday) {
                return findSpecificType(for: .friday) ?? .friday
            }
            // Fallback to weekday if available
            if isAvailable(.weekday) {
                return findSpecificType(for: .weekday) ?? .weekday
            }
        }
        
        // Check for holiday/weekend calendar types
        if isHoliday && isAvailable(.holiday) {
            return findSpecificType(for: .holiday) ?? .holiday
        }
        if isSunday && isAvailable(.sunday) {
            return findSpecificType(for: .sunday) ?? .sunday
        }
        if isSaturday && isAvailable(.saturday) {
            return findSpecificType(for: .saturday) ?? .saturday
        }
        if isSatHoliday && isAvailable(.saturdayHoliday) {
            return findSpecificType(for: .saturdayHoliday) ?? .saturdayHoliday
        }
        
        // Final fallback: Use weekday if available, otherwise use first available type
        if isAvailable(.weekday) {
            return findSpecificType(for: .weekday) ?? .weekday
        }
        
        // If weekday is not available, use the first available type
        return availableTypes.first ?? .weekday
    }
    
    // MARK: - Japanese Holiday Detection
    // Check for Japanese holidays and weekday matching
    var isJapaneseHoliday: Bool { 
        return isRegularHoliday || isSubstituteHoliday || isNationalHoliday
    }
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
                // Only add if it's actually between two consecutive holidays (within 2 days)
                let daysBetween = calendar.dateComponents([.day], from: currentHoliday, to: nextHoliday).day ?? 0
                if daysBetween == 2 {
                    nationalHolidays.append(dayBetween)
                }
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
    // Get calendar type for route and line based on date with cached available types
    // Uses line-level cache key (structure: goorback -> line -> calendar types)
    func calendarType(for date: Date, num: Int) -> ODPTCalendarType {
        // Use line-level cache key to get available types for this specific line
        let lineCacheKey = "\(self)line\(num + 1)_calendarTypes"
        var availableTypes: [ODPTCalendarType] = []
        
        // Try to get cached calendar types for this specific line
        if let cachedTypes = UserDefaults.standard.stringArray(forKey: lineCacheKey),
           !cachedTypes.isEmpty {
            availableTypes = cachedTypes.compactMap { ODPTCalendarType(rawValue: $0) }
        }
        
        // If no line-specific cache, try to detect from actual data
        if availableTypes.isEmpty {
            availableTypes = self.loadAvailableCalendarTypes(num: num)
        }
        
        // Fallback to default types if no cache or data found
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
    // Split station name by ":" and return first component for ODPT format
    func timetableLineTitle(_ num: Int) -> String {
        let stationName = stationArray[2 * num + 1]
        let components = stationName.components(separatedBy: ":")
        let displayStationName = components.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? stationName
        return "\(lineNameArray[num])\(" for ".localized)\(displayStationName)\("houmen".localized)"
    }
    var routeTitle: String {
        (self == "back1") ? "Setting Return Route 1".localized:
        (self == "back2") ? "Setting Return Route 2".localized:
        (self == "go1") ? "Setting Outbound Route 1".localized:
        "Setting Outbound Route 2".localized
    }
    // Get opposite route identifier (go1 <-> go2, back1 <-> back2)
    var otherroute: String { self.prefix(self.count - 1) + ((self.suffix(1) == "1") ? "2": "1") }

    // MARK: - Timetable Data Processing
    // Get target calendar type based on date and available calendar types for the line
    // Cache available types per route to avoid repeated loading
    private static var availableTypesCache: [String: [ODPTCalendarType]] = [:]
    
    func getTargetCalendarType(_ date: Date, _ num: Int) -> ODPTCalendarType {
        // Create cache key: route + line number
        let cacheKey = "\(self)_line\(num)"
        
        // Get available calendar types for this line (use cache if available)
        let availableTypes: [ODPTCalendarType]
        if let cached = String.availableTypesCache[cacheKey] {
            availableTypes = cached
        } else {
            availableTypes = self.loadAvailableCalendarTypes(num: num)
            String.availableTypesCache[cacheKey] = availableTypes
        }
        
        // Determine target calendar type based on the provided date
        let targetCalendarType = date.odpTCalendarType(fallbackTo: availableTypes)
        
        return targetCalendarType
    }
    
    // Clear cache when calendar types are updated (called from SettingsLineViewModel)
    func clearCalendarTypesCache(num: Int) {
        let cacheKey = "\(self)_line\(num)"
        String.availableTypesCache.removeValue(forKey: cacheKey)
    }
    
    // Generate timetable arrays for all lines (0-2)
    // Each line uses its own target calendar type based on date and available calendar types
    func timetableArray(_ date: Date) -> [[Int]] {
        return (0...2).map { num in
            let targetCalendarType = getTargetCalendarType(date, num)
            return (4...25).flatMap { hour in timetableTime(targetCalendarType, num, hour).timeString
                .components(separatedBy: CharacterSet(charactersIn: " "))
                .compactMap { Int($0) }
                .map { $0 + hour * 100 }
                .filter { $0 >= 0 && $0 < 2700 }
            }.sorted()
        }
    }
    // Get ride time for a specific departure time
    // Uses timetableRideTime if available, otherwise falls back to input rideTime
    // Determines calendar type based on date and available calendar types for the line
    func getRideTime(_ date: Date, departTime: Int, num: Int) -> Int {
        // Get target calendar type based on date and available calendar types
        let targetCalendarType = getTargetCalendarType(date, num)
        
        let hour = departTime / 100
        let minutesInHour = departTime % 100
        
        // Try to get timetableRideTime for this hour
        let rideTimeKey = self.timetableRideTimeKey(targetCalendarType, num, hour)
        
        if let rideTimeString = UserDefaults.standard.string(forKey: rideTimeKey),
           !rideTimeString.isEmpty {
            let rideTimes = rideTimeString.components(separatedBy: " ").compactMap { Int($0) }
            
            // Find corresponding ride time by matching departure time
            let timetableKey = self.timetableKey(targetCalendarType, num, hour)
            if let timetableString = UserDefaults.standard.string(forKey: timetableKey),
               !timetableString.isEmpty {
                let departureTimes = timetableString.components(separatedBy: " ").compactMap { Int($0) }
                if let index = departureTimes.firstIndex(of: minutesInHour),
                   index < rideTimes.count {
                    return rideTimes[index]
                }
                // If exact match not found, use first available ride time
                if let firstRideTime = rideTimes.first {
                    return firstRideTime
                }
            }
        }
        
        // Fallback to default ride time for this line
        return rideTimeArray[num]
    }
    
    // Calculate departure and arrival times for current route based on current time
    // Uses timetableRideTime if available, otherwise falls back to input rideTime
    func timeArray(_ date: Date, _ currenttime: Int) -> [Int] {
        // Depart time of line 1
        var timeArray = [timetableArray(date)[0].first { $0 > (currenttime/100).plusHHMM(transferTimeArray[1]) } ?? 2700]
        // Arrive time of line 1
        timeArray.append(timeArray[0].plusHHMM(getRideTime(date, departTime: timeArray[0], num: 0)).overTime(timeArray[0]))
        // Depart time from depart point
        timeArray.insert(timeArray[0].minusHHMM(transferTimeArray[1]).overTime(timeArray[0]), at: 0)
        
        if (changeLineInt > 0) {
            for i in 1...changeLineInt {
                // Depart time of line i
                timeArray.append(timetableArray(date)[i].first { $0 >= timeArray[2 * i].plusHHMM(transferTimeArray[i + 1]) } ?? 2700)
                // Arrive time of line i
                timeArray.append(timeArray[2 * i + 1].plusHHMM(getRideTime(date, departTime: timeArray[2 * i + 1], num: i)).overTime(timeArray[2 * i + 1]))
            }
        }
        // Arrive time to destination (insert at index 0, so it becomes timeArray[0])
        // Use the last arrival time (which is the last element after all inserts)
        let lastArrivalTime = timeArray.last!
        timeArray.insert(lastArrivalTime.plusHHMM(transferTimeArray[0]).overTime(lastArrivalTime), at: 0)
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
    // For .specific types, use original calendarType to check with unique identifier-based key
    func hasTimetableDataForType(_ calendarType: ODPTCalendarType, num: Int) -> Bool {
        // Use original calendarType directly to check with the correct key
        // For .specific types, this ensures we check the identifier-based key
        // For standard types, this checks the standard key
        
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
        
        // Also check cached calendar types which may include .specific cases
        // Check line-level cache (each line has its own calendar types list)
        let lineCacheKey = "\(self)line\(num + 1)_calendarTypes"
        if let cachedTypes = UserDefaults.standard.stringArray(forKey: lineCacheKey),
           !cachedTypes.isEmpty {
            for cachedTypeString in cachedTypes {
                if let cachedCalendarType = ODPTCalendarType(rawValue: cachedTypeString) {
                    // If it's a .specific type, check if data exists for THIS specific line
                    if case .specific = cachedCalendarType {
                        if hasTimetableDataForType(cachedCalendarType, num: num) {
                            detectedTypes.insert(cachedCalendarType)
                            // Also add the displayCalendarType so it appears in the dropdown
                            let displayType = cachedCalendarType.displayCalendarType
                            if !detectedTypes.contains(displayType) && displayType != cachedCalendarType {
                                // Check if data exists for the display type as well
                                if hasTimetableDataForType(displayType, num: num) {
                                    detectedTypes.insert(displayType)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return Array(detectedTypes).sorted { $0.rawValue < $1.rawValue }
    }
    
    // MARK: - Available Calendar Types Loading
    // Load available calendar types from cache or detect from data
    func loadAvailableCalendarTypes(num: Int) -> [ODPTCalendarType] {
        // Check line-level cache first
        // Structure: goorback -> line -> calendar types -> timetable data
        let lineCacheKey = "\(self)line\(num + 1)_calendarTypes"
        if let cachedTypes = UserDefaults.standard.stringArray(forKey: lineCacheKey),
           !cachedTypes.isEmpty {
            let cachedCalendarTypes = cachedTypes.compactMap { ODPTCalendarType(rawValue: $0) }
            if !cachedCalendarTypes.isEmpty {
                // Verify that cached types have actual data for THIS specific line
                let verifiedTypes = cachedCalendarTypes.filter { hasTimetableDataForType($0, num: num) }
                if !verifiedTypes.isEmpty {
                    return verifiedTypes
                }
            }
        }
        
        // Try to detect from actual data
        let detectedTypes = detectAvailableCalendarTypesFromData(num: num)
        if !detectedTypes.isEmpty {
            return detectedTypes
        }
        
        // IMPORTANT: Do NOT search all keys for calendar types, as this can cause cross-route contamination
        // Each route should only use its own cached calendar types
        // If the current route's cache is not available, fall back to detection from actual data
        
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

// MARK: - TransportationTime Array Extensions
// Extensions for processing arrays of TransportationTime
extension Array where Element == any TransportationTime {
    // Merge and sort transportation times, removing duplicates
    func mergeAndSortTransportationTimes() -> [any TransportationTime] {
        // Use Set to remove exact duplicates (based on departureTime and arrivalTime)
        var seenTimes: Set<String> = []
        var uniqueTimes: [any TransportationTime] = []
        
        for time in self {
            let timeKey = "\(time.departureTime)-\(time.arrivalTime)"
            if !seenTimes.contains(timeKey) {
                seenTimes.insert(timeKey)
                uniqueTimes.append(time)
            }
        }
        
        // Sort by departure time
        uniqueTimes.sort { time1, time2 in
            let dep1Minutes = time1.departureTime.timeToMinutes
            let dep2Minutes = time2.departureTime.timeToMinutes
            if dep1Minutes != dep2Minutes {
                return dep1Minutes < dep2Minutes
            }
            // If departure times are equal, sort by arrival time
            let arr1Minutes = time1.arrivalTime.timeToMinutes
            let arr2Minutes = time2.arrivalTime.timeToMinutes
            return arr1Minutes < arr2Minutes
        }
        
        return uniqueTimes
    }
}

// MARK: - ODPT Calendar Type Extensions
// Extensions for ODPT calendar type utilities
extension ODPTCalendarType {
    
    // MARK: - Display Calendar Type
    // Convert .specific calendar types to standard types for display
    // API calls use original rawValue, but display uses converted types
    var displayCalendarType: ODPTCalendarType {
        switch self {
        
        case .specific(let rawValue):
            // Check for suffix patterns (e.g., "odpt.Calendar:Specific.YokohamaMunicipal.01_1.Weekday")
            let components = rawValue.components(separatedBy: ".")
            if let lastComponent = components.last {
                // Check if last component is a day type name
                switch lastComponent {
                case "Weekday": return .weekday
                case "Saturday": return .saturday
                case "Holiday": return .holiday
                default:
                    // Handle identifier patterns (e.g., "odpt.Calendar:Specific.Toei.81-170" or "21_7")
                    // Extract identifier and check last part after "-" or "_"
                    let identifier = lastComponent
                    // Try to extract last part after "-" first, then "_"
                    let partsByDash = identifier.components(separatedBy: "-")
                    let partsByUnderscore = identifier.components(separatedBy: "_")
                    let lastPart = partsByDash.count > 1 ? partsByDash.last ?? "" : (partsByUnderscore.count > 1 ? partsByUnderscore.last ?? "" : identifier)
                    
                    switch lastPart {
                    case "100", "109": return .holiday
                    case "160": return .saturday
                    case "170", "179": return .weekday
                    default: return .weekday  // Fallback to weekday
                    }
                }
            }
            return .weekday  // Default fallback
        default: return self
        }
    }
    
    // MARK: - Base Display Name
    // Base English name for each calendar type
    // For .specific types, include identifier to distinguish different types with same display type
    var debugDisplayName: String {
        let displayType = displayCalendarType
        switch displayType {
        case .weekday: return "Weekday"
        case .holiday: return "Holiday"
        case .saturdayHoliday: return "Saturday/Holiday"
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .specific: return "Specific"
        }
    }
    
    // MARK: - Display Name
    // Localized display name for each calendar type
    // For .specific types, shows only the display type (identifier not shown for cleaner UI)
    var displayName: String {
        return displayCalendarType.debugDisplayName.localized
    }
    
    // MARK: - Calendar Tag
    // Get calendar tag for UserDefaults keys
    // For .specific types, use identifier to ensure unique keys and prevent data overwriting
    var calendarTag: String {
        // Extract identifier from .specific rawValue for unique key
        if case .specific(let rawValue) = self,
           let lastComponent = rawValue.components(separatedBy: ".").last {
            return lastComponent.lowercased()
        }
        // For standard types, use display type tag
        let displayType = displayCalendarType
        return displayType == .saturdayHoliday ? "weekend" : displayType.debugDisplayName.lowercased()
    }
}

