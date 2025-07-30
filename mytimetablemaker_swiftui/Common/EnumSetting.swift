//
//  EnumSetting.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2020/12/27.
//

import SwiftUI

// MARK: - Transit Time Enumeration
// Defines the number of transfers for transit routes
enum TransitTime: String, CaseIterable {
    case zero = "Zero";
    case once = "Once";
    case twice = "Twice";
    var Number: Int {
        switch (self) {
            case .zero: return 0
            case .once: return 1
            case .twice: return 2
        }
    }
}

// MARK: - Transportation Enumeration
// Defines available transportation modes for transit segments
enum Transportation: String, CaseIterable {
    case walking = "Walking"
    case bicycle = "Bicycle"
    case car = "Car"
}

// MARK: - Custom Color Enumeration
// Defines color options for line customization with RGB values
enum CustomColor: String, CaseIterable {
    case accent = "DEFAULT"
    case red    = "RED"
    case orange = "ORANGE"
    case yellow = "YELLOW"
    case yelgre = "YELLOW GREEN"
    case green  = "GREEN"
    case blugre = "BLUE GREEN"
    case ligblr = "LIGHT BLUE"
    case blue   = "BLUE"
    case navblu = "NAVY BLUE"
    case purple = "PURPLE"
    case pink   = "PINK"
    case darred = "DARK RED"
    case brown  = "BROWN"
    case gold   = "GOLD"
    case silver = "SILVER"
    case black  = "BLACK"
    var RGB: String {
        switch self {
            case .accent: return "#03DAC5"
            case .red   : return "#FF0000"
            case .orange: return "#F68B1E"
            case .yellow: return "#FFD400"
            case .yelgre: return "#99CC00"
            case .green : return "#009933"
            case .blugre: return "#00AC9A"
            case .ligblr: return "#00BAE8"
            case .blue  : return "#0000FF"
            case .navblu: return "#003686"
            case .purple: return "#A757A8"
            case .pink  : return "#E85298"
            case .darred: return "#C9252F"
            case .brown : return "#BB6633"
            case .gold  : return "#C5C544"
            case .silver: return "#89A1AD"
            case .black : return "#000000"
        }
    }
}
