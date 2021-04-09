//
//  TimetableGridTitle.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/03.
//

import SwiftUI

struct TimetableGridTitle: View {

    private let weekflag: Bool

    init(
        _ weekflag: Bool
    ) {
        self.weekflag = weekflag
    }
    
    var body: some View {
        
        let primary = Color(DefaultColor.primary.rawValue.colorInt)

        ZStack {
            Color.white
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 1) {
                primary
                    .frame(width: UIScreen.screenWidth, height: 0)
                HStack(spacing: 1) {
                    Color.white.frame(width: 1)
                    ZStack(alignment: .center) {
                        primary
                            .frame(width: UIScreen.screenWidth - 2, height: 25)
                        Text(weekflag.weekLabelText)
                            .foregroundColor(weekflag.weekLabelColor)
                            .fontWeight(.bold)
                    }
                    Color.white.frame(width: 1)
                }
            }
        }
        Color.white
            .frame(width: UIScreen.screenWidth, height: 0)
    }
}

struct TimetableGridTitle_Previews: PreviewProvider {
    static var previews: some View {
        TimetableGridTitle(false)
    }
}
