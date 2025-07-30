//
//  AdMobView.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/04/06.
//

// MARK: - AdMob Banner View Implementation
// Google Mobile Ads banner view implementation (currently disabled)
//import SwiftUI
//import GoogleMobileAds
//
// MARK: - UIViewRepresentable for GADBannerView
// Wraps Google Mobile Ads banner view for SwiftUI integration
//struct AdView: UIViewRepresentable {
//
//    func makeUIView(context: Context) -> GADBannerView {
//        let adSize = GADAdSizeFromCGSize(CGSize(width: 320, height: 100))
//        let banner = GADBannerView(adSize: adSize)
//        banner.adUnitID = Config.adMobBannerUnitID
//        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
//        banner.load(GADRequest())
//        return banner
//    }
//
//    func updateUIView(_ uiView: GADBannerView, context: Context) {
//    }
//}
//
// MARK: - SwiftUI AdMob View
// SwiftUI wrapper for displaying Google Mobile Ads banner
//struct AdMobView: View {
//
//    let admobflag = true
//
//    var body: some View {
//        if (admobflag) {
//            AdView()
//                .frame(width: 320, height: 50)
//                .offset(y: -14)
//        }
//    }
//}
//
// MARK: - Preview Provider
// Provides preview for SwiftUI previews in Xcode
//struct AdMobView_Previews: PreviewProvider {
//    static var previews: some View {
//        AdMobView()
//            .background(Color.black)
//    }
//}
