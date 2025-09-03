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

// MARK: - Main Content View
// Main view that manages app navigation and core functionality
struct ContentView: View {
    
    // Core data models for app state management
    @ObservedObject private var myTransfer: MyTransfer
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore

    // MARK: - Initialization
    init(
        _ myTransfer: MyTransfer,
        _ myLogin: MyLogin,
        _ myFirestore: MyFirestore
    ) {
        self.myTransfer = myTransfer
        self.myLogin = myLogin
        self.myFirestore = myFirestore
        self.toTracking()
    }

    var body: some View {
        // Display splash screen with light color scheme
        SplashContentView(myTransfer, myLogin, myFirestore)
            .preferredColorScheme(.light)        
    }
    
    // MARK: - Tracking Authorization
    // Request app tracking transparency permission
    private func toTracking(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                print("🔍 AdMob Debug: App tracking transparency status: \(status.rawValue)")
            })
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransfer = MyTransfer()
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        ContentView(myTransfer, myLogin, myFirestore)
    }
}
