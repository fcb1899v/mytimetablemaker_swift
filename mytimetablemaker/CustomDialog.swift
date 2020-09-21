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

        // ピッカー設定
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
        return UIAlertAction(title: "Register", style: .default
        ){ (action) in
             let datestring = dateformatter.string(from: datepicker.date)
             datebutton.setTitle(datestring,for: UIControl.State.normal)
        }
    
    }
    
    //キャンセルボタン
    class func setCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    }

    //駅名および路線名を設定するTextFieldの設定
    class func getTextFieldAlert(title: String, key: String) -> UIAlertController{

        let alert = UIAlertController(
            title: title,
            message: "",
            preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {
            (textfield: UITextField!) in
            textfield.text = FileAndData.getUserDefaultValue(key: key, defaultvalue: "")
            textfield.textAlignment = NSTextAlignment.center
            textfield.placeholder = "Maximum 20 Charactors"
            textfield.keyboardType = .default})
        return alert
        
    }

    //TextFieldに文字入力をして設定するダイアログ
    class func textFieldDialog(viewcontroller: UIViewController, label: UILabel, title: String, key: String) {

        let alert = getTextFieldAlert(title: title, key: key)
        alert.addAction(setTextFieldRegistorAction(label: label, textfield: (alert.textFields?.first)!, key: key))
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    
    }
    
    //駅名を設定するダイアログ
    class func stationTextFieldDialog(viewcontroller: UIViewController, label: UILabel, goorback: String, keytag: String) {

        let title = "Setting your station name "
        let key = goorback + "station" + keytag
        textFieldDialog(viewcontroller: viewcontroller, label: label, title: title, key: key)
    
    }

    //出発地を設定するダイアログ
    class func departurepointTextFieldDialog(viewcontroller: UIViewController, label: UILabel, goorback: String) {
        
        let title = "Setting your departure point"
        var key = "departurepoint"
        if (goorback == "back1" || goorback == "back2") {
            key = "destination"
        }
        textFieldDialog(viewcontroller: viewcontroller, label: label, title: title, key: key)

    }

    //目的地を設定するダイアログ
    class func destinationTextFieldDialog(viewcontroller: UIViewController, label: UILabel, goorback: String) {

        let title = "Setting your destination"
        var key = "destination"
        if (goorback == "back1" || goorback == "back2") {
            key = "departurepoint"
        }
        textFieldDialog(viewcontroller: viewcontroller, label: label, title: title, key: key)

    }

    //登録ボタン：UserDefaultにデータ保存・ラベルにテキスト表示
    class func setTextFieldRegistorAction(label: UILabel, textfield: UITextField, key: String) -> UIAlertAction {
        return UIAlertAction(title: "Register", style: .default) {
            (action: UIAlertAction) in
            label.text = textfield.text!
            UserDefaults.standard.set(textfield.text, forKey: key)
        }
    }
    
    //登録ボタン：UserDefaultにデータ保存
    class func setMinutesFieldRegistorAction(textfield: UITextField, key: String, unit: String) -> UIAlertAction {
        return UIAlertAction(title: "Register", style: .default) {
            (action: UIAlertAction) in
            UserDefaults.standard.set(textfield.text, forKey: key)
        }
    }

    //路線名を設定するダイアログ
    class func lineTextFieldDialog(viewcontroller: UIViewController, label: UILabel, stackview: UIStackView, goorback: String, keytag: String) {

        //TextFieldのアラートを表示
        let title = "Setting your line name"
        let key = goorback + "linename" + keytag
        let alert = getTextFieldAlert(title: title, key: key)
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
    
        let title = "Setting your line color"
        let namekey = goorback + "linename" + keytag
        let colorkey = goorback + "linecolor" + keytag
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
                if (textfield.text != nil) {
                    label.text = textfield.text!
                    UserDefaults.standard.set(textfield.text, forKey: namekey)
                }
            colorPickerDialog(viewcontroller: viewcontroller, label: label, stackview: stackview, colorkey: colorkey)
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
    class func colorPickerDialog(viewcontroller: UIViewController, label: UILabel, stackview: UIStackView, colorkey: String) {
//        if #available(iOS 14.0, *) {
//            let colorpicker = UIColorPickerViewController()
//            colorpicker.supportsAlpha = false
//            colorpicker.delegate = viewcontroller as? UIColorPickerViewControllerDelegate
//            label.textColor = colorpicker.selectedColor
//            stackview.backgroundColor = colorpicker.selectedColor
//            viewcontroller.present(colorpicker, animated: true, completion: nil)
//        } else {
            let picker = UIAlertController(title: "Setting your line color", message: "", preferredStyle: UIAlertController.Style.alert)
            picker.addAction(setColorRegistorAction(colortitle: "DEFAULT", color: 0x03DAC5, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "RED", color: 0xFF0000, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "ORANGE", color: 0xF68B1E, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "YELLOW", color: 0xFFD400, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "YELLOW GREEN", color: 0x99CC00, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "GREEN", color: 0x009933, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "BLUE GREEN", color: 0x00AC9A, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "LIGHT BLUE", color: 0x00BAE8, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "BLUE", color: 0x0000FF, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "NAVY BLUE", color: 0x003686, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "PURPLE", color: 0xA757A8, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "PINK", color: 0xE85298, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "DARK RED", color: 0xC9252F, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "BROWN", color: 0xBB6633, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "GOLD", color: 0xC5C544, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "SILVER", color: 0x89A1AD, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setColorRegistorAction(colortitle: "BLACK", color: 0x000000, label: label, stackview: stackview, colorkey: colorkey))
            picker.addAction(setCancelAction())
            viewcontroller.present(picker, animated: true, completion: nil)
//        }
    }

    //移動手段を設定するダイアログ
    class func transportPickerDialog(viewcontroller: UIViewController, label: UILabel, goorback: String, keytag: String) {

        let title = "Setting your transportation"
        let key = goorback + "transport" + keytag
        let picker = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        picker.addAction(setTransportRegistorAction(title: "Walking", label: label, key: key))
        picker.addAction(setTransportRegistorAction(title: "Bicycle", label: label, key: key))
        picker.addAction(setTransportRegistorAction(title: "Car", label: label, key: key))
        picker.addAction(setCancelAction())
        viewcontroller.present(picker, animated: true, completion: nil)

    }
 
    //移動手段設定ボタン
    class func setTransportRegistorAction(title: String, label: UILabel, key: String) -> UIAlertAction {

        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
                label.text = title
                UserDefaults.standard.set(title, forKey: key)
        }

    }

    //乗車時間および乗換時間を設定するTextFieldの設定
    class func getMinutesFieldAlert(title: String, message: String, key: String) -> UIAlertController{

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {
            (textfield: UITextField!) in
            textfield.text = FileAndData.getUserDefaultValue(key: key, defaultvalue: "")
            textfield.textAlignment = NSTextAlignment.center
            textfield.placeholder = "Enter 0~99 [min]"
            textfield.keyboardType = .phonePad})
        return alert
    }

    //TextFieldに時間を入力して設定するダイアログ
    class func minuteFieldDialog(viewcontroller: UIViewController, title: String, message: String, key: String) {

        //TextFieldのアラートを表示
        let alert = getMinutesFieldAlert(title: title, message: message, key: key)
        //登録ボタンの表示：入力したTextを保存・表示する
        alert.addAction(setMinutesFieldRegistorAction(textfield: (alert.textFields?.first)!, key: key, unit: " [min]"))
        //キャンセルボタン：アラートから抜ける
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)

    }
    
    //乗換時間を設定するダイアログ
    class func transitTimeFieldDialog(viewcontroller: UIViewController, goorback: String, keytag: String) {
        
        let departstation = FileAndData.getArriveStation(
            goorback: goorback, keytag: keytag)
        let arrivestation = FileAndData.getDepartStation(
            goorback: goorback, keytag: keytag)
        let title = "Setting your required time [min]"
        let message = "from " + departstation + " to " + arrivestation
        let key = goorback + "transittime" + keytag
        return minuteFieldDialog(viewcontroller: viewcontroller, title: title, message: message, key: key)
    }

    //乗換時間を設定するダイアログ
    class func rideTimeFieldDialog(viewcontroller: UIViewController, goorback: String, keytag: String) {

        let linekey = goorback + "linename" + keytag
        var defaultvalue = "Line 1-" + keytag
        if (goorback == "back2" || goorback == "go2") {
            defaultvalue = "Line 2-" + keytag
        }
        let linename = FileAndData.getUserDefaultValue(key: linekey, defaultvalue: defaultvalue)!
        let title = "Setting your ride time [min]"
        let message = "on " + linename
        let key = goorback + "ridetime" + keytag
        return minuteFieldDialog(viewcontroller: viewcontroller, title: title, message: message, key: key)
    
    }

}

