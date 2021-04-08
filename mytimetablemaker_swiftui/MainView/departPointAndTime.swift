//
//  departPointAndTime.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/02/23.
//

import SwiftUI

struct departPointAndTime: View {
    
    @State private var isShowingAlert = false
    
    private let goorback: String
    private let time: String
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ time: String
    ){
        self.goorback = goorback
        self.time = time
    }
    
    var body: some View {
        
        let office = "Office".localized
        let home = "Home".localized

        let title = DialogTitle.departplace.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "destination": "departurepoint"
        let defaultvalue = goorback.departurePoint(office, home)

        HStack {
            mainAlertLabel(title, message, key, defaultvalue)
            timeLabel(time)
        }
    }
}

struct departPointAndTime_Previews: PreviewProvider {
    static var previews: some View {
        departPointAndTime("back1", "00:00")
    }
}
