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

    let primary = Color(DefaultColor.primary.rawValue.colorInt)
    
    var body: some View {
        Button(action: {
            termsLink()
        }) {
            HStack {
                termsCheckBox(loginviewmodel)
                termsLabel
            }.frame(width: UIScreen.screenWidth * 0.7, height: 40 ,alignment: .leading)
        }
    }
    
    private var termsLabel: some View {
        (Text("I have read and agree to the ".localized)
        + Text("terms and privacy policy".localized)
            .underline(color: Color.white)
        + Text("kakunin".localized))
            .font(.subheadline)
            .foregroundColor(Color.white)
    }

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
            .background(Color.black)
    }
}

