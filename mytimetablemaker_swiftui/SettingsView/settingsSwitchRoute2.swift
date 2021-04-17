//
//  settingsSwitchRoute2.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/14.
//

import SwiftUI

struct settingsSwitchRoute2: View {
    
    private let goorback: String
    private let ison: Binding<Bool>
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ ison: Binding<Bool>
    ){
        self.goorback = goorback
        self.ison = ison
    }
    
    private let accent = Color(DefaultColor.accent.rawValue.colorInt)
    
    var body: some View {
    
        let back2label = "Going home route 2".localized
        let go2label = "Outgoing route 2".localized
        let label = (goorback == "back2") ? back2label: go2label
        
        Toggle(
            isOn: ison
        ){
            Text(label)
                .font(.subheadline)
                .foregroundColor(Color.black)
        }.toggleStyle(SwitchToggleStyle(tint: accent))
    }
}

