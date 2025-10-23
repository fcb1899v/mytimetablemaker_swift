//
//  DateAndTime.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2020/12/27.
//

import SwiftUI

// MARK: - Time Conversion Extensions
// Extensions for time format conversions and calculations
extension Int {
    
    // MARK: - Time Format Conversions
    // Convert between different time formats (HHMM, MM, HHMMSS, etc.)
    var HHMMtoMM: Int { self / 100 * 60 + self % 100 }   // Convert HHMM format to minutes
    var MMtoHHMM: Int { self / 60 * 100 + self % 60 }    // Convert minutes to HHMM format
    var MMSStoSS: Int { self / 100 * 60 + self % 100 }   // Convert MMSS format to seconds
    var SStoMMSS: Int { self / 60 * 100 + self % 60 }    // Convert seconds to MMSS format
    var HHMMSStoSS: Int { self / 10000 * 3600 + (self % 10000) / 100 * 60 + self % 100 }         // Convert HHMMSS format to seconds
    var SStoHHMMSS: Int { self / 3600 * 10000 + (self % 3600) / 60 * 100 + self % 60 }           // Convert seconds to HHMMSS format
    var HHMMSStoMMSS: Int { (self / 10000 * 60 + (self % 10000) / 100) * 100 + self % 100 }      // Convert HHMMSS format to MMSS format
    
    // MARK: - Time Arithmetic Operations
    // Addition operations for different time formats
    func plusHHMM(_ time: Int) -> Int { (HHMMtoMM + time.HHMMtoMM).MMtoHHMM }            // Add HHMM format times
    func plusHHMMSS(_ time: Int) -> Int { (HHMMSStoSS + time.HHMMSStoSS).SStoHHMMSS }    // Add HHMMSS format times
    func plusMMSS(_ time: Int) -> Int { (MMSStoSS + time.MMSStoSS).SStoMMSS }            // Add MMSS format times
    
    // MARK: - Time Subtraction Operations
    // Subtraction operations for different time formats
    func minusHHMM(_ time: Int) -> Int { (HHMMtoMM < time.HHMMtoMM) ?                    // Subtract HHMM format times
        ((self + 2400).HHMMtoMM - time.HHMMtoMM).MMtoHHMM:
        (HHMMtoMM - time.HHMMtoMM).MMtoHHMM }
    func minusHHMMSS(_ time: Int) -> Int { (self.HHMMSStoSS < time.HHMMSStoSS) ?         // Subtract HHMMSS format times
        ((self + 240000).HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS:
        (HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS }
    func minusMMSS(_ time: Int) -> Int { (self.MMSStoSS - time.MMSStoSS).SStoMMSS }      // Subtract MMSS format times
    
    // MARK: - Time Display Formatting
    // Format time for display purposes
    var addZeroTime: String { (0...9 ~= self) ? "0\(self)": "\(self)" }                              // Add leading zero for single digits
    func overTime(_ beforeTime: Int) -> Int { (beforeTime == 2700) ? 2700: (self > 2700) ? 2700: self }

    var timeHH: String { (self / 100 + (self % 100) / 60).addZeroTime }
    var timeMM: String { (self % 100 % 60).addZeroTime }
    var stringTime: String { ("\(timeHH):\(timeMM)" != "27:00") ? "\(timeHH):\(timeMM)": "--:--" }   // Convert HHMM format to display time
    
    var timetableHour: Int { (self > 3) ? self: self + 24 }
    
    // MARK: - Countdown Functions
    // Countdown timer formatting and calculations
    var countdown: String{ (0...9999 ~= self) ? "\((self / 100).addZeroTime):\((self % 100).addZeroTime)": "--:--" }           // Convert MMSS format to countdown display
    func countdownTime(_ departtime: Int) -> String { (departtime * 100).minusHHMMSS(self).HHMMSStoMMSS.countdown }

    // MARK: - ODPT Calendar Type Detection
    // Get ODPT calendar type for this day with fallback to available types
    func odpTCalendarType(fallbackTo availableTypes: [ODPTCalendarType]) -> ODPTCalendarType {
        // Priority order: holiday > sunday > saturday > saturdayHoliday > specific weekdays > weekday > allday
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
    
    // MARK: - Choice Copy Time List Function
    // Generates copy time choice list for timetable editing
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
// Extensions for Date formatting and weekday detection
extension Date {

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
    
    // MARK: - ODPT Calendar Type Detection for Date
    // Get ODPT calendar type for this date with priority
//    var odpTCalendarType: ODPTCalendarType {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "E"
//        let dayOfWeek = formatter.string(from: self)
//        
//        // Priority order:
//        // 1. .holiday (highest priority)
//        // 2. .saturdayHoliday (second priority)
//        // 3. .sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday (third priority)
//        // 4. .weekday (lowest priority)
//        
//        // Check if it's a Japanese holiday first
//    }
    var odpTCalendarType: ODPTCalendarType {
        return .weekday
    }
    
    // MARK: - ODPT Calendar Type with Fallback
    // Get ODPT calendar type for this date with fallback to available types
    func odpTCalendarType(fallbackTo availableTypes: [ODPTCalendarType]) -> ODPTCalendarType {

        // Priority order: holiday > sunday > saturday > saturdayHoliday > specific weekdays > weekday > allday
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
    // Check for regular or substitute or Japanese national holidays
    var isJapaneseHoliday: Bool { isRegularHoliday || isSubstituteHoliday || isNationalHoliday }
    func isWeekMatch(enWeek: String, jaWeek: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        let dayOfWeek = formatter.string(from: self)
        return dayOfWeek == enWeek || dayOfWeek == jaWeek
    }
    var isSaturdayHoloday: Bool { isJapaneseHoliday || isWeekMatch(enWeek: "Sun", jaWeek: "日") || isWeekMatch(enWeek: "Sat", jaWeek: "土")}
    
    // MARK: - Regular Holiday Detection
    // Check if the date is a regular Japanese public holiday
    private var isRegularHoliday: Bool {
        let year = Calendar.current.component(.year, from: self)
        let holidays = getAllHolidaysForYear(year)
        // Check if this date matches any regular holiday
        return holidays.contains { holiday in
            Calendar.current.isDate(self, inSameDayAs: holiday)
        }
    }
    
    // MARK: - Substitute Holiday Detection
    // Check if the date is a substitute holiday
    private var isSubstituteHoliday: Bool {
        let year = Calendar.current.component(.year, from: self)
        let substituteHolidays = getSubstituteHolidaysForYear(year)
        // Check if this date matches any substitute holiday
        return substituteHolidays.contains { holiday in
            Calendar.current.isDate(self, inSameDayAs: holiday)
        }
    }
    
    // MARK: - National Holiday Detection
    // Check if the date is a national holiday
    private var isNationalHoliday: Bool {
        let year = Calendar.current.component(.year, from: self)
        let nationalHolidays = getNationalHolidaysForYear(year)
        // Check if this date matches any national holiday
        return nationalHolidays.contains { holiday in
            Calendar.current.isDate(self, inSameDayAs: holiday)
        }
    }
    
    // MARK: - Helper Methods
    // Get all holidays for a specific year
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
    
    // MARK: - Variable Holiday Calculation
    // Calculate variable holidays for a specific year
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
    
    // MARK: - Substitute Holiday Calculation
    // Calculate substitute holidays for a specific year
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
    
    // MARK: - National Holiday Calculation
    // Calculate national holidays for a specific year
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
// Extensions for string-based time operations and parsing
extension String {
    
    func intText(min: Int, max: Int) -> Int {
        let intText: Int = Int(self) ?? min - 1
        return (intText > min - 1 && intText < max + 1) ? intText: min - 1
    }
    
    var dateFromDate: Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "E, MMM d, yyyy".localized
        return formatter.date(from: self)!
    }

    // MARK: - Current Time Parsing
    // Parse current time from string format
    var currentTime: Int {
        let timeHH = Int(self.components(separatedBy: ":")[0]) ?? 0
        let timemm = Int(self.components(separatedBy: ":")[1]) ?? 0
        let timess = Int(self.components(separatedBy: ":")[2]) ?? 0
        return timeHH * 10000 + timemm * 100 + timess
    }
    
    // MARK: - Time String Processing
    // Process time strings for timetable operations
    var timeString: String { (self.prefix(1) == " ") ? String(self.suffix(self.count - 1)): self }
    
    // MARK: - Minutes Only Display
    // Extract minutes only from time strings (e.g., "07:24" -> "24")
    var minutesOnly: String {
        let components = self.components(separatedBy: ":")
        if components.count == 2, let minutes = components.last {
            return minutes
        }
        return self
    }
    
    // MARK: - Leading Zero Removal
    // Remove leading zero from time strings (e.g., "03" -> "3")
    var trimmingLeadingZero: String { (self.count > 1 && self.hasPrefix("0")) ? String(self.dropFirst()): self }
    
    func addInputTime(_ inputText: String) -> String { return (self != "") ? "\(self) \(inputText)": inputText}
    
    // MARK: - Ride Time Calculation
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
    
    // MARK: - Time Conversion Helper
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
    
    // MARK: - Time Adjustment Helper
    // Adjust departure time for timetable display (0-3 AM times are previous day)
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
    
    func timeSorting(charactersin: String) -> [String] {
        Array(Set(self.components(separatedBy: CharacterSet(charactersIn: charactersin))
            .map{Int($0) ?? 60}
            .filter{$0 < 60}
            .filter{$0 > -1}
        ))
        .sorted()
        .map{String($0)}
    }
    
    // MARK: - Alert Message Generation
    // Dynamic alert title and message generation
    func timetableLineTitle(_ num: Int) -> String { "\(lineNameArray[num])\(" for ".localized)\(stationArray[2 * num + 1])\("houmen".localized)" }
    var routeTitle: String {
        (self == "back1") ? "Setting Return Route 1".localized:
        (self == "back2") ? "Setting Return Route 2".localized:
        (self == "go1") ? "Setting Outbound Route 1".localized:
        "Setting Outbound Route 2".localized
    }
    var otherroute: String { self.prefix(self.count - 1) + ((self.suffix(1) == "1") ? "2": "1") }

    // MARK: - Timetable Management
    // Timetable data processing and manipulation
    func timetable(_ calendarType: ODPTCalendarType, _ num: Int) -> [Int] {
        (4...25).flatMap { hour in timetableTime(calendarType, num, hour).timeString
            .components(separatedBy: CharacterSet(charactersIn: " "))
            .compactMap { Int($0) }
            .map { $0 + hour * 100 }
            .filter { $0 >= 0 && $0 < 2700 }
            .sorted()
        }
    }
    func timetableArray(_ calendarType: ODPTCalendarType) -> [[Int]] { (0...2).map { num in timetable(calendarType, num) } }
    
    // MARK: - Time Array Generation
    // Generate departure and arrival times for current route
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
    // Add time to timetable
    func addTimeFromTimetable(_ inputText: String, _ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int) -> String {
        timetableTime(calendarType, num, hour)
            .addInputTime(inputText)
            .timeSorting(charactersin: " ")
            .joined(separator: " ")
    }
    // Delete time from timetable
    func deleteTimeFromTimetable(_ inputText: String, _ calendarType: ODPTCalendarType, _ num: Int, _ hour: Int) -> String {
        timetableTime(calendarType, num, hour)
            .trimmingCharacters(in: .whitespaces)
            .timeSorting(charactersin: " ")
            .filter{$0 != inputText}
            .joined(separator: " ")
    }
}

