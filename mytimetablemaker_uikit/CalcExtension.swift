//
//  CalcExtension.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/10/30.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Time Format Conversion Extensions
// Extensions for converting between different time formats
extension Int {
    // MARK: - Time Format Conversions
    // Converts HHMM format to minutes
    var HHMMtoMM: Int {
        return self / 100 * 60 + self % 100
    }
    // Converts minutes to HHMM format
    var MMtoHHMM: Int {
        return self / 60 * 100 + self % 60
    }
    // Converts MMSS format to seconds
    var MMSStoSS: Int {
        return self / 100 * 60 + self % 100
    }
    // Converts seconds to MMSS format
    var SStoMMSS: Int {
        return self / 60 * 100 + self % 60
    }
    // Converts HHMMSS format to seconds
    var HHMMSStoSS: Int {
        return self / 10000 * 3600 + (self % 10000) / 100 * 60 + self % 100
    }
    // Converts seconds to HHMMSS format
    var SStoHHMMSS: Int {
        return self / 3600 * 10000 + (self % 3600) / 60 * 100 + self % 60
    }
    // Converts HHMMSS format to MMSS format
    var HHMMSStoMMSS: Int {
        return (self / 10000 * 60 + (self % 10000) / 100) * 100 + self % 100
    }
    // Converts MMSS format to HHMMSS format
    var MMSStoHHMMSS: Int {
        return (self / 100 / 60) * 10000 + (self / 100 % 60) * 100 + self % 100
    }
}

// MARK: - Time Calculation Extensions
// Extensions for performing time calculations
extension Int {
    
    // MARK: - Time Addition Operations
    // Adds two HHMM format times
    func plusHHMM(_ time: Int) -> Int {
        return (self.HHMMtoMM + time.HHMMtoMM).MMtoHHMM
    }
    // Adds two HHMMSS format times
    func plusHHMMSS(_ time: Int) -> Int {
        return (self.HHMMSStoSS + time.HHMMSStoSS).SStoHHMMSS
    }
    // Adds two MMSS format times
    func plusMMSS(_ time: Int) -> Int {
        return (self.MMSStoSS + time.MMSStoSS).SStoMMSS
    }
    
    // MARK: - Time Subtraction Operations
    // Subtracts HHMM format times with overflow handling
    func minusHHMM(_ time: Int) -> Int {
        return (self.HHMMtoMM < time.HHMMtoMM) ?
            ((self + 2400).HHMMtoMM - time.HHMMtoMM).MMtoHHMM:
            (self.HHMMtoMM - time.HHMMtoMM).MMtoHHMM
    }
    // Subtracts HHMMSS format times with overflow handling
    func minusHHMMSS(_ time: Int) -> Int {
        return (self.HHMMSStoSS < time.HHMMSStoSS) ?
            ((self + 240000).HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS:
            (self.HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS
    }
    // Subtracts MMSS format times
    func minusMMSS(_ time: Int) -> Int {
        return (self.MMSStoSS - time.MMSStoSS).SStoMMSS
    }
}

// MARK: - Time Display Extensions
// Extensions for formatting time for display
extension Int {
    // MARK: - Time Formatting
    // Adds leading zero for single digit numbers
    var addZeroTime: String {
        return (0...9 ~= self) ? "0" + String(self): String(self)
    }
    // Converts HHMM format to display string
    var stringTime: String {
        let stringtimehh = (self / 100 + (self % 100) / 60).addZeroTime
        let stringtimemm = (self % 100 % 60).addZeroTime
        let stringtime = stringtimehh + ":" + stringtimemm
        if (stringtime != "27:00") {
            return stringtimehh + ":" + stringtimemm
        } else {
            return "--:--"
        }
    }
    
    // MARK: - Countdown Display
    // Converts MMSS format to countdown display string
    var countdown: String{
        var intcountdowntime = self
        switch (self) {
            case 0...9999: break
            default: intcountdowntime = -1000000
        }
        let countdownmm: String = (intcountdowntime / 100).addZeroTime
        let countdownss: String = (intcountdowntime % 100).addZeroTime
        if (intcountdowntime == -1000000) {
            return "--:--"
        } else {
            return countdownmm + ":" + countdownss
        }
    }
    // Calculates countdown time between departure time and current time
    func countdownTime(_ departtime: Int) -> String {
        // Calculate countdown (difference between departure time and current time)
        return (departtime * 100).minusHHMMSS(self).HHMMSStoMMSS.countdown
    }
    // Gets warning color for countdown display
    func countdownColor(_ departtime:Int) -> UIColor{
        return (departtime * 100).minusHHMMSS(self).HHMMSStoMMSS.countdownColor!
    }
    
    // MARK: - Countdown Color Logic
    // Returns appropriate color based on countdown time
    var countdownColor: UIColor? {
        if (self % 2 == 0) {
            switch (self) {
                case 1000...9999: return DefaultColor.accent.UI
                case 500...999: return DefaultColor.yellow.UI
                case 0...499: return DefaultColor.red.UI
                default: return DefaultColor.gray.UI
            }
        }
        return DefaultColor.gray.UI
    }
}

