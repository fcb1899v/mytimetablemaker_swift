//
//  lineTimeButton.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2023/10/01.
//

import SwiftUI
import Foundation

// MARK: - Line Time Image View
// Custom view component displaying different icons based on line type and transfer information
struct lineTimeImage: View {
    
    // MARK: - Properties
    private let lineColor: Color
    private let lineCode: String
    private let isTransfer: Bool
    private let transportation: String
    
    // MARK: - Initialization
    init(
        lineColor: Color,
        lineCode: String,
        isTransfer: Bool,
        transportation: String
    ){
        self.lineColor = lineColor
        self.lineCode = lineCode
        self.isTransfer = isTransfer
        self.transportation = transportation
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .center) {
            // MARK: - Background Rectangle
            Rectangle()
                .frame(width: lineImageBackgroundSize, height: lineImageBackgroundSize)
                .foregroundColor(lineColor)
            
            // MARK: - Icon Content
            Group {
                if isTransfer {
                    // MARK: - Transfer Icon
                    // Displays transportation method icon for transfer scenarios
                    Image(systemName: transportation != "" ? getTransportationType(label: transportation).iconName: "figure.walk")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: lineImageForegroundSize,
                            height: lineImageForegroundSize
                        )
                } else {
                    // MARK: - Lightrail Icon
                    // Default icon for lines without specific line codes
                    Image(systemName: "lightrail")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: lineImageForegroundSize,
                            height: lineImageForegroundSize
                        )
                }
            }
            .foregroundColor(Color.white)
            
            // MARK: - Line Code Text
            // Displays line code as text with appropriate styling
            Text(lineCode)
                .font(.system(size: 14, weight: .bold, design: .default))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundColor(Color.white)
                .shadow(color: .secondary, radius: 0, x: 0.5, y: 0)
                .shadow(color: .secondary, radius: 0, x: -0.5, y: 0)
                .shadow(color: .secondary, radius: 0, x: 0, y: 0.5)
                .shadow(color: .secondary, radius: 0, x: 0, y: -0.5)
                .shadow(color: .secondary, radius: 0, x: 0.5, y: 0.5)
                .shadow(color: .secondary, radius: 0, x: 0.5, y: -0.5)
                .shadow(color: .secondary, radius: 0, x: -0.5, y: 0.5)
                .shadow(color: .secondary, radius: 0, x: -0.5, y: -0.5)
        }
    }
}
    
// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct lineTimeImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Transfer example
            lineTimeImage(lineColor: Color.grayColor, lineCode: "", isTransfer: true, transportation: "walking")
            // Line code example (JK for 京浜東北線)
            lineTimeImage(lineColor: Color.green, lineCode: "JK", isTransfer: false, transportation: "")
            // Default lightrail example
            lineTimeImage(lineColor: Color.grayColor, lineCode: "", isTransfer: true, transportation: "walking")
        }
    }
}

