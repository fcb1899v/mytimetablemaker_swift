//
//  Color.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/05/02.
//

import Foundation
import SwiftUI


extension Color {
    static let accentColor = Color("myaccent")
    static let primaryColor = Color("myprimary")
    static let grayColor = Color("mygray")
    static let redColor = Color("myred")
    static let yellowColor = Color("myyellow")
}

extension UIColor {
        static let headerColor = UIColor(red: 49/255, green: 4/255, blue: 172/255, alpha: 1)
}

//色をRGCの16進数数字で指定
extension Color {
    
    init(
        _ hex: Int,
        opacity: Double = 1.0
    ) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

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

//String型ColorをInt型に変換
extension String {
    var colorInt: Int {
        return Int(self.replacingOccurrences(of: "#", with: ""), radix: 16) ?? 000000
    }
}

//<>
extension String {
    var settingsColor: Color {
        return (self == Unit.notset.rawValue.localized) ? Color.grayColor: Color.black
    }
}
