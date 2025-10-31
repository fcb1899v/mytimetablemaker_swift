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
    // Text content to display in the tag
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
    // Binding for selected state (true = left, false = right)
    @Binding var isLeftSelected: Bool
    
    // Left option text and color
    let leftText: String
    let leftColor: Color
    
    // Right option text and color
    let rightText: String
    let rightColor: Color
    
    // Toggle circle color
    let circleColor: Color
    
    // Color for unselected state
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
    // Binding for the selected value
    @Binding var value: Int
    
    // Flag to restrict range to 0-59 (for time) or 0-99 (for general use)
    let isZeroToFive: Bool
    
    // MARK: - Computed Properties
    
    // Minimum selectable value
    private var minValue: Int { 0 }
    
    // Maximum selectable value based on isZeroToFive flag
    private var maxValue: Int { isZeroToFive ? 59 : 99 }
    
    // Extract tens digit from value
    private var tensDigit: Int { value / 10 }
    
    // Extract ones digit from value
    private var onesDigit: Int { value % 10 }
    
    // Range for tens digit picker
    private var tensRange: ClosedRange<Int> {
        let minTens = minValue / 10
        let maxTens = maxValue / 10
        return minTens...maxTens
    }
    
    // Range for ones digit picker (dynamically adjusted based on tens value)
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
    // Button title text
    let title: String
    
    // Optional SF Symbol icon name
    let icon: String?
    
    // Background color when enabled
    let backgroundColor: Color
    
    // Whether button is enabled/disabled
    let isEnabled: Bool
    
    // Action to perform when tapped
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
    // Button title text
    let title: String
    
    // Optional SF Symbol icon name
    let icon: String?
    
    // Tint color for the button
    let tintColor: Color
    
    // Action to perform when tapped
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
    // Background color to apply
    let backgroundColor: Color
    
    // Initialize with default or custom background color
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
    // Border color to apply
    let borderColor: Color
    
    // Initialize with default or custom border color
    init(borderColor: Color = Color(.separator)) {
        self.borderColor = borderColor
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: screen.settingsSheetCornerRadius)
            .stroke(borderColor, lineWidth: screen.settingsSheetStrokeLineWidth)
    }
}

// MARK: - Custom Back Button Button
// Reusable back button component with consistent styling across iOS versions
struct CustomBackButton: View {
    // Foreground color for button text and icon
    let foregroundColor: Color
    
    // Action to perform when tapped
    let action: () -> Void
    
    // Initialize with default or custom foreground color
    init(
        foregroundColor: Color = .white,
        action: @escaping () -> Void
    ) {
        self.foregroundColor = foregroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "arrowshape.backward.fill")
                    .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                    .foregroundColor(foregroundColor)
                Text("Back to homepage".localized)
                    .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                    .foregroundColor(foregroundColor)
            }
        }
    }
}

// MARK: - Custom Account Button
// Generic button component for account-related operations with confirmation and result alerts
struct CustomAccountButton: View {
    
    // Observed objects
    @ObservedObject private var myTransfer: TransferViewModel
    @ObservedObject private var myLogin: LoginViewModel
    @ObservedObject private var myFirestore: FirestoreViewModel
    
    // Alert and navigation state flags
    @State private var isShowAlert = false
    @State private var isShowResultAlert = false
    @State private var isNavigateToMain = false
    
    // Configuration properties
    let buttonTitle: String
    let alertTitle: String
    let alertMessage: String
    let action: () -> Void
    let isSuccess: () -> Bool
    
    init(
        myTransfer: TransferViewModel,
        myLogin: LoginViewModel,
        myFirestore: FirestoreViewModel,
        buttonTitle: String,
        alertTitle: String,
        alertMessage: String,
        action: @escaping () -> Void,
        isSuccess: @escaping () -> Bool
    ) {
        self.myTransfer = myTransfer
        self.myLogin = myLogin
        self.myFirestore = myFirestore
        self.buttonTitle = buttonTitle
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.action = action
        self.isSuccess = isSuccess
    }
    
    var body: some View {
        Button(action: {
            isShowAlert = true
        }) {
            Text(buttonTitle.localized)
                .font(.system(size: screen.settingsFontSize))
                .foregroundColor(.black)
        }
        // MARK: - Confirmation Alert
        .alert(alertTitle.localized, isPresented: $isShowAlert) {
            // OK button
            Button("OK".localized, role: .destructive) {
                action()
                isShowAlert = false
                // Show result alert after action
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isShowResultAlert = true
                }
            }
            // Cancel button
            Button("Cancel".localized, role: .cancel) {
                isShowAlert = false
            }
        } message: {
            Text(alertMessage.localized)
        }
        .tint(.primary)
        
        // MARK: - Result Alert
        .alert(myLogin.alertTitle, isPresented: $isShowResultAlert) {
            Button("OK".localized, role: .none) {
                isShowResultAlert = false
                if isSuccess() {
                    isNavigateToMain = true
                }
            }
        } message: {
            Text(myLogin.alertMessage)
        }
        .tint(.primary)
        .navigationDestination(isPresented: $isNavigateToMain) {
            MainContentView(myTransfer, myLogin, myFirestore)
        }
    }
}
