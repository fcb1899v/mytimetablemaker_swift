//
//  Size.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/05/03.
//

import Foundation
import SwiftUI

//Screen Size
let screenSize: CGSize = UIScreen.main.bounds.size
let screenWidth: CGFloat = screenSize.width
let customWidth: CGFloat = (screenWidth < 600) ? screenWidth: 600
let halfScreenWidth: CGFloat = screenWidth / 2
let screenHeight: CGFloat = screenSize.height

//Status bar height
var statusBarHeight: CGFloat {
    let scenes = UIApplication.shared.connectedScenes
    let windowScenes = scenes.first as? UIWindowScene
    let window = windowScenes?.windows.first
    return  window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
}

// LoginContentView

//Login
let loginButtonWidth: CGFloat = customWidth * 0.8
let loginButtonHeight: CGFloat = 40.0
let loginButtonCornerRadius: CGFloat = 20.0
let loginTextHeight: CGFloat = 40.0
let loginTextCornerRadius: CGFloat = 5.0

//MainContentView

//Header Date
let headerTopMargin: CGFloat = statusBarHeight + 5
let headerHeight: CGFloat = statusBarHeight + operationButtonWidth + 5
let headerDateFontSize: CGFloat = customWidth / 20
let headerDateHeight: CGFloat = customWidth / 30
let headerSpace: CGFloat = customWidth / 60

//Header Operation Button
let operationButtonWidth: CGFloat = customWidth / 6
let operationButtonHeight: CGFloat = customWidth / 12
let operationButtonCornerRadius: CGFloat = customWidth / 24
let operationButtonSidePadding: CGFloat = customWidth / 24
let operationButtonMargin: CGFloat = customWidth / 24
let operationButtonFontSize: CGFloat = customWidth / 24
let operationSettingsBottonSize: CGFloat = customWidth / 20

//Route Size
let routeSingleWidth: CGFloat = customWidth - 10 * routeSidePadding
let routeDoubleWidth: CGFloat = customWidth / 2 - 4 * routeSidePadding
extension Bool {
    //isShowRoute2
    var routeWidth: CGFloat {
        return self ? routeDoubleWidth: routeSingleWidth
    }
}
let routeHeight: CGFloat = screenHeight - admobBannerHeight - headerHeight
let routeSidePadding: CGFloat = customWidth / 40
let routeBottomSpace: CGFloat = routeHeight / 180

//Route Countdown
let routeCountdownFontSize: CGFloat = customWidth / 12
let routeCountdownAdditionalPadding: CGFloat = (routeHeight > 600) ? ((routeHeight - 600) / 10): 0
let routeCountdownTopSpace: CGFloat = (routeHeight > 600) ? ((routeHeight - 600) / 20 + 5): 5
let routeCountdownPadding: CGFloat = customWidth / 50 + routeCountdownAdditionalPadding

//Route
let routeStationFontSize: CGFloat = customWidth / 27
let routeLineFontSize: CGFloat = customWidth / 27
let routeTimeFontSize: CGFloat = customWidth / 18
let routeLineImageForegroundSize: CGFloat = customWidth / 25
let routeLineImageForegroundLeftPadding: CGFloat = customWidth / 30
let routeLineImageBackgroundWidth: CGFloat = customWidth / 20
let routeLineImageBackgroundHeight: CGFloat = customWidth / 15
let routeLineImageBackgroundPadding: CGFloat = customWidth / 200
let routeLineImageLeftPadding: CGFloat = customWidth / 200


//TimetabelContentView

//Week button
let timetableWeekButtonWidth: CGFloat = 100
let timetableWeekButtonHeight: CGFloat = 35.0
let timetableWeekButtonCornerRadius: CGFloat = 17.5
//Image Picker button
let ImagePickerButtonWidth: CGFloat = customWidth * 0.8
let ImagePickerButtonHeight: CGFloat = 40.0
let ImagePickerCornerRadius: CGFloat = 20.0


let admobBannerWidth: CGFloat = screenWidth - 100
let admobBannerMinWidth: CGFloat = 320
let admobBannerHeight: CGFloat = 50

