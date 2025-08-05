//
//  Color.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/05/02.
//

import Foundation
import SwiftUI

// MARK: - Color Extensions
// Extensions for color management and hex color support
extension Color {
    
    // MARK: - Custom Color Definitions
    // Predefined custom colors for the application
    static let accentColor = Color("myaccent")
    static let primaryColor = Color("myprimary")
    static let grayColor = Color("mygray")
    static let redColor = Color("myred")
    static let yellowColor = Color("myyellow")
    
    // MARK: - Hex Color Initializer
    // Initialize color from hex integer value
    init(
        _ hex: Int,
        opacity: Double = 1.0
    ) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    // MARK: - Hex String Conversion
    // Convert color to hex string representation
    func hex(withHash hash: Bool = false, uppercase up: Bool = false) -> String {
        if let components = self.cgColor?.components {
            let r = ("0" + String(Int(components[0] * 255.0), radix: 16, uppercase: up)).suffix(2)
            let g = ("0" + String(Int(components[1] * 255.0), radix: 16, uppercase: up)).suffix(2)
            let b = ("0" + String(Int(components[2] * 255.0), radix: 16, uppercase: up)).suffix(2)
            return (hash ? "#" : "") + String(r + g + b)
        }
        return "000000"
    }    
}

// MARK: - UIColor Extensions
// UIKit color extensions for header styling
extension UIColor {
        static let headerColor = UIColor(red: 49/255, green: 4/255, blue: 172/255, alpha: 1)
}

<<<<<<< HEAD
=======
// MARK: - Color String Constants
// Hex string constants for color definitions
let primaryColorString = "#3700B3"
let accentColorString  = "#03DAC5"
let redColorString     = "#FF0000"
let yellowColorString  = "#FFFF00"
let grayColorString    = "#AAAAAA"
let blackColorString   = "#000000"
let whiteColorString   = "#FFFFFF"

>>>>>>> 62ded4e0371b7659ed61348b05e40bcbe2a94148
// MARK: - String Color Extensions
// Extensions for string-based color operations
extension String {
        
    // MARK: - Hex String to Int Conversion
    // Convert hex color string to integer value
    var colorInt: Int {
        return Int(self.replacingOccurrences(of: "#", with: ""), radix: 16) ?? 000000
    }
    
    // MARK: - Settings Color Logic
    // Determine color for settings display based on text value
    var settingsColor: Color {
        return (self == textNotSet) ? Color.grayColor: Color.black
    }
    
}

// MARK: - Integer Color Extensions
// Extensions for countdown color calculations
extension Int {
    
    // MARK: - Countdown Color Calculation
    // Calculate color based on countdown time relative to departure time
    func countdownColor(_ departtime:Int) -> Color {
        return (departtime * 100).minusHHMMSS(self).HHMMSStoMMSS.countdownColor
    }

    // MARK: - Countdown Color Logic
    // Determine color based on countdown time ranges
    var countdownColor: Color { return (self % 2 == 1) ? Color.grayColor:
        (1000...9999 ~= self) ? Color.accentColor:
        (500...999 ~= self) ? Color.yellowColor:
        (0...499 ~= self) ? Color.redColor:
        Color.grayColor
    }
}

// MARK: - Boolean Color Extensions
// Extensions for weekday-based color logic
extension Bool {
    
    // MARK: - Weekday Color Logic
    // self is isWeekday
    var weekLabelColor: Color { return self ? Color.white: Color.redColor }
    var weekButtonColor: Color { return self ? Color.redColor: Color.white }
    var weekButtonLabelColor: Color { return self ? Color.white: Color.primaryColor }
}
