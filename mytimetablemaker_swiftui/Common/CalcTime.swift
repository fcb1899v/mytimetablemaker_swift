//
//  CalcTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2020/12/27.
//

import SwiftUI

struct CalcTime: Calculation{
    
    let goorback: String
    let weekflag: Bool
    
    init(
        _ goorback: String,
        _ weekflag: Bool
    ){
        self.goorback = goorback
        self.weekflag = weekflag
    }
    
    //時刻表データの配列を取得
    var timetableArray: [[Int]] {
        var timetablearray: [[Int]] = []
        for num in 0...goorback.changeLineInt {
            timetablearray.append(Timetable(goorback, weekflag, num).timetable)
        }
        return timetablearray
    }

    //
    private func nextStartTime(_ possibletime: Int, _ i: Int) -> Int {
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
        let possibletime = (currenttime/100).plusHHMM(goorback.transitTimeArray[0])
        let nextstarttime = nextStartTime(possibletime, 0)
        return nextstarttime.minusHHMM(goorback.transitTimeArray[0])
    }

    //ルート内の各路線の乗車可能時刻[0]・発車時刻[1]・到着時刻[2]を取得
    private func timeArray(_ currenttime: Int) -> [[Int]] {
        var timearrays: [[Int]] = [[]]
        let changeline = goorback.changeLineInt
        //路線1の乗車可能時刻・発車時刻・到着時刻を取得
        timearrays[0].append((currenttime/100).plusHHMM(goorback.transitTimeArray[0]))
        timearrays[0].append(nextStartTime(timearrays[0][0], 0))
        timearrays[0].append(timearrays[0][1].plusHHMM(goorback.rideTimeArray[0]))
        //路線1以降の乗車可能時刻・発車時刻・到着時刻を取得
        if (changeline > 0) {
            for i in 1...changeline {
                timearrays.append([])
                timearrays[i].append(timearrays[i - 1][2].plusHHMM(goorback.transitTimeArray[i]))
                timearrays[i].append(nextStartTime(timearrays[i][0], i))
                timearrays[i].append(timearrays[i][1].plusHHMM(goorback.rideTimeArray[i]))
            }
        }
        for j in 0...changeline {
            if timearrays[j][1] == 2700 {
                timearrays[j][2] = 2700
            }
        }
        return timearrays
    }

    //
    func displayTimeArray(_ currenttime: Int) -> [String] {
        let timearray = timeArray(currenttime)
        let changeline = goorback.changeLineInt
        let departtime = timearray[0][1].minusHHMM(goorback.transitTimeArray[0])
        let arrivetime = timearray[changeline][2].plusHHMM(goorback.transitTimeArray[changeline + 1])
        var displaytimearray: [String] = []
        
        //乗車可能時刻・発車時刻・到着時刻を取得
        displaytimearray.append(((timearray[changeline][2] != 2700) ? arrivetime: 2700).stringTime)
        displaytimearray.append(((timearray[0][1] != 2700) ? departtime: 2700).stringTime)
        for i in 0...changeline {
            displaytimearray.append(timearray[i][1].stringTime)
            displaytimearray.append(timearray[i][2].stringTime)
        }
        return displaytimearray
    }
}
