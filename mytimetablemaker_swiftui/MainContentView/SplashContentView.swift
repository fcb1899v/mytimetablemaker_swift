//
//  MainContentView.swift
//  mytimetablemaker_swiftui
//  Created by Nakajima Masao on 2020/12/25.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

struct SplashContentView: View {

    @ObservedObject private var myTransit: MyTransit
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore

    @State private var isFinishSplash = false

    init(
        _ myTransit: MyTransit,
        _ myLogin: MyLogin,
        _ myFirestore: MyFirestore
    ) {
        self.myTransit = myTransit
        self.myLogin = myLogin
        self.myFirestore = myFirestore
    }

    var body: some View {
        
        NavigationView {
            ZStack {
                Color.accentColor
                VStack {
                    Spacer()
                    Text(appTitle)
                        .font(.system(size: splashTitleFontSize))
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryColor)
                    Spacer()
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: splashIconSize, height: splashIconSize)
                    Spacer()
                    Spacer()
                    Spacer()
                }
                VStack {
                    Spacer()
                    Image("splash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth)
                }
                NavigationLink(
                    destination: MainContentView(myTransit, myLogin, myFirestore),
                    isActive: $isFinishSplash
                ) {
                    EmptyView()
                }
            }
            .frame(width: screenWidth, height: screenHeight)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation() {
                        isFinishSplash = true
                    }
                }
            }.edgesIgnoringSafeArea(.all)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SplashContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = MyTransit()
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        SplashContentView(myTransit, myLogin, myFirestore)
    }
}

private func requestAppTrackingTransparencyAuthorization() {
    guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            // リクエスト後の状態に応じた処理を行う
        })
    }
}
