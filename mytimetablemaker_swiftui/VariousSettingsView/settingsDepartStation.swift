//
//  settingsDepartStation.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/01.
//

import SwiftUI

struct settingsDepartStation: View {
    
    @State private var isShowingAlert = false

    private let goorback: String
    private let keytag: String
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ keytag: String
    ){
        self.goorback = goorback
        self.keytag = keytag
    }
    
    var body: some View {

        let ofdepsta = "of departure station ".localized
        let depsta = "Dep. St. ".localized
        let gray = Color(DefaultColor.gray.rawValue.colorInt)

        let label = "\(depsta)\(keytag)"
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\(ofdepsta)\(keytag)"
        let key = "\(goorback)departstation\(keytag)"
        let color = (key.userDefaultsValue("") == "") ? gray: Color.black

        settingsTextFieldAlertLabel(label, title, message, key, color)
    }
}

struct settingsDepartStation_Previews: PreviewProvider {
    static var previews: some View {
        settingsDepartStation("back1", "1")
    }
}
