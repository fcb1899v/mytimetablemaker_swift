//
//  destinationAndTIme.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/23.
//

import SwiftUI

struct destinationAndTime: View {
    
    @State private var isShowingAlert = false
    @State private var text = ""
    
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
        
        let title = DialogTitle.destination.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
        let defaultvalue = goorback.destination(home, office)
        
        HStack {
            mainAlertLabel(title, message, key, defaultvalue)
            timeLabel(time)
        }
    }
}

struct destinationAndTime_Previews: PreviewProvider {
    static var previews: some View {
        destinationAndTime("back1", "00:00")
    }
}

