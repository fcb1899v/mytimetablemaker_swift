//
//  MainViewModel.swift
//  mytimetablemakers_swiftui
//
//  Created by Masao Nakajima on 2021/02/08.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Transfer Data Model
// Manages transfer information, timetables, and real-time updates
class MyTransfer: ObservableObject {
    
    // Timer for real-time updates
    private var cancellable: AnyCancellable?
    
    @Published var selectDate: Date
    @Published var dateLabel: String
    @Published var timeLabel: String
    @Published var isTimeStop: Bool
    @Published var isBack: Bool
    
    // Route visibility settings with UserDefaults persistence
    @Published var isShowBackRoute2: Bool
    @Published var isShowGoRoute2: Bool
    
    // Line change settings with UserDefaults persistence
    @Published var changeLine1: Int
    @Published var changeLine2: Int
    
    // Route direction identifiers with UserDefaults persistence
    @Published var goOrBack1: String
    @Published var goOrBack2: String
    
    // Line data arrays for real-time updates
    @Published var home: String
    @Published var office: String
    @Published var stationArray1: [String]
    @Published var stationArray2: [String]
    @Published var lineNameArray1: [String]
    @Published var lineNameArray2: [String]
    @Published var lineColorArray1: [Color]
    @Published var lineColorArray2: [Color]
    @Published var transportationArray1: [String]
    @Published var transportationArray2: [String]
    @Published var transferTimeArray1: [Int]
    @Published var transferTimeArray2: [Int]
    

    // MARK: - Initialization
    init() {
        self.isBack = true
        self.isShowBackRoute2 = "back2".isShowRoute2
        self.isShowGoRoute2 = "go2".isShowRoute2
        self.changeLine1 = "back1".changeLineInt
        self.changeLine2 = "back2".changeLineInt
        self.goOrBack1 = "back1"
        self.goOrBack2 = "back2"
        self.isTimeStop = false
        self.selectDate = Date()
        self.dateLabel = Date().setDate
        self.timeLabel = Date().setTime
        self.home = "back1".departurePoint
        self.office = "back1".destination
        self.stationArray1 = "back1".stationArray
        self.stationArray2 = "back2".stationArray
        self.lineNameArray1 = "back1".lineNameArray
        self.lineNameArray2 = "back2".lineNameArray
        self.lineColorArray1 = "back1".lineColorArray
        self.lineColorArray2 = "back2".lineColorArray
        self.transportationArray1 = "back1".transportationArray
        self.transportationArray2 = "back2".transportationArray
        self.transferTimeArray1 = "back1".transferTimeArray
        self.transferTimeArray2 = "back2".transferTimeArray
    }
    
    // MARK: - Route Management
    // Updates 
    func setGoOrBack() {
        goOrBack1 = isBack.goOrBack1
        goOrBack2 = isBack.goOrBack2
    }

    // Updates route visibility settings from UserDefaults
    func setRoute2() {
        isShowBackRoute2 = "back2".isShowRoute2
        isShowGoRoute2 = "go2".isShowRoute2
    }
    
    // Updates line change settings based on current direction
    func setLineData() {
        home = goOrBack1.departurePoint
        office = goOrBack1.destination
        changeLine1 = goOrBack1.changeLineInt
        changeLine2 = goOrBack2.changeLineInt
        stationArray1 = goOrBack1.stationArray
        stationArray2 = goOrBack2.stationArray
        lineNameArray1 = goOrBack1.lineNameArray
        lineNameArray2 = goOrBack2.lineNameArray
        lineColorArray1 = goOrBack1.lineColorArray
        lineColorArray2 = goOrBack2.lineColorArray
    }
    
    func setTransferData() {
        transportationArray1 = goOrBack1.transportationArray
        transportationArray2 = goOrBack2.transportationArray
        transferTimeArray1 = goOrBack1.transferTimeArray
        transferTimeArray2 = goOrBack2.transferTimeArray
    }
 
    // MARK: - UserDefaults Persistence
    // Save route visibility settings to UserDefaults
    func saveRoute2Settings() {
        UserDefaults.standard.set(isShowBackRoute2, forKey: "back2".isShowRoute2Key)
        UserDefaults.standard.set(isShowGoRoute2, forKey: "go2".isShowRoute2Key)
    }
    
    // Save line change settings to UserDefaults
    func saveChangeLineSettings() {
        UserDefaults.standard.set(changeLine1, forKey: goOrBack1.changeLineKey)
        UserDefaults.standard.set(changeLine2, forKey: goOrBack2.changeLineKey)
    }
    
    // MARK: - UserDefaults Data Update
    // Updates all data from UserDefaults when changes are detected
    func updateAllDataFromUserDefaults() {
        // Update route direction identifiers
        setGoOrBack()
        // Update route 2 visibility settings
        setRoute2()
        // Update line settings
        setLineData()
        // Update time
        timeLabel = Date().setTime
        // Force UI update by triggering objectWillChange
        objectWillChange.send()
    }
    
    // MARK: - Direction Control
    // Switches to return direction and updates line settings
    func backButton() {
        isBack = true
        updateAllDataFromUserDefaults()
    }
    
    // Switches to outbound direction and updates line settings
    func goButton() {
        isBack = false
        updateAllDataFromUserDefaults()
    }
    
    // MARK: - Timer Control
    // Starts real-time timer for updating date and time
    func startButton() {
        // Cancel existing timer before starting new one
        cancellable?.cancel()
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
    
    // MARK: - Timer State Management
    // Ensures timer is running when view appears
    func ensureTimerRunning() {
        // Always start timer when view appears, regardless of current state
        startButton()
    }
    
    // Stops timer when view disappears
    func stopTimerOnDisappear() {
        // Always stop timer when view disappears
        stopButton()
    }
    
    // MARK: - Computed Properties
    // Current date and time information
    var isWeekday: Bool { return dateLabel.dateFromDate.isWeekday }
    var currentTime: Int { return timeLabel.currentTime }
    
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

