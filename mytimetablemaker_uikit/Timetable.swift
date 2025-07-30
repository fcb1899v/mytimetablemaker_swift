//
//  Timetable.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/11/07.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Timetable Structure
// Represents a timetable with route direction, week flag, and key tag
struct Timetable: Calculation{
    var goorback: String
    var weekflag: Bool
    var keytag: String
    
    // MARK: - Initialization
    // Initialize timetable with route direction, week flag, and key tag
    init(_ goorback: String, _ weekflag: Bool, _ keytag: String){
        self.goorback = goorback
        self.weekflag = weekflag
        self.keytag = keytag
    }
}

// MARK: - Timetable Extensions
extension Timetable {

    // MARK: - Week Tag Management
    // Returns week tag based on week flag
    var weektag: String {
        return (self.weekflag) ? "weekday": "weekend"
    }

    // MARK: - Timetable Title Generation
    // Generates timetable title with line name and arrival station
    var timetableTitle: String {
        let arrivestation = timetableArriveStation
        let linename = timetableLineName
        return "(\(linename)\(" for ".localized)\(arrivestation)\("houmen".localized))"
    }

    // MARK: - Station Information Access
    // Retrieves departure station name from UserDefaults
    var timetableDepartStation: String {
        return "\(goorback)departstation\(keytag)"
            .userDefaultValue("\("Dep. St.".localized)\(keytag)")
    }

    // Retrieves arrival station name from UserDefaults
    var timetableArriveStation: String {
        return "\(goorback)arrivestation\(keytag)"
            .userDefaultValue("Arr. St.".localized + keytag)
    }
    
    // Retrieves line name from UserDefaults
    var timetableLineName: String {
        return "\(goorback)linename\(keytag)"
            .userDefaultValue("Line ".localized + keytag)
    }

    // MARK: - Week Display Management
    // Returns week label text based on week flag
    var weekLabelText: String {
        return (self.weekflag) ? "Weekday".localized: "Weekend".localized
    }

    // Returns week label color based on week flag
    func weekLabelColor(_ daycolor: Int, _ endcolor: Int) -> UIColor {
        return (weekflag) ? UIColor(daycolor): UIColor(endcolor)
    }

    // Sets week button title based on week flag
    func weekButtonTitle(_ weekbutton: UIButton) {
        let buttontext = (self.weekflag) ? "Weekend".localized: "Weekday".localized
        return weekbutton.setTitle(buttontext.uppercased(), for: UIControl.State.normal)
    }

    // Sets week button color based on week flag
    func weekButtonColor(_ weekbutton: UIButton, _ daycolor: Int, _ endcolor: Int) {
        return weekbutton.setTitleColor((weekflag) ? UIColor(daycolor): UIColor(endcolor), for: UIControl.State.normal)
    }

    // MARK: - Timetable Data Access
    // Retrieves timetable time for specific hour from UserDefaults
    func timetableTime(_ hour: Int) -> String {
        return "\(goorback)line\(keytag)\(weektag)\(String(hour))".userDefaultValue("")
    }
}

// MARK: - String Time Processing Extensions
// Extensions for processing time strings
extension String {
    
    // MARK: - Time Sorting
    // Sorts and filters time values from string
    func timeSorting(charactersin: String) -> [String] {
        return Array(Set(self
                .components(separatedBy: CharacterSet(charactersIn: charactersin))
                .map{Int($0) ?? 60}
                .filter{$0 < 60}
                .filter{$0 > -1}
            ))
            .sorted()
            .map{String($0)}
    }
    
    // MARK: - Time Extraction
    // Extracts time values with hour offset
    func timeGetting(charactersin: String, hour: Int) -> [Int] {
        return Array(Set(self
                .components(separatedBy: CharacterSet(charactersIn: charactersin))
                .map{(Int($0)! + hour * 100)}
                .filter{$0 < 2560}
                .filter{$0 > -1}
            ))
            .sorted()
    }
    
    // MARK: - Route Switching
    // Switches between route 1 and route 2
    var otherroute: String {
        return self.prefix(self.count - 1) + ((self.suffix(1) == "1") ? "2": "1")
    }
}
