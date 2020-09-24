//
//  DateAndTime.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/08.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class DateAndTime: NSObject {
    
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
            setButtonEnabled(button: button1, flag: !flag, color: color1)
            setButtonEnabled(button: button2, flag: flag, color: color2)
        return flag
    }

    class func setWeekButton(weekbutton: UIButton, weekdaycolor: UIColor, weekendcolor: UIColor, weekflag: Bool) -> Bool{
        if (weekflag == true) {
            weekbutton.setTitle("WEEKDAY", for: UIControl.State.normal)
            weekbutton.setTitleColor(weekdaycolor, for: UIControl.State.normal)
            return false
        } else {
            weekbutton.setTitle("WEEKEND", for: UIControl.State.normal)
            weekbutton.setTitleColor(weekendcolor, for: UIControl.State.normal)
            return true
        }
    }

    
}
