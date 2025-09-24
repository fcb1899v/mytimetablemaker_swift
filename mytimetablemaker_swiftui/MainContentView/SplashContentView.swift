//
//  MainContentView.swift
//  mytimetablemaker_swiftui
//  Created by Nakajima Masao on 2020/12/25.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

// MARK: - Splash Content View
// Initial splash screen displayed when app launches
struct SplashContentView: View {

    @ObservedObject private var myTransfer: MyTransfer
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore

    @State private var isFinishSplash = false

    init(
        _ myTransfer: MyTransfer,
        _ myLogin: MyLogin,
        _ myFirestore: MyFirestore
    ) {
        self.myTransfer = myTransfer
        self.myLogin = myLogin
        self.myFirestore = myFirestore
    }

    var body: some View {
        
        NavigationStack {
            ZStack {
                // MARK: - Background and Content
                Color.accent
                VStack {
                    Spacer()
                    Text(appTitle)
                        .font(.system(size: screen.splashTitleFontSize))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screen.splashIconSize, height: screen.splashIconSize)
                    Spacer()
                    Spacer()
                    Spacer()
                }
                VStack(spacing: 0) {
                    Spacer()
                    Image("splash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screen.screenWidth)
                    Color.primary
                        .frame(width: screen.screenWidth, height: screen.admobBannerHeight)
                }
            }
            .frame(width: screen.screenWidth, height: screen.screenHeight)
            .onAppear {
                // Auto-navigate to main content after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation() {
                        isFinishSplash = true
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationDestination(isPresented: $isFinishSplash) {
                MainContentView(myTransfer, myLogin, myFirestore)
            }
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct SplashContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransfer = MyTransfer()
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        SplashContentView(myTransfer, myLogin, myFirestore)
    }
}

// MARK: - App Tracking Transparency Helper
// Requests app tracking transparency authorization
private func requestAppTrackingTransparencyAuthorization() {
    guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            // Handle post-request state processing
        })
    }
}
