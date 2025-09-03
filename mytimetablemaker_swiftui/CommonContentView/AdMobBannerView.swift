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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // Tell the delegate the initial ad width.
    let width = view.frame.inset(by: view.safeAreaInsets).size.width
    delegate?.bannerViewController(self, didUpdate: width)
    
    // Load ad after view appears with a slight delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      if let bannerView = self.view.subviews.first(where: { $0 is GADBannerView }) as? GADBannerView {
        bannerView.load(GADRequest())
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
    private let bannerView = GADBannerView()
    
    // MARK: - Ad Unit ID Configuration
    // Reads AdMob unit ID from xcconfig file environment variable
    private var adUnitID: String {
        // Method 1: Try to get from Info.plist (set by xcconfig)
        if let unitID = Bundle.main.infoDictionary?["ADMOB_BANNER_UNIT_ID"] as? String {
            return unitID
        } else {
            print("🔍 AdMob Debug: ❌ Failed to get unit ID from Info.plist")
        }
        
        // Method 2: Try to get from environment variable directly
        if let unitID = ProcessInfo.processInfo.environment["ADMOB_BANNER_UNIT_ID"] {
            return unitID
        } else {
            print("🔍 AdMob Debug: ❌ Failed to get unit ID from environment")
        }
        
        // No fallback - configuration must be properly set
        fatalError("ADMOB_BANNER_UNIT_ID not found in configuration. Please check Debug.xcconfig and Release.xcconfig files.")
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        
        // Log the ad unit ID before setting it
        let bannerViewController = BannerViewController()
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = bannerViewController
        
        // Log the ad unit ID after setting it
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
        
        // Set the width delegate
        bannerViewController.delegate = context.coordinator
        
        return bannerViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard viewWidth != .zero else {
            return 
        }
        
        // Set ad size based on view width
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        // Load the ad
        bannerView.load(GADRequest())
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
            print("🔍 AdMob Debug: Ad failed to load with error: \(error.localizedDescription)")
            print("🔍 AdMob Debug: Error domain: \((error as NSError).domain)")
            print("🔍 AdMob Debug: Error code: \((error as NSError).code)")
            print("🔍 AdMob Debug: Error user info: \((error as NSError).userInfo)")
            
            // Check if it's a network error
            if let nsError = error as NSError? {
                switch nsError.code {
                case 0:
                    print("🔍 AdMob Debug: Network error - check internet connection")
                case 1:
                    print("🔍 AdMob Debug: Invalid request - check ad unit ID")
                case 2:
                    print("🔍 AdMob Debug: No fill - no ads available")
                case 3:
                    print("🔍 AdMob Debug: Network error")
                case 4:
                    print("🔍 AdMob Debug: Internal error")
                case 5:
                    print("🔍 AdMob Debug: Invalid argument")
                case 6:
                    print("🔍 AdMob Debug: Received invalid response")
                case 7:
                    print("🔍 AdMob Debug: Load in progress")
                case 8:
                    print("🔍 AdMob Debug: Ad already used")
                case 9:
                    print("🔍 AdMob Debug: Application not found")
                case 10:
                    print("🔍 AdMob Debug: Ad unit not found")
                default:
                    print("🔍 AdMob Debug: Unknown error code: \(nsError.code)")
                }
            }
        }
        
        func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat) {
            parent.viewWidth = width
        }
    }
}
