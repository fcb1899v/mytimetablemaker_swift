//
//  DateAndTime.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/09/08.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

// MARK: - Date and Time Structure
// Manages date and time display and selection functionality
struct DateAndTime {
    var datebutton: UIButton
    var timebutton: UIButton
    var timeflag: Bool
    
    // MARK: - Initialization
    // Initialize with date button, time button, and time flag
    init(_ datebutton: UIButton, _ timebutton: UIButton, _ timeflag: Bool) {
        self.datebutton = datebutton
        self.timebutton = timebutton
        self.timeflag = timeflag
    }
    
    // MARK: - Format Constants
    // Localized date and time format strings
    let customdate = Unit.customdate.rawValue.localized
    let customHHmmss = Unit.customHHmmss.rawValue
    let customHHmm = Unit.customHHmm.rawValue
    let register = Action.register.rawValue.localized
    let cancel = Action.cancel.rawValue.localized
}

// MARK: - Date and Time Extensions
extension DateAndTime {
    
    // MARK: - Current Date and Time Display
    // Sets current date to the date button
    func setCurrentDate() {
        if (self.timeflag) {
            let formatter = DateFormatter()
            formatter.dateFormat = customdate
            datebutton.setTitle(formatter.string(from: Date()), for: UIControl.State.normal)
        }
    }

    // Sets current time to the time button
    func setCurrentTime() {
        if (self.timeflag) {
            let formatter = DateFormatter()
            formatter.dateFormat = customHHmmss
            timebutton.setTitle(formatter.string(from: Date()), for: UIControl.State.normal)
        }
    }
    
    // MARK: - Time Extraction
    // Extracts current time in HHMMSS format from time button
    var currentHHmmssFromTimeButton: Int {
        let formatter = DateFormatter()
        // Extract displayed hours
        formatter.dateFormat = "HH"
        let timeHH = timebutton.title(for: UIControl.State.normal)
        let HH =  (timeflag) ? Int(formatter.string(from: Date())) ?? 0: Int(timeHH!.prefix(2)) ?? 0
        // Extract displayed minutes
        formatter.dateFormat = "mm"
        let timemm = timebutton.title(for: UIControl.State.normal)
        let mm =  (timeflag) ? Int(formatter.string(from: Date())) ?? 0: Int(timemm!.suffix(2)) ?? 0
        // Extract displayed seconds
        formatter.dateFormat = "ss"
        let ss = (timeflag) ? Int(formatter.string(from: Date())) ?? 0: 0

        return HH * 10000 + mm * 100 + ss
    }

    // MARK: - Date Extraction
    // Extracts date from date button
    var dateFromDateButton: Date {
        let stringdate = datebutton.title(for: UIControl.State.normal)
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = customdate
        return formatter.date(from: stringdate!)!
    }
    
    // MARK: - Date Picker Configuration
    // Creates and configures date picker with specified mode
    func datePicker(_ datepickermode: UIDatePicker.Mode) -> UIDatePicker{
        let datepicker = UIDatePicker()
        datepicker.date = Date()
        datepicker.datePickerMode = datepickermode
        datepicker.timeZone = NSTimeZone.local
        datepicker.locale = Locale.current
        return datepicker
    }

    // MARK: - Date Picker Dialog
    // Displays date picker dialog for date selection
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

    // MARK: - Time Picker Dialog
    // Displays time picker dialog for time selection
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

    // MARK: - Alert Action Handlers
    // Creates register action for date picker
    func setDateRegisterAction(_ datepicker: UIDatePicker, _ stringformat: String) -> UIAlertAction {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = stringformat
        return UIAlertAction(title: register, style: .default){ (action) in
             let datestring = dateformatter.string(from: datepicker.date)
             datebutton.setTitle(datestring,for: UIControl.State.normal)
        }
    }

    // Creates register action for time picker
    func setTimeRegisterAction(_ datepicker: UIDatePicker, _ stringformat: String) -> UIAlertAction {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = stringformat
        return UIAlertAction(title: register, style: .default){ (action) in
             let datestring = dateformatter.string(from: datepicker.date)
             timebutton.setTitle(datestring,for: UIControl.State.normal)
        }
    }

    // Creates cancel action
    func setCancelAction() -> UIAlertAction {
        return UIAlertAction(title: cancel, style: .cancel, handler: nil)
    }
}

// MARK: - Date Extension
// Extension for date-related functionality
extension Date {
    // MARK: - Week Flag
    // Returns week flag indicating weekday (true) or weekend (false)
    var weekFlag: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        switch (formatter.string(from: self)) {
            case "Sat", "Sun", "土", "日": return false
            default: return true
        }
    }
}
