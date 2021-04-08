//
//  termsCheckBox.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/04/04.
//

import SwiftUI

struct termsCheckBox: View {
    
    @ObservedObject private var loginviewmodel: LoginViewModel
    
    init(
        _ loginviewmodel: LoginViewModel
    ) {
        self.loginviewmodel = loginviewmodel
    }

    let primary = Color(DefaultColor.primary.rawValue.colorInt)
    
    var body: some View {
        Button(action: toggle) {
            if(loginviewmodel.isTermsAgree) {
                Image(systemName: "checkmark.square.fill")
                    .foregroundColor(primary)
                    .padding(10)
            } else {
                Image(systemName: "square")
                    .foregroundColor(.white)
                    .padding(10)
            }
        }
    }
    
    // タップ時の状態の切り替え
    private func toggle() -> Void {
        loginviewmodel.isTermsAgree = !loginviewmodel.isTermsAgree
        UIImpactFeedbackGenerator(style: .medium)
        .impactOccurred()
    }
}

struct termsCheckBox_Previews: PreviewProvider {
    static var previews: some View {
        let accent = Color(DefaultColor.accent.rawValue.colorInt)
        let loginviewmodel = LoginViewModel()
        termsCheckBox(loginviewmodel)
            .background(accent)
    }
}
