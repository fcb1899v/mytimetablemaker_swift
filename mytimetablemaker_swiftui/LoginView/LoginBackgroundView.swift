//
//  LoginBackgroundView.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/09.
//

import SwiftUI

struct LoginBackgroundView: View {
    
    var body: some View {
        ZStack {
            Color.myaccent
            VStack(spacing: 0) {
                Image("splash")
                    .resizable()
                    .scaledToFit()
                    .offset(y: 50)
                Color.myprimary
                    .frame(width: .screenwidth, height: 70)
                    .offset(y: 50)
            }
        }.edgesIgnoringSafeArea(.all)
        .frame(width: .screenwidth, height: .screenheight)
    }
}

struct LoginBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        LoginBackgroundView()
    }
}
