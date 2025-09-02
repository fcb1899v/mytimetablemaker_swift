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
let appTitle = "My Transfer Makers".localized
let goorbackarray = ["back1", "go1", "back2", "go2"]

// MARK: - Default Data Functions
// Provides default values for station and line names
func departStationDefault(_ num: Int) -> String { return "\("Dep. St. ".localized)\(num + 1)" }
func arriveStationDefault(_ num: Int) -> String { return "\("Arr. St. ".localized)\(num + 1)" }
func lineNameDefault(_ num: Int) -> String { return "\("Line ".localized)\(num + 1)" }

// MARK: - UserDefault Key
let homeKey = "departurepoint"
let officeKey = "destination"

// MARK: - Placeholder Text
// Input field placeholder text
let placeHolder = "Maximum 20 Charactors".localized
let minutePlaceHolder = "Enter 0~59 [min]".localized

// MARK: - Choice Copy Time List Function
// Generates copy time choice list for timetable editing
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

// MARK: - App Information
// App version and external links
let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!
let termslink = "https://nakajimamasao-appstudio.web.app/terms".localized

// MARK: - ODPT API Keys
// API keys for ODPT (Open Data for Public Transportation) services
let odptAccessKey = "h34l1u19vxxa3itym1sa3n2qiufokufo543zfifwbuenj3dtpwthnf91k8u4lyra"
let odptChallengeKey = "fadeyt8wutw5nkfziikuroi3jj5s69zqoc2gqzd10mpybqpwjv39ev8vwbehvmyt"

// MARK: - Color String Constants
// Hex string constants for color definitions
let primaryColorString = "#3700B3"
let accentColorString  = "#03DAC5"
let redColorString     = "#FF0000"
let yellowColorString  = "#FFFF00"
let grayColorString    = "#AAAAAA"
let blackColorString   = "#000000"
let whiteColorString   = "#FFFFFF"

