//
//  CommonComponent.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2025/08/24.
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
    let offColor: Color
    
    // MARK: - Initializer
    init(
        isLeftSelected: Binding<Bool>,
        leftText: String,
        leftColor: Color,
        rightText: String,
        rightColor: Color,
        circleColor: Color,
        offColor: Color
    ) {
        self._isLeftSelected = isLeftSelected
        self.leftText = leftText
        self.leftColor = leftColor
        self.rightText = rightText
        self.rightColor = rightColor
        self.circleColor = circleColor
        self.offColor = offColor
    }
    
    var body: some View {
        HStack(spacing: screen.customToggleSpacing) {
            // Left label
            Text(leftText)
                .font(.system(size: screen.settingsSheetInputFontSize, weight: .medium))
                .foregroundColor(isLeftSelected ? leftColor : offColor)
                .animation(.easeInOut(duration: 0.2), value: isLeftSelected)
            
            // Toggle switch
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: screen.customToggleCornerRadius)
                    .fill(isLeftSelected ? leftColor : rightColor)
                    .frame(width: screen.customToggleWidth, height: screen.customToggleHeight)
                    .animation(.easeInOut(duration: 0.1), value: isLeftSelected)
                
                // Toggle circle
                Circle()
                    .fill(circleColor)
                    .frame(width: screen.customToggleCircleSize, height: screen.customToggleCircleSize)
                    .offset(x: isLeftSelected ? -screen.customToggleCircleOffset : screen.customToggleCircleOffset)
                    .animation(.easeInOut(duration: 0.2), value: isLeftSelected)
            }
            .onTapGesture {
                isLeftSelected.toggle()
            }
            
            // Right label
            Text(rightText)
                .font(.system(size: screen.settingsSheetInputFontSize, weight: .medium))
                .foregroundColor(isLeftSelected ? offColor : rightColor)
                .animation(.easeInOut(duration: 0.2), value: isLeftSelected)
        }
        .padding(.horizontal, screen.customTogglePaddingHorizontal)
    }
}

// MARK: - CustomToggle Convenience Initializers
extension CustomToggle {
    // Convenience initializer with default colors
    init(
        isLeftSelected: Binding<Bool>,
        leftText: String,
        rightText: String,
        primaryColor: Color = .primary,
        secondaryColor: Color = .secondary,
        circleColor: Color = .white,
    ) {
        self.init(
            isLeftSelected: isLeftSelected,
            leftText: leftText,
            leftColor: primaryColor,
            rightText: rightText,
            rightColor: secondaryColor,
            circleColor: circleColor,
            offColor: secondaryColor
        )
    }
    
    // Convenience initializer for boolean states
    init(
        isOn: Binding<Bool>,
        onText: String,
        offText: String,
        onColor: Color = .primary,
        offColor: Color = .secondary,
        circleColor: Color = .white
    ) {
        self.init(
            isLeftSelected: isOn,
            leftText: onText,
            leftColor: onColor,
            rightText: offText,
            rightColor: offColor,
            circleColor: circleColor,
            offColor: offColor
        )
    }
}

// MARK: - Two Digit Number Picker
// Picker component for selecting two-digit numbers with separate tens and ones place
struct Custom2DigitPicker: View {
    @Binding var value: Int
    
    let isZeroToFive: Bool
    
    // MARK: - Computed Properties
    private var minValue: Int { 0 }    
    private var maxValue: Int { isZeroToFive ? 59 : 99 }
    
    // MARK: - Computed Properties
    private var tensDigit: Int { value / 10 }
    private var onesDigit: Int { value % 10 }
    
    private var tensRange: ClosedRange<Int> {
        let minTens = minValue / 10
        let maxTens = maxValue / 10
        return minTens...maxTens
    }
    
    private var onesRange: ClosedRange<Int> {
        // Always allow 0-9 for ones digit regardless of isZeroToFive setting
        let baseRange = 0...9
        let minTens = minValue / 10
        let maxTens = maxValue / 10
        
        // Determine range based on tens digit position
        let lowerBound = tensDigit == minTens ? max(baseRange.lowerBound, minValue % 10) : baseRange.lowerBound
        let upperBound = tensDigit == maxTens ? min(baseRange.upperBound, maxValue % 10) : baseRange.upperBound
        
        return lowerBound...upperBound
    }
    
    // MARK: - Initializer
    init(value: Binding<Int>, isZeroToFive: Bool = false) {
        self._value = value
        self.isZeroToFive = isZeroToFive
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: screen.settingsSheetPickerSpacing) {
            // Tens digit picker
            Picker("Tens", selection: Binding(
                get: { tensDigit },
                set: { newTens in
                    let newValue = newTens * 10 + onesDigit
                    if newValue >= minValue && newValue <= maxValue {
                        value = newValue
                    }
                }
            )) {
                ForEach(tensRange, id: \.self) { digit in
                    Text("\(digit)")
                        .tag(digit)
                        .font(.system(size: screen.settingsSheetInputFontSize, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: screen.settingsSheetPickerSelectWidth, height: screen.settingsSheetPickerSelectHeight)
            
            // Ones digit picker
            Picker("Ones", selection: Binding(
                get: { onesDigit },
                set: { newOnes in
                    let newValue = tensDigit * 10 + newOnes
                    if newValue >= minValue && newValue <= maxValue {
                        value = newValue
                    }
                }
            )) {
                ForEach(onesRange, id: \.self) { digit in
                    Text("\(digit)")
                        .tag(digit)
                        .font(.system(size: screen.settingsSheetInputFontSize, weight: .medium))
                        .foregroundColor(.black)                        
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: screen.settingsSheetPickerSelectWidth, height: screen.settingsSheetPickerSelectHeight)
        }
        .frame(height: screen.settingsSheetPickerSelectHeight)
    }
}

/// Custom button component for consistent styling
struct CustomButton: View {
    let title: String
    let icon: String?
    let backgroundColor: Color
    let isEnabled: Bool
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        backgroundColor: Color = Color.accent,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: icon != nil ? screen.settingsSheetIconSpacing : 0) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: screen.settingsSheetButtonFontSize, weight: .medium))
                }
                Text(title)
                    .font(.system(size: screen.settingsSheetButtonFontSize, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: screen.settingsSheetButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: screen.settingsSheetButtonCornerRadius)
                    .fill(isEnabled ? backgroundColor : Color.gray)
            )
        }
        .disabled(!isEnabled)
    }
}

/// Custom rectangle button component for consistent styling
struct CustomRectangleButton: View {
    let title: String
    let icon: String?
    let tintColor: Color
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        tintColor: Color = Color.accent,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.tintColor = tintColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: icon != nil ? screen.settingsSheetIconSpacing : 0) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: screen.settingsSheetInputFontSize))
                        .foregroundColor(.white)
                }
                Text(title)
                    .font(.system(size: screen.settingsSheetInputFontSize))
                    .foregroundColor(.white)
            }
        }
        .font(.system(size: screen.settingsSheetButtonFontSize))
        .buttonStyle(.borderedProminent)
        .tint(tintColor)
    }
}

// MARK: - Custom Styling Helpers
// Common custom styling components for consistent UI appearance

/// Custom background for input fields
struct CustomBackground: View {
    let backgroundColor: Color
    
    init(backgroundColor: Color = Color(.secondarySystemBackground)) {
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
            .fill(backgroundColor)
    }
}

/// Custom border for input fields
struct CustomBorder: View {
    let borderColor: Color
    
    init(borderColor: Color = Color(.separator)) {
        self.borderColor = borderColor
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
            .stroke(borderColor, lineWidth: screen.settingsSheetStrokeLineWidth)
    }
}

