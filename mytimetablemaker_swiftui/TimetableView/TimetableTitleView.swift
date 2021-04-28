//
//  TimetableTitleView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/05.
//

import SwiftUI

struct TimetableTitleView: View {

    private let goorback: String
    private let weekflag: Bool
    private let keytag: String
    private let action: () -> Void

    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ keytag: String,
        _ action: @escaping () -> Void
    ) {
        self.goorback = goorback
        self.weekflag = weekflag
        self.keytag = keytag
        self.action = action
    }
    
    var body: some View {
        
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(Timetable(goorback, weekflag, keytag).timetableDepartStation)
                        .font(.title3)
                        .foregroundColor(Color.white)
                    Text(Timetable(goorback, weekflag, keytag).timetableTitle)
                        .font(.callout)
                        .foregroundColor(Color.white)
                }
                Spacer()
                dayAndEndButton(weekflag, action: action)
            }.padding(10)
    }
}

struct TimetableTitleView_Previews: PreviewProvider {
    static var previews: some View {
        let weekflag = !Date().weekFlag
        TimetableTitleView("back1", weekflag, "1", {})
            .background(Color.black)
    }
}
