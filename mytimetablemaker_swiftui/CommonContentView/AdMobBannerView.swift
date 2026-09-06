//
//  AdMobBannerView.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2023/10/01.
//

import Foundation
import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

// MARK: - Banner Width Delegate Protocol
// Delegate methods for receiving width update messages from banner view controller
protocol BannerViewControllerWidthDelegate: AnyObject {
  func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat)
}

// MARK: - Banner View Controller
// Manages banner view lifecycle and width updates for adaptive banner ads
class BannerViewController: UIViewController {
    
  // Delegate for width updates (weak to avoid retain cycles)
  weak var delegate: BannerViewControllerWidthDelegate?
  
  // Last time when ad was loaded to prevent too frequent loads
  private var lastLoadTime: Date = Date.distantPast
  
  // Minimum interval between ad loads in seconds to prevent excessive requests
  private let minimumLoadInterval: TimeInterval = 60.0
  
  // Flag to enable/disable AdMob functionality
  var isAdMobEnabled: Bool = false

  // MARK: - Lifecycle Methods
  // Called when the view controller's view appears on screen
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // Notify delegate of the initial ad width for adaptive banner sizing
    let width = view.frame.inset(by: view.safeAreaInsets).size.width
    delegate?.bannerViewController(self, didUpdate: width)
    
    // Only load ads if AdMob is enabled
    guard isAdMobEnabled else { return }
    
    // Load ad after view appears with a slight delay (only if enough time has passed)
    let currentTime = Date()
    if currentTime.timeIntervalSince(lastLoadTime) >= minimumLoadInterval {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        if let bannerView = self.view.subviews.first(where: { $0 is BannerView }) as? BannerView,
           bannerView.adUnitID != nil && !bannerView.adUnitID!.isEmpty {
          let request = Request()
          bannerView.load(request)
          self.lastLoadTime = currentTime
        }
      }
    }
  }

  // Called when the device orientation changes
  // Updates banner width to match new orientation
  override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    coordinator.animate { _ in
      // No animation needed during transition
    } completion: { _ in
      // Notify delegate of ad width changes after transition completes
      let width = self.view.frame.inset(by: self.view.safeAreaInsets).size.width
      self.delegate?.bannerViewController(self, didUpdate: width)
    }
  }
}

// MARK: - SwiftUI AdMob Banner View
// SwiftUI wrapper for Google Mobile Ads banner view
struct AdMobBannerView: UIViewControllerRepresentable {

    // Current width of the banner view for adaptive sizing
    @State private var viewWidth: CGFloat = .zero
    
    // Last time when ad was loaded to prevent too frequent loads
    @State private var lastLoadTime: Date = Date.distantPast
    
    // Google Ads banner view instance
    private let bannerView = BannerView()
    
    // Minimum interval between ad loads in seconds to prevent excessive requests
    private let minimumLoadInterval: TimeInterval = 60.0
    
    // Flag to enable/disable AdMob for ads
    private let isAdMobEnabled: Bool = true
    
    // MARK: - Ad Unit ID Configuration
    // Reads AdMob unit ID from xcconfig file environment variable
    private var adUnitID: String {
        // Method 1: Try to get from Info.plist (set by xcconfig)
        if let unitID = Bundle.main.infoDictionary?["ADMOB_BANNER_UNIT_ID"] as? String,
           !unitID.isEmpty && unitID != "$(ADMOB_BANNER_UNIT_ID)" {
            print("🔍 AdMob Debug: ✅ Using unit ID from Info.plist: \(unitID)")
            return unitID
        }
        
        // Method 2: Try to get from environment variable directly
        if let unitID = ProcessInfo.processInfo.environment["ADMOB_BANNER_UNIT_ID"],
           !unitID.isEmpty {
            print("🔍 AdMob Debug: ✅ Using unit ID from environment: \(unitID)")
            return unitID
        }
        
        // Fallback to test unit ID to prevent invalid request errors
        print("🔍 AdMob Debug: ⚠️ Using fallback test unit ID")
        return "ca-app-pub-3940256099942544/2435281174"  // iOS adaptive demo unit
    }
    
    // MARK: - UIViewControllerRepresentable Methods
    // Create and configure the UIKit view controller for AdMob banner
    func makeUIViewController(context: Context) -> some UIViewController {
        let bannerViewController = BannerViewController()
        bannerViewController.isAdMobEnabled = isAdMobEnabled
        
        // Only initialize AdMob if enabled
        if isAdMobEnabled {
            bannerView.adUnitID = adUnitID
            bannerView.rootViewController = bannerViewController
            
            bannerViewController.view.addSubview(bannerView)
            
            // Set proper constraints for the banner view
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bannerView.centerXAnchor.constraint(equalTo: bannerViewController.view.centerXAnchor),
                bannerView.centerYAnchor.constraint(equalTo: bannerViewController.view.centerYAnchor),
                bannerView.widthAnchor.constraint(equalTo: bannerViewController.view.widthAnchor),
                bannerView.heightAnchor.constraint(equalToConstant: screen.admobBannerHeight)
            ])
            
            // Add delegate to handle ad loading
            bannerView.delegate = context.coordinator
        } else {
            // Create empty view when AdMob is disabled
            let emptyView = UIView()
            emptyView.backgroundColor = .clear
            bannerViewController.view.addSubview(emptyView)
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                emptyView.centerXAnchor.constraint(equalTo: bannerViewController.view.centerXAnchor),
                emptyView.centerYAnchor.constraint(equalTo: bannerViewController.view.centerYAnchor),
                emptyView.widthAnchor.constraint(equalTo: bannerViewController.view.widthAnchor),
                emptyView.heightAnchor.constraint(equalToConstant: screen.admobBannerHeight)
            ])
        }
        
        // Set the width delegate
        bannerViewController.delegate = context.coordinator
        
        return bannerViewController
    }
    
    // Update the UIKit view controller when SwiftUI state changes
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard viewWidth != .zero && isAdMobEnabled else {
            return 
        }
        
        // Check if enough time has passed since last load
        let currentTime = Date()
        guard currentTime.timeIntervalSince(lastLoadTime) >= minimumLoadInterval else {
            return
        }
        
        // Only load if banner view exists and is properly configured
        guard bannerView.adUnitID != nil && !bannerView.adUnitID!.isEmpty else {
            return
        }
        
        // Set ad size based on view width
        bannerView.adSize = inlineAdaptiveBanner(width: viewWidth, maxHeight: screen.admobBannerHeight)
        
        // Load the ad with error handling
        let request = Request()
        bannerView.load(request)
        lastLoadTime = currentTime
    }
    
    func makeCoordinator() -> Coordinator {
        // Create coordinator instance to handle delegate callbacks
        return Coordinator(self)
    }
    
    // MARK: - Coordinator
    // Coordinator class to handle AdMob delegate callbacks
    class Coordinator: NSObject, BannerViewDelegate, BannerViewControllerWidthDelegate {
        // Reference to parent AdMobBannerView for state updates
        var parent: AdMobBannerView
        
        // Initialize coordinator with reference to parent view
        init(_ parent: AdMobBannerView) {
            self.parent = parent
        }
        
        // Inline adaptive reports the size it was actually given here, not at
        // request time. The frame is pinned to admobBannerHeight, so a shorter
        // ad leaves the difference as empty space
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            let requested = bannerView.adSize.size
            let served = bannerView.intrinsicContentSize
            print("AdSize: \(Int(requested.width)) x cap \(Int(screen.admobBannerHeight)) / served: \(Int(served.width)) x \(Int(served.height))")
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            // Only log critical errors, suppress common test environment errors
            if let nsError = error as NSError? {
                switch nsError.code {
                case 1: // Invalid request error code
                    // Suppress this common error in test environment
                    return
                case 2: // No fill error code (no ads available)
                    // Suppress this common error in test environment
                    return
                default:
                    // Log other errors for debugging
                    print("🔍 AdMob Debug: Ad failed to load with error: \(error.localizedDescription)")
                }
            }
        }
        
        // Called when banner view width changes (e.g., orientation change)
        // Updates parent view width state for adaptive ad sizing
        func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat) {
            parent.viewWidth = width
        }
    }
    
    // MARK: - App Tracking Transparency
    // Request app tracking transparency permission
    // Must be called before ad preloading
    private static func requestAppTrackingTransparency(completion: @escaping () -> Void) {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            print("🔍 AdMob Debug: ATT already determined: \(ATTrackingManager.trackingAuthorizationStatus.rawValue)")
            // ATT already determined, proceed with ad loading immediately
            completion()
            return
        }
        
        // Request immediately
        // Small delay to ensure view is fully presented
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ATTrackingManager.requestTrackingAuthorization { status in
                print("🔍 AdMob Debug: App tracking transparency status: \(status.rawValue)")
                // Proceed with ad loading after ATT response
                completion()
            }
        }
    }
    
    // MARK: - Ad Preloading
    // Preload ads during splash screen to improve user experience
    // ATT is requested first, then ads are loaded after user response
    static func preloadAds() -> BannerView? {
        // Request ATT first, then load ads after user response
        requestAppTrackingTransparency {
            // This closure is called after ATT response (or immediately if already determined)
            loadAdAfterATT()
        }
        
        // Return banner view immediately (will be configured after ATT)
        // Get screen width for adaptive banner sizing
        let bannerWidth = screen.screenWidth
        
        // Create banner view for preloading
        let bannerView = BannerView()
        bannerView.adSize = inlineAdaptiveBanner(width: bannerWidth, maxHeight: screen.admobBannerHeight)
        
        // Get root view controller for banner view
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
            return bannerView
        } else {
            print("🔍 AdMob Debug: ⚠️ Failed to get root view controller for ad preloading")
            return nil
        }
    }
    
    // MARK: - Load Ad After ATT
    // Load ad after ATT permission is determined
    private static func loadAdAfterATT() {
        print("🔍 AdMob Debug: Starting ad preloading after ATT response...")
        
        // Get ad unit ID (same logic as AdMobBannerView)
        let adUnitID: String = {
            if let unitID = Bundle.main.infoDictionary?["ADMOB_BANNER_UNIT_ID"] as? String,
               !unitID.isEmpty && unitID != "$(ADMOB_BANNER_UNIT_ID)" {
                print("🔍 AdMob Debug: ✅ Using unit ID from Info.plist for preload: \(unitID)")
                return unitID
            }
            if let unitID = ProcessInfo.processInfo.environment["ADMOB_BANNER_UNIT_ID"],
               !unitID.isEmpty {
                print("🔍 AdMob Debug: ✅ Using unit ID from environment for preload: \(unitID)")
                return unitID
            }
            // Fallback to test unit ID
            print("🔍 AdMob Debug: ⚠️ Using fallback test unit ID for preload")
            return "ca-app-pub-3940256099942544/2435281174"  // iOS adaptive demo unit
        }()
        
        // Get root view controller and banner view
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("🔍 AdMob Debug: ⚠️ Failed to get root view controller for ad loading")
            return
        }
        
        // Find existing banner view or create new one
        let bannerWidth = screen.screenWidth
        let bannerView = BannerView()
        bannerView.adUnitID = adUnitID
        bannerView.adSize = inlineAdaptiveBanner(width: bannerWidth, maxHeight: screen.admobBannerHeight)
        bannerView.rootViewController = rootViewController
        
        // Load the ad
        let request = Request()
        bannerView.load(request)
        
        print("🔍 AdMob Debug: ✅ Ad preloading started after ATT response")
    }
}
