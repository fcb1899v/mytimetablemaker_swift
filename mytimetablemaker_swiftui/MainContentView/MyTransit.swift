//
//  MainViewModel.swift
//  mytimetablemakers_swiftui
//
//  Created by Masao Nakajima on 2021/02/08.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Transit Data Model
// Manages transit information, timetables, and real-time updates
class MyTransit: ObservableObject {
    
    // Timer for real-time updates
    private var cancellable: AnyCancellable?
    
    @Published var selectDate: Date
    @Published var dateLabel: String
    @Published var timeLabel: String
    @Published var isTimeStop: Bool
    @Published var isBack: Bool
    
    // Route visibility settings with UserDefaults persistence
    @Published var isShowBackRoute2: Bool {
        didSet {
            UserDefaults.standard.set(isShowBackRoute2, forKey: "back2".isShowRoute2Key)
        }
    }
    @Published var isShowGoRoute2: Bool {
        didSet {
            UserDefaults.standard.set(isShowGoRoute2, forKey: "go2".isShowRoute2Key)
        }
    }
    
    // Line change settings with UserDefaults persistence
    @Published var changeLine1: Int {
        didSet {
            UserDefaults.standard.set(changeLine1, forKey: isBack.goOrBack1.changeLineKey)
        }
    }
    @Published var changeLine2: Int {
        didSet {
            UserDefaults.standard.set(changeLine2, forKey: isBack.goOrBack2.changeLineKey)
        }
    }
    
    // MARK: - Initialization
    init() {
        self.isBack = true
        self.isShowBackRoute2 = "back2".isShowRoute2
        self.isShowGoRoute2 = "go2".isShowRoute2
        self.changeLine1 = "back1".changeLineInt
        self.changeLine2 = "back2".changeLineInt
        self.isTimeStop = false
        self.selectDate = Date()
        self.dateLabel = Date().setDate
        self.timeLabel = Date().setTime
    }
    
    // MARK: - Route Management
    // Updates route visibility settings from UserDefaults
    func setRoute2() {
        isShowBackRoute2 = "back2".isShowRoute2
        isShowGoRoute2 = "go2".isShowRoute2
    }
    
    // Updates line change settings based on current direction
    func setChangeLine() {
        changeLine1 = isBack.goOrBack1.changeLineInt
        changeLine2 = isBack.goOrBack2.changeLineInt
    }
    
    // MARK: - Direction Control
    // Switches to return direction and updates line settings
    func backButton() {
        isBack = true
        setChangeLine()
    }
    
    // Switches to outbound direction and updates line settings
    func goButton() {
        isBack = false
        setChangeLine()
    }
    
    // MARK: - Timer Control
    // Starts real-time timer for updating date and time
    func startButton() {
        isTimeStop = false
        selectDate = Date()
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.dateLabel = Date().setDate
                self.timeLabel = Date().setTime
            }
    }
    
    // Stops real-time timer
    func stopButton() {
        isTimeStop = true
        cancellable?.cancel()
    }
    
    // MARK: - Computed Properties
    // Current date and time information
    var isWeekday: Bool { return dateLabel.dateFromDate.isWeekday }
    var currentTime: Int { return timeLabel.currentTime }
    
    // Direction-based route identifiers
    var goOrBack1: String { return isBack.goOrBack1 }
    var goOrBack2: String { return isBack.goOrBack2 }
    
    // Route visibility based on current direction
    var isShowRoute2: Bool { return isBack ? isShowBackRoute2: isShowGoRoute2 }
    var routeWidth: CGFloat { return isShowRoute2.routeWidth }
    
    // Timetable data for both routes
    var timetableArray1: [[Int]] { return goOrBack1.timetableArray(isWeekday) }
    var timetableArray2: [[Int]] { return goOrBack2.timetableArray(isWeekday) }
    
    // Current time-based schedule information
    var timeArray1: [Int] { return goOrBack1.timeArray(isWeekday, currentTime) }
    var timeArray2: [Int] { return goOrBack2.timeArray(isWeekday, currentTime) }
    var timeArrayString1: [String] { return timeArray1.map { $0.stringTime } }
    var timeArrayString2: [String] { return timeArray2.map { $0.stringTime } }
    
    // Countdown information for next trains
    var countdownTime1: String { return currentTime.countdownTime(timeArray1[1]) }
    var countdownTime2: String { return currentTime.countdownTime(timeArray2[1]) }
    var countdownColor1: Color { return currentTime.countdownColor(timeArray1[1]) }
    var countdownColor2: Color { return currentTime.countdownColor(timeArray2[1]) }
}

