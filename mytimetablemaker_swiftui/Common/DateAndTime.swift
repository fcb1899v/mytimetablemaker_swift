//
//  DateAndTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2020/12/27.
//

import SwiftUI

//＜時刻の変換＞
extension Int {
    //Int型時刻HHMMをMMに変換する関数
    var HHMMtoMM: Int {
        return self / 100 * 60 + self % 100
    }
    //Int型時刻MMをHHMMに変換する関数
    var MMtoHHMM: Int {
        return self / 60 * 100 + self % 60
    }
    //Int型時刻MMSSをSSに変換する関数
    var MMSStoSS: Int {
        return self / 100 * 60 + self % 100
    }
    //Int型時刻SSをMMSSに変換する関数
    var SStoMMSS: Int {
        return self / 60 * 100 + self % 60
    }
    //Int型時刻HHMMSSをSSに変換する関数
    var HHMMSStoSS: Int {
        return self / 10000 * 3600 + (self % 10000) / 100 * 60 + self % 100
    }
    //Int型時刻SSをHHMMSSに変換する関数
    var SStoHHMMSS: Int {
        return self / 3600 * 10000 + (self % 3600) / 60 * 100 + self % 60
    }
    //Int型時刻HHMMSSをMMSSに変換する関数
    var HHMMSStoMMSS: Int {
        return (self / 10000 * 60 + (self % 10000) / 100) * 100 + self % 100
    }
    //Int型時刻MMSSをHHMMSSに変換する関数
    var MMSStoHHMMSS: Int {
        return (self / 100 / 60) * 10000 + (self / 100 % 60) * 100 + self % 100
    }

    //Int型時刻HHMMの足し算
    func plusHHMM(_ time: Int) -> Int {
        return (self.HHMMtoMM + time.HHMMtoMM).MMtoHHMM
    }
    //Int型時刻HHMMSSの足し算
    func plusHHMMSS(_ time: Int) -> Int {
        return (self.HHMMSStoSS + time.HHMMSStoSS).SStoHHMMSS
    }
    //Int型時刻MMSSの足し算
    func plusMMSS(_ time: Int) -> Int {
        return (self.MMSStoSS + time.MMSStoSS).SStoMMSS
    }
    //Int型時刻HHMMの引き算をする関数
    func minusHHMM(_ time: Int) -> Int {
        return (self.HHMMtoMM < time.HHMMtoMM) ?
            ((self + 2400).HHMMtoMM - time.HHMMtoMM).MMtoHHMM:
            (self.HHMMtoMM - time.HHMMtoMM).MMtoHHMM
    }
    //Int型時刻HHMMSSの引き算をする関数
    func minusHHMMSS(_ time: Int) -> Int {
        return (self.HHMMSStoSS < time.HHMMSStoSS) ?
            ((self + 240000).HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS:
            (self.HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS
    }
    //Int型時刻HHMMの引き算をする関数
    func minusMMSS(_ time: Int) -> Int {
        return (self.MMSStoSS - time.MMSStoSS).SStoMMSS
    }

    //1桁のときに0を追加
    var addZeroTime: String {
        return (0...9 ~= self) ? "0" + String(self): String(self)
    }
    
    //Int型時刻HHMMから表示時刻に変換
    var stringTime: String {
        let stringtimehh = (self / 100 + (self % 100) / 60).addZeroTime
        let stringtimemm = (self % 100 % 60).addZeroTime
        let stringtime = stringtimehh + ":" + stringtimemm
        if (stringtime != "27:00") {
            return stringtimehh + ":" + stringtimemm
        } else {
            return "--:--"
        }
    }
    
    //Int型時刻MMSSからカウントダウンに変換
    var countdown: String{
        var intcountdowntime = self
        switch (self) {
            case 0...9999: break
            default: intcountdowntime = -1000000
        }
        let countdownmm: String = (intcountdowntime / 100).addZeroTime
        let countdownss: String = (intcountdowntime % 100).addZeroTime
        if (intcountdowntime == -1000000) {
            return "--:--"
        } else {
            return countdownmm + ":" + countdownss
        }
    }
    
    //カウントダウン時間（mm:ss）を取得
    func countdownTime(_ departtime: Int) -> String {
        //カウントダウン（出発時刻と現在時刻の差）を計算
        return (departtime * 100).minusHHMMSS(self).HHMMSStoMMSS.countdown
    }
    
    //カウントダウン表示の警告色を取得
    func countdownColor(_ departtime:Int) -> Color{
        return (departtime * 100).minusHHMMSS(self).HHMMSStoMMSS.countdownColor
    }
    
    //
    var countdownColor: Color {
        if (self % 2 == 0) {
            switch (self) {
            case 1000...9999: return Color.myaccent
            case 500...999: return Color.myyellow
                case 0...499: return Color.myred
                default: return Color.mygray
            }
        } else {
            return Color.mygray
        }
    }

    //曜日の変換
    var weekDayOrEnd: String {
        return (self == 0 || self == 6) ? "weekend".localized: "weekday".localized
    }

    //曜日の変換
    var weekDayOrEndFlag: Bool {
        return (self == 0 || self == 6) ? false: true
    }
}

//Date型の変換
extension Date {

    //現在日付を表示
    var setDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Unit.customdate.rawValue.localized
        return formatter.string(from: self)
    }

    //現在時刻を表示
    var setTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Unit.customHHmmss.rawValue.localized
        return formatter.string(from: self)
    }
    
    var weekFlag: Bool {
        let weeknumber = Calendar.current.component(.weekday, from: self)
        return (weeknumber == 0 || weeknumber == 6) ? false: true
    }
}
