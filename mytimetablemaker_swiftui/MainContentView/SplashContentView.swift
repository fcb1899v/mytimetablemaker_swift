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
import GoogleMobileAds

// MARK: - Splash Content View
// Main view that manages app navigation and core functionality
struct SplashContentView: View {
    
    // Core data models for app state management
    @ObservedObject private var myTransit: TransitViewModel
    @ObservedObject private var myLogin: LoginViewModel
    @ObservedObject private var myFirestore: FirestoreViewModel
    // Shared data manager for monitoring loading state
    @ObservedObject private var sharedDataManager = SharedDataManager.shared
    // Inline splash navigation state
    @State private var isFinishSplash = false
    // Ad banner view for preloading ads during splash
    @State private var adBannerView: BannerView?

    // MARK: - Initialization
    init(
        _ myTransit: TransitViewModel,
        _ myLogin: LoginViewModel,
        _ myFirestore: FirestoreViewModel
    ) {
        self.myTransit = myTransit
        self.myLogin = myLogin
        self.myFirestore = myFirestore
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
                
                // MARK: - Loading Overlay
                // Dark overlay with progress bar when loading initial data
                if sharedDataManager.isLoading {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                    
                    VStack(spacing: screen.splashLoadingSpacing) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Loading data...".localized)
                            .font(.system(size: screen.splashLoadingFontSize))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: screen.screenWidth, height: screen.screenHeight)
            .onAppear {
                // Set loading state immediately when view appears
                sharedDataManager.isLoading = true
                
                // Preload ads during splash screen (ATT is requested inside preloadAds)
                print("🚀 Splash screen appeared - starting initialization")
                adBannerView = AdMobBannerView.preloadAds()
                
                // Initialize data and perform update check when app launches
                Task {
                    await sharedDataManager.performSplashInitialization()
                    
                    // Navigate to main content after loading completes
                    await MainActor.run {
                        withAnimation() { isFinishSplash = true }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationDestination(isPresented: $isFinishSplash) {
                MainContentView(myTransit, myLogin, myFirestore)
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct SplashContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = TransitViewModel()
        let myLogin = LoginViewModel()
        let myFirestore = FirestoreViewModel()
        SplashContentView(myTransit, myLogin, myFirestore)
    }
}
