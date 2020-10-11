//
//  Timetable.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/27.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class Timetable: NSObject {
 
    //時刻表のタイトルを取得する関数
    class func getTimetableTitle(goorback: String, keytag: String) -> String {
        let arrivestation = FileAndData.getArriveStation(
            goorback: goorback, keytag: keytag)
        let linename = FileAndData.getLinename(
            goorback: goorback, keytag: keytag)
        return "(" + linename + " for ".localized + arrivestation + "houmen".localized + ")"
    }
    
    //WEEKDAYとWEEKENDの表示を取得する
    class func setWeekButton(weeklabel: UILabel, weekbutton: UIButton, weekdaycolor: Int, weekendcolor: Int, weekflag: Bool) {
        if (weekflag) {
            weeklabel.text = "Weekday".localized
            weeklabel.textColor = UIColor(rgb: 0xFFFFFF)
            weekbutton.setTitle("WEEKEND".localized, for: UIControl.State.normal)
            weekbutton.setTitleColor(UIColor(rgb: weekendcolor), for: UIControl.State.normal)
        } else {
            weeklabel.text = "Weekend".localized
            weeklabel.textColor = UIColor(rgb: weekendcolor)
            weekbutton.setTitle("WEEKDAY".localized, for: UIControl.State.normal)
            weekbutton.setTitleColor(UIColor(rgb: weekdaycolor), for: UIControl.State.normal)
        }
    }

    //WEEKDAYとWEEKENDの切替ボタン
    class func getWeekButton(weeklabel: UILabel, weekbutton: UIButton, weekdaycolor: Int, weekendcolor: Int, weekflag: Bool) -> Bool{
        setWeekButton(
            weeklabel: weeklabel,
            weekbutton: weekbutton,
            weekdaycolor: weekdaycolor,
            weekendcolor: weekendcolor,
            weekflag: weekflag)
        return !weekflag
    }

    //時刻表の時刻の表示を取得する関数
    class func getTimetableTime(goorback: String, keytag: String, weekflag: Bool, timekeytag: String) -> String {
        let weektag = (weekflag) ? "weekday".localized: "weekend".localized
        let timekey = goorback + "line" + keytag + weektag + timekeytag
        return FileAndData.getUserDefaultValue(key: timekey, defaultvalue: "-")
    }

    //内部ストレージに保存された各時台の時刻表データを取得する関数
    class func getTimetableHour(goorback: String, keytag: String, weekflag: Bool, timekeytag: String) -> [Int] {
        let weektag = (!weekflag) ? "weekend".localized: "weekday".localized
        let timekey = goorback + "line" + keytag + weektag + timekeytag
        let splitunit = " "
        let timetext = FileAndData.getUserDefaultValue(key: timekey, defaultvalue: "")
        var timearray: [Int] = []
        if (timetext != "") {
            let timeset1 = Set(timetext.components(separatedBy: CharacterSet(charactersIn: splitunit)))
            let timeset2 = timeset1.map{(Int($0)! + Int(timekeytag)! * 100)}
            let timeset3 = timeset2.filter({$0 < 2560}).filter({$0 > -1})
            timearray = Array(timeset3).sorted()
        }
        return timearray
    }

    //内部ストレージに保存された全時台の時刻表データを取得する関数
    class func getTimetable(goorback: String, keytag: String, weekflag: Bool) -> [Int] {
        var timetable: [Int] = []
        for hour in 4...25 {
            let timekeytag = DateAndTime.addZeroTime(time: hour)
            timetable.append(contentsOf: getTimetableHour(
                                goorback: goorback, keytag: keytag, weekflag: weekflag, timekeytag: timekeytag))
        }
        return timetable
    }
    
    //時刻表の配列を取得する関数
    class func getTimetableArray(goorback: String, changeline: Int, weekflag: Bool) -> [[Int]]{
        var timetablearray: [[Int]] = []
        for i in 0...changeline {
           timetablearray.append(Timetable.getTimetable(goorback: goorback, keytag: String(i + 1), weekflag: weekflag))
        }
        return timetablearray
    }
}
