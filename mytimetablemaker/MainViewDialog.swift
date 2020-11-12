//
//  AlertDialog.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/11.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//
import Foundation
import UIKit

struct MainViewDialog: Display {
    var viewcontroller: UIViewController
    var goorback: String
    init(_ viewcontroller: UIViewController, _ goorback: String) {
        self.viewcontroller = viewcontroller
        self.goorback = goorback
    }
    let register = Action.register.rawValue.localized
    let cancel = Action.cancel.rawValue.localized
    let minites = Unit.minites.rawValue.localized
    let maxchar = Int("20".localized)!
}

extension MainViewDialog {
    
    //TextFieldに文字入力をして設定するダイアログ
    func textFieldDialog(_ label: UILabel, _ title: String, _ message: String, _ key: String) {
        let alert = textFieldAlert(title, message, key)
        alert.addAction(setTextFieldRegisterAction(label, (alert.textFields?.first)!, key))
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
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
    
    //出発地を設定するダイアログ
    func departurePointTextFieldDialog(_ label: UILabel) {
        let title = DialogTitle.departplace.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "destination": "departurepoint"
        textFieldDialog(label, title, message, key)
    }

    //乗車駅名を設定するダイアログ
    func departStationTextFieldDialog(_ label: UILabel, _ keytag: String) {
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\("of departure station ".localized)\(keytag)"
        let key = "\(goorback)departstation\(keytag)"
        textFieldDialog(label, title, message, key)
    }
    
    //降車駅名を設定するダイアログ
    func arriveStationTextFieldDialog(_ label: UILabel, _ keytag: String) {
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\("of arrival station ".localized)\(keytag)"
        let key = "\(goorback)arrivestation\(keytag)"
        textFieldDialog(label, title, message, key)
    }
    
    //目的地を設定するダイアログ
    func destinationTextFieldDialog(_ label: UILabel) {
        let title = DialogTitle.destination.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
        textFieldDialog(label, title, message, key)
    }

    //路線名を設定するダイアログ
    func lineTextFieldDialog(_ label: UILabel, _ stackview: UIStackView, _ keytag: String) {
        let title = DialogTitle.linename.rawValue.localized
        let message = "\("of ".localized)\("line ".localized)\(keytag)"
        let key = "\(goorback)linename\(keytag)"
        let alert = textFieldAlert(title, message, key)
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setTextFieldRegisterAction(label, (alert.textFields?.first)!, key))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        //路線カラーの設定
        alert.addAction(setLineColorDialogAction(label, (alert.textFields?.first)!, stackview, keytag))
        viewcontroller.present(alert, animated: true, completion: nil)
    }
    
    //路線カラー設定ボタン：設定用ダイアログ表示・UserDefaultに路線データ保存・ラベルにテキスト表示
    func setLineColorDialogAction(_ label: UILabel, _ textfield: UITextField, _ stackview: UIStackView, _ keytag: String) -> UIAlertAction {
        let title = DialogTitle.linecolor.rawValue.localized
        let namekey = "\(goorback)linename\(keytag)"
        let colorkey = "\(goorback)linecolor\(keytag)"
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            if (textfield.text != nil || textfield.text != "") {
                UserDefaults.standard.set(textfield.text, forKey: namekey)
            }
            colorPickerDialog(label, stackview, colorkey, keytag)
        }
    }
  
    //路線カラー設定ボタン
    func setColorRegisterAction(_ colortitle: String, _ color: Int, _ label: UILabel, _ stackview: UIStackView, _ colorkey: String) -> UIAlertAction {
        return UIAlertAction(title: colortitle, style: .default) {
            (action: UIAlertAction) in
                label.textColor = UIColor(color)
                stackview.backgroundColor = UIColor(color)
                UserDefaults.standard.set(color, forKey: colorkey)
        }
    }
    
    //路線カラーを設定するダイアログ
    func colorPickerDialog(_ label: UILabel, _ stackview: UIStackView, _ colorkey: String, _ keytag: String) {
//        if #available(iOS 14.0, *) {
//            let colorpicker = UIColorPickerViewController()
//            colorpicker.supportsAlpha = false
//            colorpicker.delegate = viewcontroller as? UIColorPickerViewControllerDelegate
//            label.textColor = colorpicker.selectedColor
//            stackview.backgroundColor = colorpicker.selectedColor
//            viewcontroller.present(colorpicker, animated: true, completion: nil)
//        } else {
//        }
        let title = DialogTitle.linecolor.rawValue.localized
        let message = "\("of ".localized)\(goorback.lineName(keytag, "line ".localized + keytag))"
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let colorlistarray: [String] = CustomColor.allCases.map{$0.rawValue.localized}
        let colorvaluearray: [Int] = CustomColor.allCases.map{$0.RGB}
        for i in 0..<colorlistarray.count {
            picker.addAction(setColorRegisterAction(colorlistarray[i], colorvaluearray[i], label, stackview, colorkey))
        }
        picker.addAction(setCancelAction())
        viewcontroller.present(picker, animated: true, completion: nil)
    }

    //移動手段を設定するダイアログ
    func transportPickerDialog(_ label: UILabel, _ keytag: String) {
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

    //登録ボタン：UserDefaultにデータ保存
    func setMinutesFieldRegisterAction(_ textfield: UITextField, _ key: String, _ unit: String) -> UIAlertAction {
        return UIAlertAction(title: Action.register.rawValue.localized, style: .default) {
            (action: UIAlertAction) in
            if (Int(textfield.text!) ?? 100 >= 0 && Int(textfield.text!) ?? 100 < 100) {
                UserDefaults.standard.set(textfield.text, forKey: key)
            }
        }
    }
    
    //乗換時間を設定するダイアログ
    func transitTimeFieldDialog(_ keytag: String) {
        let departstation = goorback.transitDepartStation(keytag)
        let arrivestation = goorback.transitArriveStation(keytag)
        let title = DialogTitle.transittime.rawValue.localized
        let message = "\("from ".localized)\(departstation)\(" to ".localized)\(arrivestation)"
        let key = "\(goorback)transittime\(keytag)"
        let unit = minites
        //TextFieldのアラートを表示
        let alert = minutesFieldAlert(title, message, key)
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setMinutesFieldRegisterAction((alert.textFields?.first)!, key, unit))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }

    //乗車時間を設定するダイアログ
    func rideTimeFieldDialog(_ stackview: UIStackView, _ keytag: String, _ weekflag: Bool) {
        let title = DialogTitle.ridetime.rawValue.localized
        let message = "\("on ".localized)\(goorback.lineName(keytag, "\("Line ".localized)\(keytag)"))"
        let key = "\(goorback)ridetime\(keytag)"
        let unit = minites
        //TextFieldのアラートを表示
        let alert = minutesFieldAlert(title, message, key)
        let textfield = (alert.textFields?.first)!
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setMinutesFieldRegisterAction(textfield, key, unit))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
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
}
