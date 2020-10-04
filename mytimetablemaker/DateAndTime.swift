//
//  DateAndTime.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/08.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class DateAndTime: NSObject {
    
   //＜時刻の変換＞
    //Int型時刻HHMMをMMに変換する関数
    class func getHHMMtoMM(time: Int) -> Int {
        return time / 100 * 60 + time % 100
    }

    //Int型時刻MMをHHMMに変換する関数
    class func getMMtoHHMM(time: Int) -> Int {
        return time / 60 * 100 + time % 60
    }

    //Int型時刻MMSSをSSに変換する関数
    class func  getMMSStoSS(time: Int) -> Int {
        return time / 100 * 60 + time % 100
    }

    //Int型時刻SSをMMSSに変換する関数
    class func getSStoMMSS(time: Int) -> Int {
        return time / 60 * 100 + time % 60
    }

    //Int型時刻HHMMSSをSSに変換する関数
    class func getHHMMSStoSS(time: Int) -> Int {
        return time / 10000 * 3600 + (time % 10000) / 100 * 60 + time % 100
    }

    //Int型時刻SSをHHMMSSに変換する関数
    class func getSStoHHMMSS(time: Int) -> Int {
        return time / 3600 * 10000 + (time % 3600) / 60 * 100 + time % 60
    }

    //Int型時刻HHMMSSをMMSSに変換する関数
    class func getHHMMSStoMMSS(time: Int) -> Int {
        return (time / 10000 * 60 + (time % 10000) / 100) * 100 + time % 100
    }

    //Int型時刻MMSSをHHMMSSに変換する関数
    class func getMMSStoHHMMSS(time: Int) -> Int {
        return (time / 100 / 60) * 10000 + (time / 100 % 60) * 100 + time % 100
    }

    //＜時刻の足し算＞
    //Int型時刻HHMMの足し算をする関数
    class func getPlusHHMM(time1: Int, time2: Int) -> Int {
        return getMMtoHHMM(time: getHHMMtoMM(time: time1) + getHHMMtoMM(time: time2))
    }

    //Int型時刻HHMMSSの足し算をする関数
    class func getPlusHHMMSS(time1: Int, time2: Int) -> Int {
        return getSStoHHMMSS(time: getHHMMSStoSS(time: time1) + getHHMMSStoSS(time: time2))
    }

    //Int型時刻MMSSの足し算をする関数
    class func getPlusMMSS(time1: Int, time2: Int) -> Int {
        return getSStoMMSS(time: getMMSStoSS(time: time1) + getMMSStoSS(time: time2))
    }

    //＜時刻の引き算＞
    //Int型時刻HHMMの引き算をする関数
    class func getMinusHHMM(time1: Int, time2: Int) -> Int {
        return (getHHMMtoMM(time: time1) < getHHMMtoMM(time: time2)) ?
            getMMtoHHMM(time: getHHMMtoMM(time: time1 + 2400) - getHHMMtoMM(time: time2)):
            getMMtoHHMM(time: getHHMMtoMM(time: time1) - getHHMMtoMM(time: time2))
    }

    //Int型時刻HHMMSSの引き算をする関数
    class func getMinusHHMMSS(time1: Int, time2: Int) -> Int {
        return (getHHMMSStoSS(time: time1) < getHHMMSStoSS(time: time2)) ?
            getSStoHHMMSS(time: getHHMMSStoSS(time: time1 + 240000) - getHHMMSStoSS(time: time2)):
            getSStoHHMMSS(time: getHHMMSStoSS(time: time1) - getHHMMSStoSS(time: time2))
    }

    //Int型時刻HHMMの引き算をする関数
    class func getMinusMMSS(time1: Int, time2: Int) -> Int {
        return getSStoMMSS(time: getMMSStoSS(time: time1) - getMMSStoSS(time: time2))
    }

    //＜時刻の表示＞
    //現在日付を表示する関数
    class func setCurrentDate(datebutton: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d, yyyy".localized
        datebutton.setTitle(formatter.string(from: Date()), for: UIControl.State.normal)
    }

    //現在時刻を表示する関数
    class func setCurrentTime(timebutton: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        timebutton.setTitle(formatter.string(from: Date()), for: UIControl.State.normal)
    }
    
    //表示されている時刻を取得する関数
    class func getCurrentHHmmssFromTimeButton(timebutton: UIButton, timeflag: Bool) -> Int {
        return getCurrentHHFromTimeButton(timebutton: timebutton, timeflag: timeflag) * 10000 +
            getCurrentmmFromTimeButton(timebutton: timebutton, timeflag: timeflag) * 100 +
            getCurrentssFromTimeButton(timebutton: timebutton, timeflag: timeflag)
    }

    //表示されている「時」を取得する関数
    class func getCurrentHHFromTimeButton(timebutton: UIButton, timeflag: Bool) -> Int {
        if (timeflag) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH"
            return Int(formatter.string(from: Date())) ?? 0
        } else {
            let time = timebutton.title(for: UIControl.State.normal)
            return Int(time!.prefix(2)) ?? 0
        }
    }

    //表示されている「分」を取得する関数
    class func getCurrentmmFromTimeButton(timebutton: UIButton, timeflag: Bool) -> Int {
        if (timeflag) {
            let formatter = DateFormatter()
            formatter.dateFormat = "mm"
            return Int(formatter.string(from: Date())) ?? 0
        } else {
            let time = timebutton.title(for: UIControl.State.normal)
            return Int(time!.suffix(2)) ?? 0
        }
    }

    //表示されている「秒」を取得する関数
    class func getCurrentssFromTimeButton(timebutton: UIButton, timeflag: Bool) -> Int {
        if (timeflag) {
            let formatter = DateFormatter()
            formatter.dateFormat = "ss"
            return Int(formatter.string(from: Date())) ?? 0
        } else {
            return  0
        }
    }

    //表示されている日付を取得する関数
    class func getDateFromDateButton(datebutton: UIButton) -> Date {
        let stringdate = datebutton.title(for: UIControl.State.normal)
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "E, MMM d, yyyy".localized
        return formatter.date(from: stringdate!)!
    }
    
    //表示されている日付から平日と土日を表すフラグを取得する関数
    class func getWeekFlagFromDateButton(datebutton: UIButton) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        switch (formatter.string(from: getDateFromDateButton(datebutton: datebutton))) {
            case "Sat", "Sun", "土", "日": return false
            default: return true
        }
    }

    //平日と土日を表すフラグを取得する関数
    class func getWeekFlag() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        switch (formatter.string(from: Date())) {
            case "Sat", "Sun", "土", "日": return false
            default: return true
        }
    }

    //1桁のときに0を追加する関数
    class func addZeroTime(time: Int) -> String {
        return (0...9 ~= time) ? "0" + String(time): String(time)
    }

    //Int型時刻HHMMから表示時刻に変換する関数
    class func getStringTime(time: Int) -> String {
        let stringtimehh = addZeroTime(time: time / 100 + (time % 100) / 60)
        let stringtimemm = addZeroTime(time: time % 100 % 60)
        return stringtimehh + ":" + stringtimemm
    }
    
    //ボタンの表示変更
    class func setButtonEnabled(flag: Bool, button: UIButton, color: Int) {
        button.isEnabled = flag
        button.setTitleColor(UIColor(rgb: color), for: UIControl.State.normal)
    }

    //ボタンの表示変更
    class func changeButtonEnabled(flag: Bool, button: UIButton, color1: Int, color2: Int) {
        button.isEnabled = flag
        let color = (flag) ? color1: color2
        button.setTitleColor(UIColor(rgb: color), for: UIControl.State.normal)
    }

    
    //乗換時間の配列を取得する関数
    class func getTransitTimeArray(goorback: String, changeline: Int) -> [Int]{
        var transittimearray: [Int] = []
        for i in 0...changeline + 1 {
           let key = (i == changeline + 1) ? goorback + "transittimee": goorback + "transittime" + String(i + 1)
            transittimearray.append(FileAndData.getUserDefaultInt(key: key, defaultvalue: 0)!)
        }
        return transittimearray
    }
    
    //乗車時間を取得する関数
    class func getRideTime(goorback: String, changeline: Int, keytag: String) -> Int {
        let key = goorback + "ridetime" + keytag
        return FileAndData.getUserDefaultInt(key: key, defaultvalue: 0)!
    }
    
    //乗車時間の配列を取得する関数
    class func getRideTimeArray(goorback: String, changeline: Int) -> [Int]{
        var ridetimearray: [Int] = []
        for i in 0...changeline {
            ridetimearray.append(getRideTime(goorback: goorback, changeline: changeline, keytag: String(i + 1)))
        }
        return ridetimearray
    }
    
    //ルート内の各路線の乗車可能時刻[0]・発車時刻[1]・到着時刻[2]を取得する関数
    class func getTimeArray(currenttime: Int, changeline: Int, transittime: [Int], ridetime: [Int], timetable: [[Int]]) -> [[Int]] {
        var timearrays: [[Int]] = [[]]
        //路線1の乗車可能時刻・発車時刻・到着時刻を取得
        timearrays[0].append(getPlusHHMM(time1: currenttime/100, time2: transittime[0]))
        timearrays[0].append(getNextStartTime(possibletime: timearrays[0][0] , timetable: timetable[0]))
        timearrays[0].append(getPlusHHMM(time1: timearrays[0][1] , time2: ridetime[0]))
        //路線1以降の乗車可能時刻・発車時刻・到着時刻を取得
        if (changeline > 0) {
            for i in 1...changeline {
                timearrays.append([])
                timearrays[i].append(getPlusHHMM(time1: timearrays[i - 1][2] , time2: transittime[i]))
                timearrays[i].append(getNextStartTime(possibletime: timearrays[i][0] , timetable: timetable[i]))
                timearrays[i].append(getPlusHHMM(time1: timearrays[i][1] , time2: ridetime[i]))
            }
        }
        return timearrays
    }

    //発車時刻を取得する関数
    class func getNextStartTime(possibletime: Int, timetable: [Int]) -> Int {
        var nextstarttime: Int
        for i in 0..<timetable.count {
            nextstarttime = timetable[i]
            if (possibletime < nextstarttime) {
                return nextstarttime
            }
        }
        nextstarttime = 2700
        return nextstarttime
    }

    //カウントダウン時間（mm:ss）を取得する関数
    class func getCountdownTime(currenthhmmss: Int, departtime: Int, timeflag: Bool) -> String {
        var countdowntime = "--:--"
        if (timeflag) {
            //カウントダウン（出発時刻と現在時刻の差）を計算
            var intcountdowntime =
                getHHMMSStoMMSS(time: getMinusHHMMSS(time1: departtime * 100, time2: currenthhmmss))
            switch (intcountdowntime) {
                case 1...9959: break
                case -59...0: intcountdowntime = 0
                default: intcountdowntime = -100
            }
            let countdownmm: String = addZeroTime(time: intcountdowntime / 100)
            let countdownss: String = addZeroTime(time: intcountdowntime % 100)
            if (intcountdowntime == -100) { return "--:--" }
            countdowntime = countdownmm + ":" + countdownss
        }
        return countdowntime
    }

    //カウントダウン表示の警告色を取得する関数
    class func getCountDownColor(currenthhmmss: Int, departtime:Int, timeflag: Bool) -> UIColor{
        var countdowncolor = 0x8E8E93
        if (timeflag) {
            let intcountdown = getMinusHHMMSS(time1: departtime * 100, time2: currenthhmmss)
            if (intcountdown % 2 == 0) {
                switch (intcountdown) {
                    case 1000...9999: countdowncolor = 0x03DAC5
                    case 500...999: countdowncolor = 0xFFFF00
                    case -59...499: countdowncolor = 0xFF0000
                    default: countdowncolor = 0x8E8E93
                }
            }
        }
        return UIColor(rgb: countdowncolor)
    }
}
