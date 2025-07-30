//
//  stateButton.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/02/06.
//

import SwiftUI

// MARK: - Operation Button
// Custom button component for header operation controls
struct operationButton: View {
    
    private let isOn: Bool
    private let label: String
    private let action: () -> Void

    init(
        isOn: Bool,
        label: String,
        action: @escaping () -> Void
    ){
        self.isOn = isOn
        self.label = label
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: operationButtonFontSize))
                .fontWeight(.semibold)
                .frame(width: operationButtonWidth, height: operationButtonHeight)
                .foregroundColor(.white)
                .background(isOn ? Color.accentColor: Color.grayColor)
                .cornerRadius(operationButtonCornerRadius)
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct stateButton_Previews: PreviewProvider {
    static var previews: some View {
        operationButton(
            isOn: true,
            label: "Back",
            action: {}
        )
    }
}

