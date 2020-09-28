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
    
    //乗換時間の配列を取得する関数
    class func getTransitTimeArray(goorback: String, changeline: Int) -> [Int]{
        var transittimearray: [Int] = []
        for i in 0...changeline + 1 {
           let key = (i == changeline + 1) ? goorback + "transittimee": goorback + "transittime" + String(i)
            transittimearray.append(FileAndData.getUserDefaultInt(key: key, defaultvalue: 0)!)
        }
        return transittimearray
    }
    
    //乗車時間の配列を取得する関数
    class func getRideTimeArray(goorback: String, changeline: Int) -> [Int]{
        var ridetimearray: [Int] = []
        for i in 0...changeline {
           let key = goorback + "ridetime" + String(i)
           ridetimearray.append(FileAndData.getUserDefaultInt(key: key, defaultvalue: 0)!)
        }
        return ridetimearray
    }
    
    //ルート内の各路線の乗車可能時刻[0]・発車時刻[1]・到着時刻[2]を取得する関数
    class func getTimeArray(currenttime: Int, changeline: Int, walktime: [Int], ridetime: [Int], timelist: [[Int]]) -> [[Int]] {
        var timearrays: [[Int]] = [[]]
        //路線1の乗車可能時刻・発車時刻・到着時刻を取得
        timearrays[0][0] = getPlusHHMM(time1: currenttime, time2: walktime[0])
        timearrays[0][1] = getNextStartTime(possibletime: timearrays[0][0] , timelist: timelist[0])
        timearrays[0][2] = getPlusHHMM(time1: timearrays[0][1] , time2: ridetime[0])
        //路線1以降の乗車可能時刻・発車時刻・到着時刻を取得
        if (changeline > 0) {
            for i in 1...changeline {
                timearrays[i][0] = getPlusHHMM(time1: timearrays[i - 1][2] , time2: walktime[i])
                timearrays[i][1] = getNextStartTime(possibletime: timearrays[i][0] , timelist: timelist[i])
                timearrays[i][2] = getPlusHHMM(time1: timearrays[i][1] , time2: ridetime[i])
            }
        }
        return timearrays
    }

    //発車時刻を取得する関数
    class func getNextStartTime(possibletime: Int, timelist: [Int]) -> Int {
        var nextstarttime: Int
        var i = 0
        repeat {
            if (i >= timelist.count) {
                nextstarttime = timelist[0]
                return nextstarttime
            }
            nextstarttime = timelist[i]
            i += 1
        } while (possibletime > nextstarttime)
        return nextstarttime
    }

    //カウントダウン時間（mm:ss）を取得する関数
    class func getCountdownTime(currenthhmmss: Int, departtime: Int, flag: Bool) -> String {
        var countdowntime = "--:--"
        if (flag) {
            //カウントダウン（出発時刻と現在時刻の差）を計算
            var intcountdowntime =
                getHHMMSStoMMSS(time: getMinusHHMMSS(time1: departtime * 100, time2: currenthhmmss))
            switch (intcountdowntime) {
                case 0...9959: break
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
    class func getCountDownColor(currenthhmmss: Int, departtime:Int, currenthhmm: Int, timeflag: Bool) -> Int{
        var countdowncolor = 0x8E8E93
        if (timeflag) {
            let countdownmm = getMinusHHMM(time1: departtime, time2: currenthhmm)
            if (currenthhmmss % 2 == 0) {
                switch (countdownmm) {
                    case 11...99: countdowncolor = 0x03DAC5
                    case 6...10: countdowncolor = 0xFFFF00
                    case 0...5: countdowncolor = 0xFF0000
                    default: countdowncolor = 0x8E8E93
                }
            }
        }
        return countdowncolor
    }

    class func getCurrentDate(datebutton: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d, yyyy"
        datebutton.setTitle(formatter.string(from: Date()), for: UIControl.State.normal)
    }

    class func getCurrentTime(timebutton: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        timebutton.setTitle(formatter.string(from: Date()), for: UIControl.State.normal)
    }
    
    class func setButtonEnabled(button: UIButton, flag: Bool, color: UIColor) {
        button.isEnabled = flag
        button.setTitleColor(color, for: UIControl.State.normal)
    }
    
    class func setButtonCondition(flag: Bool, button1: UIButton, button2: UIButton, color1: UIColor, color2: UIColor) -> Bool{
        setButtonEnabled(button: button1, flag: !flag, color: color1)
        setButtonEnabled(button: button2, flag: flag, color: color2)
        return flag
    }
}
