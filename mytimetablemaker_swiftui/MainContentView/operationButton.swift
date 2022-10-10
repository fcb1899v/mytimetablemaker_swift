//
//  stateButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/06.
//

import SwiftUI

struct operationButton: View {
    
    private let isOn: Bool
    private let label: String
    private let action: () -> Void

    /// 値を指定して生成する
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
                .fontWeight(.bold)
                .frame(width: operationButtonWidth, height: operationButtonHeight)
                .foregroundColor(.white)
                .background(isOn ? Color.accentColor: Color.grayColor)
                .cornerRadius(operationButtonCornerRadius)
        }
    }
}

struct stateButton_Previews: PreviewProvider {
    static var previews: some View {
        operationButton(
            isOn: true,
            label: "Back",
            action: {}
        )
    }
}

