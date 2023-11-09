//
//  mytimetablemaker_swiftuiApp.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/06.
//

import UIKit
import SwiftUI
import Firebase


@main
struct mytimetablemaker_swiftuiApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        
        let myTransit = MyTransit()
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        
        WindowGroup {
            ContentView(myTransit, myLogin, myFirestore)
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
