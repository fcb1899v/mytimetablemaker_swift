//
//  DateAndTime.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/08.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class DateAndTime {
    
    class func getCurrentDate(datebutton: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d, yyyy"
        datebutton.setTitle(formatter.string(from: Date()), for: UIControl.State.normal)
    }

    class func getCurrentTime(timebutton: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        timebutton.setTitle(formatter.string(from: Date()), for: UIControl.State.normal)
    }
    
    class func setButtonEnabled(button: UIButton, flag: Bool, color: UIColor) {
        button.isEnabled = flag
        button.setTitleColor(color, for: UIControl.State.normal)
    }
    
    class func setButtonCondition(flag: Bool, button1: UIButton, button2: UIButton, color1: UIColor, color2: UIColor) -> Bool{
        DateAndTime.setButtonEnabled(button: button1, flag: !flag, color: color1)
        DateAndTime.setButtonEnabled(button: button2, flag: flag, color: color2)
        return flag
    }

    class func setDateRegisterButton(datebutton: UIButton, datepicker: UIDatePicker, stringformat: String) -> UIAlertAction {

        let dateformatter = DateFormatter()
        dateformatter.dateFormat = stringformat

        return UIAlertAction(
            title: "Register",
            style: .default
        ){ (action) in
             let datestring = dateformatter.string(from: datepicker.date)
             datebutton.setTitle(datestring,for: UIControl.State.normal)
        }
    }
    
    class func setDateCancelButton() -> UIAlertAction {
        return UIAlertAction(
            title: "Cancel",
            style: .default,
            handler: nil
        )
    }
    
    class func setDatePickerDialog(datebutton: UIButton, stringformat: String) -> UIAlertController{
        // ピッカー設定
        let datepicker = UIDatePicker()
        datepicker.date = Date()
        datepicker.datePickerMode = .date
        datepicker.timeZone = NSTimeZone.local
        datepicker.locale = Locale.current

        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datepicker)
        
        alert.addAction(setDateRegisterButton(datebutton: datebutton, datepicker: datepicker, stringformat: stringformat))
        alert.addAction(setDateCancelButton())
        
        return alert
    }

    class func setTimePickerDialog(timebutton: UIButton, stringformat: String) -> UIAlertController{

        // ピッカー設定
        let timepicker = UIDatePicker()
        timepicker.date = Date()
        timepicker.datePickerMode = .time
        timepicker.timeZone = NSTimeZone.local
        timepicker.locale = Locale.init(identifier: "Japanese")

        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(timepicker)

        alert.addAction(setDateRegisterButton(datebutton: timebutton, datepicker: timepicker, stringformat: stringformat))
        alert.addAction(setDateCancelButton())

        return alert
    }
}
