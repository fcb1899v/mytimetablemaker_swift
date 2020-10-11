//
//  SettingPreference.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/10/01.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class SettingPreference: NSObject {
    
    //ルート2のフラグを取得してスイッチを表示する関数
    class func getSwitch2Flag(goorback2: String, switch2: UISwitch) -> Bool {
        let switchflag = UserDefaults.standard.bool(forKey: goorback2 + "switch")
        switch2.setOn(switchflag, animated: false)
        return switchflag
    }
    
    //ルート2のフラグとスイッチを設定する関数
    class func setSwitch2Flag(goorback2: String, sender: AnyObject) -> Bool {
        let switchflag = sender.isOn
        UserDefaults.standard.set(sender.isOn, forKey: goorback2 + "switch")
        return switchflag ?? true
    }
    
    //ルート2のフラグに応じた乗換回数設定の設定
    class func setChangeLineSettingTitle(goorback: String, changelinetitle: UILabel, changelinelabel: UILabel, switchflag: Bool) {
        changelinelabel.text = (switchflag) ? FileAndData.getChangeLine(goorback: goorback): "Not use".localized
        changelinelabel.textColor = (switchflag) ? UIColor(rgb: 0x000000): UIColor(rgb: 0x8E8E93)
        changelinetitle.textColor = (switchflag) ? UIColor(rgb: 0x000000): UIColor(rgb: 0x8E8E93)
    }

    //ルート2のフラグに応じた詳細設定に遷移するボタンの設定
    class func setGoOrBack2SettingsTitle(settingstitle: UIButton, switchflag: Bool) {
        settingstitle.isEnabled = switchflag
        if (switchflag) {
            settingstitle.setTitleColor(UIColor(rgb: 0x000000), for: UIControl.State.normal)
        } else {
            settingstitle.setTitleColor(UIColor(rgb: 0x8E8E93), for: UIControl.State.normal)
        }
    }
    
    //
    class func setPreferenceCondition(label: UILabel, button: UIButton, changeline: Int, keytag: String) {
        let intkeytag = Int(keytag)!
        if (intkeytag > changeline + 1) {
            label.text = "Not use".localized
            label.textColor = UIColor(rgb: 0x8E8E93)
            button.setTitleColor(UIColor(rgb: 0x8E8E93), for: UIControl.State.normal)
            button.isEnabled = false
        } else {
            button.isEnabled = true
        }
    }
    
    //UserDefaultsに保存された出発地を取得する関数
    class func getPrefDepartPlace(goorback: String) -> String {
        if (goorback == "back1" || goorback == "back2") {
            return FileAndData.getUserDefaultValue(
                key: "destination",
                defaultvalue: "Not set".localized)
        } else {
            return FileAndData.getUserDefaultValue(
                key: "departurepoint",
                defaultvalue: "Not set".localized)
        }
    }
    
    //UserDefaultsに保存された発車駅名を取得する関数
    class func getPrefDepartStation(goorback: String, keytag: String) -> String {
        return FileAndData.getUserDefaultValue(
            key: goorback + "departstation" + keytag,
            defaultvalue: "Not set".localized)
    }

    //UserDefaultsに保存された降車駅名を取得する関数
    class func getPrefArriveStation(goorback: String, keytag: String) -> String {
        return FileAndData.getUserDefaultValue(
            key: goorback + "arrivestation" + keytag,
            defaultvalue: "Not set".localized)
    }

    //UserDefaultsに保存された目的地を取得する関数
    class func getPrefDestination(goorback: String) -> String {
        if (goorback == "back1" || goorback == "back2") {
            return FileAndData.getUserDefaultValue(
                key: "departurepoint",
                defaultvalue: "Not set".localized)
        } else {
            return FileAndData.getUserDefaultValue(
                key: "destination",
                defaultvalue: "Not set".localized)
        }
    }

    //UserDefaultsに保存された路線名を取得する関数
    class func getLineName(goorback: String, keytag: String) -> String {
        return FileAndData.getUserDefaultValue(
            key: goorback + "linename" + keytag,
            defaultvalue: "Not set".localized)
    }

    //
    class func getLineColor(goorback: String, keytag: String) -> UIColor {
        return FileAndData.getUserDefaultColor(
            key: goorback + "linecolor" + keytag,
            defaultvalue: 0x000000)!
    }
    
    //
    class func getStringRideTime(goorback: String, keytag: String) -> String {
        let ridetime = FileAndData.getUserDefaultInt(
            key: goorback + "ridetime" + keytag,
            defaultvalue: 0)
        return (ridetime == 0) ? "Not set".localized: String(ridetime) + "[min]".localized
    }
    
    //
    class func getTransportation(goorback: String, keytag: String) -> String {
        return FileAndData.getUserDefaultValue(
            key: goorback + "transport" + keytag,
            defaultvalue: "Not set".localized)
    }
    
    //
    class func getStringTransitTime(goorback: String, keytag: String) -> String {
        let ridetime = FileAndData.getUserDefaultInt(
            key: goorback + "transittime" + keytag,
            defaultvalue: 0)
        return (ridetime == 0) ? "Not set".localized: String(ridetime) + "[min]".localized
    }
}
