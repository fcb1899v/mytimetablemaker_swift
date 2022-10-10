//
//  MainViewModel.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/02/08.
//

import Foundation
import SwiftUI

class MyTransit: ObservableObject {
    
    @Published var selectDate = Date()
    @Published var dateLabel = "\(Date().setDate)"
    @Published var timeLabel = "\(Date().setTime)"
    @Published var isTimeStop = false
    @Published var isBack = true
    
    @Published var isShowBackRoute2: Bool {
        didSet {
            UserDefaults.standard.set(isShowBackRoute2, forKey: "backRoute2")
        }
    }
    @Published var isShowGoRoute2: Bool {
        didSet {
            UserDefaults.standard.set(isShowGoRoute2, forKey: "backRoute2")
        }
    }

    init() {
        self.isShowBackRoute2 = UserDefaults.standard.bool(forKey: "backRoute2")
        self.isShowGoRoute2 = UserDefaults.standard.bool(forKey: "goRoute2")
    }
    
    let customHHmmss = Unit.customHHmmss.rawValue
    let customHHmm = Unit.customHHmm.rawValue

    func backButtonChangeData() {
        isBack = true
    }

    func goButtonChangeData() {
        isBack = false
    }

    func startButtonChangeData() {
        updateDateLabels()
        isTimeStop = false
    }

    func stopButtonChangeData() {
        isTimeStop = true
    }
    
    func updateDateLabels() {
        let date = Date()
        dateLabel = date.setDate
        timeLabel = date.setTime
    }
    
    var goOrBack1: String {
        return isBack ? "back1": "go1"
    }
    
    var goOrBack2: String {
        return isBack ? "back2": "go2"
    }

    var isShowRoute2: Bool {
        return isBack ? isShowBackRoute2: isShowGoRoute2
    }
    
    var routeWidth: CGFloat {
        return isShowRoute2.routeWidth
    }
    
    var isWeekday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        switch (formatter.string(from: dateFromDate)) {
            case "Sat", "Sun", "土", "日": return false
            default: return true
        }
    }
    
    //表示されている時刻を取得する関数
    var currentTime: Int {
        let timeHH = Int(timeLabel.components(separatedBy: ":")[0]) ?? 0
        let timemm = Int(timeLabel.components(separatedBy: ":")[1]) ?? 0
        let timess = Int(timeLabel.components(separatedBy: ":")[2]) ?? 0
        return timeHH * 10000 + timemm * 100 + timess
    }

    //表示されている日付を取得する関数
    var dateFromDate: Date {
        let customdate = Unit.customdate.rawValue.localized
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = customdate
        return formatter.date(from: dateLabel)!
    }
}

