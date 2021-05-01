//
//  CalcTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2020/12/27.
//

import SwiftUI

extension Bool {
    
    //UserDefaultに保存された時刻表の時刻の表示を取得
    private func timetableTime(_ goorback: String, _ linenumber: String, _ hour: Int) -> String {
        let weektag = (self) ? "weekday": "weekend"
        let key = "\(goorback)line\(linenumber)\(weektag)\(hour.addZeroTime)"
        return key.userDefaultsValue("")
    }
    
    //時刻表データを取得
    private func timetable(_ goorback: String, _ linenumber: String) -> [Int] {
        var timetable: [Int] = []
        for hour in 4...25 {
            let temptext = timetableTime(goorback, linenumber, hour)
            let timetext = (temptext.prefix(1) == " ") ? String(temptext.suffix(temptext.count - 1)): temptext
            if (timetext != "") {
                let timearray = Array(Set(timetext.components(separatedBy: CharacterSet(charactersIn: " "))
                                        .map{(Int($0)! + hour * 100)}
                                        .filter{$0 < 2700}
                                        .filter{$0 > -1}
                            )).sorted()
                timetable.append(contentsOf: timearray)
            }
        }
        return timetable
    }

    //時刻表データの配列を取得
    private func timetableArray(_ goorback: String) -> [[Int]] {
        var timetablearray: [[Int]] = []
        for i in 0...goorback.changeLineInt {
            timetablearray.append(timetable(goorback, String(i + 1)))
        }
        return timetablearray
    }

    //乗換時間の配列を取得
    private func transitTimeArray(_ goorback: String) -> [Int]{
        var transittimearray: [Int] = []
        for i in 0...goorback.changeLineInt + 1 {
            let transittime = (i == goorback.changeLineInt + 1) ? (goorback.transitTime(0)): goorback.transitTime(i)
            transittimearray.append(transittime)
        }
        return transittimearray
    }

    //乗車時間の配列を取得
    private func rideTimeArray(_ goorback: String) -> [Int]{
        var ridetimearray: [Int] = []
        let changeline = goorback.changeLineInt
        for i in 0...changeline {
            ridetimearray.append(goorback.rideTime(i))
        }
        return ridetimearray
    }

    //
    private func nextStartTime(_ goorback: String, _ possibletime: Int, _ i: Int) -> Int {
        var nextstarttime: Int
        for j in 0..<timetableArray(goorback)[i].count {
            nextstarttime = timetableArray(goorback)[i][j]
            if (possibletime < nextstarttime) {
                return nextstarttime
            }
        }
        nextstarttime = 2700
        return nextstarttime
    }

    //出発時刻を取得する
    func departureTime(_ goorback: String, _ currenttime: Int) -> Int {
        let possibletime = (currenttime/100).plusHHMM(transitTimeArray(goorback)[0])
        let nextstarttime = nextStartTime(goorback, possibletime, 0)
        return nextstarttime.minusHHMM(transitTimeArray(goorback)[0])
    }

    //ルート内の各路線の乗車可能時刻[0]・発車時刻[1]・到着時刻[2]を取得
    private func timeArray(_ goorback: String, _ currenttime: Int) -> [[Int]] {
        var timearrays: [[Int]] = [[]]
        let changeline = goorback.changeLineInt
        //路線1の乗車可能時刻・発車時刻・到着時刻を取得
        timearrays[0].append((currenttime/100).plusHHMM(transitTimeArray(goorback)[0]))
        timearrays[0].append(nextStartTime(goorback, timearrays[0][0], 0))
        timearrays[0].append(timearrays[0][1].plusHHMM(rideTimeArray(goorback)[0]))
        //路線1以降の乗車可能時刻・発車時刻・到着時刻を取得
        if (changeline > 0) {
            for i in 1...changeline {
                timearrays.append([])
                timearrays[i].append(timearrays[i - 1][2].plusHHMM(transitTimeArray(goorback)[i]))
                timearrays[i].append(nextStartTime(goorback, timearrays[i][0], i))
                timearrays[i].append(timearrays[i][1].plusHHMM(rideTimeArray(goorback)[i]))
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
    func displayTimeArray(_ goorback: String, _ currenttime: Int) -> [String] {
        let timearray = timeArray(goorback, currenttime)
        let changeline = goorback.changeLineInt
        let departtime = timearray[0][1].minusHHMM(transitTimeArray(goorback)[0])
        let arrivetime = timearray[changeline][2].plusHHMM(transitTimeArray(goorback)[changeline + 1])
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
