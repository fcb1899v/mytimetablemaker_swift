//
//  SceneDelegate.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/09/03.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

// MARK: - Scene Delegate
// Manages scene lifecycle for iOS 13+ multi-scene support
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    // Main window for the scene
    var window: UIWindow?

    // MARK: - Scene Lifecycle
    // Called when a new scene is being created
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Configure and attach `window` to `scene` (automatic with a storyboard).
        // The scene or session is not necessarily new; see application:configurationForConnectingSceneSession.
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    // MARK: - Scene State Changes
    // Called when the scene is being released by the system
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called shortly after the scene enters the background or its session is discarded.
        // Release re-creatable resources; the scene may reconnect (see didDiscardSceneSessions)
    }

    // Called when the scene has moved from an inactive state to an active state
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    // Called when the scene will move from an active state to an inactive state
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    // Called as the scene transitions from the background to the foreground
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    // Called as the scene transitions from the foreground to the background
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called on foreground -> background.
        // Save data, release shared resources, and store enough scene-specific state to restore the scene later.
    }
}

