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
let stationFontSize: CGFloat = customWidth / 27
let transferHeight: CGFloat = screenHeight * 0.036
let lineNameHeight: CGFloat = screenHeight * 0.045
let lineFontSize: CGFloat = customWidth / 27
let lineImageForegroundSize: CGFloat = customWidth / 20
let lineImageForegroundPadding: CGFloat = customWidth / 80
let lineImageBackgroundSize: CGFloat = customWidth / 15
let lineImageBackgroundPadding: CGFloat = customWidth / 200
let lineImagePadding: CGFloat = customWidth / 300
let timeFontSize: CGFloat = customWidth / 18

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

// MARK: - Settings Line Sheet
// Basic Layout
let settingsLineSheetPadding: CGFloat = screenWidth * 0.03
let settingsLineSheetTitlePadding: CGFloat = screenWidth * 0.02
let settingsLineSheetSpacing: CGFloat = screenHeight * 0.012
let settingsLineSheetIconSpacing: CGFloat = screenHeight * 0.005
let settingsLineSheetCornerRadius: CGFloat = screenHeight * 0.01
let settingsLineSheetButtonCornerRadius: CGFloat = screenHeight * 0.020
// Typography
let settingsLineSheetTitleFontSize: CGFloat = screenHeight * 0.020
let settingsLineSheetHeaderFontSize: CGFloat = screenHeight * 0.018
let settingsLineSheetInputFontSize: CGFloat = screenHeight * 0.018
let settingsLineSheetButtonFontSize: CGFloat = screenHeight * 0.018
let settingsLineSheetHeadlineFontSize: CGFloat = screenHeight * 0.016
let settingsLineSheetCaptionFontSize: CGFloat = screenHeight * 0.012
// Component Heights
let settingsLineSheetTextFieldHeight: CGFloat = screenHeight * 0.040
let settingsLineSheetButtonHeight: CGFloat = screenHeight * 0.044
let settingsLineSheetSuggestionItemHeight: CGFloat = screenHeight * 0.056
let settingsLineSheetMaxSuggestionHeight: CGFloat = screenHeight * 0.4
// Color Elements
let settingsLineSheetColorCircleSize: CGFloat = screenHeight * 0.03
let settingsLineSheetColorCircleSmallSize: CGFloat = screenHeight * 0.02
let settingsLineSheetColorPaddingHorizontal: CGFloat = screenWidth * 0.04
let settingsLineSheetColorPaddingVertical: CGFloat = screenHeight * 0.008
// Input Elements
let settingsLineSheetInputPaddingHorizontal: CGFloat = screenWidth * 0.04
let settingsLineSheetInputPaddingVertical: CGFloat = screenHeight * 0.008
// Tags and Icons
let settingsLineSheetTagPaddingHorizontal: CGFloat = screenHeight * 0.006
let settingsLineSheetTagPaddingVertical: CGFloat = screenHeight * 0.003
let settingsLineSheetIconSize: CGFloat = screenHeight * 0.016
// Grid and Spacing
let settingsLineSheetGridSpacing: CGFloat = screenHeight * 0.02
let settingsLineSheetHStackSpacing: CGFloat = screenHeight * 0.008
// Visual Effects
let settingsLineSheetShadowRadius: CGFloat = screenHeight * 0.006
let settingsLineSheetStrokeLineWidth: CGFloat = screenHeight * 0.001
// Sheet Offsets
let settingsLineSheetLineOffset: CGFloat = screenHeight * 0.12
let settingsLineSheetColorOffset: CGFloat = screenHeight * 0.19
let settingsLineSheetDepartureOffset: CGFloat = screenHeight * 0.27
let settingsLineSheetArrivalOffset: CGFloat = screenHeight * 0.32

// Settings
let settingsTitleFontSize: CGFloat = screenHeight * 0.024
let settingsHeaderFontSize: CGFloat = screenHeight * 0.016
let settingsFontSize: CGFloat = screenHeight * 0.018

// MARK: - Transportation Toggle Constants
// Transportation toggle component sizing and responsive layout
let transportationToggleSpacing: CGFloat = screenHeight * 0.013
let transportationToggleCornerRadius: CGFloat = screenHeight * 0.026
let transportationToggleWidth: CGFloat = screenHeight * 0.051
let transportationToggleHeight: CGFloat = screenHeight * 0.029
let transportationToggleCircleSize: CGFloat = screenHeight * 0.022
let transportationToggleCircleOffset: CGFloat = screenHeight * 0.011
let transportationTogglePaddingHorizontal: CGFloat = screenWidth * 0.02
