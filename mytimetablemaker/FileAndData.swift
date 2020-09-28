//
//  FIleAndData.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/06.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class FileAndData: NSObject {

    //Various Settingsのタイトルを取得する関数
    class func getVariousSettingsTitle(goorback: String) -> String {
        var varioussettingstitle = { "Various settings on " }()
            switch goorback {
                case "go1": varioussettingstitle += "outgoing route 1"
                case "back2": varioussettingstitle += "route home 2"
                case "go2": varioussettingstitle += "outgoing route 2"
                default: varioussettingstitle += "route home 1"
        }
        return varioussettingstitle
    }
    
    //UserDefaultsに保存された文字列を取得する関数
    class func getUserDefaultValue(key: String, defaultvalue: String) -> String? {
        return UserDefaults.standard.string(forKey: key) ?? defaultvalue
    }

    //UserDefaultsに保存された文字列を取得する関数
    class func getUserDefaultInt(key: String, defaultvalue: Int) -> Int? {
        return UserDefaults.standard.integer(forKey: key) ?? defaultvalue
    }

    //UserDefaultsに保存された色データを取得する関数
    class func getUserDefaultColor(key: String, defaultvalue: Int) -> UIColor? {
        return (UserDefaults.standard.string(forKey: key) != nil) ?
            UIColor(rgb: UserDefaults.standard.integer(forKey: key)):
            UIColor(rgb: defaultvalue)
    }
    
    //UserDefaultsに保存された目的地を取得する関数
    class func getDeparturePoint(goorback: String) -> String {
        let key = (goorback == "back1" || goorback == "back2") ? "destination": "departurepoint"
        let defaultvalue = (goorback == "back1" || goorback == "back2") ? "Office": "Home"
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
    }

    //UserDefaultsに保存された出発地を取得する関数
    class func getDestination(goorback: String) -> String {
        let key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
        let defaultvalue = (goorback == "back1" || goorback == "back2") ? "Home": "Office"
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
    }

    //発車駅名の初期値を取得する関数
    class func getDepartStationDefaultvalue(goorback: String, keytag: String) -> String {    
        return (goorback == "back2" || goorback == "go2") ? "Dep. St.2-" + keytag: "Dep. St.1-" + keytag
    }

    //UserDefaultsに保存された発車駅名を取得する関数
    class func getDepartStation(goorback: String, keytag: String) -> String {
        return getUserDefaultValue(
            key: goorback + "departstation" + keytag, 
            defaultvalue: getDepartStationDefaultvalue(goorback: goorback, keytag: keytag))!
    }

    //降車駅名の初期値を取得する関数
    class func getArriveStationDefaultvalue(goorback: String, keytag: String) -> String {    
        return (goorback == "back2" || goorback == "go2") ? "Arr. St.2-" + keytag: "Arr. St.1-" + keytag
    }

    //UserDefaultsに保存された降車駅名を取得する関数
    class func getArriveStation(goorback: String, keytag: String) -> String {
        return getUserDefaultValue(
            key: goorback + "arrivestation" + keytag, 
            defaultvalue: getArriveStationDefaultvalue(goorback: goorback, keytag: keytag))!
    }
    
    //UserDefaultsに保存された乗換出発駅を取得する関数
    class func getTransitDepartStation(goorback: String, keytag: String) -> String {
        //乗換回数の取得
        let changelinekey = goorback + "changeline"
        let changeline = FileAndData.getUserDefaultValue(key: changelinekey, defaultvalue: "Zero")
        var intchangeline = 0
        switch (changeline) {
            case "Once": intchangeline = 1
            case "Twice": intchangeline = 2
            default : intchangeline = 0
        }
        //乗換回数に応じた表示の変更        
        let intkeytag = Int(keytag) ?? intchangeline + 2
        let keytag0 = (intkeytag > intchangeline + 2) ? String(intchangeline + 1): String(intkeytag - 1)
        var key = goorback + "arrivestation" + keytag0
        var defaultvalue = getArriveStationDefaultvalue(goorback: goorback, keytag: keytag0)
        if (keytag0 == "0") {
            key = (goorback == "back1" || goorback == "back2") ? "destination": "departurepoint"
            defaultvalue = (goorback == "back1" || goorback == "back2") ? "Office": "Home"
        }
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
    }
    
    //UserDefaultsに保存された乗換到着駅を取得する関数
    class func getTransitArriveStation(goorback: String, keytag: String) -> String {
        //乗換回数の取得
        let changelinekey = goorback + "changeline"
        let changeline = FileAndData.getUserDefaultValue(
            key: changelinekey, defaultvalue: "Zero")
        var intchangeline = 0
        switch (changeline) {
            case "Once": intchangeline = 1
            case "Twice": intchangeline = 2
            default : intchangeline = 0
        }
        //乗換回数に応じた表示の変更        
        let intkeytag = Int(keytag) ?? intchangeline + 2
        let keytag0 = (intkeytag > intchangeline + 1) ? "e": keytag
        var key = goorback + "departstation" + keytag0
        var defaultvalue = getDepartStationDefaultvalue(goorback: goorback, keytag: keytag0)
        if (keytag0 == "e") {
            key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
            defaultvalue = (goorback == "back1" || goorback == "back2") ? "Home": "Office"
        }
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
    }
    
    //路線名の初期値を取得する関数
    class func getLinenameDefaultvalue(goorback: String, keytag: String) -> String {
        return (goorback == "back2" || goorback == "go2") ? "Line 2-" + keytag: "Line 1-" + keytag
    }

    //UserDefaultsに保存された路線名を取得する関数
    class func getLinename(goorback: String, keytag: String) -> String {
        return getUserDefaultValue(
            key: goorback + "linename" + keytag, 
            defaultvalue: getLinenameDefaultvalue(goorback: goorback, keytag: keytag))!
    }
    
    //UserDefaultsに保存された路線カラーを取得する関数
    class func getLineColor(goorback: String, keytag: String, defaultcolor: Int) -> UIColor {
        return getUserDefaultColor(
            key: goorback + "linecolor" + keytag, 
            defaultvalue: defaultcolor)!
    }

    //ルート2の表示・非表示のフラグを取得する関数
    class func getDisplayBool(goorback2: String) -> Bool {
        let key = goorback2 + "display"
        return (UserDefaults.standard.string(forKey: key) != nil) ?
            UserDefaults.standard.bool(forKey: key):
            false
    }
    
    //乗換回数に応じて表示を変更する関数
    class func changeDisplayLine(changeline: String, stackview2: UIStackView, stackview3: UIStackView) {
        switch (changeline) {
            case "Once":
                stackview2.isHidden = false
                stackview3.isHidden = true
            case "Twice":
                stackview2.isHidden = false
                stackview3.isHidden = false
            default:
                stackview2.isHidden = true
                stackview3.isHidden = true
        }
    }
}
