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
        
        let timetable = Timetable(goorback, weekflag, num)
        
        HStack {
            
            VStack(alignment: .leading, spacing: 5) {
                Text(goorback.stationArray[2 * num + 2])
                    .font(.title3)
                    .foregroundColor(.white)
                Text(timetable.timetableTitle)
                    .font(.callout)
                    .foregroundColor(.white)
            }.padding(10)
            
            Spacer()
            
            Button(action: action){
                Text(timetable.revWeekLabelText)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(width: .statebuttonwidth, height: 35)
                    .foregroundColor(timetable.weekButtonLabelColor)
                    .background(timetable.weekButtonBackColor)
                    .cornerRadius(15)
            }
        }.frame(width: CGFloat().timetablewidth)
    }
}

struct TimetableTitleView_Previews: PreviewProvider {
    static var previews: some View {
        let weekflag = Date().weekFlag
        TimetableTitleView("back1", weekflag, 0, {})
            .background(Color.myprimary)
    }
}
