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
                VStack(alignment: .leading) {
                    Text(Timetable(goorback, weekflag, keytag).timetableDepartStation)
                        .font(.title3)
                        .foregroundColor(Color.white)
                    Text(Timetable(goorback, weekflag, keytag).timetableTitle)
                        .foregroundColor(Color.white)
                }
                Spacer()
                dayAndEndButton(weekflag, action: action)
            }.frame(width: UIScreen.screenWidth - 20)
    }
}

struct TimetableTitleView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableTitleView("back1", true, "1", {})
    }
}
