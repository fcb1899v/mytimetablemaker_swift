//
//  SwiftUIView.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/04/18.
//

import SwiftUI
import FirebaseAuth
import AppTrackingTransparency
import AdSupport
import GoogleMobileAds

// MARK: - Main Content View
// Main view that manages app navigation and core functionality
struct ContentView: View {
    
    // Core data models for app state management
    @ObservedObject private var myTransit: MyTransit
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore

    // MARK: - Initialization
    init(
        _ myTransit: MyTransit,
        _ myLogin: MyLogin,
        _ myFirestore: MyFirestore
    ) {
        self.myTransit = myTransit
        self.myLogin = myLogin
        self.myFirestore = myFirestore
        self.toTracking()
    }

    var body: some View {
        // Display splash screen with light color scheme
        SplashContentView(myTransit, myLogin, myFirestore)
            .preferredColorScheme(.light)        
    }
    
    // MARK: - Tracking Authorization
    // Request app tracking transparency permission and initialize mobile ads
    private func toTracking(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                // Initialize Google Mobile Ads after tracking permission is granted
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            })
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = MyTransit()
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        ContentView(myTransit, myLogin, myFirestore)
    }
}
