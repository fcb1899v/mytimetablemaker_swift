//
//  countdownLabel.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/02/07.
//

import SwiftUI

struct countdownLabel: View {
    
    @ObservedObject private var mainviewmodel: MainViewModel
    private let goorback: String

    init(
        _ mainviewmodel: MainViewModel,
        _ goorback: String
    ) {
        self.mainviewmodel = mainviewmodel
        self.goorback = goorback
    }

    var body: some View {

        let currenttime = mainviewmodel.currentHHmmssFromTime
        let departuretime = mainviewmodel.weekFlag.departureTime(goorback, currenttime)
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
        countdownLabel(mainviewmodel, "back1")
    }
}

