//
//  lineTimeButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2023/10/01.
//

import SwiftUI

struct lineTimeImage: View {
    
    private let color: Color
    
    /// 値を指定して生成する
    init(
        color: Color
    ){
        self.color = color
    }
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(width: routeLineImageBackgroundWidth, height: routeLineImageBackgroundHeight)
                .foregroundColor(color)
            Image(uiImage: UIImage(named: "ic_clock2.png")!)
                .resizable()
                .scaledToFit()
                .frame(width: routeLineImageForegroundSize)
                .foregroundColor(.white)
                .padding(.leading, routeLineImageLeftPadding)
        }
        .padding(.leading, routeLineImageForegroundLeftPadding)
        .padding(.trailing, routeLineImageBackgroundPadding)
        .padding(.top, routeLineImageBackgroundPadding)
        .padding(.bottom, routeLineImageBackgroundPadding)
    }
}
    
struct lineTimeImage_Previews: PreviewProvider {
    static var previews: some View {
        lineTimeImage(color: Color.grayColor)
    }
}

