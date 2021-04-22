//
//  LineData.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2020/12/27.
//

import SwiftUI
import Foundation
import Combine

// 多言語対応
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: self)
    }
}

//画面サイズを取得
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

//色をRGCの16進数数字で指定
extension Color {
    
    init(
        _ hex: Int,
        opacity: Double = 1.0
    ) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    func hex(withHash hash: Bool = false, uppercase up: Bool = false) -> String {
        if let components = self.cgColor?.components {
            let r = ("0" + String(Int(components[0] * 255.0), radix: 16, uppercase: up)).suffix(2)
            let g = ("0" + String(Int(components[1] * 255.0), radix: 16, uppercase: up)).suffix(2)
            let b = ("0" + String(Int(components[2] * 255.0), radix: 16, uppercase: up)).suffix(2)
            return (hash ? "#" : "") + String(r + g + b)
        }
        return "000000"
    }
}

//String型ColorをInt型に変換
extension String {
    var colorInt: Int {
        return Int(self.replacingOccurrences(of: "#", with: ""), radix: 16) ?? 000000
    }
}

//＜key＞
extension String{
    //UserDefaultsに保存された文字列を取得
    func userDefaultsValue(_ defaultvalue: String?) -> String {
        let defaultstring = (defaultvalue != nil) ? defaultvalue: ""
        return UserDefaults.standard.string(forKey: self) ?? defaultstring!
    }
    //UserDefaultsに保存された文字列を取得
    func userDefaultsInt(_ defaultvalue: Int?) -> Int {
        let defaultint = (defaultvalue != nil) ? defaultvalue: 0
        return (UserDefaults.standard.object(forKey: self) != nil) ?
            UserDefaults.standard.integer(forKey: self):
            defaultint!
    }
    //UserDefaultsに保存
    func userDefaultsBool(_ defaultvalue: Bool?) -> Bool {
        let defaultbool = (defaultvalue != nil) ? defaultvalue: false
        return (UserDefaults.standard.object(forKey: self) != nil) ?
            UserDefaults.standard.bool(forKey: self):
            defaultbool!
    }
    //UserDefaultsに保存された色データを取得
    func userDefaultsColor(_ defaultvalue: String?) -> Color {
        return Color(userDefaultsValue(defaultvalue).colorInt)
    }
}

//＜goorback＞メイン画面
extension String{

    //goorbackに応じて異なるString値を返す
    func stringGoOrBack(_ backstring: String, _ gostring: String) -> String {
        return (self == "back1" || self == "back2") ? backstring: gostring
    }

    //
    var departPointKey: String {
        return self.stringGoOrBack("destination", "departurepoint")
    }
    
    //
    var arrivalPointKey: String {
        return self.stringGoOrBack("departurepoint", "destination")
    }
    
    //UserDefaultsに保存された目的地を取得 : "Office".localized, "Home".localized
    func departurePoint(_ backdefault: String, _ godefault: String) -> String {
        return self.stringGoOrBack(
            "destination".userDefaultsValue(backdefault),
            "departurepoint".userDefaultsValue(godefault)
        )
    }

    //UserDefaultsに保存された出発地を取得する関数 : "Home".localized, "Office".localized
    func destination(_ backdefault: String, _ godefault: String) -> String {
        return self.stringGoOrBack(
            "departurepoint".userDefaultsValue(backdefault),
            "destination".userDefaultsValue(godefault)
        )
    }

    //UserDefaultsに保存された発車駅名を取得 : "Dep. St.".localized + keytag
    func departStation(_ keytag: String, _ depstadefault: String) -> String {
        return "\(self)departstation\(keytag)".userDefaultsValue(depstadefault)
    }

    //UserDefaultsに保存された降車駅名を取得 : "Arr. St.".localized + keytag
    func arriveStation(_ keytag: String, _ arrstadefault: String) -> String {
        return "\(self)arrivestation\(keytag)".userDefaultsValue(arrstadefault)
    }

    //
    var departStationArray: Array<String> {
        return [
            self.departStation("1", "\("Dep. St. ".localized)1"),
            self.departStation("2", "\("Dep. St. ".localized)2"),
            self.departStation("3", "\("Dep. St. ".localized)3"),
        ]
    }

    //
    var arriveStationArray: Array<String> {
        return [
            self.arriveStation("1", "\("Arr. St. ".localized)1"),
            self.arriveStation("2", "\("Arr. St. ".localized)2"),
            self.arriveStation("3", "\("Arr. St. ".localized)3")
        ]
    }
    
    //
    var stationArray: Array<String> {
        let deppoint = (self == "back1" || self == "back2") ? "Home".localized: "Office".localized
        let arrpoint = (self == "back1" || self == "back2") ? "Office".localized: "Home".localized
        return [
            self.destination(deppoint, arrpoint),
            self.departurePoint(arrpoint, deppoint),
            self.departStation("1", "\("Dep. St. ".localized)1"),
            self.arriveStation("1", "\("Arr. St. ".localized)1"),
            self.departStation("2", "\("Dep. St. ".localized)2"),
            self.arriveStation("2", "\("Arr. St. ".localized)2"),
            self.departStation("3", "\("Dep. St. ".localized)3"),
            self.arriveStation("3", "\("Arr. St. ".localized)3")
        ]
    }

    //UserDefaultsに保存された路線名を取得 : "Line ".localized + keytag
    func lineName(_ keytag: String, _ linedefault: String) -> String {
        return "\(self)linename\(keytag)".userDefaultsValue(linedefault)
    }

    //
    var lineNameArray: Array<String> {
        return [
            self.lineName("1", "\("Line ".localized)1"),
            self.lineName("2", "\("Line ".localized)2"),
            self.lineName("3", "\("Line ".localized)3")
        ]
    }

    //UserDefaultsに保存された路線カラーを取得
    func lineColor(_ keytag: String, _ colordefault: String) -> Color {
        return "\(self)linecolor\(keytag)".userDefaultsColor(colordefault)
    }

    //UserDefaultsに保存された路線カラーを取得
    func lineColorString(_ keytag: String, _ colordefault: String) -> String {
        return "\(self)linecolor\(keytag)".userDefaultsValue(colordefault)
    }
    
    //
    var lineColorArray: Array<Color> {
        return [
            self.lineColor("1", DefaultColor.accent.rawValue),
            self.lineColor("2", DefaultColor.accent.rawValue),
            self.lineColor("3", DefaultColor.accent.rawValue)
        ]
    }

    //
    var lineColorStringArray: Array<String> {
        return [
            self.lineColorString("1", DefaultColor.accent.rawValue),
            self.lineColorString("2", DefaultColor.accent.rawValue),
            self.lineColorString("3", DefaultColor.accent.rawValue)
        ]
    }

    //UserDefaultsに保存された移動手段を取得 : "Walking".localized
    func transportation(_ keytag: String, _ transportdefalut: String) -> String {
        return "\(self)transport\(keytag)".userDefaultsValue(transportdefalut)
    }

    var transportationArray: Array<String> {
        return [
            self.transportation("e", Transportation.walking.rawValue.localized),
            self.transportation("1", Transportation.walking.rawValue.localized),
            self.transportation("2", Transportation.walking.rawValue.localized),
            self.transportation("3", Transportation.walking.rawValue.localized)
        ]
    }

    //UserDefaultsに保存された乗換出発駅を取得する関数
    func transitDepartStation(_ num: Int) -> String {
        let keytag = (num == 0) ? "\(self.changeLineInt + 1)": "\(num - 1)"
        return (num == 1) ? self.departurePoint("Office".localized, "Home".localized):
            "\(self)arrivestation\(keytag)".userDefaultsValue("\("Arr. St. ".localized)\(keytag)")
    }

    //UserDefaultsに保存された乗換到着駅を取得する関数
    func transitArriveStation(_ num: Int) -> String {
        return (num == 0) ? self.destination("Home".localized, "Office".localized):
            "\(self)departstation\(num)".userDefaultsValue("\("Dep. St. ".localized)\(num)")
    }

    //UserDefaultsに保存された乗車時間を取得
    func rideTime(_ keytag: String) -> Int {
        return "\(self)ridetime\(keytag)".userDefaultsInt(0)
    }

    //
    var rideTimeArray: Array<Int> {
        return [
            self.rideTime("1"),
            self.rideTime("2"),
            self.rideTime("3")
        ]
    }

    //UserDefaultsに保存された乗車時間をString型で取得(設定画面用)
    func rideTimeString(_ keytag: String) -> String {
        return (self.rideTime(keytag) == 0) ? Unit.notset.rawValue.localized:
            "\(String(self.rideTime(keytag)))\(Unit.minites.rawValue.localized)"
    }

    //
    var rideTimeStringArray: Array<String> {
        return [
            self.rideTimeString("1"),
            self.rideTimeString("2"),
            self.rideTimeString("3")
        ]
    }

    //UserDefaultsに保存された移動時間を取得
    func transitTime(_ keytag: String) -> Int {
        return "\(self)transittime\(keytag)".userDefaultsInt(0)
    }

    //
    var transitTimeArray: Array<Int> {
        return [
            self.transitTime("e"),
            self.transitTime("1"),
            self.transitTime("2"),
            self.transitTime("3")
        ]
    }

    //UserDefaultsに保存された移動時間をString型で取得(設定画面用)
    func transitTimeString(_ keytag: String) -> String {
        return (self.transitTime(keytag) == 0) ? Unit.notset.rawValue.localized:
            "\(String(self.transitTime(keytag)))\(Unit.minites.rawValue.localized)"
    }

    //
    var transitTimeStringArray: Array<String> {
        return [
            self.transitTimeString("e"),
            self.transitTimeString("1"),
            self.transitTimeString("2"),
            self.transitTimeString("3")
        ]
    }
}

//＜goorback＞設定画面
extension String{

    //UserDefaultsに保存されたスイッチの状態を取得
    var route2Flag: Bool {
        var route2flag = "\(self)route2flag".userDefaultsBool(true)
        if (self == "back1" || self == "go1") {
            route2flag = true
        }
        return route2flag
    }
    //UserDefaultsに保存された乗換回数の取得
    var changeLineInt: Int {
        return "\(self)changeline".userDefaultsInt(0)
    }
    //乗換回数の取得(String型)
    var changeLine: String {
        return self.changeLineInt.stringChangeLine
    }

    //
    var routeTitle: String {
        switch (self) {
            case "go1": return EachRouteTitle.go1.rawValue.localized
            case "back2": return EachRouteTitle.back2.rawValue.localized
            case "go2": return EachRouteTitle.go2.rawValue.localized
            default: return EachRouteTitle.back1.rawValue.localized
        }
    }

    //Various Settingsのタイトルを取得する関数
    var variousSettingsTitle: String {
        switch (self) {
            case "go1": return VariousSettingsTitle.go1.rawValue.localized
            case "back2": return VariousSettingsTitle.back2.rawValue.localized
            case "go2": return VariousSettingsTitle.go2.rawValue.localized
            default: return VariousSettingsTitle.back1.rawValue.localized
        }
    }
}

//
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
}

