//
//  signUpView.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/12.
//

import SwiftUI
import FirebaseAuth
import GoogleMobileAds

struct signUpView: View {
    
    @ObservedObject private var loginviewmodel: LoginViewModel
    @ObservedObject private var firestoreviewmodel: FirestoreViewModel

    init(
        _ loginviewmodel: LoginViewModel,
        _ firestoreviewmodel: FirestoreViewModel
    ) {
        self.loginviewmodel = loginviewmodel
        self.firestoreviewmodel = firestoreviewmodel
    }

    var body: some View {
        ZStack(alignment: .top){
            Color.accent
            VStack(spacing: 35) {
                loginTitleView(MainTitle.signup.rawValue.localized)
                emailPlusTextField(loginviewmodel)
                signUpButton(loginviewmodel, firestoreviewmodel)
                termsLinkView(loginviewmodel)
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                AdMobView()
            }
        }
    }
}

struct signUpView_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        signUpView(loginviewmodel, firestoreviewmodel)
    }
}

