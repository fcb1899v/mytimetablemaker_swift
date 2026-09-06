//
//  mytimetablemaker_swiftuiApp.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2021/04/06.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseAppCheck
import GoogleMobileAds

// MARK: - Main App Structure
// Main entry point for the SwiftUI timetable maker application
@main
struct mytimetablemaker_swiftuiApp: App {
    
    // UIKit integration for handling app lifecycle events
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // Coming back from background is the one moment the network can change
    // without the app doing anything
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        
        // Initialize core data models for the application
        let myTransit = TransitViewModel()
        let myLogin = LoginViewModel()
        let myFirestore = FirestoreViewModel()
        
        WindowGroup {
            SplashContentView(myTransit, myLogin, myFirestore)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active { AppCheckState.shared.refresh() }
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
        // App Check must be installed before configure(), or the first token
        // request goes out without a provider. Firestore holds one document
        // tree per signed in user and had no protection beyond the rules.
        //
        // Debug prints a token to the console; register it under Firebase
        // Console -> App Check -> Manage debug tokens, per install.
        AppCheckState.seedDebugToken()
        AppCheckState.installProvider()

        // Initialize Firebase services when app launches
        FirebaseApp.configure()

        AppCheckState.shared.refresh()
        
        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)
    
        return true
    }
    
    // MARK: - Screen Orientation
    // Lock screen orientation to portrait mode only
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: - App Check State
// Whether App Check has cleared. Firestore holds one document tree per signed
// in user, so the settings account section stays hidden until this is true.
// Lives in this file because adding a file means editing the Xcode project.
final class AppCheckState: ObservableObject {
    static let shared = AppCheckState()

    @Published private(set) var isReady = false

    private init() {}

    // A failed attestation can still hand back a non-empty placeholder, which
    // the backend later rejects. Only a real three part JWT counts as ready
    static func isValidJWT(_ token: String?) -> Bool {
        guard let token = token, !token.isEmpty else { return false }
        let parts = token.split(separator: ".", omittingEmptySubsequences: false)
        return parts.count == 3 && parts.allSatisfy { !$0.isEmpty }
    }

    // The debug provider reads this key, so the token from Debug.xcconfig is
    // used instead of one the SDK generates per install. Must run before
    // FirebaseApp.configure()
    static func seedDebugToken() {
        #if DEBUG
        guard let token = Bundle.main.infoDictionary?["APP_CHECK_DEBUG_TOKEN"] as? String,
              !token.isEmpty, token != "$(APP_CHECK_DEBUG_TOKEN)" else {
            print("App Check: no APP_CHECK_DEBUG_TOKEN in Debug.xcconfig; the SDK will generate one")
            return
        }
        UserDefaults.standard.set(token, forKey: "FIRAAppCheckDebugToken")
        #endif
    }

    // Staged, not the same call repeated: a stale cache is fixed by forcing a
    // refresh, and a provider that never installed is fixed by installing it
    // again. Repeating one call just repeats one failure
    func refresh() {
        if isReady { return }
        token(forcingRefresh: false) { [weak self] cached in
            guard let self = self else { return }
            if AppCheckState.isValidJWT(cached) { return self.settle(cached) }
            self.token(forcingRefresh: true) { forced in
                if AppCheckState.isValidJWT(forced) { return self.settle(forced) }
                AppCheckState.installProvider()
                self.token(forcingRefresh: true) { retried in self.settle(retried) }
            }
        }
    }

    // Installed at launch and again as the last stage above
    static func installProvider() {
        #if DEBUG
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(DeviceCheckProviderFactory())
        #endif
    }

    private func settle(_ token: String?) {
        let ready = AppCheckState.isValidJWT(token)
        DispatchQueue.main.async { self.isReady = ready }
        print("App Check: \(ready ? "ready (token length \(token?.count ?? 0))" : "NOT ready")")
    }

    private func token(forcingRefresh: Bool, next: @escaping (String?) -> Void) {
        AppCheck.appCheck().token(forcingRefresh: forcingRefresh) { token, error in
            if let error = error {
                print("App Check token failed (forcingRefresh: \(forcingRefresh)) - \(error.localizedDescription)")
            }
            next(token?.token)
        }
    }
}
