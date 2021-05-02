//
//  SettingsLinkView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/16.
//

import SwiftUI

struct settingsLinkView: View {
    
    let termstitle = "Terms and privacy policy".localized
    let termslink = "https://nakajimamasao-appstudio.web.app/privacypolicy.html".localized
    
    var body: some View {
        Button(action: {
            if let yourURL = URL(string: termslink) {
                UIApplication.shared.open(yourURL, options: [:], completionHandler: nil)
            }
        }) {
           Text(termstitle)
            .font(.subheadline)
            .foregroundColor(.black)
            .padding(5)
        }
    }
}

struct settingLinkView_Previews: PreviewProvider {
    static var previews: some View {
        settingsLinkView()
    }
}

