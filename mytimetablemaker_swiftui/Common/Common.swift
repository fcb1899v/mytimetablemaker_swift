//
//  Common.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/05/02.
//

import SwiftUI
import Foundation
import Combine

// 多言語対応
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: self)
    }
}

//＜key＞
extension String{
    
    //UserDefaultsに保存された文字列を取得
    func userDefaultsValue(_ defaultvalue: String?) -> String {
        let defaultstring = (defaultvalue != nil) ? defaultvalue: ""
        return UserDefaults.standard.string(forKey: self) ?? defaultstring!
    }
    
    //UserDefaultsに保存された文字列を取得
    func userDefaultsInt(_ defaultvalue: Int?) -> Int {
        let defaultint = (defaultvalue != nil) ? defaultvalue: 0
        return (UserDefaults.standard.object(forKey: self) != nil) ?
            UserDefaults.standard.integer(forKey: self):
            defaultint!
    }
   
    //UserDefaultsに保存されたBoolを取得
    func userDefaultsBool(_ defaultvalue: Bool?) -> Bool {
        let defaultbool = (defaultvalue != nil) ? defaultvalue: false
        return (UserDefaults.standard.object(forKey: self) != nil) ?
            UserDefaults.standard.bool(forKey: self):
            defaultbool!
    }
    
    //UserDefaultsに保存された色データを取得
    func userDefaultsColor(_ defaultvalue: String?) -> Color {
        return Color(userDefaultsValue(defaultvalue).colorInt)
    }
    
    //UserDefaultsに保存するActionButtonの配列を取得
    func ActionSheetButtons(list: [String], value: [Any]) -> [ActionSheet.Button] {
        var buttonsArray: [ActionSheet.Button] = []
        for i in 0..<list.count {
            buttonsArray.append(.default(Text(list[i])) {
                UserDefaults.standard.set(value[i], forKey: self)
            })
        }
        buttonsArray.append(.cancel())
        return buttonsArray
    }
}
