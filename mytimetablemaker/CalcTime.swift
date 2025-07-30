//
//  Timetable.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/27.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

struct CalcTime: Calculation {
    var goorback: String
    var weekflag: Bool
    var changeline: Int
    init(_ goorback: String, _ weekflag: Bool, _ changeline: Int) {
        self.goorback = goorback
        self.weekflag = weekflag
        self.changeline = changeline
    }
}

extension CalcTime {
    
    //UserDefaultに保存された時刻表の時刻の表示を取得
    func timetableTime(_ keytag: String, _ hour: Int) -> String {
        let weektag = (weekflag) ? "weekday": "weekend"
        let key = "\(goorback)line\(keytag)\(weektag)\(String(hour))"
        return key.userDefaultValue("")
    }
    
    //時刻表データを取得
    func timetable(_ keytag: String) -> [Int] {
        var timetable: [Int] = []
        for hour in 4...25 {
            let timetext = String(timetableTime(keytag, hour).dropFirst(1))
            if (timetext != "") {
                timetable.append(contentsOf: timetext.timeGetting(charactersin: " ", hour: hour))
            }
        }
        return timetable
    }
    
    //時刻表データの配列を取得
    var timetableArray: [[Int]] {
        var timetablearray: [[Int]] = []
        for i in 0...changeline {
            timetablearray.append(self.timetable(String(i + 1)))
        }
        return timetablearray
    }
    
    //乗換時間の配列を取得
    var transitTimeArray: [Int]{
        var transittimearray: [Int] = []
        for i in 0...changeline + 1 {
            let transittime = (i == changeline + 1) ? (goorback.transitTime("e")): goorback.transitTime(String(i + 1))
            transittimearray.append(transittime)
        }
        return transittimearray
    }
    
    //乗車時間の配列を取得
    var rideTimeArray: [Int]{
        var ridetimearray: [Int] = []
        for i in 0...changeline {
            ridetimearray.append(goorback.rideTime(String(i + 1)))
        }
        return ridetimearray
    }
    
    //
    func nextStartTime(_ possibletime: Int, _ i: Int) -> Int {
        var nextstarttime: Int
        for j in 0..<timetableArray[i].count {
            nextstarttime = timetableArray[i][j]
            if (possibletime < nextstarttime) {
                return nextstarttime
            }
        }
        nextstarttime = 2700
        return nextstarttime
    }
    
    //出発時刻を取得する
    func departureTime(_ currenttime: Int) -> Int {
        let possibletime = (currenttime/100).plusHHMM(transitTimeArray[0])
        let nextstarttime = nextStartTime(possibletime, 0)
        return nextstarttime.minusHHMM(transitTimeArray[0])
    }
    
    //ルート内の各路線の乗車可能時刻[0]・発車時刻[1]・到着時刻[2]を取得
    func timeArray(_ currenttime: Int) -> [[Int]] {
        var timearrays: [[Int]] = [[]]
        //路線1の乗車可能時刻・発車時刻・到着時刻を取得
        timearrays[0].append((currenttime/100).plusHHMM(transitTimeArray[0]))
        timearrays[0].append(nextStartTime(timearrays[0][0], 0))
        timearrays[0].append(timearrays[0][1].plusHHMM(rideTimeArray[0]))
        //路線1以降の乗車可能時刻・発車時刻・到着時刻を取得
        if (changeline > 0) {
            for i in 1...changeline {
                timearrays.append([])
                timearrays[i].append(timearrays[i - 1][2].plusHHMM(transitTimeArray[i]))
                timearrays[i].append(nextStartTime(timearrays[i][0], i))
                timearrays[i].append(timearrays[i][1].plusHHMM(rideTimeArray[i]))
            }
        }
        return timearrays
    }
    
    //
    func displayTimeArray(_ currenttime: Int) -> [String] {
        let timearray = timeArray(currenttime)
        var displaytimearray: [String] = []
        //乗車可能時刻・発車時刻・到着時刻を取得
        displaytimearray.append(timearray[changeline][2].plusHHMM(transitTimeArray[changeline + 1]).stringTime)
        displaytimearray.append(timearray[0][1].minusHHMM(transitTimeArray[0]).stringTime)
        for i in 0...changeline {
            displaytimearray.append(timearray[i][1].stringTime)
            displaytimearray.append(timearray[i][2].stringTime)
        }
        return displaytimearray
    }
}
