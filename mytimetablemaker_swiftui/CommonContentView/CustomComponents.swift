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
struct CustomTag: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: screen.settingsLineSheetCaptionFontSize, weight: .medium))
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(Capsule().fill(Color(.secondarySystemFill)))
    }
}

// MARK: - Generic Custom Toggle Component
// Customizable toggle component with left/right text and colors
struct CustomToggle: View {
    @Binding var isLeftSelected: Bool
    
    let leftText: String
    let rightText: String
    let leftColor: Color
    let rightColor: Color
    let circleColor: Color
    
    // MARK: - Initializer
    init(
        isLeftSelected: Binding<Bool>,
        leftText: String,
        leftColor: Color,
        rightText: String,
        rightColor: Color,
        circleColor: Color = .white
    ) {
        self._isLeftSelected = isLeftSelected
        self.leftText = leftText
        self.leftColor = leftColor
        self.rightText = rightText
        self.rightColor = rightColor
        self.circleColor = circleColor
    }
    
    var body: some View {
        HStack(spacing: screen.transportationToggleSpacing) {
            // Left label
            Text(leftText)
                .font(.system(size: screen.settingsLineSheetInputFontSize, weight: .medium))
                .foregroundColor(isLeftSelected ? leftColor : .secondary)
                .animation(.easeInOut(duration: 0.2), value: isLeftSelected)
            
            // Toggle switch
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: screen.transportationToggleCornerRadius)
                    .fill(isLeftSelected ? leftColor : rightColor)
                    .frame(width: screen.transportationToggleWidth, height: screen.transportationToggleHeight)
                    .animation(.easeInOut(duration: 0.1), value: isLeftSelected)
                
                // Toggle circle
                Circle()
                    .fill(circleColor)
                    .frame(width: screen.transportationToggleCircleSize, height: screen.transportationToggleCircleSize)
                    .offset(x: isLeftSelected ? -screen.transportationToggleCircleOffset : screen.transportationToggleCircleOffset)
                    .animation(.easeInOut(duration: 0.2), value: isLeftSelected)
            }
            .onTapGesture {
                isLeftSelected.toggle()
            }
            
            // Right label
            Text(rightText)
                .font(.system(size: screen.settingsLineSheetInputFontSize, weight: .medium))
                .foregroundColor(isLeftSelected ? .secondary : rightColor)
                .animation(.easeInOut(duration: 0.2), value: isLeftSelected)
        }
        .padding(.horizontal, screen.transportationTogglePaddingHorizontal)
    }
}

// MARK: - CustomToggle Convenience Initializers
extension CustomToggle {
    // Convenience initializer with default colors
    init(
        isLeftSelected: Binding<Bool>,
        leftText: String,
        rightText: String,
        primaryColor: Color = .primaryColor,
        secondaryColor: Color = .secondary,
        circleColor: Color = .white
    ) {
        self.init(
            isLeftSelected: isLeftSelected,
            leftText: leftText,
            leftColor: primaryColor,
            rightText: rightText,
            rightColor: secondaryColor,
            circleColor: circleColor
        )
    }
    
    // Convenience initializer for boolean states
    init(
        isOn: Binding<Bool>,
        onText: String,
        offText: String,
        onColor: Color = .primaryColor,
        offColor: Color = .secondary,
        circleColor: Color = .white
    ) {
        self.init(
            isLeftSelected: isOn,
            leftText: onText,
            leftColor: onColor,
            rightText: offText,
            rightColor: offColor,
            circleColor: circleColor
        )
    }
}

