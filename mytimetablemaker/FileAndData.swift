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
    
    class func getUserDefaultValue(key: String, defaultvalue: String) -> String? {
        return UserDefaults.standard.string(forKey: key) ?? defaultvalue
    }

    class func getUserDefaultColor(key: String, defaultvalue: Int) -> UIColor? {
        var color = UIColor(rgb: defaultvalue)
        if (UserDefaults.standard.string(forKey: key) != nil) {
            color = UIColor(rgb: UserDefaults.standard.integer(forKey: key))
        }
        return color
    }
    
    class func getDepartStation(goorback: String, keytag: String) -> String {

        let key = goorback + "departstation" + keytag
        var defaultvalue = "Dep. St.1-" + keytag
        if (goorback == "back2" || goorback == "go2") {
            defaultvalue = "Dep. St.2-" + keytag
        }
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!

    }

    class func getArriveStation(goorback: String, keytag: String) -> String {

        let key = goorback + "arrivestation" + keytag
        var defaultvalue = "Arr. St.1-" + keytag
        if (goorback == "back2" || goorback == "go2") {
            defaultvalue = "Arr. St.2-" + keytag
        }
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
    }
    
    class func getTransitDepartStation(goorback: String, keytag: String) -> String {

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
        
        let intkeytag = Int(keytag) ?? intchangeline + 2
        var keytag0 = String(intkeytag - 1)
        if (intkeytag > intchangeline + 2) {
            keytag0 = String(intchangeline + 1)
        }

        var key = goorback + "arrivestation" + keytag0
        var defaultvalue = "Arr. St.1-" + keytag0
        if (goorback == "back2" || goorback == "go2") {
            defaultvalue = "Arr. 2-" + keytag0
        }
        
        if (keytag0 == "0") {
            if ( goorback == "go1" || goorback == "go2") {
                key = "departurepoint"
                defaultvalue = "Home"
            } else {
                key = "destination"
                defaultvalue = "Office"
            }
        }
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
    }
    
    class func getTransitArriveStation(goorback: String, keytag: String) -> String {

        let changelinekey = goorback + "changeline"
        let changeline = FileAndData.getUserDefaultValue(
            key: changelinekey, defaultvalue: "Zero")
        var intchangeline = 0
        switch (changeline) {
            case "Once": intchangeline = 1
            case "Twice": intchangeline = 2
            default : intchangeline = 0
        }

        let intkeytag = Int(keytag) ?? intchangeline + 2
        var keytag0 = keytag
        if (intkeytag > intchangeline + 1) {
            keytag0 = "e"
        }

        var key = goorback + "departstation" + keytag0
        var defaultvalue = "Dep. St.1-" + keytag0
        if (goorback == "back2" || goorback == "go2") {
            defaultvalue = "Dep. 2-" + keytag0
        }

        if (keytag0 == "e") {
            if ( goorback == "back1" || goorback == "back2") {
                key = "departurepoint"
                defaultvalue = "Home"
            } else {
                key = "destination"
                defaultvalue = "Office"
            }
        }
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
    }
    
    class func getDestination(goorback: String) -> String {

        var key = "destination"
        var defaultvalue = "Office"
        if (goorback == "back1" || goorback == "back2") {
            key = "departurepoint"
            defaultvalue = "Home"
        }
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!

    }

    class func getDeparturePoint(goorback: String) -> String {

        var key = "departurepoint"
        var defaultvalue = "Home"
        if (goorback == "back1" || goorback == "back2") {
            key = "destination"
            defaultvalue = "Office"
        }
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
        
    }
    
    class func getLinename(goorback: String, keytag: String) -> String {
        
        let key = goorback + "linename" + keytag
        var defaultvalue = "Line 1-" + keytag
        if (goorback == "back2" || goorback == "go2") {
            defaultvalue = "Line 2-" + keytag
        }
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
    }
    
    class func getLineColor(goorback: String, keytag: String) -> UIColor {
        
        let key = goorback + "linecolor" + keytag
        return getUserDefaultColor(key: key, defaultvalue: 0x03DAC5)!

    }

    class func getDisplayBool(goorback2: String) -> Bool {
        let key = goorback2 + "display"
        var displaybool = false
        if (UserDefaults.standard.string(forKey: key) != nil) {
            displaybool = UserDefaults.standard.bool(forKey: key)
        }
        return displaybool
    }
    
    class func changeDisplayLine(changeline1: String, changeline2: String, stackview12: UIStackView, stackview13: UIStackView, stackview22: UIStackView, stackview23: UIStackView) {
        switch (changeline1) {
            case "Once":
                stackview12.isHidden = false
                stackview13.isHidden = true
            case "Twice":
                stackview12.isHidden = false
                stackview13.isHidden = false
            default:
                stackview12.isHidden = true
                stackview13.isHidden = true
        }
        switch (changeline2) {
            case "Once":
                stackview22.isHidden = false
                stackview23.isHidden = true
            case "Twice":
                stackview22.isHidden = false
                stackview23.isHidden = false
            default:
                stackview22.isHidden = true
                stackview23.isHidden = true
        }
    }
    
}
