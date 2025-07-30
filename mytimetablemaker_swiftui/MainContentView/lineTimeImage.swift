//
//  lineTimeButton.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2023/10/01.
//

import SwiftUI

// MARK: - Line Time Image View
// Custom view component displaying a clock icon with colored background
struct lineTimeImage: View {
    
    private let color: Color
    
    init(
        color: Color
    ){
        self.color = color
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // MARK: - Background Rectangle
            Rectangle()
                .frame(width: routeLineImageBackgroundWidth, height: routeLineImageBackgroundHeight)
                .foregroundColor(color)
            
            // MARK: - Clock Icon
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
    
// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct lineTimeImage_Previews: PreviewProvider {
    static var previews: some View {
        lineTimeImage(color: Color.grayColor)
    }
}

