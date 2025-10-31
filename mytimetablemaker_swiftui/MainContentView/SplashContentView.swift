//
//  SwiftUIView.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2021/04/18.
//

import SwiftUI
import FirebaseAuth
import AppTrackingTransparency
import AdSupport

// MARK: - Splash Content View
// Main view that manages app navigation and core functionality
struct SplashContentView: View {
    
    // Core data models for app state management
    @ObservedObject private var myTransfer: TransferViewModel
    @ObservedObject private var myLogin: LoginViewModel
    @ObservedObject private var myFirestore: FirestoreViewModel
    // Inline splash navigation state
    @State private var isFinishSplash = false

    // MARK: - Initialization
    init(
        _ myTransfer: TransferViewModel,
        _ myLogin: LoginViewModel,
        _ myFirestore: FirestoreViewModel
    ) {
        self.myTransfer = myTransfer
        self.myLogin = myLogin
        self.myFirestore = myFirestore
        self.toTracking()
    }

    var body: some View {
        // Splash screen with light color scheme
        NavigationStack {
            ZStack {
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
                    Spacer(); Spacer(); Spacer()
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
                // Auto-navigate to main content after 2 seconds.
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation() { isFinishSplash = true }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationDestination(isPresented: $isFinishSplash) {
                MainContentView(myTransfer, myLogin, myFirestore)
            }
        }
        .preferredColorScheme(.light)
    }
    
    // MARK: - Tracking Authorization
    // Request app tracking transparency permission
    private func toTracking(){
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                print("🔍 AdMob Debug: App tracking transparency status: \(status.rawValue)")
            }
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct SplashContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransfer = TransferViewModel()
        let myLogin = LoginViewModel()
        let myFirestore = FirestoreViewModel()
        SplashContentView(myTransfer, myLogin, myFirestore)
    }
}
