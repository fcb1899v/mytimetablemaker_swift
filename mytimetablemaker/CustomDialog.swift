//
//  AlertDialog.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/11.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class CustomDialog: NSObject {

    //日時を設定するアラートを設定
    class func getDatePicker(datepickermode: UIDatePicker.Mode) -> UIDatePicker{
        let datepicker = UIDatePicker()
        datepicker.date = Date()
        datepicker.datePickerMode = datepickermode
        datepicker.timeZone = NSTimeZone.local
        datepicker.locale = Locale.current
        return datepicker
    }

    //日時を設定するダイアログを表示
    class func setDatePickerDialog(viewcontroller: UIViewController, datepickermode: UIDatePicker.Mode, datebutton: UIButton, stringformat: String){
        let datepicker = getDatePicker(datepickermode: datepickermode)
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datepicker)
        alert.addAction(setDateRegisterAction(datebutton: datebutton, datepicker: datepicker, stringformat: stringformat))
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }

    //日時設定・表示ボタン
    class func setDateRegisterAction(datebutton: UIButton, datepicker: UIDatePicker, stringformat: String) -> UIAlertAction {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = stringformat
        return UIAlertAction(title: "Register".localized, style: .default){ (action) in
             let datestring = dateformatter.string(from: datepicker.date)
             datebutton.setTitle(datestring,for: UIControl.State.normal)
        }
    }
    
    //キャンセルボタン
    class func setCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
    }

    //駅名および路線名を設定するTextFieldの設定
    class func getTextFieldAlert(title: String, message: String, key: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {
            (textfield: UITextField!) in
            textfield.text = FileAndData.getUserDefaultValue(key: key, defaultvalue: "")
            textfield.textAlignment = NSTextAlignment.center
            textfield.placeholder = "Maximum 20 Charactors".localized
            textfield.keyboardType = .default})
        return alert
    }

    //TextFieldに文字入力をして設定するダイアログ
    class func textFieldDialog(viewcontroller: UIViewController, label: UILabel, title: String, message: String, key: String) {
        let alert = getTextFieldAlert(title: title, message: message, key: key)
        alert.addAction(setTextFieldRegistorAction(label: label, textfield: (alert.textFields?.first)!, key: key))
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }
 
    //乗車駅名を設定するダイアログ
    class func departStationTextFieldDialog(viewcontroller: UIViewController, label: UILabel, goorback: String, keytag: String) {
        let title = "Setting your station name ".localized
        let message = (goorback == "back2" || goorback == "go2") ?
            "of departure station ".localized + "2-" + keytag:
            "of departure station ".localized + "1-" + keytag
        let key = goorback + "departstation" + keytag
        textFieldDialog(viewcontroller: viewcontroller, label: label, title: title, message: message, key: key)
    }
    
    //降車駅名を設定するダイアログ
    class func arriveStationTextFieldDialog(viewcontroller: UIViewController, label: UILabel, goorback: String, keytag: String) {
        let title = "Setting your station name ".localized
        let message = (goorback == "back2" || goorback == "go2") ?
            "of arrival station ".localized + "2-" + keytag:
            "of arrival station ".localized + "1-" + keytag
        let key = goorback + "arrivestation" + keytag
        textFieldDialog(viewcontroller: viewcontroller, label: label, title: title, message: message, key: key)
    }

    //出発地を設定するダイアログ
    class func departurepointTextFieldDialog(viewcontroller: UIViewController, label: UILabel, goorback: String) {
        let title = "Setting your departure place".localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "destination": "departurepoint"
        textFieldDialog(viewcontroller: viewcontroller, label: label, title: title, message: message, key: key)
    }

    //目的地を設定するダイアログ
    class func destinationTextFieldDialog(viewcontroller: UIViewController, label: UILabel, goorback: String) {
        let title = "Setting your destination".localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
        textFieldDialog(viewcontroller: viewcontroller, label: label, title: title, message: message, key: key)
    }

    //登録ボタン：UserDefaultにデータ保存・ラベルにテキスト表示
    class func setTextFieldRegistorAction(label: UILabel, textfield: UITextField, key: String) -> UIAlertAction {
        return UIAlertAction(title: "Register".localized, style: .default) {
            (action: UIAlertAction) in
            label.text = textfield.text!
            if (textfield.text != "") {UserDefaults.standard.set(textfield.text, forKey: key)}
        }
    }
    
    //登録ボタン：UserDefaultにデータ保存
    class func setMinutesFieldRegistorAction(textfield: UITextField, key: String, unit: String) -> UIAlertAction {
        return UIAlertAction(title: "Register".localized, style: .default) {
            (action: UIAlertAction) in
            if (textfield.text != "") {UserDefaults.standard.set(textfield.text, forKey: key)}
        }
    }

    //路線名を設定するダイアログ
    class func lineTextFieldDialog(viewcontroller: UIViewController, label: UILabel, stackview: UIStackView, goorback: String, keytag: String) {
        let title = "Setting your line name".localized
        let message = (goorback == "back2" || goorback == "go2") ?
            "of ".localized + "line ".localized + "2-" + keytag:
            "of ".localized + "line ".localized + "1-" + keytag
        let key = goorback + "linename" + keytag
        let alert = getTextFieldAlert(title: title, message: message, key: key)
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setTextFieldRegistorAction(label: label, textfield: (alert.textFields?.first)!, key: key))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        //路線カラーの設定
        alert.addAction(setLineColorDialogAction(viewcontroller: viewcontroller, textfield: (alert.textFields?.first)!, label: label, stackview: stackview, goorback: goorback, keytag: keytag))
        viewcontroller.present(alert, animated: true, completion: nil)
    }

    //路線カラー設定ボタン：設定用ダイアログ表示・UserDefaultに路線データ保存・ラベルにテキスト表示
    class func setLineColorDialogAction(viewcontroller: UIViewController, textfield: UITextField, label: UILabel, stackview: UIStackView, goorback: String, keytag: String) -> UIAlertAction {
        let title = "Setting your line color".localized
        let namekey = goorback + "linename" + keytag
        let colorkey = goorback + "linecolor" + keytag
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            if (textfield.text != nil) {
                label.text = textfield.text!
                if (textfield.text != "") {UserDefaults.standard.set(textfield.text, forKey: namekey)}
            }
            colorPickerDialog(viewcontroller: viewcontroller, label: label, stackview: stackview, colorkey: colorkey, goorback: goorback, keytag: keytag)
        }
    }
  
    //路線カラー設定ボタン
    class func setColorRegistorAction(colortitle: String, color: Int, label: UILabel, stackview: UIStackView, colorkey: String) -> UIAlertAction {
        return UIAlertAction(title: colortitle, style: .default) {
            (action: UIAlertAction) in
                label.textColor = UIColor(rgb: color)
                stackview.backgroundColor = UIColor(rgb: color)
                UserDefaults.standard.set(color, forKey: colorkey)
        }
    }
    
    //路線カラーを設定するダイアログ
    class func colorPickerDialog(viewcontroller: UIViewController, label: UILabel, stackview: UIStackView, colorkey: String, goorback: String, keytag: String) {
//        if #available(iOS 14.0, *) {
//            let colorpicker = UIColorPickerViewController()
//            colorpicker.supportsAlpha = false
//            colorpicker.delegate = viewcontroller as? UIColorPickerViewControllerDelegate
//            label.textColor = colorpicker.selectedColor
//            stackview.backgroundColor = colorpicker.selectedColor
//            viewcontroller.present(colorpicker, animated: true, completion: nil)
//        } else {
//        }
        let title = "Setting your line color".localized
        let namekey = goorback + "linename" + keytag
        let defaultvalue = (goorback == "back2" || goorback == "go2") ?
            "line ".localized + "2-" + keytag:
            "line ".localized + "1-" + keytag
        let message = "of ".localized + FileAndData.getUserDefaultValue(key: namekey, defaultvalue: defaultvalue)
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let colorarray = [
            ["DEFAULT".localized, 0x03DAC5],
            ["RED".localized, 0xFF0000],
            ["ORANGE".localized, 0xF68B1E],
            ["YELLOW".localized, 0xFFD400],
            ["YELLOW GREEN".localized, 0x99CC00],
            ["GREEN".localized, 0x009933],
            ["BLUE GREEN".localized, 0x00AC9A],
            ["LIGHT BLUE".localized, 0x00BAE8],
            ["BLUE".localized, 0x0000FF],
            ["NAVY BLUE".localized, 0x003686],
            ["PURPLE".localized, 0xA757A8],
            ["PINK".localized, 0xE85298],
            ["DARK RED".localized, 0xC9252F],
            ["BROWN".localized, 0xBB6633],
            ["GOLD".localized, 0xC5C544],
            ["SILVER".localized, 0x89A1AD],
            ["BLACK".localized, 0x000000]]
        picker.addAction(setCancelAction())
        for i in 0..<colorarray.count {
            picker.addAction(
                setColorRegistorAction(
                    colortitle: colorarray[i][0] as! String,
                    color: colorarray[i][1] as! Int,
                    label: label,
                    stackview: stackview,
                    colorkey: colorkey))
        }
        viewcontroller.present(picker, animated: true, completion: nil)
    }

    //移動手段を設定するダイアログ
    class func transportPickerDialog(viewcontroller: UIViewController, label: UILabel, goorback: String, keytag: String) {
        let title = "Setting your transportation".localized
        let message = "from ".localized + FileAndData.getTransitDepartStation(goorback: goorback, keytag: keytag) + "kara".localized
        let key = goorback + "transport" + keytag
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        picker.addAction(setChoiceRegistorAction(title: "Walking".localized, label: label, key: key))
        picker.addAction(setChoiceRegistorAction(title: "Bicycle".localized, label: label, key: key))
        picker.addAction(setChoiceRegistorAction(title: "Car".localized, label: label, key: key))
        picker.addAction(setCancelAction())
        viewcontroller.present(picker, animated: true, completion: nil)
    }
 
    //選択設定ボタン
    class func setChoiceRegistorAction(title: String, label: UILabel, key: String) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
                label.text = title
                UserDefaults.standard.set(title, forKey: key)
        }
    }

    //乗車時間および乗換時間を設定するTextFieldの設定
    class func getMinutesFieldAlert(title: String, message: String, key: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {
            (textfield: UITextField!) in
            textfield.text = FileAndData.getUserDefaultValue(key: key, defaultvalue: "")
            textfield.textAlignment = NSTextAlignment.center
            textfield.placeholder = "Enter 0~99 [min]".localized
            textfield.keyboardType = .phonePad})
        return alert
    }

    //乗換時間を設定するダイアログ
    class func transitTimeFieldDialog(viewcontroller: UIViewController, goorback: String, keytag: String) {
        let departstation = FileAndData.getTransitDepartStation(goorback: goorback, keytag: keytag)
        let arrivestation = FileAndData.getTransitArriveStation(goorback: goorback, keytag: keytag)
        let title = "Setting your required time [min]".localized
        let message = "from ".localized + departstation + " to ".localized + arrivestation
        let key = goorback + "transittime" + keytag
        let unit = "[min]".localized
        //TextFieldのアラートを表示
        let alert = getMinutesFieldAlert(title: title, message: message, key: key)
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setMinutesFieldRegistorAction(textfield: (alert.textFields?.first)!, key: key, unit: unit))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }

    //乗車時間を設定するダイアログ
    class func rideTimeFieldDialog(viewcontroller: UIViewController, stackview: UIStackView, goorback: String, keytag: String, weekflag: Bool) {
        let linekey = goorback + "linename" + keytag
        let defaultvalue = (goorback == "back2" || goorback == "go2") ?
            "Line ".localized + "2-" + keytag:
            "Line ".localized + "1-" + keytag
        let linename = FileAndData.getUserDefaultValue(key: linekey, defaultvalue: defaultvalue)
        let title = "Setting your ride time".localized + " " + "[min]".localized
        let message = "on ".localized + linename
        let key = goorback + "ridetime" + keytag
        let unit = "[min]".localized
        //TextFieldのアラートを表示
        let alert = getMinutesFieldAlert(title: title, message: message, key: key)
        let textfield = (alert.textFields?.first)!
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setMinutesFieldRegistorAction(textfield: textfield, key: key, unit: unit))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        alert.addAction(storyboardTimetableAction(viewcontroller: viewcontroller, textfield: textfield, key: key, goorback: goorback, keytag: keytag, weekflag: weekflag))
        viewcontroller.present(alert, animated: true, completion: nil)
    }

    //時刻表画面に遷移するアクション
    class func storyboardTimetableAction(viewcontroller: UIViewController, textfield: UITextField, key: String, goorback: String, keytag: String, weekflag: Bool) -> UIAlertAction{
        let title = "Setting your timetable".localized
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
    
    //乗換回数を設定するダイアログ
    class func changeLinePickerDialog(viewcontroller: UIViewController, taplabel: UILabel, setlabel: UILabel, goorback: String) {
        let title = "Setting your number of transfers".localized
        let message = taplabel.text
        let key = goorback + "changeline"
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        picker.addAction(setChoiceChangeLineAction(title: "Zero".localized, label: setlabel, key: key))
        picker.addAction(setChoiceChangeLineAction(title: "Once".localized, label: setlabel, key: key))
        picker.addAction(setChoiceChangeLineAction(title: "Twice".localized, label: setlabel, key: key))
        picker.addAction(setCancelAction())
        viewcontroller.present(picker, animated: true, completion: nil)
    }
    
    //選択設定ボタン
    class func setChoiceChangeLineAction(title: String, label: UILabel, key: String) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            label.text = title
            var changeline = 0
            switch (title) {
                case "Zero".localized: changeline = 0
                case "Once".localized: changeline = 1
                case "Twice".localized: changeline = 2
                default: changeline = 0
            }
            UserDefaults.standard.set(changeline, forKey: key)
        }
    }
 
    //時刻を追加する関数
    class func addTimeFromTimetable(label: UILabel, addtext: String, timekey: String) -> String {
        let splitunit = " "
        let currenttext = FileAndData.getUserDefaultValue(key: timekey, defaultvalue: "")
        let temptext = (currenttext + splitunit + addtext)
            .trimmingCharacters(in: .whitespaces)
        let textarray = Array(Set(temptext
                .components(separatedBy: CharacterSet(charactersIn: splitunit))
                .map{Int($0) ?? 60}
                .filter{$0 < 60}
                .filter{$0 > -1}
            ))
            .sorted()
            .map{String($0)}
        let edittext = textarray.joined(separator: splitunit)
        UserDefaults.standard.set(edittext, forKey: timekey)
        return edittext
    }
    
    //時刻を削除する関数
    class func deleteTimeFromTimetable(label: UILabel, deletetext: String, timekey: String) -> String {
        let splitunit = " "
        let currenttext = FileAndData.getUserDefaultValue(key: timekey, defaultvalue: "")
        let temparray = Array(Set(currenttext
            .components(separatedBy: CharacterSet(charactersIn: splitunit))
                .map{Int($0) ?? 60}
                .filter{$0 < 60}
                .filter{$0 > -1}
            ))
        let textarray = temparray
            .sorted()
            .map{String($0)}
            .filter{$0 != deletetext}
        let edittext = textarray.joined(separator: splitunit)
        UserDefaults.standard.set(edittext, forKey: timekey)
        return edittext
    }

    //時刻表の時刻を設定するTextFieldの設定
    class func getTimeFieldAlert(title: String, message: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {
            (textfield: UITextField!) in
            textfield.textAlignment = NSTextAlignment.center
            textfield.placeholder = "Enter 0~99 [min]".localized
            textfield.keyboardType = .phonePad})
        return alert
    }

    //時刻表の時刻登録ボタン：UserDefaultにデータ保存
    class func setTimeFieldRegistorAction(viewcontroller: UIViewController, textfield: UITextField, label: UILabel, timekey: String, goorback: String, weekflag: Bool, keytag: String, timekeytag: String) -> UIAlertAction {
        return UIAlertAction(title: "Register".localized, style: .default) {
            (action: UIAlertAction) in
            let edittext = addTimeFromTimetable(label: label, addtext: textfield.text ?? "", timekey: timekey)
            label.text = edittext
            setTimeFieldDialog(viewcontroller: viewcontroller, label: label, goorback: goorback, weekflag: weekflag, keytag: keytag, timekeytag: timekeytag)
        }
    }

    //時刻表の時刻登録ボタン：UserDefaultにデータ保存
    class func deleteTimeFieldRegistorAction(textfield: UITextField, label: UILabel, timekey: String) -> UIAlertAction {
        return UIAlertAction(title: "Delete".localized, style: .destructive) {
            (action: UIAlertAction) in
            let edittext = deleteTimeFromTimetable(label: label, deletetext: textfield.text ?? "", timekey: timekey)
            label.text = edittext
        }
    }
    
    //時刻表の時刻を登録・削除するダイアログ
    class func setTimeFieldDialog(viewcontroller: UIViewController, label: UILabel, goorback: String, weekflag: Bool, keytag: String, timekeytag: String) {
        let key = goorback + "linename" + keytag
        let defaultvalue = (goorback == "back2" || goorback == "go2") ?
            "Line ".localized + "2-" + keytag:
            "Line ".localized + "1-" + keytag
        let linename = FileAndData.getUserDefaultValue(key: key, defaultvalue: defaultvalue)
        let weektag = (weekflag) ? "weekday".localized: "weekend".localized
        let title = "Setting your timetable".localized + " " + "[min]".localized
        let message = "on ".localized + linename
        let timekey = goorback + "line" + keytag + weektag + timekeytag
        //TextFieldのアラートを表示
        let alert = getTimeFieldAlert(title: title, message: message)
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setTimeFieldRegistorAction(viewcontroller: viewcontroller, textfield: (alert.textFields?.first)!, label: label, timekey: timekey, goorback: goorback, weekflag: weekflag, keytag: keytag, timekeytag: timekeytag))
        //削除ボタンの表示：入力したTextを削除する
        alert.addAction(deleteTimeFieldRegistorAction(textfield: (alert.textFields?.first)!, label: label, timekey: timekey))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }
    
    //＜設定画面＞
    //設定画面の乗車駅名を設定するダイアログ
    class func prefDepartStationTextFieldDialog(viewcontroller: UIViewController, label: UILabel, goorback: String, keytag: String) {
        let title = "Setting your station name ".localized
        let message = "of departure station ".localized + keytag
        let key = goorback + "departstation" + keytag
        textFieldDialog(viewcontroller: viewcontroller, label: label, title: title, message: message, key: key)
    }
    
    //設定画面の降車駅名を設定するダイアログ
    class func prefArriveStationTextFieldDialog(viewcontroller: UIViewController, label: UILabel, goorback: String, keytag: String) {
        let title = "Setting your station name ".localized
        let message = "of arrival station ".localized + keytag
        let key = goorback + "arrivestation" + keytag
        textFieldDialog(viewcontroller: viewcontroller, label: label, title: title, message: message, key: key)
    }

    //設定画面の路線名を設定するダイアログ
    class func prefLineTextFieldDialog(viewcontroller: UIViewController, linenamelabel: UILabel, ridetimelabel: UILabel, goorback: String, keytag: String) {
        let title = "Setting your line name".localized
        let message = "line ".localized + keytag
        let key = goorback + "linename" + keytag
        let alert = getTextFieldAlert(title: title, message: message, key: key)
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setTextFieldRegistorAction(label: linenamelabel, textfield: (alert.textFields?.first)!, key: key))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        //路線カラーの設定
        alert.addAction(prefLineColorDialogAction(viewcontroller: viewcontroller, textfield: (alert.textFields?.first)!, linenamelabel: linenamelabel, ridetimelabel: ridetimelabel, goorback: goorback, keytag: keytag))
        viewcontroller.present(alert, animated: true, completion: nil)
    }

    //設定画面の路線カラー設定ボタン：設定用ダイアログ表示・UserDefaultに路線データ保存・ラベルにテキスト表示
    class func prefLineColorDialogAction(viewcontroller: UIViewController, textfield: UITextField, linenamelabel: UILabel, ridetimelabel: UILabel, goorback: String, keytag: String) -> UIAlertAction {
        let title = "Setting your line color".localized
        let namekey = goorback + "linename" + keytag
        let colorkey = goorback + "linecolor" + keytag
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            if (textfield.text != nil) {
                linenamelabel.text = textfield.text!
                if (textfield.text != "") {UserDefaults.standard.set(textfield.text, forKey: namekey)}
            }
            prefColorPickerDialog(viewcontroller: viewcontroller, linenamelabel: linenamelabel, ridetimelabel: ridetimelabel, colorkey: colorkey, goorback: goorback, keytag: keytag)
        }
    }

    //設定画面の路線カラー設定ボタン
    class func prefColorRegistorAction(colortitle: String, color: Int, linenamelabel: UILabel, ridetimelabel: UILabel, colorkey: String) -> UIAlertAction {
        return UIAlertAction(title: colortitle, style: .default) {
            (action: UIAlertAction) in
                linenamelabel.textColor = UIColor(rgb: color)
                ridetimelabel.textColor = UIColor(rgb: color)
                UserDefaults.standard.set(color, forKey: colorkey)
        }
    }

    //設定画面の路線カラーを設定するダイアログ
    class func prefColorPickerDialog(viewcontroller: UIViewController, linenamelabel: UILabel, ridetimelabel: UILabel, colorkey: String, goorback: String, keytag: String) {
        let linenamekey = goorback + "linename" + keytag
        let defaultvalue = "line ".localized + keytag
        let linename = FileAndData.getUserDefaultValue(key: linenamekey, defaultvalue: defaultvalue)
        let title = "Setting your line color".localized
        let message = "of ".localized + linename
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let colorarray = [
            ["DEFAULT".localized, 0x03DAC5],
            ["RED".localized, 0xFF0000],
            ["ORANGE".localized, 0xF68B1E],
            ["YELLOW".localized, 0xFFD400],
            ["YELLOW GREEN".localized, 0x99CC00],
            ["GREEN".localized, 0x009933],
            ["BLUE GREEN".localized, 0x00AC9A],
            ["LIGHT BLUE".localized, 0x00BAE8],
            ["BLUE".localized, 0x0000FF],
            ["NAVY BLUE".localized, 0x003686],
            ["PURPLE".localized, 0xA757A8],
            ["PINK".localized, 0xE85298],
            ["DARK RED".localized, 0xC9252F],
            ["BROWN".localized, 0xBB6633],
            ["GOLD".localized, 0xC5C544],
            ["SILVER".localized, 0x89A1AD],
            ["BLACK".localized, 0x000000]]
        picker.addAction(setCancelAction())
        for i in 0..<colorarray.count {
            picker.addAction(
                prefColorRegistorAction(
                    colortitle: colorarray[i][0] as! String,
                    color: colorarray[i][1] as! Int,
                    linenamelabel: linenamelabel,
                    ridetimelabel: ridetimelabel,
                    colorkey: colorkey))
        }
        viewcontroller.present(picker, animated: true, completion: nil)
    }

    //設定画面の乗車時間を設定するダイアログ
    class func prefRideTimeFieldDialog(viewcontroller: UIViewController, goorback: String, keytag: String, weekflag: Bool) {
        let linenamekey = goorback + "linename" + keytag
        let defaultvalue = "line ".localized + keytag
        let linename = FileAndData.getUserDefaultValue(key: linenamekey, defaultvalue: defaultvalue)
        let title = "Setting your ride time".localized + " " + "[min]".localized
        let message = "on ".localized + linename
        let key = goorback + "ridetime" + keytag
        let unit =  "[min]".localized
        //TextFieldのアラートを表示
        let alert = getMinutesFieldAlert(title: title, message: message, key: key)
        let textfield = (alert.textFields?.first)!
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setMinutesFieldRegistorAction(textfield: textfield, key: key, unit: unit))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        //時刻表遷移ボタン
        alert.addAction(storyboardTimetableAction(viewcontroller: viewcontroller, textfield: textfield, key: key, goorback: goorback, keytag: keytag, weekflag: weekflag))
        viewcontroller.present(alert, animated: true, completion: nil)
    }
    
    //設定画面の移動手段を設定するダイアログ
    class func prefTransportPickerDialog(viewcontroller: UIViewController, label: UILabel, goorback: String, keytag: String) {
        let title = "Setting your transportation".localized
        let message = ""
        let key = goorback + "transport" + keytag
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        picker.addAction(setChoiceRegistorAction(title: "Walking".localized, label: label, key: key))
        picker.addAction(setChoiceRegistorAction(title: "Bicycle".localized, label: label, key: key))
        picker.addAction(setChoiceRegistorAction(title: "Car".localized, label: label, key: key))
        picker.addAction(setCancelAction())
        viewcontroller.present(picker, animated: true, completion: nil)
    }
    
    //設定画面の乗換時間を設定するダイアログ
    class func prefTransitTimeFieldDialog(viewcontroller: UIViewController, goorback: String, keytag: String) {
        let title = "Setting your required time [min]".localized
        let message = ""
        let key = goorback + "transittime" + keytag
        let unit = "[min]".localized
        //TextFieldのアラートを表示
        let alert = getMinutesFieldAlert(title: title, message: message, key: key)
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setMinutesFieldRegistorAction(textfield: (alert.textFields?.first)!, key: key, unit: unit))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }

}

