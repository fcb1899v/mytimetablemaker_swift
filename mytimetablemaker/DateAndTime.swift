//
//  DateAndTime.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/08.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

struct DateAndTime {
    var datebutton: UIButton
    var timebutton: UIButton
    var timeflag: Bool
    init(_ datebutton: UIButton, _ timebutton: UIButton, _ timeflag: Bool) {
        self.datebutton = datebutton
        self.timebutton = timebutton
        self.timeflag = timeflag
    }
    let customdate = Unit.customdate.rawValue.localized
    let customHHmmss = Unit.customHHmmss.rawValue
    let customHHmm = Unit.customHHmm.rawValue
    let register = Action.register.rawValue.localized
    let cancel = Action.cancel.rawValue.localized
}

extension DateAndTime {
    
    //現在日付を表示
    func setCurrentDate() {
        if (self.timeflag) {
            let formatter = DateFormatter()
            formatter.dateFormat = customdate
            datebutton.setTitle(formatter.string(from: Date()), for: UIControl.State.normal)
        }
    }

    //現在時刻を表示
    func setCurrentTime() {
        if (self.timeflag) {
            let formatter = DateFormatter()
            formatter.dateFormat = customHHmmss
            timebutton.setTitle(formatter.string(from: Date()), for: UIControl.State.normal)
        }
    }
    
    //表示されている時刻を取得する関数
    var currentHHmmssFromTimeButton: Int {
        let formatter = DateFormatter()
        //表示されている「時」を取得
        formatter.dateFormat = "HH"
        let timeHH = timebutton.title(for: UIControl.State.normal)
        let HH =  (timeflag) ? Int(formatter.string(from: Date())) ?? 0: Int(timeHH!.prefix(2)) ?? 0
        //表示されている「分」を取得
        formatter.dateFormat = "mm"
        let timemm = timebutton.title(for: UIControl.State.normal)
        let mm =  (timeflag) ? Int(formatter.string(from: Date())) ?? 0: Int(timemm!.suffix(2)) ?? 0
        //表示されている「秒」を取得
        formatter.dateFormat = "ss"
        let ss = (timeflag) ? Int(formatter.string(from: Date())) ?? 0: 0

        return HH * 10000 + mm * 100 + ss
    }

    //表示されている日付を取得する関数
    var dateFromDateButton: Date {
        let stringdate = datebutton.title(for: UIControl.State.normal)
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = customdate
        return formatter.date(from: stringdate!)!
    }
    
    //日時を設定するアラートを設定
    func datePicker(_ datepickermode: UIDatePicker.Mode) -> UIDatePicker{
        let datepicker = UIDatePicker()
        datepicker.date = Date()
        datepicker.datePickerMode = datepickermode
        datepicker.timeZone = NSTimeZone.local
        datepicker.locale = Locale.current
        return datepicker
    }

    //日時を設定するダイアログを表示
    func datePickerDialog(_ viewcontroller: UIViewController) {
        let datepicker = datePicker(.date)
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datepicker)
        alert.addAction(setDateRegisterAction(datepicker, customdate))
        alert.addAction(setCancelAction())
        if (!timeflag) {
            viewcontroller.present(alert, animated: true, completion: nil)
        }
    }

    //日時を設定するダイアログを表示
    func timePickerDialog(_ viewcontroller: UIViewController) {
        let datepicker = datePicker(.time)
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datepicker)
        alert.addAction(setTimeRegisterAction(datepicker, customHHmm))
        alert.addAction(setCancelAction())
        if (!timeflag) {
            viewcontroller.present(alert, animated: true, completion: nil)
        }
    }

    //日時設定・表示ボタン
    func setDateRegisterAction(_ datepicker: UIDatePicker, _ stringformat: String) -> UIAlertAction {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = stringformat
        return UIAlertAction(title: register, style: .default){ (action) in
             let datestring = dateformatter.string(from: datepicker.date)
             datebutton.setTitle(datestring,for: UIControl.State.normal)
        }
    }

    //日時設定・表示ボタン
    func setTimeRegisterAction(_ datepicker: UIDatePicker, _ stringformat: String) -> UIAlertAction {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = stringformat
        return UIAlertAction(title: register, style: .default){ (action) in
             let datestring = dateformatter.string(from: datepicker.date)
             timebutton.setTitle(datestring,for: UIControl.State.normal)
        }
    }

    //キャンセルボタン
    func setCancelAction() -> UIAlertAction {
        return UIAlertAction(title: cancel, style: .cancel, handler: nil)
    }
}

extension Date {
    //平日と土日を表すフラグを取得する関数
    var weekFlag: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        switch (formatter.string(from: self)) {
            case "Sat", "Sun", "土", "日": return false
            default: return true
        }
    }
}
