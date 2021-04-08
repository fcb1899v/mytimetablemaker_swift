//
//  EnumSetting.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2020/12/27.
//

import SwiftUI

enum Action: String {
    case register = "Register"
    case cancel = "Cancel"
    case add = "Add"
    case delete = "Delete"
    case copy = "Copy"
    case reset = "Reset"
    case ok = "OK"
    case yes = "Yes"
    case No = "No"
}

//TransitTime
enum TransitTime: String, CaseIterable {
    case zero = "Zero";
    case once = "Once";
    case twice = "Twice";
    var Number: Int {
        switch (self) {
            case .zero: return 0
            case .once: return 1
            case .twice: return 2
        }
    }
}

//Transportation
enum Transportation: String, CaseIterable {
    case walking = "Walking"
    case bicycle = "Bicycle"
    case car = "Car"
}

//CustomColor
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
    var RGB: String {
        switch self {
            case .accent: return "#03DAC5"
            case .red   : return "#FF0000"
            case .orange: return "#F68B1E"
            case .yellow: return "#FFD400"
            case .yelgre: return "#99CC00"
            case .green : return "#009933"
            case .blugre: return "#00AC9A"
            case .ligblr: return "#00BAE8"
            case .blue  : return "#0000FF"
            case .navblu: return "#003686"
            case .purple: return "#A757A8"
            case .pink  : return "#E85298"
            case .darred: return "#C9252F"
            case .brown : return "#BB6633"
            case .gold  : return "#C5C544"
            case .silver: return "#89A1AD"
            case .black : return "#000000"
        }
    }
}

//CustomColor
enum DefaultColor: String {
    case primary = "#3700B3"
    case accent  = "#03DAC5"
    case red     = "#FF0000"
    case yellow  = "#FFFF00"
    case gray    = "#AAAAAA"
    case black   = "#000000"
    case white   = "#FFFFFF"
}

//Unit
enum Unit: String {
    case minites = "[min]"
    case notset = "Not set"
    case notuse = "Not use"
    case customdate = "E, MMM d, yyyy"
    case customHHmmss = "HH:mm:ss"
    case customHHmm = "HH:mm"
}

//DialogTitle
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
    case selectpicture = "Select your timetable picture"
}

//Hint
enum Hint: String {
    case maxchar = "Maximum 20 Charactors"
    case to99min = "Enter 0~99 [min]"
    case to59min = "Enter 0~59 [min]"
    case email = "Enter your e-mail"
}

//EachRouteTitle
enum EachRouteTitle: String {
    case back1 = "Going home route 1"
    case go1   = "Outgoing route 1"
    case back2 = "Going home route 2"
    case go2   = "Outgoing route 2"
}

//VariousSettingsTitle
enum VariousSettingsTitle: String {
    case back1 = "Various settings on going home route 1"
    case go1   = "Various settings on outgoing route 1"
    case back2 = "Various settings on going home route 2"
    case go2   = "Various settings on outgoing route 2"
}

