//
//  settingsArriveStation.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/01.
//

import SwiftUI

struct settingsArriveStation: View {
    
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

        let ofarrsta = "of arrival station ".localized
        let arrsta = "Arr. St. ".localized
        let gray = Color(DefaultColor.gray.rawValue.colorInt)

        let label = "\(arrsta)\(keytag)"
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\(ofarrsta)\(keytag)"
        let key = "\(goorback)arrivestation\(keytag)"
        let color = (key.userDefaultsValue("") == "") ? gray: Color.black

        settingsTextFieldAlertLabel(label, title, message, key, color)
    }
}

struct settingsArriveStation_Previews: PreviewProvider {
    static var previews: some View {
        settingsArriveStation("back1", "1")
    }
}
