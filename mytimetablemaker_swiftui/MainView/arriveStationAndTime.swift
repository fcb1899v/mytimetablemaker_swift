//
//  arriveStationAlertView.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/02/22.
//

import SwiftUI

struct arriveStationAndTime: View {
    
    private let goorback: String
    private let weekflag: Bool
    private let currenttime: Int
    private let num: Int
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ currenttime: Int,
        _ num: Int
    ){
        self.goorback = goorback
        self.weekflag = weekflag
        self.currenttime = currenttime
        self.num = num
    }

    var body: some View {
        
        let ofarrsta = "of arrival station ".localized
        let arrsta = "Arr. St. ".localized
        let keytag = "\(num + 1)"
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\(ofarrsta)\(keytag)"
        let key = "\(goorback)arrivestation\(keytag)"
        let defaultvalue = "\(arrsta)\(keytag)"
        let primary = Color(DefaultColor.primary.rawValue.colorInt)
        
        if num < goorback.changeLineInt + 1 {
            let time = weekflag.displayTimeArray(goorback, currenttime)[2 * num + 3]
            HStack {
                mainAlertLabel(title, message, key, defaultvalue)
                Text(time)
                    .font(Font.title2.monospacedDigit())
                    .foregroundColor(primary)
            }
        }
    }
}

struct arriveStationAndTime_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        arriveStationAndTime(
            mainviewmodel.goorback1,
            mainviewmodel.weekFlag,
            mainviewmodel.currentHHmmssFromTime,
            1
        )
    }
}

