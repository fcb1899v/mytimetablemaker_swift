//
//  CommonComponent.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/08/24.
//  Common UI components used across the application
//  Provides reusable UI elements for consistent design
//

import SwiftUI

// MARK: - UI Components
// Small tag display component for showing metadata
struct Tag: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: settingsLineSheetCaptionFontSize, weight: .medium))
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(Capsule().fill(Color(.secondarySystemFill)))
    }
}

// MARK: - Custom Toggle Component
// Railway/Bus selection toggle with dynamic color changes and responsive sizing
struct TransportationToggle: View {
    @Binding var isRailway: Bool
    
    var body: some View {
        HStack(spacing: transportationToggleSpacing) {
            // Railway label
            Text("Railway".localized)
                .font(.system(size: settingsLineSheetInputFontSize, weight: .medium))
                .foregroundColor(isRailway ? .primaryColor : .secondary)
                .animation(.easeInOut(duration: 0.2), value: isRailway)
            
            // Toggle switch
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: transportationToggleCornerRadius)
                    .fill(Color.primaryColor)
                    .frame(width: transportationToggleWidth, height: transportationToggleHeight)
                    .animation(.easeInOut(duration: 0.1), value: isRailway)
                
                // Toggle circle
                Circle()
                    .fill(Color.white)
                    .frame(width: transportationToggleCircleSize, height: transportationToggleCircleSize)
                    .offset(x: isRailway ? -transportationToggleCircleOffset : transportationToggleCircleOffset)
                    .animation(.easeInOut(duration: 0.2), value: isRailway)
            }
            .onTapGesture {
                isRailway.toggle()
            }
            
            // Bus label
            Text("Bus".localized)
                .font(.system(size: settingsLineSheetInputFontSize, weight: .medium))
                .foregroundColor(isRailway ? .secondary : .primaryColor)
                .animation(.easeInOut(duration: 0.1), value: isRailway)
        }
        .padding(.horizontal, transportationTogglePaddingHorizontal)
    }
}

