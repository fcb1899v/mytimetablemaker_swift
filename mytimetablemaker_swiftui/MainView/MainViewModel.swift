//
//  MainViewModel.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/02/08.
//

import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    
    @Published var selectdate = Date()
    @Published var datelabel = "\(Date().setDate)"
    @Published var timelabel = "\(Date().setTime)"
    @Published var timeflag = true
    @Published var goorbackflag = true              //back:true
    @Published var goorback1 = "back1"
    @Published var goorback2 = "back2"
    
    @Published var linecolor1 = [
        "back1".lineColor("1", DefaultColor.accent.rawValue),
        "back1".lineColor("2", DefaultColor.accent.rawValue),
        "back1".lineColor("3", DefaultColor.accent.rawValue)
    ]
    @Published var linecolor2 = [
        "back2".lineColor("1", DefaultColor.accent.rawValue),
        "back2".lineColor("2", DefaultColor.accent.rawValue),
        "back2".lineColor("3", DefaultColor.accent.rawValue)
    ]
    
    let timer = Timer.publish(every: 0.4, on: .current, in: .common).autoconnect()
    let primary = Color(DefaultColor.primary.rawValue.colorInt)
    let accent = Color(DefaultColor.accent.rawValue.colorInt)
    let customdate = Unit.customdate.rawValue.localized
    let customHHmmss = Unit.customHHmmss.rawValue
    let customHHmm = Unit.customHHmm.rawValue

    func backButtonChangeData() {
        goorbackflag = true
        goorback1 = "back1"
        goorback2 = "back2"
        setLineColor()
    }

    func goButtonChangeData() {
        goorbackflag = false
        goorback1 = "go1"
        goorback2 = "go2"
        setLineColor()
    }

    func setLineColor() {
        linecolor1 = [
            goorback1.lineColor("1", DefaultColor.accent.rawValue),
            goorback1.lineColor("2", DefaultColor.accent.rawValue),
            goorback1.lineColor("3", DefaultColor.accent.rawValue)
        ]
        linecolor2 = [
            goorback2.lineColor("1", DefaultColor.accent.rawValue),
            goorback2.lineColor("2", DefaultColor.accent.rawValue),
            goorback2.lineColor("3", DefaultColor.accent.rawValue)
        ]
    }
    
    func startButtonChangeData() {
        datelabel = "\(Date().setDate)"
        timelabel = "\(Date().setTime)"
        timeflag = true
    }

    func stopButtonChangeData() {
        timeflag = false
    }
    
    var dateLabelView: some View {
        Text(datelabel)
            .font(Font.title3.monospacedDigit())
            .foregroundColor(Color.white)
    }
    
    var timeLabelView: some View {
        Text(timelabel)
            .font(Font.title2.monospacedDigit())
            .foregroundColor(Color.white)
    }
    
    var dateTextView: some View {
        dateLabelView
            .onReceive(timer) { (_) in
                self.selectdate = Date()
                self.datelabel = "\(Date().setDate)"
            }
    }
        
    var timeTextView: some View {
        timeLabelView
            .onReceive(timer) { (_) in
                self.selectdate = Date()
                self.timelabel = "\(Date().setTime)"
            }
    }

    //表示されている時刻を取得する関数
    var currentHHmmssFromTime: Int {
        let timeHH = Int(timelabel.components(separatedBy: ":")[0]) ?? 0
        let timemm = Int(timelabel.components(separatedBy: ":")[1]) ?? 0
        let timess = Int(timelabel.components(separatedBy: ":")[2]) ?? 0
        return timeHH * 10000 + timemm * 100 + timess
    }

    //表示されている日付を取得する関数
    var dateFromDate: Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = customdate
        return formatter.date(from: datelabel)!
    }
    
    var weekFlag: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        switch (formatter.string(from: dateFromDate)) {
            case "Sat", "Sun", "土", "日": return false
            default: return true
        }
    }
}
