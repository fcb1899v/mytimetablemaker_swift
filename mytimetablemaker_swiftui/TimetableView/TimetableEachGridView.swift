//
//  TimetableEachGridView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI

struct TimetableEachGridView: View {

    private let goorback: String
    private let weekflag: Bool
    private let keytag: String
    private let hour: Int

    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ keytag: String,
        _ hour: Int
    ) {
        self.goorback = goorback
        self.weekflag = weekflag
        self.keytag = keytag
        self.hour = hour
    }

    var body: some View {
        
        let primary = Color(DefaultColor.primary.rawValue.colorInt)
        let accent = Color(DefaultColor.accent.rawValue.colorInt)
        
        ZStack {
            Color.white
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 1) {
                HStack(spacing: 1) {
                    Color.white.frame(width: 1)
                    ZStack {
                        primary.frame(width: 27)
                        Text(hour.addZeroTime).foregroundColor(accent)
                    }
                    TimetableAlertLabel(goorback, weekflag, keytag, hour)
                    Color.white.frame(width: 1)
                }
            }
        }
    }
}

struct TimetableEachGridView_Previews: PreviewProvider {
    static var previews: some View {
        let weekflag = !Date().weekFlag
        TimetableEachGridView("back1", weekflag, "1", 4)
    }
}
