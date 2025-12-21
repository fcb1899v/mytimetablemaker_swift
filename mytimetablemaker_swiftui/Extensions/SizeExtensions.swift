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
    
    // MARK: - Basic Screen Properties
    var screenWidth: CGFloat { bounds.size.width }
    var screenHeight: CGFloat { bounds.size.height }
    var customWidth: CGFloat { bounds.size.width < 600 ? bounds.size.width : 600 }
    var statusBarHeight: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let window = windowScenes?.windows.first
        return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    
    // MARK: - Splash Screen
    var splashTitleFontSize: CGFloat { customWidth * 0.08 }
    var splashIconSize: CGFloat { customWidth * 0.3 }
    var splashLoadingFontSize: CGFloat { customWidth * 0.06 }
    var splashLoadingSpacing: CGFloat { screenHeight * 0.02 }

    // MARK: - Header & Navigation
    var headerTopMargin: CGFloat { statusBarHeight + 5 }
    var headerHeight: CGFloat { statusBarHeight + operationButtonWidth + 10 }
    var headerDateFontSize: CGFloat { customWidth / 20 }
    var headerDateHeight: CGFloat { customWidth / 30 }
    var headerDateMargin: CGFloat { customWidth / 6 }
    var headerSpace: CGFloat { customWidth / 60 }
    var headerSettingsButtonSize: CGFloat { customWidth / 16 }
    var operationButtonWidth: CGFloat { customWidth / 6 }
    var operationButtonHeight: CGFloat { customWidth / 12 }
    var operationButtonMargin: CGFloat { customWidth / 24 }
    
    // MARK: - Main Content Layout
    var routeSingleWidth: CGFloat { customWidth - 10 * routeSidePadding }
    var routeDoubleWidth: CGFloat { customWidth / 2 - 4 * routeSidePadding }
    var routeHeight: CGFloat { screenHeight - admobBannerHeight - headerHeight }
    var routeSidePadding: CGFloat { customWidth / 40 }
    var routeBottomSpace: CGFloat { routeHeight / 150 }
    var routeCountdownFontSize: CGFloat { customWidth / 12 }
    var routeCountdownTopSpace: CGFloat { (routeHeight > 600) ? ((routeHeight - 600) / 20 + 5) : 5 }
    var routeCountdownPadding: CGFloat { customWidth / 50 + ((routeHeight > 600) ? ((routeHeight - 600) / 10) : 0) }
    var stationFontSize: CGFloat { customWidth / 27 }
    var transferHeight: CGFloat { screenHeight * 0.036 }
    var lineNameHeight: CGFloat { screenHeight * 0.045 }
    var lineFontSize: CGFloat { customWidth / 27 }
    var lineImageForegroundSize: CGFloat { customWidth / 20 }
    var lineImageBackgroundSize: CGFloat { customWidth / 15 }
    var timeFontSize: CGFloat { customWidth / 18 }
    var admobBannerWidth: CGFloat { customWidth - 100 }
    var admobBannerMinWidth: CGFloat { 320 }
    var admobBannerHeight: CGFloat { ((screenHeight - headerHeight - 75) < 500) ? 50 : (screenHeight - headerHeight - 75) / 10 }
    
    // MARK: - Login
    var loginTitleFontSize: CGFloat { customWidth * 0.06 }
    var loginButtonWidth: CGFloat { customWidth * 0.88 }
    var loginTextFieldFontSize: CGFloat { customWidth * 0.036 }
    var loginEyeIconSize: CGFloat { customWidth * 0.042 }
    var loginTitleTopMargin: CGFloat { screenHeight * 0.12 }
    var loginTitleBottomMargin: CGFloat { screenHeight * 0.02 }
    var loginTextHeight: CGFloat { screenHeight * 0.045 }
    var loginMargin: CGFloat { screenHeight * 0.03 }
    
    // MARK: - Timetable
    var timetableDisplayWidth:     CGFloat { customWidth * 0.90 }
    var timetableHourFontSize:     CGFloat { customWidth * 0.036 }
    var timetableMinuteFontSize:   CGFloat { customWidth * 0.032 }
    var timetableRideTimeFontSize: CGFloat { customWidth * 0.020 }
    var timetableMinuteSpacing:    CGFloat { customWidth * 0.008 }
    var timetableHorizontalSpacing: CGFloat { customWidth * 0.04 }
    var timetableHourFrameWidth:   CGFloat { customWidth * 0.1 }
    var timetableMinuteFrameWidth: CGFloat { customWidth - timetableHourFrameWidth - 1 }
    var timetableTypeMenuWidth:    CGFloat { customWidth * 0.50 }
    var timetableEditButtonWidth:  CGFloat { customWidth * 0.44 }
    var timetablePickerWidth:      CGFloat { customWidth * 0.43 }
    var timetableTypeMenuOffsetX:  CGFloat { customWidth * 0.00 }
    var timetableNumberHeight:    CGFloat { screenHeight * 0.018 }
    var timetableGridHeight:      CGFloat { screenHeight * 0.024 }
    var timetableDisplayHeight:   CGFloat { screenHeight * 0.06 }
    var timetableMaxHeight:       CGFloat { screenHeight * 0.64 }
    var timetableVerticalSpacing: CGFloat { screenHeight * 0.012 }
    var timetableTypeMenuOffsetY: CGFloat { screenHeight * -0.045 }
    var timetableCopyMenuOffsetY: CGFloat { screenHeight * 0.13 }
    var timetableCalendarMenuOffsetY: CGFloat { screenHeight * -0.34 }
    var timetableContentViewMenuOffsetY: CGFloat { screenHeight * 0.10 }
    var timetablePickerTopPadding:    CGFloat { screenHeight * -0.036 }
    var timetablePickerBottomPadding: CGFloat { screenHeight * -0.012 }
    var settingsTimetableSheetHeight: CGFloat { screenHeight * 0.6 }
    
    func calculateContentHeight(_ trainTimesCount: Int) -> CGFloat {
        let maxItemsPerRow = 10
        return trainTimesCount > maxItemsPerRow ?
            CGFloat((trainTimesCount + maxItemsPerRow - 1) / maxItemsPerRow) * timetableNumberHeight:
            timetableGridHeight 
    }
    
    // MARK: - Settings
    var settingsTitleFontSize: CGFloat { screenHeight * 0.022 }
    var settingsHeaderFontSize: CGFloat { screenHeight * 0.016 }
    var settingsFontSize: CGFloat { screenHeight * 0.018 }
    
    // MARK: - Settings Sheet Common
    var settingsSheetHorizontalPadding: CGFloat { customWidth * 0.06 }
    var settingsSheetHorizontalSpacing: CGFloat { customWidth * 0.015 }
    var settingsSheetTitleFontSize: CGFloat { customWidth * 0.040 }
    var settingsSheetHeadlineFontSize: CGFloat { customWidth * 0.032 }
    var settingsSheetInputFontSize: CGFloat { customWidth * 0.036 }
    var settingsSheetButtonFontSize: CGFloat { customWidth * 0.040 }
    var settingsSheetInputPaddingHorizontal: CGFloat { customWidth * 0.04 }
    var settingsSheetStrokeLineWidth: CGFloat { customWidth * 0.002 }
    var settingsSheetIconSize: CGFloat { customWidth * 0.016 }
    var settingsSheetPickerSelectWidth: CGFloat { customWidth * 0.10 }
    var settingsSheetPickerSpacing: CGFloat { customWidth * -0.030 }
    var settingsSheetIconSpacing: CGFloat { customWidth * 0.02 }
    var settingsSheetVerticalSpacing: CGFloat { screenHeight * 0.012 }
    var settingsSheetInputPaddingVertical: CGFloat { screenHeight * 0.008 }
    var settingsSheetCornerRadius: CGFloat { screenHeight * 0.016 }
    var settingsSheetPickerSelectHeight: CGFloat { screenHeight * 0.10 }
    var settingsSheetPickerDisplayHeight: CGFloat { screenHeight * 0.022 }
    var settingsSheetButtonHeight: CGFloat { screenHeight * 0.044 }
    var settingsSheetButtonCornerRadius: CGFloat { screenHeight * 0.022 }
    
    // MARK: - Settings Line Sheet
    var settingsLineSheetPickerPadding: CGFloat { screenHeight * -0.032 }
    var settingsLineSheetShadowRadius: CGFloat { screenHeight * 0.006 }
    var settingsLineSheetGridSpacing: CGFloat { screenHeight * 0.02 }
    var settingsLineSheetColorVerticalPadding: CGFloat { screenHeight * 0.008 }
    var settingsLineSheetSuggestionItemHeight: CGFloat { screenHeight * 0.046 }
    var settingsLineSheetMaxSuggestionHeight: CGFloat { screenHeight * 0.280 }
    var settingsLineSheetStopMaxSuggestionHeight: CGFloat { screenHeight * 0.234 }
    var settingsLineSheetTagPaddingVertical: CGFloat { screenHeight * 0.003 }
    var settingsLineSheetSuggestionSpacing: CGFloat { screenHeight * 0.002 }
    var settingsLineSheetSuggestionPaddingVertical: CGFloat { screenHeight * 0.004 }
    var settingsLineSheetOperatorOffset: CGFloat { screenHeight * 0.13 }
    var settingsLineSheetLineOffset: CGFloat { screenHeight * 0.18 }
    var settingsLineSheetColorOffset: CGFloat { screenHeight * 0.25 }
    var settingsLineSheetDepartureOffset: CGFloat { screenHeight * 0.32 }
    var settingsLineSheetArrivalOffset: CGFloat { screenHeight * 0.37 }
    var settingsLineSheetCaptionFontSize: CGFloat { customWidth * 0.024 }
    var settingsLineSheetColorSettingWidth: CGFloat { customWidth * 0.80 }
    var settingsLineSheetColorHorizontalPadding: CGFloat { customWidth * 0.04 }
    var settingsLineSheetColorCircleSize: CGFloat { customWidth * 0.08 }
    var settingsLineSheetColorCircleSmallSize: CGFloat { customWidth * 0.04 }
    var settingsLineSheetTagPaddingHorizontal: CGFloat { customWidth * 0.006 }
    
    // MARK: - Settings Transfer Sheet
    var settingsTransferSheetVerticalSpacing: CGFloat { screenHeight * 0.02 }
    var settingsTransferSheetCheckmarkSpacing: CGFloat { screenHeight * 0.009 }
    var settingsTransferSheetPickerWidth: CGFloat { customWidth * 0.28 }
    var settingsTransferSheetPaddingLeft: CGFloat { customWidth * 0.03 }
    
    // MARK: - Components
    var customToggleSpacing: CGFloat { screenHeight * 0.006 }
    var customToggleCornerRadius: CGFloat { screenHeight * 0.026 }
    var customToggleWidth: CGFloat { screenHeight * 0.051 }
    var customToggleHeight: CGFloat { screenHeight * 0.029 }
    var customToggleCircleSize: CGFloat { screenHeight * 0.022 }
    var customToggleCircleOffset: CGFloat { screenHeight * 0.011 }
    var customTogglePaddingHorizontal: CGFloat { customWidth * 0.02 }
}

// MARK: - Bool Extension for Route Width
extension Bool {
    var routeWidth: CGFloat { self ? UIScreen.main.routeDoubleWidth : UIScreen.main.routeSingleWidth }
}
