//
//  countdownLabel.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/02/07.
//

import SwiftUI

struct countdownLabel: View {
    
    let goorback: String
    let weekflag: Bool
    let currenttime: Int

    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ currenttime: Int
    ) {
        self.goorback = goorback
        self.weekflag = weekflag
        self.currenttime = currenttime
    }

    var body: some View {

        let departuretime = weekflag.departureTime(goorback, currenttime)
        let time = currenttime.countdownTime(departuretime)
        let color = currenttime.countdownColor(departuretime)

        Text(time)
            .font(Font.largeTitle.monospacedDigit())
            .foregroundColor(color)
    }
}

struct countdownLabel_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        countdownLabel(
            mainviewmodel.goorback1,
            mainviewmodel.weekFlag,
            mainviewmodel.currentHHmmssFromTime
        )
    }
}

