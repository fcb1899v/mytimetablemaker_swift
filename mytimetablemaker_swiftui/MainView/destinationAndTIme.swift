//
//  destinationAndTIme.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/23.
//

import SwiftUI

struct destinationAndTime: View {
    
    private let goorback: String
    private let weekflag: Bool
    private let currenttime: Int

    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ currenttime: Int
    ){
        self.goorback = goorback
        self.weekflag = weekflag
        self.currenttime = currenttime
    }

    var body: some View {
        
        let office = "Office".localized
        let home = "Home".localized
        
        let title = DialogTitle.destination.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
        let defaultvalue = goorback.destination(home, office)
        let time = weekflag.displayTimeArray(goorback, currenttime)[0]
        let primary = Color(DefaultColor.primary.rawValue.colorInt)

        HStack {
            mainAlertBothLabel(title, message, key, defaultvalue)
            Text(time)
                .font(Font.title2.monospacedDigit())
                .foregroundColor(primary)
        }
    }
}

struct destinationAndTime_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        destinationAndTime(
            mainviewmodel.goorback1,
            mainviewmodel.weekFlag,
            mainviewmodel.currentHHmmssFromTime
        )
    }
}

