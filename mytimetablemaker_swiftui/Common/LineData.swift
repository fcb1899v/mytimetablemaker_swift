//
//  LineData.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2020/12/27.
//

import SwiftUI
import Foundation
import Combine

//＜goorback＞
extension String{

    //goorbackに応じて異なるString値を返す
    func stringGoOrBack(_ backstring: String, _ gostring: String) -> String {
        return (self == "back1" || self == "back2") ? backstring: gostring
    }

    //
    var departurePointKey: String {
        return self.stringGoOrBack("destination", "departurepoint")
    }
    
    //
    var arrivalPointKey: String {
        return self.stringGoOrBack("departurepoint", "destination")
    }
    
    var departurePointDefault: String {
        return (self == "back1" || self == "back2") ? "Home".localized: "Office".localized
    }
    
    var arrivalPointDefault: String {
        return (self == "back1" || self == "back2") ? "Office".localized: "Home".localized
    }
    
    //UserDefaultsに保存された目的地を取得
    var departurePoint: String {
        return departurePointKey.userDefaultsValue(departurePointDefault)
    }

    //UserDefaultsに保存された出発地を取得する関数
    var arrivalPoint: String {
        return arrivalPointKey.userDefaultsValue(arrivalPointDefault)
    }

    //UserDefaultsに保存された目的地を取得
    var settingsDeparturePoint: String {
        return departurePointKey.userDefaultsValue(Unit.notset.rawValue.localized)
    }

    //UserDefaultsに保存された出発地を取得する関数
    var settingsArrivalPoint: String {
        return arrivalPointKey.userDefaultsValue(Unit.notset.rawValue.localized)
    }

    //
    func departStationKey(_ num: Int) -> String {
        return "\(self)departstation\(num + 1)"
    }
    
    func departStationDefault(_ num: Int) -> String {
        return "\("Dep. St. ".localized)\(num + 1)"
    }
    
    //UserDefaultsに保存された発車駅名を取得
    func departStation(_ num: Int, _ depstadefault: String) -> String {
        return departStationKey(num).userDefaultsValue(depstadefault)
    }

    //
    func arriveStationKey(_ num: Int) -> String {
        return "\(self)arrivestation\(num + 1)"
    }
    
    func arriveStationDefault(_ num: Int) -> String {
        return "\("Arr. St. ".localized)\(num + 1)"
    }

    //UserDefaultsに保存された降車駅名を取得
    func arriveStation(_ num: Int, _ arrstadefault: String) -> String {
        return arriveStationKey(num).userDefaultsValue(arrstadefault)
    }

    //
    var departStationArray: Array<String> {
        return [
            self.departStation(0, departStationDefault(0)),
            self.departStation(1, departStationDefault(1)),
            self.departStation(2, departStationDefault(2)),
        ]
    }

    //
    var departStationSettingsArray: Array<String> {
        return [
            self.departStation(0, Unit.notset.rawValue.localized),
            self.departStation(1, Unit.notset.rawValue.localized),
            self.departStation(2, Unit.notset.rawValue.localized),
        ]
    }
    
    //
    var arriveStationArray: Array<String> {
        return [
            self.arriveStation(0, arriveStationDefault(0)),
            self.arriveStation(1, arriveStationDefault(1)),
            self.arriveStation(2, arriveStationDefault(2))
        ]
    }

    //
    var arriveStationSettingsArray: Array<String> {
        return [
            self.arriveStation(0, Unit.notset.rawValue.localized),
            self.arriveStation(1, Unit.notset.rawValue.localized),
            self.arriveStation(2, Unit.notset.rawValue.localized)
        ]
    }

    //
    var stationArray: Array<String> {
        return [
            arrivalPoint,
            departurePoint,
            self.departStationArray[0],
            self.arriveStationArray[0],
            self.departStationArray[1],
            self.arriveStationArray[1],
            self.departStationArray[2],
            self.arriveStationArray[2]
        ]
    }

    //
    var stationSettingsArray: Array<String> {
        return [
            self.settingsArrivalPoint,
            self.settingsDeparturePoint,
            self.departStationSettingsArray[0],
            self.arriveStationSettingsArray[0],
            self.departStationSettingsArray[1],
            self.arriveStationSettingsArray[1],
            self.departStationSettingsArray[2],
            self.arriveStationSettingsArray[2]
        ]
    }
    
    //
    var stationAlertLabelArray: Array<String> {
        return [
            (self == "back1" || self == "back2") ? "Destination".localized: "Departure place".localized,
            (self == "back1" || self == "back2") ? "Departure place".localized: "Destination".localized,
            "\("Dep. St. ".localized)1",
            "\("Arr. St. ".localized)1",
            "\("Dep. St. ".localized)2",
            "\("Arr. St. ".localized)2",
            "\("Dep. St. ".localized)3",
            "\("Arr. St. ".localized)3"
        ]
    }

    //
    var stationAlertTitleArray: Array<String> {
        return [
            DialogTitle.destination.rawValue.localized,
            DialogTitle.departplace.rawValue.localized,
            DialogTitle.stationname.rawValue.localized,
            DialogTitle.stationname.rawValue.localized,
            DialogTitle.stationname.rawValue.localized,
            DialogTitle.stationname.rawValue.localized,
            DialogTitle.stationname.rawValue.localized,
            DialogTitle.stationname.rawValue.localized
        ]
    }
    
    //
    var stationAlertMessageArray: Array<String> {
        return [
            "",
            "",
            "\("of departure station ".localized)1",
            "\("of arrival station ".localized)1",
            "\("of departure station ".localized)2",
            "\("of arrival station ".localized)2",
            "\("of departure station ".localized)3",
            "\("of arrival station ".localized)3"
        ]
    }

    //
    var stationKeyArray: Array<String> {
        return [
            (self == "back1" || self == "back2") ? "departurepoint": "destination",
            (self == "back1" || self == "back2") ? "destination": "departurepoint",
            "\(self)departstation1",
            "\(self)arrivestation1",
            "\(self)departstation2",
            "\(self)arrivestation2",
            "\(self)departstation3",
            "\(self)arrivestation3"
        ]
    }

    //UserDefaultsに保存する路線名のkeyを取得
    func lineNameKey(_ num: Int) -> String {
        return "\(self)linename\(num + 1)"
    }

    //UserDefaultsに保存する前の路線名の初期値を取得
    func lineNameDefault(_ num: Int) -> String {
        return "\("Line ".localized)\(num + 1)"
    }

    //UserDefaultsに保存された路線名を取得 :
    func lineName(_ num: Int, _ linedefault: String) -> String {
        return lineNameKey(num).userDefaultsValue(linedefault)
    }

    //UserDefaultsに保存された路線名を配列で取得 :
    var lineNameArray: Array<String> {
        return [
            self.lineName(0, lineNameDefault(0)),
            self.lineName(1, lineNameDefault(1)),
            self.lineName(2, lineNameDefault(2))
        ]
    }

    //UserDefaultsに保存された路線名を配列で取得 :
    var lineNameSettingsArray: Array<String> {
        return [
            self.lineName(0, Unit.notset.rawValue.localized),
            self.lineName(1, Unit.notset.rawValue.localized),
            self.lineName(2, Unit.notset.rawValue.localized)
        ]
    }

    //UserDefaultsに保存する路線カラーのkeyを取得
    func lineColorKey(_ num: Int) -> String {
        return "\(self)linecolor\(num + 1)"
    }

    //UserDefaultsに保存された路線カラーを取得
    func lineColor(_ num: Int, _ colordefault: String) -> Color {
        return lineColorKey(num).userDefaultsColor(colordefault)
    }

    //UserDefaultsに保存された路線カラーを文字列で取得
    func lineColorString(_ num: Int, _ colordefault: String) -> String {
        return lineColorKey(num).userDefaultsValue(colordefault)
    }
    
    //UserDefaultsに保存された路線カラーを配列で取得
    var lineColorArray: Array<Color> {
        return [
            self.lineColor(0, DefaultColor.accent.rawValue),
            self.lineColor(1, DefaultColor.accent.rawValue),
            self.lineColor(2, DefaultColor.accent.rawValue)
        ]
    }

    //UserDefaultsに保存された路線カラーを文字列配列で取得
    var lineColorStringArray: Array<String> {
        return [
            self.lineColorString(0, DefaultColor.accent.rawValue),
            self.lineColorString(1, DefaultColor.accent.rawValue),
            self.lineColorString(2, DefaultColor.accent.rawValue)
        ]
    }

    //
    func lineNameAlertMessage(_ num: Int) -> String {
        return "\("of ".localized)\("line ".localized)\(num + 1)"
    }
        
    func rideTimeKey(_ num: Int) -> String {
        return "\(self)ridetime\(num + 1)"
    }
    
    //UserDefaultsに保存された乗車時間を取得
    func rideTime(_ num: Int) -> Int {
        return rideTimeKey(num).userDefaultsInt(0)
    }

    //
    var rideTimeArray: Array<Int> {
        return [
            self.rideTime(0),
            self.rideTime(1),
            self.rideTime(2)
        ]
    }

    //UserDefaultsに保存された乗車時間をString型で取得(設定画面用)
    func rideTimeString(_ num: Int) -> String {
        return (self.rideTime(num) == 0) ? Unit.notset.rawValue.localized:
            "\(String(self.rideTime(num)))\(Unit.minites.rawValue.localized)"
    }

    //
    func rideTimeSettingsColor(_ num: Int) -> Color {
        return (self.rideTime(num) == 0) ? Color.mygray: lineColorArray[num]
    }
    
    //
    var rideTimeStringArray: Array<String> {
        return [
            self.rideTimeString(0),
            self.rideTimeString(1),
            self.rideTimeString(2)
        ]
    }

    //
    func rideTimeAlertMessage(_ num: Int) -> String {
        return  "\("on ".localized)\(self.lineNameArray[num])"
    }
    
    //
    func transportationKey(_ num: Int) ->  String {
        return (num == 0) ? "\(self)transporte": "\(self)transport\(num)"
    }

    //UserDefaultsに保存された移動手段を取得
    func transportation(_ num: Int, _ transportdefalut: String) -> String {
        return transportationKey(num).userDefaultsValue(transportdefalut)
    }

    //
    var transportationArray: Array<String> {
        return [
            self.transportation(0, Transportation.walking.rawValue.localized),
            self.transportation(1, Transportation.walking.rawValue.localized),
            self.transportation(2, Transportation.walking.rawValue.localized),
            self.transportation(3, Transportation.walking.rawValue.localized)
        ]
    }

    //
    var transportationSettingsArray: Array<String> {
        return [
            self.transportation(0, Unit.notset.rawValue.localized),
            self.transportation(1, Unit.notset.rawValue.localized),
            self.transportation(2, Unit.notset.rawValue.localized),
            self.transportation(3, Unit.notset.rawValue.localized)
        ]
    }

    //UserDefaultsに保存された乗換出発駅を取得する関数
    func transitDepartStation(_ num: Int) -> String {
        let keytag = (num == 0) ? "\(self.changeLineInt + 1)": "\(num - 1)"
        return (num == 1) ? self.departurePoint:
            "\(self)arrivestation\(keytag)".userDefaultsValue("\("Arr. St. ".localized)\(keytag)")
    }

    //UserDefaultsに保存された乗換到着駅を取得する関数
    func transitArriveStation(_ num: Int) -> String {
        return (num == 0) ? self.arrivalPoint:
            "\(self)departstation\(num)".userDefaultsValue("\("Dep. St. ".localized)\(num)")
    }
    
    //
    func transportationMessage(_ num: Int) -> String {
        let transdepsta = self.transitDepartStation(num).localized
        let transarrsta = self.transitArriveStation(num).localized
        return "\("from ".localized)\(transdepsta)\(" to ".localized)\(transarrsta)"
    }

    //
    func transportationLabel(_ num: Int) -> String {
        let transdepsta = self.transitDepartStation(num).localized
        let transarrsta = self.transitArriveStation(num).localized
        return (num == 1) ? "\("from ".localized)\(transdepsta)\(" to ".localized)":
            "\("To ".localized)\(transarrsta)\("he".localized)"
    }

    //
    func transitTimeKey(_ num: Int) ->  String {
        return (num == 0) ? "\(self)transittimee": "\(self)transittime\(num)"
    }

    //UserDefaultsに保存された移動時間を取得
    func transitTime(_ num: Int) -> Int {
        return transitTimeKey(num).userDefaultsInt(0)
    }

    //
    var transitTimeArray: Array<Int> {
        return [
            self.transitTime(0),
            self.transitTime(1),
            self.transitTime(2),
            self.transitTime(3)
        ]
    }

    //UserDefaultsに保存された移動時間をString型で取得(設定画面用)
    func transitTimeString(_ num: Int) -> String {
        return (self.transitTime(num) == 0) ? Unit.notset.rawValue.localized:
            "\(String(self.transitTime(num)))\(Unit.minites.rawValue.localized)"
    }

    //
    var transitTimeStringArray: Array<String> {
        return [
            self.transitTimeString(0),
            self.transitTimeString(1),
            self.transitTimeString(2),
            self.transitTimeString(3)
        ]
    }
    
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

