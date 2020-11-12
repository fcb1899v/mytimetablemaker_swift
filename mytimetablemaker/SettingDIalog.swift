//
//  SettingDIalog.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/11/07.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import Foundation
import UIKit

struct SettingDialog: Display {
    var viewcontroller: UIViewController
    var goorback: String
    init(_ viewcontroller: UIViewController, _ goorback: String) {
        self.viewcontroller = viewcontroller
        self.goorback = goorback
    }
    let register = Action.register.rawValue.localized
    let cancel = Action.cancel.rawValue.localized
    let minutes = Unit.minites.rawValue.localized
    let maxchar = Int("20".localized)!
}

extension SettingDialog {
    
    //選択設定ボタン
    func setChoiceChangeLineAction(_ title: String, _ label: UILabel, _ key: String, _ value: Int) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            label.text = title
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
    //登録ボタン：UserDefaultにデータ保存・ラベルにテキスト表示
    func setTextFieldRegisterAction(_ label: UILabel, _ textfield: UITextField, _ key: String) -> UIAlertAction {
        return UIAlertAction(title: register, style: .default) {
            (action: UIAlertAction) in
            if (textfield.text != nil || textfield.text != "" || textfield.text!.count <= maxchar) {
                label.text = textfield.text!
                UserDefaults.standard.set(textfield.text, forKey: key)
            }
        }
    }

    //キャンセルボタン
    func setCancelAction() -> UIAlertAction {
        return UIAlertAction(title: cancel, style: .cancel, handler: nil)
    }
    
    //乗換回数を設定するダイアログ
    func changeLinePickerDialog(_ taplabel: UILabel, _ setlabel: UILabel) {
        let title = DialogTitle.numtransit.rawValue.localized
        let message = taplabel.text
        let key = "\(goorback)changeline"
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let transittimearray: [String] = TransitTime.allCases.map{$0.rawValue.localized}
        let transitvaluearray: [Int] = TransitTime.allCases.map{$0.Number}
        for i in 0..<transittimearray.count {
            picker.addAction(setChoiceChangeLineAction(transittimearray[i], setlabel, key, transitvaluearray[i]))
        }
        picker.addAction(setCancelAction())
        viewcontroller.present(picker, animated: true, completion: nil)
    }
    
    //TextFieldの設定
    func textFieldAlert(_ title: String, _ message: String, _ key: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {
            (textfield: UITextField!) in
            textfield.text = key.userDefaultValue("")
            textfield.textAlignment = NSTextAlignment.center
            textfield.placeholder = Hint.maxchar.rawValue.localized
            textfield.keyboardType = .default})
        return alert
    }

    //TextFieldに文字入力をして設定するダイアログ
    func textFieldDialog(_ label: UILabel, _ title: String, _ message: String, _ key: String) {
        let alert = textFieldAlert(title, message, key)
        alert.addAction(setTextFieldRegisterAction(label, (alert.textFields?.first)!, key))
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }
 
    //出発地を設定するダイアログ
    func prefDeparturePointTextFieldDialog(_ label: UILabel) {
        let title = DialogTitle.departplace.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "destination": "departurepoint"
        textFieldDialog(label, title, message, key)
    }

    //設定画面の乗車駅名を設定するダイアログ
    func prefDepartStationTextFieldDialog(_ label: UILabel, _ keytag: String) {
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\("of departure station ".localized)\(keytag)"
        let key = "\(goorback)departstation\(keytag)"
        textFieldDialog(label, title, message, key)
    }
    
    //設定画面の降車駅名を設定するダイアログ
    func prefArriveStationTextFieldDialog(_ label: UILabel, _ keytag: String) {
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\("of arrival station ".localized)\(keytag)"
        let key = "\(goorback)arrivestation\(keytag)"
        textFieldDialog(label, title, message, key)
    }

    //目的地を設定するダイアログ
    func prefDestinationTextFieldDialog(_ label: UILabel) {
        let title = DialogTitle.destination.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
        textFieldDialog(label, title, message, key)
    }
    
    //設定画面の路線名を設定するダイアログ
    func prefLineTextFieldDialog(_ linenamelabel: UILabel, _ ridetimelabel: UILabel, _ keytag: String) {
        let title = DialogTitle.linename.rawValue.localized
        let message = "\("line ".localized)\(keytag)"
        let key = "\(goorback)linename\(keytag)"
        let alert = textFieldAlert(title, message, key)
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setTextFieldRegisterAction(linenamelabel, (alert.textFields?.first)!, key))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        //路線カラーの設定
        alert.addAction(prefLineColorDialogAction((alert.textFields?.first)!, linenamelabel, ridetimelabel, keytag))
        viewcontroller.present(alert, animated: true, completion: nil)
    }

    //設定画面の路線カラー設定ボタン：設定用ダイアログ表示・UserDefaultに路線データ保存・ラベルにテキスト表示
    func prefLineColorDialogAction(_ textfield: UITextField, _ linenamelabel: UILabel, _ ridetimelabel: UILabel, _ keytag: String) -> UIAlertAction {
        let title = DialogTitle.linecolor.rawValue.localized
        let namekey = "\(goorback)linename\(keytag)"
        let colorkey = "\(goorback)linecolor\(keytag)"
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            if (textfield.text != nil || textfield.text != "") {
                linenamelabel.text = textfield.text!
                UserDefaults.standard.set(textfield.text, forKey: namekey)
            }
            prefColorPickerDialog(linenamelabel, ridetimelabel, colorkey, keytag)
        }
    }

    //設定画面の路線カラー設定ボタン
    func prefColorRegisterAction(_ colortitle: String, _ color: Int, _ linenamelabel: UILabel, _ ridetimelabel: UILabel, _ colorkey: String) -> UIAlertAction {
        return UIAlertAction(title: colortitle, style: .default) {
            (action: UIAlertAction) in
                linenamelabel.textColor = UIColor(color)
                ridetimelabel.textColor = UIColor(color)
                UserDefaults.standard.set(color, forKey: colorkey)
        }
    }

    //設定画面の路線カラーを設定するダイアログ
    func prefColorPickerDialog(_ linenamelabel: UILabel, _ ridetimelabel: UILabel, _ colorkey: String, _ keytag: String) {
        let title = DialogTitle.linecolor.rawValue.localized
        let message = "\("of ".localized)\(goorback.lineName(keytag, "\("line ".localized)\(keytag)"))"
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let colorlistarray: [String] = CustomColor.allCases.map{$0.rawValue.localized}
        let colorvaluearray: [Int] = CustomColor.allCases.map{$0.RGB}
        picker.addAction(setCancelAction())
        for i in 0..<colorlistarray.count {
            picker.addAction(prefColorRegisterAction(colorlistarray[i], colorvaluearray[i], linenamelabel,ridetimelabel,colorkey))
        }
        viewcontroller.present(picker, animated: true, completion: nil)
    }

    //登録ボタン：UserDefaultにデータ保存
    func setPrefMinutesFieldRegisterAction(_ textfield: UITextField, _ label: UILabel, _ key: String, _ unit: String) -> UIAlertAction {
        return UIAlertAction(title: register, style: .default) {
            (action: UIAlertAction) in
            if (Int(textfield.text!) ?? 100 >= 0 && Int(textfield.text!) ?? 100 < 100) {
                label.text = "\(textfield.text!)\(minutes)"
                UserDefaults.standard.set(textfield.text, forKey: key)
            }
        }
    }
    
    //設定画面の乗車時間を設定するダイアログ
    func prefRideTimeFieldDialog(_ label: UILabel, _ keytag: String, _ weekflag: Bool) {
        let title = DialogTitle.ridetime.rawValue.localized
        let message = "\("on ".localized)\(goorback.lineName(keytag, "\("line ".localized)\(keytag)"))"
        let key = "\(goorback)ridetime\(keytag)"
        let unit = minutes
        //TextFieldのアラートを表示
        let alert = minutesFieldAlert(title, message, key)
        let textfield = (alert.textFields?.first)!
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setPrefMinutesFieldRegisterAction(textfield, label, key, unit))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        //時刻表遷移ボタン
        alert.addAction(storyboardTimetableAction(textfield, key, keytag, weekflag))
        viewcontroller.present(alert, animated: true, completion: nil)
    }
    
    //時刻表画面に遷移するアクション
    func storyboardTimetableAction(_ textfield: UITextField, _ key: String, _ keytag: String, _ weekflag: Bool) -> UIAlertAction{
        let title = DialogTitle.timetable.rawValue.localized
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            if (textfield.text != "") {UserDefaults.standard.set(textfield.text, forKey: key)}
            let storyboard = viewcontroller.storyboard!
            let vc = storyboard.instantiateViewController(withIdentifier: "timetableview") as! TimetableViewController
            vc.goorback = goorback
            vc.keytag = keytag
            vc.weekflag = weekflag
            viewcontroller.present(vc, animated: true)
        }
    }

    //乗車時間および乗換時間を設定するTextFieldの設定
    func minutesFieldAlert(_ title: String, _ message: String, _ key: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {
            (textfield: UITextField!) in
            textfield.text = key.userDefaultValue("")
            textfield.textAlignment = NSTextAlignment.center
            textfield.placeholder = Hint.to99min.rawValue.localized
            textfield.keyboardType = .phonePad})
        return alert
    }

    //設定画面の移動手段を設定するダイアログ
    func prefTransportPickerDialog(_ label: UILabel, _ keytag: String) {
        let departstation = goorback.transitDepartStation(keytag)
        let arrivestation = goorback.transitArriveStation(keytag)
        let title = DialogTitle.transport.rawValue.localized
        let message = "\("from ".localized)\(departstation)\(" to ".localized)\(arrivestation)"
        let key = "\(goorback)transport\(keytag)"
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let transportationarray: [String] = Transportation.allCases.map{$0.rawValue.localized}
        for i in 0..<transportationarray.count {
            picker.addAction(setChoiceRegisterAction(transportationarray[i], label, key))
        }
        picker.addAction(setCancelAction())
        viewcontroller.present(picker, animated: true, completion: nil)
    }
    
    //選択設定ボタン
    func setChoiceRegisterAction(_ title: String, _ label: UILabel, _ key: String) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            if (title != "") {
                label.text = title
                UserDefaults.standard.set(title, forKey: key)
            }
        }
    }

    //設定画面の乗換時間を設定するダイアログ
    func prefTransitTimeFieldDialog(_ label: UILabel, _ keytag: String) {
        let departstation = goorback.transitDepartStation(keytag)
        let arrivestation = goorback.transitArriveStation(keytag)
        let title = DialogTitle.transittime.rawValue.localized
        let message = "\("from ".localized)\(departstation)\(" to ".localized)\(arrivestation)"
        let key = "\(goorback)transittime\(keytag)"
        let unit = minutes
        //TextFieldのアラートを表示
        let alert = minutesFieldAlert(title, message, key)
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setPrefMinutesFieldRegisterAction((alert.textFields?.first)!, label, key, unit))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }
}

