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
            .font(.system(size: screen.settingsLineSheetCaptionFontSize, weight: .medium))
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
        HStack(spacing: screen.transportationToggleSpacing) {
            // Railway label
            Text("Railway".localized)
                .font(.system(size: screen.settingsLineSheetInputFontSize, weight: .medium))
                .foregroundColor(isRailway ? .primaryColor : .secondary)
                .animation(.easeInOut(duration: 0.2), value: isRailway)
            
            // Toggle switch
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: screen.transportationToggleCornerRadius)
                    .fill(Color.primaryColor)
                    .frame(width: screen.transportationToggleWidth, height: screen.transportationToggleHeight)
                    .animation(.easeInOut(duration: 0.1), value: isRailway)
                
                // Toggle circle
                Circle()
                    .fill(Color.white)
                    .frame(width: screen.transportationToggleCircleSize, height: screen.transportationToggleCircleSize)
                    .offset(x: isRailway ? -screen.transportationToggleCircleOffset : screen.transportationToggleCircleOffset)
                    .animation(.easeInOut(duration: 0.2), value: isRailway)
            }
            .onTapGesture {
                isRailway.toggle()
            }
            
            // Bus label
            Text("Bus".localized)
                .font(.system(size: screen.settingsLineSheetInputFontSize, weight: .medium))
                .foregroundColor(isRailway ? .secondary : .primaryColor)
                .animation(.easeInOut(duration: 0.1), value: isRailway)
        }
        .padding(.horizontal, screen.transportationTogglePaddingHorizontal)
    }
}

