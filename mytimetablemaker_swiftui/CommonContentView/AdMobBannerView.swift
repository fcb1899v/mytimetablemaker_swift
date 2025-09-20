//
//  AdMobBannerView.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2023/10/01.
//

import Foundation
import SwiftUI
import GoogleMobileAds

// MARK: - Banner Width Delegate Protocol
// Delegate methods for receiving width update messages from banner view controller
protocol BannerViewControllerWidthDelegate: AnyObject {
  func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat)
}

// MARK: - Banner View Controller
// Manages banner view lifecycle and width updates for adaptive banner ads
class BannerViewController: UIViewController {
    
  weak var delegate: BannerViewControllerWidthDelegate?
  private var lastLoadTime: Date = Date.distantPast
  private let minimumLoadInterval: TimeInterval = 60.0
  var isAdMobEnabled: Bool = false

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // Tell the delegate the initial ad width.
    let width = view.frame.inset(by: view.safeAreaInsets).size.width
    delegate?.bannerViewController(self, didUpdate: width)
    
    // Only load ads if AdMob is enabled
    guard isAdMobEnabled else { return }
    
    // Load ad after view appears with a slight delay (only if enough time has passed)
    let currentTime = Date()
    if currentTime.timeIntervalSince(lastLoadTime) >= minimumLoadInterval {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        if let bannerView = self.view.subviews.first(where: { $0 is GADBannerView }) as? GADBannerView,
           bannerView.adUnitID != nil && !bannerView.adUnitID!.isEmpty {
          let request = GADRequest()
          bannerView.load(request)
          self.lastLoadTime = currentTime
        }
      }
    }
  }

  override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    coordinator.animate { _ in
      // do nothing
    } completion: { _ in
      // Notify the delegate of ad width changes.
      let width = self.view.frame.inset(by: self.view.safeAreaInsets).size.width
      self.delegate?.bannerViewController(self, didUpdate: width)
    }
  }
}

// MARK: - SwiftUI AdMob Banner View
// SwiftUI wrapper for Google Mobile Ads banner view
struct AdMobBannerView: UIViewControllerRepresentable {

    @State private var viewWidth: CGFloat = .zero
    @State private var lastLoadTime: Date = Date.distantPast
    private let bannerView = GADBannerView()
    private let minimumLoadInterval: TimeInterval = 60.0 // Minimum 60 seconds between loads
    private let isAdMobEnabled: Bool = true // Enable AdMob for ads
    
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
        return "ca-app-pub-3940256099942544/6300978111"
    }
    
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
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        // Load the ad with error handling
        let request = GADRequest()
        bannerView.load(request)
        lastLoadTime = currentTime
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, GADBannerViewDelegate, BannerViewControllerWidthDelegate {
        var parent: AdMobBannerView
        
        init(_ parent: AdMobBannerView) {
            self.parent = parent
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            // Only log critical errors, suppress common test environment errors
            if let nsError = error as NSError? {
                switch nsError.code {
                case 1: // Invalid request
                    // Suppress this common error in test environment
                    return
                case 2: // No fill
                    // Suppress this common error in test environment
                    return
                default:
                    print("🔍 AdMob Debug: Ad failed to load with error: \(error.localizedDescription)")
                }
            }
        }
        
        func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat) {
            parent.viewWidth = width
        }
    }
}
