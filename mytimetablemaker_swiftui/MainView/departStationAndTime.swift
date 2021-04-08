//
//  departStationAndTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/22.
//

import SwiftUI

struct departStationAndTime: View {
    
    @State private var isShowingAlert = false
    @State private var text = ""
    
    private let goorback: String
    private let keytag: String
    private let time: String
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ keytag: String,
        _ time: String
    ){
        self.goorback = goorback
        self.keytag = keytag
        self.time = time
    }

    var body: some View {
        
        let ofdepsta = "of departure station ".localized
        let depsta = "Dep. St. ".localized

        let title = DialogTitle.stationname.rawValue.localized
        let message = "\(ofdepsta)\(keytag)"
        let key = "\(goorback)departstation\(keytag)"
        let defaultvalue = "\(depsta)\(keytag)"
        
        HStack {
            mainAlertLabel(title, message, key, defaultvalue)
            timeLabel(time)
        }
    }
}

struct departStationAndTime_Previews: PreviewProvider {
    static var previews: some View {
        departStationAndTime("back1", "1", "00:00")
    }
}
