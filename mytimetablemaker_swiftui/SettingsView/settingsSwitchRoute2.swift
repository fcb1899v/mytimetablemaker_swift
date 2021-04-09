//
//  settingsSwitchRoute2.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/14.
//

import SwiftUI

struct settingsSwitchRoute2: View {
    
    private let title: String
    private let ison: Binding<Bool>
    
    /// 値を指定して生成する
    init(
        _ title: String,
        _ ison: Binding<Bool>
    ){
        self.title = title
        self.ison = ison
    }
    
    private let accent = Color(DefaultColor.accent.rawValue.colorInt)
    
    var body: some View {
        Toggle(
            isOn: ison
        ){
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.black)
        }.toggleStyle(SwitchToggleStyle(tint: accent))
    }
}

