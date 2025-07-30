//
//  Timetable.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/09/27.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

// MARK: - Time Calculation Structure
// Handles time calculations for route planning and timetable operations
struct CalcTime: Calculation {
    var goorback: String
    var weekflag: Bool
    var changeline: Int
    
    // MARK: - Initialization
    // Initialize with route direction, week flag, and number of transfers
    init(_ goorback: String, _ weekflag: Bool, _ changeline: Int) {
        self.goorback = goorback
        self.weekflag = weekflag
        self.changeline = changeline
    }
}

// MARK: - Time Calculation Extensions
extension CalcTime {
    
    // MARK: - Timetable Data Access
    // Retrieves timetable time for specific key tag and hour from UserDefaults
    func timetableTime(_ keytag: String, _ hour: Int) -> String {
        let weektag = (weekflag) ? "weekday": "weekend"
        let key = "\(goorback)line\(keytag)\(weektag)\(String(hour))"
        return key.userDefaultValue("")
    }
    
    // Retrieves complete timetable data for a specific key tag
    func timetable(_ keytag: String) -> [Int] {
        var timetable: [Int] = []
        for hour in 4...25 {
            let timetext = String(timetableTime(keytag, hour).dropFirst(1))
            if (timetext != "") {
                timetable.append(contentsOf: timetext.timeGetting(charactersin: " ", hour: hour))
            }
        }
        return timetable
    }
    
    // MARK: - Timetable Array Management
    // Returns array of timetable data for all lines in the route
    var timetableArray: [[Int]] {
        var timetablearray: [[Int]] = []
        for i in 0...changeline {
            timetablearray.append(self.timetable(String(i + 1)))
        }
        return timetablearray
    }
    
    // MARK: - Transit Time Management
    // Returns array of transit times for all transfer points
    var transitTimeArray: [Int]{
        var transittimearray: [Int] = []
        for i in 0...changeline + 1 {
            let transittime = (i == changeline + 1) ? (goorback.transitTime("e")): goorback.transitTime(String(i + 1))
            transittimearray.append(transittime)
        }
        return transittimearray
    }
    
    // MARK: - Ride Time Management
    // Returns array of ride times for all lines in the route
    var rideTimeArray: [Int]{
        var ridetimearray: [Int] = []
        for i in 0...changeline {
            ridetimearray.append(goorback.rideTime(String(i + 1)))
        }
        return ridetimearray
    }
    
    // MARK: - Next Start Time Calculation
    // Finds the next available start time for a given possible time and line index
    func nextStartTime(_ possibletime: Int, _ i: Int) -> Int {
        var nextstarttime: Int
        for j in 0..<timetableArray[i].count {
            nextstarttime = timetableArray[i][j]
            if (possibletime < nextstarttime) {
                return nextstarttime
            }
        }
        nextstarttime = 2700
        return nextstarttime
    }
    
    // MARK: - Departure Time Calculation
    // Calculates departure time based on current time
    func departureTime(_ currenttime: Int) -> Int {
        let possibletime = (currenttime/100).plusHHMM(transitTimeArray[0])
        let nextstarttime = nextStartTime(possibletime, 0)
        return nextstarttime.minusHHMM(transitTimeArray[0])
    }
    
    // MARK: - Time Array Generation
    // Generates array of times for each line: possible time[0], departure time[1], arrival time[2]
    func timeArray(_ currenttime: Int) -> [[Int]] {
        var timearrays: [[Int]] = [[]]
        // Get times for line 1: possible time, departure time, arrival time
        timearrays[0].append((currenttime/100).plusHHMM(transitTimeArray[0]))
        timearrays[0].append(nextStartTime(timearrays[0][0], 0))
        timearrays[0].append(timearrays[0][1].plusHHMM(rideTimeArray[0]))
        // Get times for subsequent lines: possible time, departure time, arrival time
        if (changeline > 0) {
            for i in 1...changeline {
                timearrays.append([])
                timearrays[i].append(timearrays[i - 1][2].plusHHMM(transitTimeArray[i]))
                timearrays[i].append(nextStartTime(timearrays[i][0], i))
                timearrays[i].append(timearrays[i][1].plusHHMM(rideTimeArray[i]))
            }
        }
        return timearrays
    }
    
    // MARK: - Display Time Array Generation
    // Generates formatted time array for display purposes
    func displayTimeArray(_ currenttime: Int) -> [String] {
        let timearray = timeArray(currenttime)
        var displaytimearray: [String] = []
        // Get arrival time, departure time, and intermediate times
        displaytimearray.append(timearray[changeline][2].plusHHMM(transitTimeArray[changeline + 1]).stringTime)
        displaytimearray.append(timearray[0][1].minusHHMM(transitTimeArray[0]).stringTime)
        for i in 0...changeline {
            displaytimearray.append(timearray[i][1].stringTime)
            displaytimearray.append(timearray[i][2].stringTime)
        }
        return displaytimearray
    }
}
