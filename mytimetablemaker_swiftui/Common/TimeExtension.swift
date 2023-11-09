//
//  DateAndTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2020/12/27.
//

import SwiftUI

//＜時刻の変換＞
extension Int {
    
    var HHMMtoMM: Int { return self / 100 * 60 + self % 100 }   //Int型時刻HHMMをMMに変換する関数
    var MMtoHHMM: Int { return self / 60 * 100 + self % 60 }    //Int型時刻MMをHHMMに変換する関数
    var MMSStoSS: Int { return self / 100 * 60 + self % 100 }   //Int型時刻MMSSをSSに変換する関数
    var SStoMMSS: Int { return self / 60 * 100 + self % 60 }    //Int型時刻SSをMMSSに変換する関数
    var HHMMSStoSS: Int { return self / 10000 * 3600 + (self % 10000) / 100 * 60 + self % 100 }         //Int型時刻HHMMSSをSSに変換する関数
    var SStoHHMMSS: Int { return self / 3600 * 10000 + (self % 3600) / 60 * 100 + self % 60 }           //Int型時刻SSをHHMMSSに変換する関数
    var HHMMSStoMMSS: Int { return (self / 10000 * 60 + (self % 10000) / 100) * 100 + self % 100 }      //Int型時刻HHMMSSをMMSSに変換する関数
    var MMSStoHHMMSS: Int { return (self / 100 / 60) * 10000 + (self / 100 % 60) * 100 + self % 100 }   //Int型時刻MMSSをHHMMSSに変換する関数
    
    func plusHHMM(_ time: Int) -> Int { return (HHMMtoMM + time.HHMMtoMM).MMtoHHMM }            //Int型時刻HHMMの足し算
    func plusHHMMSS(_ time: Int) -> Int { return (HHMMSStoSS + time.HHMMSStoSS).SStoHHMMSS }    //Int型時刻HHMMSSの足し算
    func plusMMSS(_ time: Int) -> Int { return (MMSStoSS + time.MMSStoSS).SStoMMSS }            //Int型時刻MMSSの足し算
    
    func minusHHMM(_ time: Int) -> Int { return (HHMMtoMM < time.HHMMtoMM) ?                    //Int型時刻HHMMの引き算をする関数
        ((self + 2400).HHMMtoMM - time.HHMMtoMM).MMtoHHMM:
        (HHMMtoMM - time.HHMMtoMM).MMtoHHMM }
    func minusHHMMSS(_ time: Int) -> Int { return (self.HHMMSStoSS < time.HHMMSStoSS) ?         //Int型時刻HHMMSSの引き算をする関数
        ((self + 240000).HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS:
        (HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS }
    func minusMMSS(_ time: Int) -> Int { return (self.MMSStoSS - time.MMSStoSS).SStoMMSS }      //Int型時刻HHMMの引き算をする関数
    
    var addZeroTime: String { return (0...9 ~= self) ? "0\(self)": "\(self)" }                              //1桁のときに0を追加
    func overTime(_ beforeTime: Int) -> Int { return (beforeTime == 2700) ? 2700: (self > 2700) ? 2700: self }

    var timeHH: String { return (self / 100 + (self % 100) / 60).addZeroTime }
    var timeMM: String { return (self % 100 % 60).addZeroTime }
    var stringTime: String { return ("\(timeHH):\(timeMM)" != "27:00") ? "\(timeHH):\(timeMM)": "--:--" }   //Int型時刻HHMMから表示時刻に変換

    
    //Countdown
    var countdownMM: String { return (self / 100).addZeroTime }
    var countdownSS: String { return (self % 100).addZeroTime }
    var countdown: String{ return (0...9999 ~= self) ? "\(countdownMM):\(countdownSS)": "--:--" }           //Int型時刻MMSSからカウントダウンに変換
    func countdownTime(_ departtime: Int) -> String {
        return (departtime * 100).minusHHMMSS(self).HHMMSStoMMSS.countdown
    }

    //Weekday
    var isWeekend: Bool { return (self == 0 || self == 6) }
    var isWeekday: Bool { return !isWeekend }
}


//Date型の変換
extension Date {

    var setDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d, yyyy".localized
        return formatter.string(from: self)
    }

    var setTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
    
    var isWeekday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        switch (formatter.string(from: self)) {
            case "Sat", "Sun", "土", "日": return false
            default: return true
        }
    }
}

extension String {
    
    func intText(min: Int, max: Int) -> Int {
        let intText: Int = Int(self) ?? min - 1
        return (intText > min - 1 && intText < max + 1) ? intText: min - 1
    }
    
    var dateFromDate: Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "E, MMM d, yyyy".localized
        return formatter.date(from: self)!
    }

    //表示されている時刻を取得する関数
    var currentTime: Int {
        let timeHH = Int(self.components(separatedBy: ":")[0]) ?? 0
        let timemm = Int(self.components(separatedBy: ":")[1]) ?? 0
        let timess = Int(self.components(separatedBy: ":")[2]) ?? 0
        return timeHH * 10000 + timemm * 100 + timess
    }
    
    //self is timeText
    var timeString: String { return (self.prefix(1) == " ") ? String(self.suffix(self.count - 1)): self }
    func addInputTime(_ inputText: String) -> String { return (self != "") ? "\(self) \(inputText)": inputText}
    func timeSorting(charactersin: String) -> [String] {
        return Array(Set(self.components(separatedBy: CharacterSet(charactersIn: charactersin))
                .map{Int($0) ?? 60}
                .filter{$0 < 60}
                .filter{$0 > -1}
            ))
            .sorted()
            .map{String($0)}
    }

}

