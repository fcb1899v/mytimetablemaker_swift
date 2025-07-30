//
//  Size.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/05/03.
//

import Foundation
import SwiftUI

// MARK: - Screen Size Constants
// Screen dimensions and responsive sizing calculations
let screenSize: CGSize = UIScreen.main.bounds.size
let screenWidth: CGFloat = screenSize.width
let customWidth: CGFloat = (screenWidth < 600) ? screenWidth: 600
let halfScreenWidth: CGFloat = screenWidth / 2
let screenHeight: CGFloat = screenSize.height

// MARK: - Status Bar Height
// Dynamic status bar height calculation for different devices
var statusBarHeight: CGFloat {
    let scenes = UIApplication.shared.connectedScenes
    let windowScenes = scenes.first as? UIWindowScene
    let window = windowScenes?.windows.first
    return  window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
}

// MARK: - Splash Screen Constants
// Splash screen sizing and typography
let splashTitleFontSize: CGFloat = customWidth / 12
let splashIconSize: CGFloat = customWidth / 3

// MARK: - Main Content View Constants

// MARK: - Header Date Styling
// Header layout and date display sizing
let headerTopMargin: CGFloat = statusBarHeight + 5
let headerHeight: CGFloat = statusBarHeight + operationButtonWidth + 10
let headerDateFontSize: CGFloat = customWidth / 20
let headerDateHeight: CGFloat = customWidth / 30
let headerSpace: CGFloat = customWidth / 60

// MARK: - Header Operation Button
// Operation button styling and layout
let operationButtonWidth: CGFloat = customWidth / 6
let operationButtonHeight: CGFloat = customWidth / 12
let operationButtonCornerRadius: CGFloat = customWidth / 28
let operationButtonMargin: CGFloat = customWidth / 24
let operationButtonFontSize: CGFloat = customWidth / 24
let operationSettingsBottonSize: CGFloat = customWidth / 20

// MARK: - Route Layout Constants
// Route display sizing and responsive layout
let routeSingleWidth: CGFloat = customWidth - 10 * routeSidePadding
let routeDoubleWidth: CGFloat = customWidth / 2 - 4 * routeSidePadding
extension Bool {
    // Dynamic route width based on route visibility
    var routeWidth: CGFloat {
        return self ? routeDoubleWidth: routeSingleWidth
    }
}
let routeHeight: CGFloat = screenHeight - admobBannerHeight - headerHeight
let routeSidePadding: CGFloat = customWidth / 40
let routeBottomSpace: CGFloat = routeHeight / 150

// MARK: - Route Countdown Styling
// Countdown timer display sizing and positioning
let routeCountdownFontSize: CGFloat = customWidth / 12
let routeCountdownTopSpace: CGFloat = (routeHeight > 600) ? ((routeHeight - 600) / 20 + 5): 5
let routeCountdownPadding: CGFloat = customWidth / 50 + ((routeHeight > 600) ? ((routeHeight - 600) / 10): 0)

// MARK: - Route Content Styling
// Route information display sizing and typography
let routeStationFontSize: CGFloat = customWidth / 27
let routeLineFontSize: CGFloat = customWidth / 27
let routeTimeFontSize: CGFloat = customWidth / 18
let routeLineImageForegroundSize: CGFloat = customWidth / 25
let routeLineImageForegroundLeftPadding: CGFloat = customWidth / 30
let routeLineImageBackgroundWidth: CGFloat = customWidth / 20
let routeLineImageBackgroundHeight: CGFloat = customWidth / 15
let routeLineImageBackgroundPadding: CGFloat = customWidth / 200
let routeLineImageLeftPadding: CGFloat = customWidth / 200

// MARK: - Login Content View Constants

// MARK: - Login Form Styling
// Login form layout and button styling
let loginTitleFontSize: CGFloat = customWidth / 15
let loginTitleTopMargin: CGFloat = statusBarHeight + 20 + routeHeight / 10
let loginTitleBottomMargin: CGFloat = routeHeight / 40
let loginButtonWidth: CGFloat = customWidth * 0.8
let loginButtonHeight: CGFloat = 40.0
let loginButtonCornerRadius: CGFloat = 20.0
let loginTextHeight: CGFloat = 40.0
let loginTextCornerRadius: CGFloat = 5.0
let loginMargin: CGFloat = customWidth / 30

// MARK: - Timetable Content View Constants
// Timetable view button sizing
let timetableButtonWidth: CGFloat = operationButtonWidth * 1.5
let ImagePickerButtonWidth: CGFloat = customWidth * 0.8

// MARK: - Ad Banner Constants
// AdMob banner sizing and responsive layout
let admobBannerWidth: CGFloat = screenWidth - 100
let admobBannerMinWidth: CGFloat = 320
let admobBannerHeight: CGFloat = ((screenHeight - headerHeight - 75) < 500) ? 50: (screenHeight - headerHeight - 75) / 10
