//
//  SizeExtensions.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2021/05/03.
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
    var operationButtonMargin: CGFloat { customWidth / 24 }
}

// MARK: - Route Layout Extensions
extension UIScreen {
    // Direction display sizing and responsive layout
    var routeSingleWidth: CGFloat { customWidth - 10 * routeSidePadding }
    var routeDoubleWidth: CGFloat { customWidth / 2 - 4 * routeSidePadding }
    var routeHeight: CGFloat { screenHeight - admobBannerHeight - headerHeight }
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
    var transferHeight: CGFloat { screenHeight * 0.036 }
    var lineNameHeight: CGFloat { screenHeight * 0.045 }
    var lineFontSize: CGFloat { customWidth / 27 }
    var lineImageForegroundSize: CGFloat { customWidth / 20 }
    var lineImageForegroundPadding: CGFloat { customWidth / 80 }
    var lineImageBackgroundSize: CGFloat { customWidth / 15 }
    var lineImageBackgroundPadding: CGFloat { customWidth / 200 }
    var lineImagePadding: CGFloat { customWidth / 300 }
    var timeFontSize: CGFloat { customWidth / 18 }
}

// MARK: - Login Extensions
// Login form layout and button styling
extension UIScreen {
    var loginTitleFontSize: CGFloat { customWidth * 0.06 }
    var loginButtonWidth: CGFloat { customWidth * 0.88 }
    var loginTextFieldFontSize: CGFloat { customWidth * 0.036 }
    var loginEyeIconSize: CGFloat { customWidth * 0.042 }

    var loginTitleTopMargin: CGFloat { screenHeight * 0.12 }
    var loginTitleBottomMargin: CGFloat { screenHeight * 0.02 }
    var loginTextHeight: CGFloat { screenHeight * 0.045 }
    var loginMargin: CGFloat { screenHeight * 0.03 }
}

// MARK: - Timetable Extensions
extension UIScreen {
    
    var timetableDisplayWidth:     CGFloat { customWidth * 0.90 }
    var timetableHourFontSize:     CGFloat { customWidth * 0.036 }
    var timetableMinuteFontSize:   CGFloat { customWidth * 0.032 }
    var timetableRideTimeFontSize: CGFloat { customWidth * 0.020 }
    var timetableMinuteSpacing:    CGFloat { customWidth * 0.008 }

    var timetableHorizontalSpacing: CGFloat { customWidth * 0.04 }
    var timetableWeekToggleSpacing: CGFloat { customWidth * 0.016 }

    var timetableHourFrameWidth:   CGFloat { customWidth * 0.1 }
    var timetableMinuteFrameWidth: CGFloat { customWidth - timetableHourFrameWidth - 1 }
    var timetableNumberWidth:      CGFloat { customWidth * 0.048 }
    var timetableTypeMenuWidth:    CGFloat { customWidth * 0.50 }
    var timetableEditButtonWidth:  CGFloat { customWidth * 0.44 }
    var timetablePickerWidth:      CGFloat { customWidth * 0.43 }
    var timetableTypeMenuOffsetX:  CGFloat { customWidth * 0.00 }

    var timetableNumberHeight:    CGFloat { screenHeight * 0.018 }
    var timetableGridHeight:      CGFloat { screenHeight * 0.024 }
    var timetableDisplayHeight:   CGFloat { screenHeight * 0.06 }
    var timetableEditTitleHeight: CGFloat { screenHeight * 0.06 }
    var timetableMaxHeight:       CGFloat { screenHeight * 0.64 }

    var timetableVerticalSpacing: CGFloat { screenHeight * 0.012 }
    var timetableTypeMenuPadding: CGFloat { screenHeight * 0.16 }
    var timetablePickerSpacing:   CGFloat { screenHeight * 0.02 }
    var timetableTypeMenuOffsetY: CGFloat { screenHeight * -0.04 }
    var timetablePickerTopPadding    : CGFloat { screenHeight * -0.036 }
    var timetablePickerBottomPadding : CGFloat { screenHeight * -0.012 }
    var timetableScrollViewMaxHeight : CGFloat { screenHeight * 0.6 }

        // Calculate content height for timetable grid based on train times count
    func calculateContentHeight(_ trainTimesCount: Int) -> CGFloat {
        let maxItemsPerRow = 10
        return trainTimesCount > maxItemsPerRow ?
            CGFloat((trainTimesCount + maxItemsPerRow - 1) / maxItemsPerRow) * timetableNumberHeight:
            timetableGridHeight 
    }    
}

// MARK: - Ad Banner Extensions
extension UIScreen {
    // AdMob banner sizing and responsive layout
    var admobBannerWidth: CGFloat { customWidth - 100 }
    var admobBannerMinWidth: CGFloat { 320 }
    var admobBannerHeight: CGFloat { ((screenHeight - headerHeight - 75) < 500) ? 50 : (screenHeight - headerHeight - 75) / 10 }
}

// MARK: - Settings Sheet Common Extensions
extension UIScreen {
    
    // Common horizontal parameters
    var settingsSheetHorizontalPadding: CGFloat { screenWidth * 0.06 }
    var settingsSheetHorizontalSpacing: CGFloat { screenWidth * 0.015 }
    
    // Common font sizes
    var settingsSheetTitleFontSize: CGFloat { customWidth * 0.040 }
    var settingsSheetHeadlineFontSize: CGFloat { customWidth * 0.032 }
    var settingsSheetInputFontSize: CGFloat { customWidth * 0.036 }
    var settingsSheetButtonFontSize: CGFloat { customWidth * 0.040 }
    
    // Common padding and sizing
    var settingsSheetInputPaddingHorizontal: CGFloat { customWidth * 0.04 }
    var settingsSheetStrokeLineWidth: CGFloat { customWidth * 0.002 }
    var settingsSheetIconSize: CGFloat { customWidth * 0.016 }
    var settingsSheetPickerSelectWidth: CGFloat { customWidth * 0.10 }
    var settingsSheetPickerSpacing: CGFloat { screenWidth * -0.030 }
    var settingsSheetIconSpacing: CGFloat { screenWidth * 0.02 }

    // Common vertical parameters
    var settingsSheetVerticalSpacing: CGFloat { screenHeight * 0.012 }
    var settingsSheetSaveButtonSpacing: CGFloat { screenHeight * 0.03 }
    var settingsSheetInputPaddingVertical: CGFloat { screenHeight * 0.008 }
    var settingsSheetCornerRadius: CGFloat { screenHeight * 0.01 }
    var settingsSheetPickerSelectHeight: CGFloat { screenHeight * 0.10 }
    var settingsSheetPickerDisplayHeight: CGFloat { screenHeight * 0.022 }

    // Common button parameters
    var settingsSheetButtonHeight: CGFloat { screenHeight * 0.044 }
    var settingsSheetButtonCornerRadius: CGFloat { screenHeight * 0.022 }
}

// MARK: - Settings Line Sheet Extensions
extension UIScreen {
    
    var settingsLineSheetPickerPadding: CGFloat { screenHeight * -0.032 }
    var settingsLineSheetShadowRadius: CGFloat { screenHeight * 0.006 }
    var settingsLineSheetTitleSpacing: CGFloat { screenHeight * 0.012 }
    var settingsLineSheetGridSpacing: CGFloat { screenHeight * 0.02 }
    var settingsLineSheetColorVerticalPadding: CGFloat { screenHeight * 0.008 }
    var settingsLineSheetSuggestionItemHeight: CGFloat { screenHeight * 0.056 }
    var settingsLineSheetMaxSuggestionHeight: CGFloat { screenHeight * 0.4 }
    var settingsLineSheetTagPaddingVertical: CGFloat { screenHeight * 0.003 }
    var settingsLineSheetLineOffset: CGFloat { screenHeight * 0.12 }
    var settingsLineSheetColorOffset: CGFloat { screenHeight * 0.19 }
    var settingsLineSheetDepartureOffset: CGFloat { screenHeight * 0.27 }
    var settingsLineSheetArrivalOffset: CGFloat { screenHeight * 0.32 }

    var settingsLineSheetCaptionFontSize: CGFloat { customWidth * 0.024 }
    var settingsLineSheetColorSettingWidth: CGFloat { customWidth * 0.80 }
    var settingsLineSheetColorHorizontalPadding: CGFloat { customWidth * 0.04 }
    var settingsLineSheetColorCircleSize: CGFloat { customWidth * 0.08 }
    var settingsLineSheetColorCircleSmallSize: CGFloat { customWidth * 0.04 }
    var settingsLineSheetTagPaddingHorizontal: CGFloat { customWidth * 0.006 }
}

// MARK: - Settings Transfer Sheet Extensions
extension UIScreen {
    var settingsTransferSheetPickerSpacing: CGFloat { screenHeight * 0.009 }
    var settingsTransferSheetRoute2Spacing: CGFloat { screenHeight * -0.02 }
    var settingsTransferSheetCheckmarkSpacing: CGFloat { screenHeight * 0.009 }
}

// MARK: - Settings Extensions
extension UIScreen {
    var settingsTitleFontSize: CGFloat { screenHeight * 0.022 }
    var settingsHeaderFontSize: CGFloat { screenHeight * 0.016 }
    var settingsFontSize: CGFloat { screenHeight * 0.018 }
}

// MARK: - Transportation Toggle Extensions
extension UIScreen {
    // Transportation toggle component sizing and responsive layout
    var customToggleSpacing: CGFloat { screenHeight * 0.013 }
    var customToggleCornerRadius: CGFloat { screenHeight * 0.026 }
    var customToggleWidth: CGFloat { screenHeight * 0.051 }
    var customToggleHeight: CGFloat { screenHeight * 0.029 }
    var customToggleCircleSize: CGFloat { screenHeight * 0.022 }
    var customToggleCircleOffset: CGFloat { screenHeight * 0.011 }
    var customTogglePaddingHorizontal: CGFloat { customWidth * 0.02 }
}

// MARK: - Bool Extension for Route Width
extension Bool {
    // Dynamic route width based on route visibility
    var routeWidth: CGFloat { self ? UIScreen.main.routeDoubleWidth : UIScreen.main.routeSingleWidth }
}
