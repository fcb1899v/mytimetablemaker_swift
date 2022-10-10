//
//  DataConstant.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2023/11/03.
//

import SwiftUI
import Foundation
import Combine

let goorbackarray: [String] = ["back1", "go1", "back2", "go2"]

//Default data
func departStationDefault(_ num: Int) -> String { return "\("Dep. St. ".localized)\(num + 1)" }
func arriveStationDefault(_ num: Int) -> String { return "\("Arr. St. ".localized)\(num + 1)" }
func lineNameDefault(_ num: Int) -> String { return "\("Line ".localized)\(num + 1)" }

//Alert Title
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

//Alert Message
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

//PlaceHolder
let placeHolder = "Maximum 20 Charactors".localized
let numberPlaceHolder = "Enter 0~99 [min]".localized
let minutePlaceHolder = "Enter 0~59 [min]".localized


let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!
let termslink = "https://nakajimamasao-appstudio.web.app/terms".localized

