//
//  mytimetablemaker_swiftuiApp.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/04/06.
//

import UIKit
import SwiftUI
import Firebase
import GoogleMobileAds

// MARK: - Main App Structure
// Main entry point for the SwiftUI timetable maker application
@main
struct mytimetablemaker_swiftuiApp: App {
    
    // UIKit integration for handling app lifecycle events
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        
        // Initialize core data models for the application
        let myTransit = MyTransit()
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        
        WindowGroup {
            ContentView(myTransit, myLogin, myFirestore)
        }
    }
}

// MARK: - App Delegate
// Handles UIKit lifecycle events and Firebase configuration
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Firebase services when app launches
        FirebaseApp.configure()
        
        // Initialize Google Mobile Ads
        print("🔍 AdMob Debug: Starting Google Mobile Ads initialization...")
        GADMobileAds.sharedInstance().start { status in
            print("🔍 AdMob Debug: Google Mobile Ads initialization completed with status: \(status)")
        }
        
        return true
    }
}
