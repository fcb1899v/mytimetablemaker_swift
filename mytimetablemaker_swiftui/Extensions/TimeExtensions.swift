//
//  DateAndTime.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2020/12/27.
//

import SwiftUI

// MARK: - Time Conversion Extensions
// Extensions for time format conversions and calculations
extension Int {
    
    // MARK: - Time Format Conversions
    // Convert between different time formats (HHMM, MM, HHMMSS, etc.)
    var HHMMtoMM: Int { return self / 100 * 60 + self % 100 }   // Convert HHMM format to minutes
    var MMtoHHMM: Int { return self / 60 * 100 + self % 60 }    // Convert minutes to HHMM format
    var MMSStoSS: Int { return self / 100 * 60 + self % 100 }   // Convert MMSS format to seconds
    var SStoMMSS: Int { return self / 60 * 100 + self % 60 }    // Convert seconds to MMSS format
    var HHMMSStoSS: Int { return self / 10000 * 3600 + (self % 10000) / 100 * 60 + self % 100 }         // Convert HHMMSS format to seconds
    var SStoHHMMSS: Int { return self / 3600 * 10000 + (self % 3600) / 60 * 100 + self % 60 }           // Convert seconds to HHMMSS format
    var HHMMSStoMMSS: Int { return (self / 10000 * 60 + (self % 10000) / 100) * 100 + self % 100 }      // Convert HHMMSS format to MMSS format
    var MMSStoHHMMSS: Int { return (self / 100 / 60) * 10000 + (self / 100 % 60) * 100 + self % 100 }   // Convert MMSS format to HHMMSS format
    
    // MARK: - Time Arithmetic Operations
    // Addition operations for different time formats
    func plusHHMM(_ time: Int) -> Int { return (HHMMtoMM + time.HHMMtoMM).MMtoHHMM }            // Add HHMM format times
    func plusHHMMSS(_ time: Int) -> Int { return (HHMMSStoSS + time.HHMMSStoSS).SStoHHMMSS }    // Add HHMMSS format times
    func plusMMSS(_ time: Int) -> Int { return (MMSStoSS + time.MMSStoSS).SStoMMSS }            // Add MMSS format times
    
    // MARK: - Time Subtraction Operations
    // Subtraction operations for different time formats
    func minusHHMM(_ time: Int) -> Int { return (HHMMtoMM < time.HHMMtoMM) ?                    // Subtract HHMM format times
        ((self + 2400).HHMMtoMM - time.HHMMtoMM).MMtoHHMM:
        (HHMMtoMM - time.HHMMtoMM).MMtoHHMM }
    func minusHHMMSS(_ time: Int) -> Int { return (self.HHMMSStoSS < time.HHMMSStoSS) ?         // Subtract HHMMSS format times
        ((self + 240000).HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS:
        (HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS }
    func minusMMSS(_ time: Int) -> Int { return (self.MMSStoSS - time.MMSStoSS).SStoMMSS }      // Subtract MMSS format times
    
    // MARK: - Time Display Formatting
    // Format time for display purposes
    var addZeroTime: String { return (0...9 ~= self) ? "0\(self)": "\(self)" }                              // Add leading zero for single digits
    func overTime(_ beforeTime: Int) -> Int { return (beforeTime == 2700) ? 2700: (self > 2700) ? 2700: self }

    var timeHH: String { return (self / 100 + (self % 100) / 60).addZeroTime }
    var timeMM: String { return (self % 100 % 60).addZeroTime }
    var stringTime: String { return ("\(timeHH):\(timeMM)" != "27:00") ? "\(timeHH):\(timeMM)": "--:--" }   // Convert HHMM format to display time

    
    // MARK: - Countdown Functions
    // Countdown timer formatting and calculations
    var countdownMM: String { return (self / 100).addZeroTime }
    var countdownSS: String { return (self % 100).addZeroTime }
    var countdown: String{ return (0...9999 ~= self) ? "\(countdownMM):\(countdownSS)": "--:--" }           // Convert MMSS format to countdown display
    func countdownTime(_ departtime: Int) -> String {
        return (departtime * 100).minusHHMMSS(self).HHMMSStoMMSS.countdown
    }

    // MARK: - Weekday Detection
    // Determine if time represents weekday or weekend
    var isWeekend: Bool { return (self == 0 || self == 6) }
    var isWeekday: Bool { return !isWeekend }
    
    // MARK: - Choice Copy Time List Function
    // Generates copy time choice list for timetable editing
    func choiceCopyTimeList(_ isWeekday: Bool) -> [String] {
        return [
            "\(self - 1)\("Hour".localized)",
            "\(self + 1)\("Hour".localized)",
            isWeekday.weekendLabel,
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
    
    var isWeekday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        switch (formatter.string(from: self)) {
            case "Sat", "Sun", "土", "日": return false
            default: return true
        }
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
    var timeString: String { return (self.prefix(1) == " ") ? String(self.suffix(self.count - 1)): self }
    func addInputTime(_ inputText: String) -> String { return (self != "") ? "\(self) \(inputText)": inputText}
    func timeSorting(charactersin: String) -> [String] {
        return Array(Set(self.components(separatedBy: CharacterSet(charactersIn: charactersin))
                .map{Int($0) ?? 60}
                .filter{$0 < 60}
                .filter{$0 > -1}
            ))
            .sorted()
            .map{String($0)}
    }
    
    // MARK: - Alert Message Generation
    // Dynamic alert title and message generation
    func timetableAlertMessage(_ num: Int, _ hour: Int) -> String { return "\(lineNameArray[num]) (\(hour)\("Hour".localized))" }
    func timetableAlertTitle(_ num: Int) -> String { return "(\(lineNameArray[num])\(" for ".localized)\(stationArray[2 * num + 1])\("houmen".localized))"}
    var routeTitle: String { return
        (self == "back1") ? "Setting home route 1".localized:
        (self == "back2") ? "Setting home route 2".localized:
        (self == "go1") ? "Setting outgoing route 1".localized:
        "Setting outgoing route 2".localized
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
