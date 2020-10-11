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
        switch (goorback) {
            case "go1": return "Various settings on outgoing route 1".localized
            case "back2": return "Various settings on route home 2".localized
            case "go2": return "Various settings on outgoing route 2".localized
            default: return "Various settings on route home 1".localized
        }
    }
    
    //UserDefaultsに保存された文字列を取得する関数
    class func getUserDefaultValue(key: String, defaultvalue: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? defaultvalue
    }

    //UserDefaultsに保存された文字列を取得する関数
    class func getUserDefaultInt(key: String, defaultvalue: Int) -> Int {
        if (UserDefaults.standard.object(forKey: key) != nil) {
            return UserDefaults.standard.integer(forKey: key)
        }
        return defaultvalue
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
        let defaultvalue = (goorback == "back1" || goorback == "back2") ? "Home".localized: "Office".localized
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)
    }

    //UserDefaultsに保存された出発地を取得する関数
    class func getDestination(goorback: String) -> String {
        let key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
        let defaultvalue = (goorback == "back1" || goorback == "back2") ? "Home".localized: "Office".localized
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)
    }

    //発車駅名の初期値を取得する関数
    class func getDepartStationDefaultvalue(goorback: String, keytag: String) -> String {    
        return (goorback == "back2" || goorback == "go2") ?
            "Dep. St.".localized + "2-" + keytag:
            "Dep. St.".localized + "1-" + keytag
    }

    //UserDefaultsに保存された発車駅名を取得する関数
    class func getDepartStation(goorback: String, keytag: String) -> String {
        return getUserDefaultValue(
            key: goorback + "departstation" + keytag,
            defaultvalue: getDepartStationDefaultvalue(goorback: goorback, keytag: keytag))
    }

    //降車駅名の初期値を取得する関数
    class func getArriveStationDefaultvalue(goorback: String, keytag: String) -> String {    
        return (goorback == "back2" || goorback == "go2") ?
            "Arr. St.".localized + "2-" + keytag:
            "Arr. St.".localized + "1-" + keytag
    }

    //UserDefaultsに保存された降車駅名を取得する関数
    class func getArriveStation(goorback: String, keytag: String) -> String {
        return getUserDefaultValue(
            key: goorback + "arrivestation" + keytag, 
            defaultvalue: getArriveStationDefaultvalue(goorback: goorback, keytag: keytag))
    }

    //乗換回数の取得
    class func getChangeLine(goorback: String) -> String {
        let changelinekey = goorback + "changeline"
        let intchangeline = FileAndData.getUserDefaultInt(key: changelinekey, defaultvalue: 0)
        switch (intchangeline) {
            case 0: return "Zero".localized
            case 1: return "Once".localized
            case 2: return "Twice".localized
            default: return "Not set".localized
        }
    }
    
    //乗換回数の取得
    class func getIntChangeLine(goorback: String) -> Int {
        let changelinekey = goorback + "changeline"
        return FileAndData.getUserDefaultInt(key: changelinekey, defaultvalue: 0)
    }
    
    //UserDefaultsに保存された乗換出発駅を取得する関数
    class func getTransitDepartStation(goorback: String, keytag: String) -> String {
        let key = getTransitDepartStationKey(goorback: goorback, keytag: keytag)
        let defaultvalue = getTransitDepartStationDefault(goorback: goorback, keytag: keytag)
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)
    }
    
    //
    class func getTransitDepartKeyTag0(goorback: String, keytag: String) -> String {
        let intchangeline = getIntChangeLine(goorback: goorback)
        let intkeytag = Int(keytag) ?? intchangeline + 2
        return (intkeytag > intchangeline + 2) ? String(intchangeline + 1): String(intkeytag - 1)
    }
    
    //
    class func getTransitDepartStationKey(goorback: String, keytag: String) -> String {
        let keytag0 = getTransitDepartKeyTag0(goorback: goorback, keytag: keytag)
        var key = goorback + "arrivestation" + keytag0
        if (keytag0 == "0") {
            key = (goorback == "back1" || goorback == "back2") ? "destination": "departurepoint"
        }
        return key
    }
    
    //
    class func getTransitDepartStationDefault(goorback: String, keytag: String) -> String {
        let keytag0 = getTransitDepartKeyTag0(goorback: goorback, keytag: keytag)
        var defaultvalue = getArriveStationDefaultvalue(goorback: goorback, keytag: keytag0)
        if (keytag0 == "0") {
            defaultvalue = (goorback == "back1" || goorback == "back2") ? "Office".localized: "Home".localized
        }
        return defaultvalue
    }
    
    //UserDefaultsに保存された乗換到着駅を取得する関数
    class func getTransitArriveStation(goorback: String, keytag: String) -> String {
        let key = getTransitArriveStationKey(goorback: goorback, keytag: keytag)
        let defaultvalue = getTransitArriveStationDefault(goorback: goorback, keytag: keytag)
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)
    }
        
    //
    class func getTransitArriveKeyTag0(goorback: String, keytag: String) -> String {
        let intchangeline = getIntChangeLine(goorback: goorback)
        let intkeytag = Int(keytag) ?? intchangeline + 2
        return (intkeytag > intchangeline + 1) ? "e": keytag
    }
    
    //
    class func getTransitArriveStationKey(goorback: String, keytag: String) -> String {
        let keytag0 = getTransitArriveKeyTag0(goorback: goorback, keytag: keytag)
        var key = goorback + "departstation" + keytag0
        if (keytag0 == "e") {
            key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
        }
        return key
    }
    
    //
    class func getTransitArriveStationDefault(goorback: String, keytag: String) -> String {
        let keytag0 = getTransitArriveKeyTag0(goorback: goorback, keytag: keytag)
        var defaultvalue = getDepartStationDefaultvalue(goorback: goorback, keytag: keytag0)
        if (keytag0 == "e") {
            defaultvalue = (goorback == "back1" || goorback == "back2") ? "Home".localized: "Office".localized
        }
        return defaultvalue
    }

    //路線名の初期値を取得する関数
    class func getLinenameDefaultvalue(goorback: String, keytag: String) -> String {
        return (goorback == "back2" || goorback == "go2") ?
            "Line ".localized + "2-" + keytag:
            "Line ".localized + "1-" + keytag
    }

    //UserDefaultsに保存された路線名を取得する関数
    class func getLinename(goorback: String, keytag: String) -> String {
        return getUserDefaultValue(
            key: goorback + "linename" + keytag, 
            defaultvalue: getLinenameDefaultvalue(goorback: goorback, keytag: keytag))
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
    class func changeDisplayLine(changeline: Int, stackview2: UIStackView, stackview3: UIStackView) {
        switch (changeline) {
            case 1:
                stackview2.isHidden = false
                stackview3.isHidden = true
            case 2:
                stackview2.isHidden = false
                stackview3.isHidden = false
            default:
                stackview2.isHidden = true
                stackview3.isHidden = true
        }
    }
}
