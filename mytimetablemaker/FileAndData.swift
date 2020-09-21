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
    
    class func getArriveStation(goorback: String, keytag: String) -> String {

        let changeline = 2
        var depdefault0 = "Office"
        let intkeytag = Int(keytag) ?? changeline + 2
        let keytag0 = String(intkeytag - 1)
        let deptag = String(2 * intkeytag - 2)
        var depkey = goorback + "station" + deptag
        var depdefault = "Arr. St.1-" + keytag0
        if (goorback == "back2" || goorback == "go2") {
            depdefault = "Arr. 2-" + keytag0
        }
        if ( goorback == "go1" || goorback == "go2") {
            depdefault0 = "Home"
            if (keytag == "1") {
                depkey = goorback + "statione"
                depdefault = depdefault0
            }
        }
        return getUserDefaultValue(key: depkey, defaultvalue: depdefault)!
    }

    class func getDepartStation(goorback: String, keytag: String) -> String {

        let changeline = 2
        var destinationdefault = "Home"
        var intkeytag = Int(keytag) ?? 4
        if ( goorback == "go1" || goorback == "go2") {
            destinationdefault = "Office"
            if (keytag == "0") {intkeytag = changeline + 2}
            if (keytag == "e") {intkeytag = 1}
        }
        let arrtag = String(2 * intkeytag - 1)
        let arrkey = goorback + "station" + arrtag
        var arrdefault = "Dep. St.1-" + keytag
        if (goorback == "back2" || goorback == "go2") {
            arrdefault = "Dep. 2-" + keytag
        }
        if (keytag == "e") { arrdefault = destinationdefault }
        return getUserDefaultValue(key: arrkey, defaultvalue: arrdefault)!

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
    
}
