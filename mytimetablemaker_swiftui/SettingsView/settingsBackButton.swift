//
//  settingsBackButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/15.
//

import SwiftUI

struct settingsBackButton: View {
    
    private let action: () -> Void
    private let color: Color
    
    init(
        action: @escaping () -> Void,
        _ color: Color
    ) {
        self.action = action
        self.color = color
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image("arrow_back_ios")
                    .foregroundColor(color)
                Text("back".localized)
                    .foregroundColor(color)
            }
        }
    }
}

struct settingsBackButton_Previews: PreviewProvider {
    static var previews: some View {
        settingsBackButton(action: {}, Color.black)
    }
}

