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
                                Color.white.frame(width: 1)
                                ZStack(alignment: .center) {
                                    Color.myprimary
                                        .frame(height: 25)
                                    Text(timetable.weekLabelText)
                                        .foregroundColor(timetable.weekLabelColor)
                                        .fontWeight(.bold)
                                }
                                Color.white.frame(width: 1)
                            }
                        }
                    }
                    
                    Color.white.frame(height: 0)

                    ForEach(4...25, id: \.self) { hour in
                        TimetableEachGridView(goorback, weekflag, num, hour)
                    }
                    Color.white.frame(height: 0)
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
