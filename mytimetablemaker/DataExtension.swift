//
//  DataExtension.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/10/30.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import Foundation
import UIKit

// 多言語対応
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: self)
    }
}

//＜key＞
extension String{
    //UserDefaultsに保存された文字列を取得
    func userDefaultValue(_ defaultvalue: String?) -> String {
        let defaultstring = (defaultvalue != nil) ? defaultvalue: ""
        return UserDefaults.standard.string(forKey: self) ?? defaultstring!
    }
    //UserDefaultsに保存された文字列を取得
    func userDefaultInt(_ defaultvalue: Int?) -> Int {
        let defaultint = (defaultvalue != nil) ? defaultvalue: 0
        return (UserDefaults.standard.object(forKey: self) != nil) ?
            UserDefaults.standard.integer(forKey: self):
            defaultint!
    }
    //UserDefaultsに保存
    func userDefaultBool(_ defaultvalue: Bool?) -> Bool {
        let defaultbool = (defaultvalue != nil) ? defaultvalue: false
        return (UserDefaults.standard.object(forKey: self) != nil) ?
            UserDefaults.standard.bool(forKey: self):
            defaultbool!
    }
    //UserDefaultsに保存された色データを取得
    func userDefaultColor(_ defaultvalue: Int?) -> UIColor? {
        let defaultint = (defaultvalue != nil) ? defaultvalue: 0
        return (UserDefaults.standard.object(forKey: self) != nil) ?
            UIColor(UserDefaults.standard.integer(forKey: self)):
            UIColor(defaultint!)
    }
}

//＜goorback＞メイン画面
extension String{
    //goorbackに応じて異なるString値を返す
    func stringGoOrBack(_ backstring: String, _ gostring: String) -> String {
        return (self == "back1" || self == "back2") ? backstring: gostring
    }
    //UserDefaultsに保存された目的地を取得 : "Office".localized, "Home".localized
    func departurePoint(_ backdefault: String, _ godefault: String) -> String {
        return self.stringGoOrBack(
            "destination".userDefaultValue(backdefault),
            "departurepoint".userDefaultValue(godefault)
        )
    }
    //UserDefaultsに保存された出発地を取得する関数 : "Home".localized, "Office".localized
    func destination(_ backdefault: String, _ godefault: String) -> String {
        return self.stringGoOrBack(
            "departurepoint".userDefaultValue(backdefault),
            "destination".userDefaultValue(godefault)
        )
    }
    //UserDefaultsに保存された発車駅名を取得 : "Dep. St.".localized + keytag
    func departStation(_ keytag: String, _ depstadefault: String) -> String {
        return "\(self)departstation\(keytag)".userDefaultValue(depstadefault)
    }
    //UserDefaultsに保存された降車駅名を取得 : "Arr. St.".localized + keytag
    func arriveStation(_ keytag: String, _ arrstadefault: String) -> String {
        return "\(self)arrivestation\(keytag)".userDefaultValue(arrstadefault)
    }
    //UserDefaultsに保存された路線名を取得 : "Line ".localized + keytag
    func lineName(_ keytag: String, _ linedefault: String) -> String {
        return "\(self)linename\(keytag)".userDefaultValue(linedefault)
    }
    //UserDefaultsに保存された路線カラーを取得 : 0x03DAC5
    func lineColor(_ keytag: String, _ colordefault: Int) -> UIColor? {
        return "\(self)linecolor\(keytag)".userDefaultColor(colordefault)
    }
    //UserDefaultsに保存された移動手段を取得 : "Walking".localized
    func transportation(_ keytag: String, _ transportdefalut: String) -> String {
        return "\(self)transport\(keytag)".userDefaultValue(transportdefalut)
    }
    //UserDefaultsに保存された乗換出発駅を取得する関数
    func transitDepartStation(_ keytag: String) -> String {
        let intkeytag = Int(keytag) ?? self.changeLineInt + 2
        let keytag0 = (intkeytag > self.changeLineInt + 2) ?
            String(self.changeLineInt + 1): String(intkeytag - 1)
        return (keytag0 == "0") ? self.departurePoint("Office".localized, "Home".localized):
            "\(self)arrivestation\(keytag0)".userDefaultValue("\("Arr. St.".localized)\(keytag0)")
    }
    //UserDefaultsに保存された乗換到着駅を取得する関数
    func transitArriveStation(_ keytag: String) -> String {
        let intkeytag = Int(keytag) ?? self.changeLineInt + 2
        let keytag0 = (intkeytag > self.changeLineInt + 1) ? "e": keytag
        return (keytag0 == "e") ? self.destination("Home".localized, "Office".localized):
            "\(self)departstation\(keytag0)".userDefaultValue("\("Dep. St.".localized)\(keytag0)")
    }
    //UserDefaultsに保存された乗車時間を取得
    func rideTime(_ keytag: String) -> Int {
        return "\(self)ridetime\(keytag)".userDefaultInt(0)
    }
    //UserDefaultsに保存された乗車時間をString型で取得(設定画面用)
    func rideTimeString(_ keytag: String) -> String {
        return (self.rideTime(keytag) == 0) ? Unit.notset.rawValue.localized:
            "\(String(self.rideTime(keytag)))\(Unit.minites.rawValue.localized)"
    }
    //UserDefaultsに保存された移動時間を取得
    func transitTime(_ keytag: String) -> Int {
        return "\(self)transittime\(keytag)".userDefaultInt(0)
    }
    //UserDefaultsに保存された移動時間をString型で取得(設定画面用)
    func transitTimeString(_ keytag: String) -> String {
        return (self.transitTime(keytag) == 0) ? Unit.notset.rawValue.localized:
            "\(String(self.transitTime(keytag)))\(Unit.minites.rawValue.localized)"
    }
}

//＜goorback＞設定画面
extension String{
    
    //Various Settingsのタイトルを取得する関数
    var variousSettingsTitle: String {
        switch (self) {
            case "go1": return VariousSettingsTitle.go1.rawValue.localized
            case "back2": return VariousSettingsTitle.back2.rawValue.localized
            case "go2": return VariousSettingsTitle.go2.rawValue.localized
            default: return VariousSettingsTitle.back1.rawValue.localized
        }
    }
    //
    var seguegoorback: String {
        switch (self) {
            case "seguevsgo1": return "go1"
            case "seguevsback2": return "back2"
            case "seguevsgo2": return "go2"
            default : return "back1"
        }
    }

    //UserDefaultsに保存されたスイッチの状態を取得
    var switchFlag: Bool {
        return "\(self)switch".userDefaultBool(false)
    }
    //UserDefaultsに保存された乗換回数の取得
    var changeLineInt: Int {
        return "\(self)changeline".userDefaultInt(0)
    }
    //乗換回数の取得(String型)
    var changeLine: String {
        return self.changeLineInt.stringChangeLine
    }
    //乗換回数の取得(設定画面用)
    func switchChangeLine(_ switchflag: Bool) -> String {
        return (switchflag) ? self.changeLine: Unit.notuse.rawValue.localized
    }
}

extension Int {
    //
    var stringChangeLine: String {
        switch(self) {
            case 0: return TransitTime.zero.rawValue.localized
            case 1: return TransitTime.once.rawValue.localized
            case 2: return TransitTime.twice.rawValue.localized
            default: return Unit.notset.rawValue.localized
        }
    }
    //
    func viewHidden(_ number: Int) -> Bool {
        return (self < number) ? true: false
    }
}
