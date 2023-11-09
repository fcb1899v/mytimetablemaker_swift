//
//  MainViewModel.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/02/08.
//

import Foundation
import Combine
import SwiftUI

class MyTransit: ObservableObject {
    
    private var cancellable: AnyCancellable?
    
    @Published var selectDate: Date
    @Published var dateLabel: String
    @Published var timeLabel: String
    @Published var isTimeStop: Bool
    @Published var isBack: Bool
    
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
    
    func setRoute2() {
        isShowBackRoute2 = "back2".isShowRoute2
        isShowGoRoute2 = "go2".isShowRoute2
    }
    
    func setChangeLine() {
        changeLine1 = isBack.goOrBack1.changeLineInt
        changeLine2 = isBack.goOrBack2.changeLineInt
    }
    
    func backButton() {
        isBack = true
        setChangeLine()
    }
    
    func goButton() {
        isBack = false
        setChangeLine()
    }
    
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
    
    func stopButton() {
        isTimeStop = true
        cancellable?.cancel()
    }
    
    var isWeekday: Bool { return dateLabel.dateFromDate.isWeekday }
    var currentTime: Int { return timeLabel.currentTime }
    var goOrBack1: String { return isBack.goOrBack1 }
    var goOrBack2: String { return isBack.goOrBack2 }
    var isShowRoute2: Bool { return isBack ? isShowBackRoute2: isShowGoRoute2 }
    var routeWidth: CGFloat { return isShowRoute2.routeWidth }
    var timetableArray1: [[Int]] { return goOrBack1.timetableArray(isWeekday) }
    var timetableArray2: [[Int]] { return goOrBack2.timetableArray(isWeekday) }
    var timeArray1: [Int] { return goOrBack1.timeArray(isWeekday, currentTime) }
    var timeArray2: [Int] { return goOrBack2.timeArray(isWeekday, currentTime) }
    var timeArrayString1: [String] { return timeArray1.map { $0.stringTime } }
    var timeArrayString2: [String] { return timeArray2.map { $0.stringTime } }
    var countdownTime1: String { return currentTime.countdownTime(timeArray1[1]) }
    var countdownTime2: String { return currentTime.countdownTime(timeArray2[1]) }
    var countdownColor1: Color { return currentTime.countdownColor(timeArray1[1]) }
    var countdownColor2: Color { return currentTime.countdownColor(timeArray2[1]) }
}

