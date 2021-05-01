//
//  departPointAndTime.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/02/23.
//

import SwiftUI

struct departPointAndTime: View {

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
        
        let title = DialogTitle.departplace.rawValue.localized
        let message = ""
        let key = goorback.departurePointKey
        let defaultvalue = goorback.departurePointDefault
        let time = weekflag.displayTimeArray(goorback, currenttime)[1]
        let primary = Color(DefaultColor.primary.rawValue.colorInt)
        
        HStack {
            mainAlertBothLabel(title, message, key, defaultvalue)
            Text(time)
                .font(Font.title2.monospacedDigit())
                .foregroundColor(primary)
        }
    }
}

struct departPointAndTime_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        departPointAndTime(
            mainviewmodel.goorback1,
            mainviewmodel.weekFlag,
            mainviewmodel.currentHHmmssFromTime
        )
    }
}
