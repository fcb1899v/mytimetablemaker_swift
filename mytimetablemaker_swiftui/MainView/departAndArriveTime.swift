//
//  departAndArriveTime.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/02/23.
//

import SwiftUI

struct departAndArriveTime: View {
    
    @ObservedObject private var mainviewmodel: MainViewModel
    private let goorback: String
    private let num: Int

    init(
        _ mainviewmodel: MainViewModel,
        _ goorback: String,
        _ num: Int
    ) {
        self.mainviewmodel = mainviewmodel
        self.goorback = goorback
        self.num = num
    }
    
    var body: some View {
        
        if num < goorback.changeLineInt + 1 {
        
            let keytag = "\(num + 1)"
            let weekflag = mainviewmodel.weekFlag
            let currenttime = mainviewmodel.currentHHmmssFromTime
            let departtime = weekflag.displayTimeArray(goorback, currenttime)[2 * num + 2]
            let arrivetime = weekflag.displayTimeArray(goorback, currenttime)[2 * num + 3]

            VStack {
                transitTimeAndName(goorback, keytag)
                Spacer(minLength: 2)
                departStationAndTime(goorback, keytag, departtime)
                Spacer(minLength: 2)
                lineColorAndName(goorback, weekflag, keytag)
                Spacer(minLength: 2)
                arriveStationAndTime(goorback, keytag, arrivetime)
                Spacer(minLength: 2)
            }
        }
    }
}

struct departAndArriveTime_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        departAndArriveTime(mainviewmodel, "back1", 0)
    }
}
