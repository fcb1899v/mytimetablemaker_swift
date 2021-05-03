//
//  Timetable.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2020/12/30.
//

import SwiftUI

protocol Calculation {
    var goorback: String { get }
    var weekflag: Bool { get }
}

struct Timetable: Calculation{
    
    let goorback: String
    let weekflag: Bool
    let num: Int
    
    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ num: Int
    ){
        self.goorback = goorback
        self.weekflag = weekflag
        self.num = num
    }

    //
    func timetableKey(_ hour: Int) -> String {
        return "\(goorback.lineNameKey(num))\(weekTag)\(hour.addZeroTime)"
    }

    //UserDefaultに保存された時刻表の時刻の表示を取得
    func timetableTime(_ hour: Int) -> String {
        return timetableKey(hour).userDefaultsValue("")
    }

    //時刻表データを取得
    var timetable: [Int] {
        var timetable: [Int] = []
        for hour in 4...25 {
            let temptext = timetableTime(hour)
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
    
    //
    func choiceCopyTimeKey(_ hour: Int) -> [String] {
        return [
            "\(goorback.lineNameKey(num))\(weekTag)\((hour - 1).addZeroTime)",
            "\(goorback.lineNameKey(num))\(weekTag)\((hour + 1).addZeroTime)",
            "\(goorback.lineNameKey(num))\(revWeekTag)\(hour.addZeroTime)",
            "\(otherroute.lineNameKey(0))\(weekTag)\(hour.addZeroTime)",
            "\(otherroute.lineNameKey(1))\(weekTag)\(hour.addZeroTime)",
            "\(otherroute.lineNameKey(2))\(weekTag)\(hour.addZeroTime)"
        ]
    }

    //
    func choiceCopyTimeTitle(_ hour: Int) -> [String] {
        return [
            "\(String(hour - 1))\("Hour".localized)",
            "\(String(hour + 1))\("Hour".localized)",
            revWeekLabelText,
            "Other route of line 1".localized,
            "Other route of line 2".localized,
            "Other route of line 3".localized
        ]
    }

    func copyButtonsArray(_ hour: Int) -> [ActionSheet.Button] {
        
        let copylist = choiceCopyTimeTitle(hour)
        let copykey = choiceCopyTimeKey(hour)
        var buttonsArray: [ActionSheet.Button] = []
        let ns = (hour == 4) ? 1: 0
        
        for i in ns..<copylist.count {
            
            if (hour == 25 && i == 1) {
                continue
            }
            
            let button: ActionSheet.Button = .default(
                    Text(copylist[i]),
                    action: {
                        UserDefaults.standard.set(copykey[i].userDefaultsValue(""), forKey: timetableKey(hour))
                    }
            )
            buttonsArray.append(button)
        }
        
        let cancelbutton: ActionSheet.Button = .cancel(){}
        buttonsArray.append(cancelbutton)

        return buttonsArray
    }
    
    func copyTimetableSheet(_ hour: Int) -> ActionSheet {
        ActionSheet(
            title: Text(DialogTitle.copytime.rawValue.localized),
            message: Text(""),
            buttons: copyButtonsArray(hour)
        )
    }

    //時刻表のタイトルを取得
    var timetableTitle: String {
        let arrivestation = goorback.stationArray[2 * num + 3]
        let linename = goorback.lineNameArray[num]
        return "(\(linename)\(" for ".localized)\(arrivestation)\("houmen".localized))"
    }

    func timetableAlertMessage(_ hour: Int) -> String {
        return "\(goorback.lineNameArray[num]) (\(String(hour))\("Hour".localized))"
    }
    
    //
    var weekTag: String {
        return weekflag ? "weekday": "weekend"
    }

    //
    var revWeekTag: String {
        return !weekflag ? "weekday": "weekend"
    }

    //
    var weekLabelText: String {
        return weekflag ? "Weekday".localized: "Weekend".localized
    }

    //
    var revWeekLabelText: String {
        return !weekflag ? "Weekday".localized: "Weekend".localized
    }

    //
    var weekLabelColor: Color {
        return weekflag ? Color.white: Color.myred
    }

    //
    var weekButtonBackColor: Color {
        return weekflag ? Color.myred: Color.white
    }
    
    //
    var weekButtonLabelColor: Color {
        return weekflag ? Color.white: Color.myprimary
    }

    //goorbackを別ルートに変更
    var otherroute: String {
        return goorback.prefix(goorback.count - 1) + ((goorback.suffix(1) == "1") ? "2": "1")
    }
}

//＜時刻表の表示＞
extension String {
    
    //時刻の整理整頓
    func timeSorting(charactersin: String) -> [String] {
        return Array(Set(self
                .components(separatedBy: CharacterSet(charactersIn: charactersin))
                .map{Int($0) ?? 60}
                .filter{$0 < 60}
                .filter{$0 > -1}
            ))
            .sorted()
            .map{String($0)}
    }

    //
    func timeGetting(_ hour: Int) -> [Int] {
        return Array(Set(self
                .components(separatedBy: CharacterSet(charactersIn: " "))
                .map{(Int($0)! + hour * 100)}
                .filter{$0 < 2700}
                .filter{$0 > -1}
            ))
            .sorted()
    }
    
    //時刻を追加
    func addTimeFromTimetable(_ key: String) -> String {
        let currenttext = key.userDefaultsValue("")
        let temptext = (currenttext != "") ? "\(currenttext) \(self)": self
        let textarray = temptext.timeSorting(charactersin: " ")
        return textarray.joined(separator: " ")
    }

    //時刻を削除
    func deleteTimeFromTimetable(_ key: String) -> String {
        let currenttext = key.userDefaultsValue("")
        let temptext = currenttext.trimmingCharacters(in: .whitespaces)
        let textarray = temptext.timeSorting(charactersin: " ").filter{$0 != self}
        return textarray.joined(separator: " ")
    }
}
