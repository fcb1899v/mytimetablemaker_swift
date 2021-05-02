//
//  termsLinkView.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/10.
//

import SwiftUI

struct termsLinkView: View {
    
    @ObservedObject private var loginviewmodel: LoginViewModel
    
    init(
        _ loginviewmodel: LoginViewModel
    ) {
        self.loginviewmodel = loginviewmodel
    }

    var body: some View {
        Button(action: {
            termsLink()
        }) {
            HStack {
                
                //チェックボックス
                Button(action: toggle) {
                    if(loginviewmodel.isTermsAgree) {
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(.myprimary)
                            .padding(10)
                    } else {
                        Image(systemName: "square")
                            .foregroundColor(.white)
                            .padding(10)
                    }
                }
                
                //利用規約へのリンク付きテキスト
                (
                    Text("I have read and agree to the ".localized)
                    + Text("terms and privacy policy".localized).underline(color: Color.white)
                        + Text("kakunin".localized)
                )
                    .font(.subheadline)
                    .foregroundColor(.white)
                
            }.frame(width: UIScreen.screenWidth * 0.7, height: 40 ,alignment: .leading)
        }
    }
    
    // タップ時の状態の切り替え
    private func toggle() -> Void {
        loginviewmodel.isTermsAgree = !loginviewmodel.isTermsAgree
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    //
    private func termsLink() {
        let termslink = "https://nakajimamasao-appstudio.web.app/privacypolicy.html".localized
        if let yourURL = URL(string: termslink) {
            UIApplication.shared.open(yourURL, options: [:], completionHandler: nil)
        }
    }
}

struct termsLinkView_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        termsLinkView(loginviewmodel)
            .background(Color.myaccent)
    }
}

