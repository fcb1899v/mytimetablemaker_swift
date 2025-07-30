//
//  AppDelegate.swift
//  mytimetablemaker
//  Created by Masao Nakajima on 2020/09/03.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit
import GoogleMobileAds

// MARK: - App Delegate
// Main application delegate for UIKit version
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    // Main window for the application
    var window: UIWindow?
    
    // MARK: - Application Lifecycle
    // Called when the application finishes launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Add a brief delay for splash screen display
        sleep(1)
        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }

    // MARK: - Scene Configuration
    // Configure scene session for iOS 13+ multi-scene support
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Scene Session Management
    // Called when scene sessions are discarded
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

