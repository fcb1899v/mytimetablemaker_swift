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
struct LineTimeImage: View {
    
    // MARK: - Properties
    private let lineColor: Color
    private let lineCode: String
    private let isTransfer: Bool
    private let transportation: String
    private let transportationKind: TransportationLine.Kind?
    
    // MARK: - Initialization
    init(
        lineColor: Color,
        lineCode: String,
        isTransfer: Bool,
        transportation: String,
        transportationKind: TransportationLine.Kind? = nil
    ){
        self.lineColor = lineColor
        self.lineCode = lineCode
        self.isTransfer = isTransfer
        self.transportation = transportation
        self.transportationKind = transportationKind
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .center) {
            // MARK: - Background Rectangle
            Rectangle()
                .frame(width: screen.lineImageBackgroundSize, height: screen.lineImageBackgroundSize)
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
                            width: screen.lineImageForegroundSize,
                            height: screen.lineImageForegroundSize
                        )
                } else {
                    // MARK: - Transportation Icon
                    // Displays appropriate icon based on transportation kind
                    Image(systemName: getTransportationIcon())
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: screen.lineImageForegroundSize,
                            height: screen.lineImageForegroundSize
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
    
    // MARK: - Helper Methods
    // Get appropriate icon based on transportation kind
    private func getTransportationIcon() -> String {
        guard let kind = transportationKind else {
            return "lightrail" // Default to lightrail for unknown types
        }
        
        switch kind {
        case .railway:
            return "lightrail"
        case .bus:
            return "bus"
        }
    }
}
    
// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct lineTimeImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Transfer example
            LineTimeImage(lineColor: Color.grayColor, lineCode: "", isTransfer: true, transportation: "walking")
            // Railway line example (JK for 京浜東北線)
            LineTimeImage(lineColor: Color.green, lineCode: "JK", isTransfer: false, transportation: "", transportationKind: .railway)
            // Bus line example
            LineTimeImage(lineColor: Color.blue, lineCode: "B01", isTransfer: false, transportation: "", transportationKind: .bus)
            // Default lightrail example
            LineTimeImage(lineColor: Color.grayColor, lineCode: "", isTransfer: true, transportation: "walking")
        }
    }
}

