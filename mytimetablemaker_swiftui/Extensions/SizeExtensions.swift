//
//  SizeExtensions.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/05/03.
//

import Foundation
import SwiftUI

let screen = UIScreen.main


// MARK: - UIScreen Extensions
// Screen dimensions and responsive sizing calculations
extension UIScreen {
    // Screen size properties
    var screenWidth: CGFloat { bounds.size.width }
    var screenHeight: CGFloat { bounds.size.height }
    var customWidth: CGFloat { bounds.size.width < 600 ? bounds.size.width : 600 }
    var halfScreenWidth: CGFloat { bounds.size.width / 2 }
    
    // Dynamic status bar height calculation for different devices
    var statusBarHeight: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let window = windowScenes?.windows.first
        return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
}

// MARK: - Splash Screen Extensions
extension UIScreen {
    // Splash screen sizing and typography
    var splashTitleFontSize: CGFloat { customWidth / 12 }
    var splashIconSize: CGFloat { customWidth / 3 }
}

// MARK: - Header Extensions
extension UIScreen {
    // Header layout and date display sizing
    var headerTopMargin: CGFloat { statusBarHeight + 5 }
    var headerHeight: CGFloat { statusBarHeight + operationButtonWidth + 10 }
    var headerDateFontSize: CGFloat { customWidth / 20 }
    var headerDateHeight: CGFloat { customWidth / 30 }
    var headerDateMargin: CGFloat { customWidth / 6 }
    var headerSpace: CGFloat { customWidth / 60 }
    var headerSettingsButtonSize: CGFloat { customWidth / 16 }
}

// MARK: - Operation Button Extensions
extension UIScreen {
    // Operation button styling and layout
    var operationButtonWidth: CGFloat { customWidth / 6 }
    var operationButtonHeight: CGFloat { customWidth / 12 }
    var operationButtonCornerRadius: CGFloat { customWidth / 28 }
    var operationButtonMargin: CGFloat { customWidth / 24 }
    var operationButtonFontSize: CGFloat { customWidth / 24 }
}

// MARK: - Route Layout Extensions
extension UIScreen {
    // Direction display sizing and responsive layout
    var routeSingleWidth: CGFloat { customWidth - 10 * routeSidePadding }
    var routeDoubleWidth: CGFloat { customWidth / 2 - 4 * routeSidePadding }
    var routeHeight: CGFloat { bounds.size.height - admobBannerHeight - headerHeight }
    var routeSidePadding: CGFloat { customWidth / 40 }
    var routeBottomSpace: CGFloat { routeHeight / 150 }
}

// MARK: - Route Countdown Extensions
extension UIScreen {
    // Countdown timer display sizing and positioning
    var routeCountdownFontSize: CGFloat { customWidth / 12 }
    var routeCountdownTopSpace: CGFloat { (routeHeight > 600) ? ((routeHeight - 600) / 20 + 5) : 5 }
    var routeCountdownPadding: CGFloat { customWidth / 50 + ((routeHeight > 600) ? ((routeHeight - 600) / 10) : 0) }
}

// MARK: - Route Content Extensions
extension UIScreen {
    // Direction information display sizing and typography
    var stationFontSize: CGFloat { customWidth / 27 }
    var transferHeight: CGFloat { bounds.size.height * 0.036 }
    var lineNameHeight: CGFloat { bounds.size.height * 0.045 }
    var lineFontSize: CGFloat { customWidth / 27 }
    var lineImageForegroundSize: CGFloat { customWidth / 20 }
    var lineImageForegroundPadding: CGFloat { customWidth / 80 }
    var lineImageBackgroundSize: CGFloat { customWidth / 15 }
    var lineImageBackgroundPadding: CGFloat { customWidth / 200 }
    var lineImagePadding: CGFloat { customWidth / 300 }
    var timeFontSize: CGFloat { customWidth / 18 }
}

// MARK: - Login Extensions
extension UIScreen {
    // Login form layout and button styling
    var loginTitleFontSize: CGFloat { customWidth / 15 }
    var loginTitleTopMargin: CGFloat { statusBarHeight + 20 + routeHeight / 10 }
    var loginTitleBottomMargin: CGFloat { routeHeight / 40 }
    var loginButtonWidth: CGFloat { customWidth * 0.8 }
    var loginButtonHeight: CGFloat { 40.0 }
    var loginButtonCornerRadius: CGFloat { 20.0 }
    var loginTextHeight: CGFloat { 40.0 }
    var loginTextCornerRadius: CGFloat { 5.0 }
    var loginMargin: CGFloat { customWidth / 30 }
}

// MARK: - Timetable Extensions
extension UIScreen {
    
    // Timetable responsive sizing based on screen height
    var timetableTitleFontSize:  CGFloat { customWidth * 0.05 }
    var timetableHeaderFontSize: CGFloat { customWidth * 0.04 }
    var timetableButtonFontSize: CGFloat { customWidth * 0.04 }
    var timetableButtonWidth:    CGFloat { customWidth * 0.20 }
    var timetableButtonHeight:   CGFloat { customWidth * 0.08 }
    var timetableGridHeight:     CGFloat { customWidth * 0.06 }
    var timetableHourFrameWidth: CGFloat { customWidth * 0.06 }
    var timetableTimeFontSize:   CGFloat { customWidth * 0.04 }
    var timetablePadding:        CGFloat { customWidth * 0.03 }
    var timetableSpacing:        CGFloat { customWidth * 0.01 }
}

// MARK: - Ad Banner Extensions
extension UIScreen {
    // AdMob banner sizing and responsive layout
    var admobBannerWidth: CGFloat { bounds.size.width - 100 }
    var admobBannerMinWidth: CGFloat { 320 }
    var admobBannerHeight: CGFloat { ((bounds.size.height - headerHeight - 75) < 500) ? 50 : (bounds.size.height - headerHeight - 75) / 10 }
}

// MARK: - Settings Line Sheet Extensions
extension UIScreen {
    // Basic Layout
    var settingsLineSheetPadding: CGFloat { bounds.size.width * 0.03 }
    var settingsLineSheetSpacing: CGFloat { bounds.size.height * 0.012 }
    var settingsLineSheetIconSpacing: CGFloat { bounds.size.height * 0.005 }
    var settingsLineSheetCornerRadius: CGFloat { bounds.size.height * 0.01 }
    var settingsLineSheetButtonCornerRadius: CGFloat { bounds.size.height * 0.020 }
    
    // Typography
    var settingsLineSheetTitleFontSize: CGFloat { bounds.size.height * 0.020 }
    var settingsLineSheetHeaderFontSize: CGFloat { bounds.size.height * 0.018 }
    var settingsLineSheetInputFontSize: CGFloat { bounds.size.height * 0.018 }
    var settingsLineSheetButtonFontSize: CGFloat { bounds.size.height * 0.018 }
    var settingsLineSheetHeadlineFontSize: CGFloat { bounds.size.height * 0.016 }
    var settingsLineSheetCaptionFontSize: CGFloat { bounds.size.height * 0.012 }
    
    // Component Heights
    var settingsLineSheetButtonHeight: CGFloat { bounds.size.height * 0.044 }
    var settingsLineSheetSuggestionItemHeight: CGFloat { bounds.size.height * 0.056 }
    var settingsLineSheetMaxSuggestionHeight: CGFloat { bounds.size.height * 0.4 }
    
    // Color Elements
    var settingsLineSheetColorCircleSize: CGFloat { bounds.size.height * 0.03 }
    var settingsLineSheetColorCircleSmallSize: CGFloat { bounds.size.height * 0.02 }
    var settingsLineSheetColorPaddingHorizontal: CGFloat { bounds.size.width * 0.04 }
    var settingsLineSheetColorPaddingVertical: CGFloat { bounds.size.height * 0.008 }
    
    // Input Elements
    var settingsLineSheetInputPaddingHorizontal: CGFloat { bounds.size.width * 0.04 }
    var settingsLineSheetInputPaddingVertical: CGFloat { bounds.size.height * 0.008 }
    
    // Tags and Icons
    var settingsLineSheetTagPaddingHorizontal: CGFloat { bounds.size.height * 0.006 }
    var settingsLineSheetTagPaddingVertical: CGFloat { bounds.size.height * 0.003 }
    var settingsLineSheetIconSize: CGFloat { bounds.size.height * 0.016 }
    
    // Grid and Spacing
    var settingsLineSheetGridSpacing: CGFloat { bounds.size.height * 0.02 }
    var settingsLineSheetHStackSpacing: CGFloat { bounds.size.height * 0.008 }
    
    // Visual Effects
    var settingsLineSheetShadowRadius: CGFloat { bounds.size.height * 0.006 }
    var settingsLineSheetStrokeLineWidth: CGFloat { bounds.size.height * 0.001 }
    
    // Sheet Offsets
    var settingsLineSheetLineOffset: CGFloat { bounds.size.height * 0.12 }
    var settingsLineSheetColorOffset: CGFloat { bounds.size.height * 0.19 }
    var settingsLineSheetDepartureOffset: CGFloat { bounds.size.height * 0.27 }
    var settingsLineSheetArrivalOffset: CGFloat { bounds.size.height * 0.32 }
}

// MARK: - Settings Extensions
extension UIScreen {
    var settingsTitleFontSize: CGFloat { bounds.size.height * 0.024 }
    var settingsHeaderFontSize: CGFloat { bounds.size.height * 0.016 }
    var settingsFontSize: CGFloat { bounds.size.height * 0.018 }
}

// MARK: - Transportation Toggle Extensions
extension UIScreen {
    // Transportation toggle component sizing and responsive layout
    var transportationToggleSpacing: CGFloat { bounds.size.height * 0.013 }
    var transportationToggleCornerRadius: CGFloat { bounds.size.height * 0.026 }
    var transportationToggleWidth: CGFloat { bounds.size.height * 0.051 }
    var transportationToggleHeight: CGFloat { bounds.size.height * 0.029 }
    var transportationToggleCircleSize: CGFloat { bounds.size.height * 0.022 }
    var transportationToggleCircleOffset: CGFloat { bounds.size.height * 0.011 }
    var transportationTogglePaddingHorizontal: CGFloat { bounds.size.width * 0.02 }
}

// MARK: - Bool Extension for Route Width
extension Bool {
    // Dynamic route width based on route visibility
    var routeWidth: CGFloat { self ? UIScreen.main.routeDoubleWidth : UIScreen.main.routeSingleWidth }
}
