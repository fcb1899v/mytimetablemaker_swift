//
//  setActionSheet.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/08.
//

import SwiftUI

func setActionSheet(title: String, message: String, list: [String], value: [Any], key: String) -> ActionSheet {
    return ActionSheet(
        title: Text(title),
        message:  Text(message),
        buttons: actionSheetButtons(list: list, value: value, key: key)
    )
}

func actionSheetButtons(list: [String], value: [Any], key: String) -> [ActionSheet.Button] {
    var buttonsArray: [ActionSheet.Button] = []
    for i in 0..<list.count {
        buttonsArray.append(.default(Text(list[i])) {
            UserDefaults.standard.set(value[i], forKey: key)
        })
    }
    return buttonsArray
}
