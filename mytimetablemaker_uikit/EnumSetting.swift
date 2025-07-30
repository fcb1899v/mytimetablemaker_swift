//
//  EnumSetting.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/11/08.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Action Enumeration
// Defines common action types used throughout the application
enum Action: String {
    case register = "Register"
    case cancel = "Cancel"
    case add = "Add"
    case delete = "Delete"
    case copy = "Copy"
    case ok = "OK"
    case yes = "Yes"
    case No = "No"
}

// MARK: - Transit Time Enumeration
// Defines the number of transit times for route planning
enum TransitTime: String, CaseIterable {
    case zero = "Zero";
    case once = "Once";
    case twice = "Twice";
    
    // MARK: - Computed Properties
    // Returns the numeric value for the transit time
    var Number: Int {
        switch (self) {
            case .zero: return 0
            case .once: return 1
            case .twice: return 2
        }
    }
}

// MARK: - Transportation Enumeration
// Defines available transportation modes
enum Transportation: String, CaseIterable {
    case walking = "Walking"
    case bicycle = "Bicycle"
    case car = "Car"
}

// MARK: - Custom Color Enumeration
// Defines available color options for UI customization
enum CustomColor: String, CaseIterable {
    case accent = "DEFAULT"
    case red    = "RED"
    case orange = "ORANGE"
    case yellow = "YELLOW"
    case yelgre = "YELLOW GREEN"
    case green  = "GREEN"
    case blugre = "BLUE GREEN"
    case ligblr = "LIGHT BLUE"
    case blue   = "BLUE"
    case navblu = "NAVY BLUE"
    case purple = "PURPLE"
    case pink   = "PINK"
    case darred = "DARK RED"
    case brown  = "BROWN"
    case gold   = "GOLD"
    case silver = "SILVER"
    case black  = "BLACK"
    
    // MARK: - Computed Properties
    // Returns the RGB color value for each color option
    var RGB: Int {
        switch self {
            case .accent: return 0x03DAC5
            case .red   : return 0xFF0000
            case .orange: return 0xF68B1E
            case .yellow: return 0xFFD400
            case .yelgre: return 0x99CC00
            case .green : return 0x009933
            case .blugre: return 0x00AC9A
            case .ligblr: return 0x00BAE8
            case .blue  : return 0x0000FF
            case .navblu: return 0x003686
            case .purple: return 0xA757A8
            case .pink  : return 0xE85298
            case .darred: return 0xC9252F
            case .brown : return 0xBB6633
            case .gold  : return 0xC5C544
            case .silver: return 0x89A1AD
            case .black : return 0x000000
        }
    }
}

// MARK: - Default Color Enumeration
// Defines default color values for the application theme
enum DefaultColor: Int {
    case primary = 0x3700B3
    case accent  = 0x03DAC5
    case red     = 0xFF0000
    case yellow  = 0xFFFF00
    case gray    = 0x8E8E93
    case black   = 0x000000
    case white   = 0xFFFFFF
    
    // MARK: - Computed Properties
    // Returns UIColor for the default color
    var UI: UIColor {
        return UIColor(self.rawValue)
    }
}

// MARK: - Unit Enumeration
// Defines common units and format strings used in the application
enum Unit: String {
    case minites = "[min]"
    case notset = "Not set"
    case notuse = "Not use"
    case customdate = "E, MMM d, yyyy"
    case customHHmmss = "HH:mm:ss"
    case customHHmm = "HH:mm"
}

// MARK: - Dialog Title Enumeration
// Defines titles for various dialog screens
enum DialogTitle: String {
    case numtransit  = "Setting your number of transfers"
    case departplace = "Setting your departure place"
    case stationname = "Setting your station name"
    case destination = "Setting your destination"
    case linename    = "Setting your line name"
    case linecolor   = "Setting your line color"
    case ridetime    = "Setting your ride time [min]"
    case transport   = "Setting your transportation"
    case transittime = "Setting your transit time [min]"
    case timetable   = "Setting your timetable"
    case adddeletime = "Add and delete your time [min]"
    case copytime    = "Copying your time"
    case allcopytime = "Copying all the time"
}

// MARK: - Hint Enumeration
// Defines hint messages for user input validation
enum Hint: String {
    case maxchar = "Maximum 20 Charactors"
    case to99min = "Enter 0~99 [min]"
    case to59min = "Enter 0~59 [min]"
}

// MARK: - Various Settings Title Enumeration
// Defines titles for various settings screens based on route direction
enum VariousSettingsTitle: String {
    case back1 = "Various settings on route home 1"
    case go1   = "Various settings on outgoing route 1"
    case back2 = "Various settings on route home 2"
    case go2   = "Various settings on outgoing route 2"
}
