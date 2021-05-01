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
    
    let register = Action.register.rawValue.localized
    let cancel = Action.cancel.rawValue.localized
    let add = Action.add.rawValue.localized
    let delete = Action.delete.rawValue.localized
    let copy = Action.copy.rawValue.localized
    let to59min = Hint.to59min.rawValue.localized
    
}

extension Timetable {

    //
    func timetableKey(_ hour: Int) -> String {
        return "\(goorback)line\(num + 1)\(weekflag.weektag)\(hour.addZeroTime)"
    }

    //UserDefaultに保存された時刻表の時刻の表示を取得
    func timetableTime(_ hour: Int) -> String {
        return timetableKey(hour).userDefaultsValue("")
    }

    //
    private func choiceCopyTimeKey(_ hour: Int) -> [String] {
        return [
            "\(goorback)line\(num + 1)\(weekflag.weektag)\((hour - 1).addZeroTime)",
            "\(goorback)line\(num + 1)\(weekflag.weektag)\((hour + 1).addZeroTime)",
            "\(goorback)line\(num + 1)\((!weekflag).weektag)\(hour.addZeroTime)",
            "\(goorback.otherroute)line1\(weekflag.weektag)\(hour.addZeroTime)",
            "\(goorback.otherroute)line2\(weekflag.weektag)\(hour.addZeroTime)",
            "\(goorback.otherroute)line3\(weekflag.weektag)\(hour.addZeroTime)"
        ]
    }

    //
    private func choiceCopyTimeTitle(_ hour: Int) -> [String] {
        return [
            "\(String(hour - 1))\("Hour".localized)",
            "\(String(hour + 1))\("Hour".localized)",
            (!weekflag) ? "Weekday".localized: "Weekend".localized,
            "Other route of line 1".localized,
            "Other route of line 2".localized,
            "Other route of line 3".localized
        ]
    }

    private func copyButtonsArray(_ hour: Int, _ key: String) -> [ActionSheet.Button] {
        
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
                        UserDefaults.standard.set(copykey[i].userDefaultsValue(""), forKey: key)
                    }
            )
            buttonsArray.append(button)
        }
        
        let cancelbutton: ActionSheet.Button = .cancel(){}
        buttonsArray.append(cancelbutton)

        return buttonsArray
    }
    
    func copyTimetableSheet(_ hour: Int, _ key: String) -> ActionSheet {
        ActionSheet(
            title: Text(DialogTitle.copytime.rawValue.localized),
            message: Text(""),
            buttons: copyButtonsArray(hour, key)
        )
    }

    //時刻表のタイトルを取得
    var timetableTitle: String {
        let arrivestation = timetableArriveStation
        let linename = timetableLineName
        return "(\(linename)\(" for ".localized)\(arrivestation)\("houmen".localized))"
    }

    //UserDefaultsに保存された発車駅名を取得
    var timetableDepartStation: String {
        return "\(goorback)departstation\(num + 1)"
            .userDefaultsValue("\("Dep. St. ".localized)\(num + 1)")
    }

    //UserDefaultsに保存された降車駅名を取得
    private var timetableArriveStation: String {
        return "\(goorback)arrivestation\(num + 1)"
            .userDefaultsValue("\("Arr. St. ".localized)\(num + 1)")
    }

    //UserDefaultsに保存された路線名を取得
    private var timetableLineName: String {
        return "\(goorback)linename\(num + 1)"
            .userDefaultsValue("\("Line ".localized)\(num + 1)")
    }
    
    func timetableAlertMessage(_ hour: Int) -> String {
        return "\(goorback.lineNameArray[num]) (\(String(hour))\("Hour".localized))"
    }
}

//weekflagの変換
extension Bool {
    
    var weektag: String {
        return (self) ? "weekday": "weekend"
    }

    //
    var weekLabelText: String {
        return self ? "Weekday".localized: "Weekend".localized
    }

    //
    var weekLabelColor: Color {
        return self ? Color.white: Color.red
    }

    //
    var weekButtonTitle: String {
        return self ? "Weekend".localized: "Weekday".localized
    }

    //
    func weekButtonColor(_ daycolor: Int, _ endcolor: Int) -> Color {
        return self ? Color(daycolor): Color(endcolor)
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
    
    //goorbackを別ルートに変更
    var otherroute: String {
        return self.prefix(self.count - 1) + ((self.suffix(1) == "1") ? "2": "1")
    }
}
