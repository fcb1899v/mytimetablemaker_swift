//
//  LoginContentView.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/09.
//

import SwiftUI
import Firebase
import FirebaseAuth
import GoogleMobileAds

struct LoginContentView: View {

    @ObservedObject private var loginviewmodel: LoginViewModel
    @ObservedObject private var mainviewmodel: MainViewModel
    @ObservedObject private var firestoreviewmodel: FirestoreViewModel

    init(
        _ loginviewmodel: LoginViewModel,
        _ mainviewmodel: MainViewModel,
        _ firestoreviewmodel: FirestoreViewModel
    ) {
        self.loginviewmodel = loginviewmodel
        self.mainviewmodel = mainviewmodel
        self.firestoreviewmodel = firestoreviewmodel
    }

    @State private var isShowSplash = true

    var body: some View {

        let title = "My Transit Makers".localized
        
        ZStack(alignment: .top) {
            LoginBackgroundView()
            VStack(spacing: 30) {
                loginTitleView(title)
                emailTextField(loginviewmodel)
                loginButton(loginviewmodel, firestoreviewmodel)
                moveSignUpButton(loginviewmodel, firestoreviewmodel)
                passwordResetView(loginviewmodel)
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                AdMobView()
            }
            .edgesIgnoringSafeArea(.all)
            .opacity(isShowSplash ? 0 : 1)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation() {
                        self.isShowSplash = false
                    }
                }
            }
        }
    }
}

struct LoginContentView_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        let mainviewmodel = MainViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        LoginContentView(loginviewmodel, mainviewmodel, firestoreviewmodel)
    }
}
