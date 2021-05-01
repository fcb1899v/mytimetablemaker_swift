//
//  settingsSwitchRoute2.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/14.
//

import SwiftUI

struct settingsSwitchRoute2: View {
    
    private let goorback: String
    @ObservedObject var settingviewmodel:  SettingsViewModel

    /// 値を指定して生成する
    init(
        _ goorback: String
    ){
        self.goorback = goorback
        self.settingviewmodel = SettingsViewModel(goorback)
    }
    
    var body: some View {
    
        let label = (goorback == "back2") ? "Going home route 2".localized: "Outgoing route 2".localized
        let accent = Color(DefaultColor.accent.rawValue.colorInt)
        
        Toggle(
            isOn: $settingviewmodel.route2flag
        ){
            Text(label)
                .font(.subheadline)
                .foregroundColor(Color.black)
        }.toggleStyle(SwitchToggleStyle(
            tint: accent
        ))
    }
}

struct settingsSwitchRoute2_Previews: PreviewProvider {
    static var previews: some View {
        settingsSwitchRoute2("back2")
    }
}

