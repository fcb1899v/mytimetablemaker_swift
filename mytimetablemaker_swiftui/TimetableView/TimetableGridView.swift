//
//  TimetableGridView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/03.
//

import SwiftUI

struct TimetableGridView: View {

    private let goorback: String
    private let weekflag: Bool
    private let num: Int

    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ num: Int
    ) {
        self.goorback = goorback
        self.weekflag = weekflag
        self.num = num
    }
    
    var body: some View {
        
        let timetable = Timetable(goorback, weekflag, num)
        
        ScrollView {
            
            ZStack {
                Color.white
                VStack(spacing: 0.5) {
                    ZStack {
                        Color.white
                        LazyVGrid(columns: [GridItem(.flexible())], spacing: 1) {
                            Color.myprimary.frame(height: 0)
                            HStack(spacing: 1) {
                                Color.myprimary
                                ZStack(alignment: .center) {
                                    Color.myprimary
                                        .frame(width: CGFloat().timetablewidth, height: 25)
                                    Text(timetable.weekLabelText)
                                        .foregroundColor(timetable.weekLabelColor)
                                        .fontWeight(.bold)
                                }
                                Color.myprimary
                            }
                        }
                    }
                    Color.white.frame(height: 0)
                    ForEach(4...25, id: \.self) { hour in
                        TimetableEachGridView(goorback, weekflag, num, hour)
                    }
                    Color.white.frame(height: 0)
                }
                HStack(spacing: 1) {
                    Color.myprimary
                    Color.clear.frame(width: (CGFloat.screenwidth > 600) ? 631: CGFloat.screenwidth)
                    Color.myprimary
                }
            }
        }
    }
}
    
struct TimetableGridView_Previews: PreviewProvider {
    static var previews: some View {
        let weekflag = Date().weekFlag
        TimetableGridView("back1", weekflag, 0)
    }
}
