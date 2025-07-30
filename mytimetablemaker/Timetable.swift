//
//  Timetable.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/11/07.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import Foundation
import UIKit

struct Timetable: Calculation{
    var goorback: String
    var weekflag: Bool
    var keytag: String
    init(_ goorback: String, _ weekflag: Bool, _ keytag: String){
        self.goorback = goorback
        self.weekflag = weekflag
        self.keytag = keytag
    }
}

extension Timetable {

    var weektag: String {
        return (self.weekflag) ? "weekday": "weekend"
    }

    //時刻表のタイトルを取得
    var timetableTitle: String {
        let arrivestation = timetableArriveStation
        let linename = timetableLineName
        return "(\(linename)\(" for ".localized)\(arrivestation)\("houmen".localized))"
    }

    //UserDefaultsに保存された発車駅名を取得
    var timetableDepartStation: String {
        return "\(goorback)departstation\(keytag)"
            .userDefaultValue("\("Dep. St.".localized)\(keytag)")
    }

    //UserDefaultsに保存された降車駅名を取得
    var timetableArriveStation: String {
        return "\(goorback)arrivestation\(keytag)"
            .userDefaultValue("Arr. St.".localized + keytag)
    }
    
    //UserDefaultsに保存された路線名を取得
    var timetableLineName: String {
        return "\(goorback)linename\(keytag)"
            .userDefaultValue("Line ".localized + keytag)
    }

    //
    var weekLabelText: String {
        return (self.weekflag) ? "Weekday".localized: "Weekend".localized
    }

    //
    func weekLabelColor(_ daycolor: Int, _ endcolor: Int) -> UIColor {
        return (weekflag) ? UIColor(daycolor): UIColor(endcolor)
    }

    //
    func weekButtonTitle(_ weekbutton: UIButton) {
        let buttontext = (self.weekflag) ? "Weekend".localized: "Weekday".localized
        return weekbutton.setTitle(buttontext.uppercased(), for: UIControl.State.normal)
    }

    //
    func weekButtonColor(_ weekbutton: UIButton, _ daycolor: Int, _ endcolor: Int) {
        return weekbutton.setTitleColor((weekflag) ? UIColor(daycolor): UIColor(endcolor), for: UIControl.State.normal)
    }

    //UserDefaultに保存された時刻表の時刻の表示を取得
    func timetableTime(_ hour: Int) -> String {
        return "\(goorback)line\(keytag)\(weektag)\(String(hour))".userDefaultValue("")
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
    func timeGetting(charactersin: String, hour: Int) -> [Int] {
        return Array(Set(self
                .components(separatedBy: CharacterSet(charactersIn: charactersin))
                .map{(Int($0)! + hour * 100)}
                .filter{$0 < 2560}
                .filter{$0 > -1}
            ))
            .sorted()
    }
    
    //goorbackを別ルートに変更
    var otherroute: String {
        return self.prefix(self.count - 1) + ((self.suffix(1) == "1") ? "2": "1")
    }
}
