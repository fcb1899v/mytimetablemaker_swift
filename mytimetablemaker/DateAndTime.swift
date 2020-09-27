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

    class func setWeekButton(weekbutton: UIButton, weekdaycolor: UIColor, weekendcolor: UIColor, weekflag: Bool) -> Bool{
        if (weekflag) {
            weekbutton.setTitle("WEEKDAY", for: UIControl.State.normal)
            weekbutton.setTitleColor(weekdaycolor, for: UIControl.State.normal)
            return false
        } else {
            weekbutton.setTitle("WEEKEND", for: UIControl.State.normal)
            weekbutton.setTitleColor(weekendcolor, for: UIControl.State.normal)
            return true
        }
    }
    

}
