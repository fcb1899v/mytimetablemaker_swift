//
//  MainContentView.swift
//  mytimetablemaker_swiftui
//  Created by Masao Nakajima on 2020/12/25.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

// MARK: - Splash Content View
// Initial splash screen displayed when app launches
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
                // MARK: - Background and Content
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
                
                // MARK: - Navigation to Main Content
                NavigationLink(
                    destination: MainContentView(myTransit, myLogin, myFirestore),
                    isActive: $isFinishSplash
                ) {
                    EmptyView()
                }
            }
            .frame(width: screenWidth, height: screenHeight)
            .onAppear {
                // Auto-navigate to main content after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation() {
                        isFinishSplash = true
                    }
                }
            }.edgesIgnoringSafeArea(.all)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct SplashContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = MyTransit()
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        SplashContentView(myTransit, myLogin, myFirestore)
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
