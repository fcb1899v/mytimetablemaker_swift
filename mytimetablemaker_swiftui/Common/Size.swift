//
//  Size.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/05/03.
//

import Foundation
import SwiftUI

//画面サイズを取得
extension UIScreen{
    /// 画面のサイズ
    static let screenSize = UIScreen.main.bounds.size
    /// 画面の幅
    static let screenWidth = UIScreen.main.bounds.size.width
    /// 画面の高さ
    static let screenHeight = UIScreen.main.bounds.size.height
}


/// サイズ定義
extension CGFloat {
    /// 画面の幅
    static let screenwidth: CGFloat = CGFloat(UIScreen.screenWidth)
    /// 画面の高さ
    static let screenheight: CGFloat = CGFloat(UIScreen.screenHeight)
    /// 画面の半幅
    static let halfscreenwidth: CGFloat = CGFloat(UIScreen.screenWidth)
    /// ログイン画面の各種ボタン・テキストフィールドの幅
    static let loginbuttonwidth: CGFloat = CGFloat(UIScreen.screenWidth * 0.8)
    /// メイン画面の各種状態のボタンの幅
    static let statebuttonwidth: CGFloat = CGFloat(UIScreen.screenWidth / 5)
    /// メイン画面の1表示の幅
    static let singleroutewidth: CGFloat = CGFloat(UIScreen.screenWidth - 80)
    /// メイン画面の2表示の幅
    static let doubleroutewidth: CGFloat = CGFloat(UIScreen.screenWidth / 2 - 40)
    /// 時刻表全体の幅
    var timetablewidth: CGFloat {
        return (CGFloat.screenwidth > 600) ? 631: CGFloat.screenwidth
    }
    /// 時刻表の時刻表示の幅
    var timetableeachwidth: CGFloat {
        return (CGFloat.screenwidth > 600) ? 600: CGFloat.screenwidth - 31
    }
}
