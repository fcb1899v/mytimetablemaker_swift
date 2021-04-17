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
    private let num: Int
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ num: Int
    ){
        self.goorback = goorback
        self.num = num
    }
    
    var body: some View {

        let ofdepsta = "of departure station ".localized
        let depsta = "Dep. St. ".localized
        let keytag = "\(num + 1)"
        let label = "\(depsta)\(keytag)"
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\(ofdepsta)\(keytag)"
        let key = "\(goorback)departstation\(keytag)"
        
        if goorback.changeLineInt > num - 1 {
            settingsTextFieldAlertLabel(label, title, message, key)
        }
    }
}

struct settingsDepartStation_Previews: PreviewProvider {
    static var previews: some View {
        settingsDepartStation("back1", 0)
    }
}
