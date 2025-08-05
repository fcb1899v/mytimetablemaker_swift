//
//  Constant.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2023/11/03.
//

import SwiftUI
import Foundation
import Combine

// MARK: - App Constants
// Core application constants and localized strings
let appTitle = "My Transit Makers".localized
let goorbackarray = ["back1", "go1", "back2", "go2"]

// MARK: - Default Data Functions
// Provides default values for station and line names
func departStationDefault(_ num: Int) -> String { return "\("Dep. St. ".localized)\(num + 1)" }
func arriveStationDefault(_ num: Int) -> String { return "\("Arr. St. ".localized)\(num + 1)" }
func lineNameDefault(_ num: Int) -> String { return "\("Line ".localized)\(num + 1)" }

// MARK: - Alert Titles
// Localized alert titles for various settings
let changeLineAlertTitle = "Setting your number of transfers".localized
let departPointAlertTitle = "Setting your departure place".localized
let destinationAlertTitle = "Setting your destination".localized
let stationAlertTitle = "Setting your station name".localized
let lineNameAlertTitle = "Setting your line name".localized
let lineColorAlertTitle = "Setting your line color".localized
let stationAlertTitleArray = [destinationAlertTitle, departPointAlertTitle] + (0..<6).flatMap { _ in [stationAlertTitle] }
let rideTimeAlertTitle = "Setting your ride time [min]".localized
let transitTimeAlertTitle = "Setting your transit time [min]".localized
let transportationAlertTitle = "Setting your transportation".localized
let timetableAlertTitle = "Setting your timetable".localized
let addAndDeleteTimeTitle = "Add and delete departure time [min]".localized
let choiceCopyTimeTitle = "Copying your timetable".localized

// MARK: - Alert Messages
// Localized alert messages for form validation and user guidance
let stationAlertMessageArray: Array<String> = ["", ""] +
    (0..<3).flatMap { i in ["\("of departure station ".localized)\(i)", "\("of arrival station ".localized)\(i)"] }
func lineNameAlertMessage(_ num: Int) -> String { return "\("of ".localized)\("line ".localized)\(num + 1)" }
func choiceCopyTimeList(_ isWeekday: Bool, _ hour: Int) -> [String] {
    return [
        "\(hour - 1)\("Hour".localized)",
        "\(hour + 1)\("Hour".localized)",
        isWeekday.weekendLabel,
        "Other route of line 1".localized,
        "Other route of line 2".localized,
        "Other route of line 3".localized
    ]
}

// MARK: - Settings Labels
// Common text labels used throughout the app
let textNotSet = "Not set".localized
let textHome = "Home".localized
let textOffice = "Office".localized
let textDestination = "Destination".localized
let textDepartPoint = "Departure place".localized

// MARK: - Button Labels
// Standard button text labels
let textOk = "OK".localized
let textCancel = "Cancel".localized
let textAdd = "Add".localized
let textDelete = "Delete".localized
let textBack = "Back".localized
let textGo = "Go".localized
let textStart = "Start".localized
let textStop = "Stop".localized
let timetablePictureButtonText = "Select your timetable picture".localized

// MARK: - Placeholder Text
// Input field placeholder text
let placeHolder = "Maximum 20 Charactors".localized
let numberPlaceHolder = "Enter 0~99 [min]".localized
let minutePlaceHolder = "Enter 0~59 [min]".localized

// MARK: - App Information
// App version and external links
let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!
let termslink = "https://nakajimamasao-appstudio.web.app/terms".localized

// MARK: - Color String Constants
// Hex string constants for color definitions
let primaryColorString = "#3700B3"
let accentColorString  = "#03DAC5"
let redColorString     = "#FF0000"
let yellowColorString  = "#FFFF00"
let grayColorString    = "#AAAAAA"
let blackColorString   = "#000000"
let whiteColorString   = "#FFFFFF"



