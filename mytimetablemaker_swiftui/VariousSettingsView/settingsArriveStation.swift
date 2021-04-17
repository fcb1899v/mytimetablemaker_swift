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

        let ofarrsta = "of arrival station ".localized
        let arrsta = "Arr. St. ".localized
        let keytag = "\(num + 1)"        
        let label = "\(arrsta)\(keytag)"
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\(ofarrsta)\(keytag)"
        let key = "\(goorback)arrivestation\(keytag)"

        if goorback.changeLineInt > num - 1 {
            settingsTextFieldAlertLabel(label, title, message, key)
        }
    }
}

struct settingsArriveStation_Previews: PreviewProvider {
    static var previews: some View {
        settingsArriveStation("back1", 0)
    }
}
