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
    private let num: Int
    private let action: () -> Void

    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ num: Int,
        _ action: @escaping () -> Void
    ) {
        self.goorback = goorback
        self.weekflag = weekflag
        self.num = num
        self.action = action
    }
    
    var body: some View {
        
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(Timetable(goorback, weekflag, num).timetableDepartStation)
                        .font(.title3)
                        .foregroundColor(Color.white)
                    Text(Timetable(goorback, weekflag, num).timetableTitle)
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
        TimetableTitleView("back1", weekflag, 0, {})
            .background(Color.black)
    }
}
