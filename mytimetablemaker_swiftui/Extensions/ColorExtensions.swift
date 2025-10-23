//
//  Color.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2021/05/02.
//

import Foundation
import SwiftUI

// MARK: - Color Extensions
// Extensions for color management and hex color support
extension Color {
    
    // MARK: - App Theme Colors
    static let primary = CustomColor.primary.color
    static let accent = CustomColor.accent.color
    static let red = CustomColor.red.color
    static let yellow = CustomColor.yellow.color
    static let gray = CustomColor.gray.color
    static let yelwgre = CustomColor.yelwgre.color
    static let orange = CustomColor.orange.color
    static let pink = CustomColor.pink.color
    static let ligblue = CustomColor.ligblue.color

    static let accentString = CustomColor.accent.RGB
    static let grayString = CustomColor.gray.RGB

    // MARK: - Legacy Color Support
    // Maintain backward compatibility with existing code
    // static let primaryColor = primary
    // static let accentColor = accent
    // static let grayColor = gray
    // static let redColor = red
    // static let yellowColor = yellow
    
    // MARK: - Hex Color Initializer
    // Initialize color from hex integer value
    init(
        _ hex: Int,
        opacity: Double = 1.0
    ) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    // MARK: - Hex String Initializer
    // Initialize color from hex string value
    init?(hex: String) {
        let cleanString = hex.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let hexValue = Int(cleanString, radix: 16) else { return nil }
        self.init(hexValue)
    }

    // MARK: - Hex String Conversion
    // Convert color to hex string representation
    func hex(withHash hash: Bool = false, uppercase up: Bool = false) -> String {
        if let components = self.cgColor?.components {
            let r = ("0" + String(Int(components[0] * 255.0), radix: 16, uppercase: up)).suffix(2)
            let g = ("0" + String(Int(components[1] * 255.0), radix: 16, uppercase: up)).suffix(2)
            let b = ("0" + String(Int(components[2] * 255.0), radix: 16, uppercase: up)).suffix(2)
            return (hash ? "#" : "") + String(r + g + b)
        }
        return "000000"
    }    
}

// MARK: - String Color Extensions
// Extensions for string-based color operations
extension String {
        
    // MARK: - Hex String to Int Conversion
    // Convert hex color string to integer value
    var colorInt: Int {
        let cleanString = self.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanString.isEmpty {
            return 0xAAAAAA // Default gray color
        }
        return Int(cleanString, radix: 16) ?? 0xAAAAAA
    }
    
    // MARK: - Settings Color Logic
    // Determine color for settings display based on text value
    var settingsColor: Color {
        return (self == "Not set".localized) ? .gray: .black
    }
    
    // MARK: - Safe Color Conversion
    // Safely convert hex string to Color with fallback
    var safeColor: Color {
        return Color(self.colorInt)
    }
    
}

// MARK: - Integer Color Extensions
// Extensions for countdown color calculations
extension Int {
    
    // MARK: - Countdown Color Calculation
    // Calculate color based on countdown time relative to departure time
    func countdownColor(_ departtime:Int) -> Color {
        return (departtime * 100).minusHHMMSS(self).HHMMSStoMMSS.countdownColor
    }

    // MARK: - Countdown Color Logic
    // Determine color based on countdown time ranges
    var countdownColor: Color { return (self % 2 == 1) ? .gray:
        (1000...9999 ~= self) ? .accent:
        (500...999 ~= self) ? .yellow:
        (0...499 ~= self) ? .red:
        .gray
    }
}

// MARK: - Train Type Color Management
// Extensions for train type color mapping and management
extension Color {
    
    // MARK: - Train Type Color Mapping
    // Convert train type string to appropriate color
    static func colorForTrainType(_ trainType: String?) -> Color {
        guard let trainType = trainType else { 
            return .white
        }
        
        let components = trainType.components(separatedBy: ".")
        
        guard let lastComponent = components.last else {
            return .white
        }
        
        guard let displayTrainType = DisplayTrainType(rawValue: lastComponent) else {
            return .white
        }
        
        return displayTrainType.color
    }
}

// MARK: - Custom Color Extensions
// Extensions for CustomColor enum to provide RGB color values
extension CustomColor {
    
    // MARK: - Color Property
    // Convert RGB string to Color object
    var color: Color {
        return Color(hex: self.RGB) ?? .gray
    }
    
    // MARK: - RGB Color Values
    // Hex color values for each custom color
    var RGB: String {
        switch self {
            case .red     : return "#E60012"
            case .darkred : return "#A22041"
            case .orange  : return "#F58220"
            case .brown   : return "#8F4C38"
            case .yellow  : return "#FFD400"
            case .beige   : return "#C1A470"
            case .yelwgre : return "#9ACD32"
            case .orive   : return "#9FB01C"
            case .green   : return "#009739"
            case .darkgre : return "#004E2E"
            case .bluegre : return "#00AC9A"
            case .ligblue : return "#00BFFF"
            case .blue    : return "#0000FF"
            case .navblue : return "#003580"
            case .primary : return "#3700B3"
            case .lavend  : return "#8F76D6"
            case .purple  : return "#B22C8D"
            case .magenta : return "#E4007F"
            case .pink    : return "#E85298"
            case .gray    : return "#9C9C9C"
            case .silver  : return "#89A1AD"
            case .gold    : return "#C5C544"
            case .black   : return "#000000"
            case .accent  : return "#03DAC5"
        }
    }
}

// MARK: - Display Train Type Extensions
// Extensions for DisplayTrainType enum to provide color mapping
extension DisplayTrainType {
    
    // MARK: - Color Mapping
    // Map train types to colors
    var color: Color {
        switch self {
        // Local trains - White
        case .defaultLocal, .local, .unknown:
            return .white
        // Express trains - Yellow Green
        case .defaultExpress, .express, .semiExpress, .sectionExpress, .sectionSemiExpress, .commuterExpress, .commuterSemiExpress:
            return .yelwgre
        // Rapid trains - Yellow
        case .defaultRapid, .rapid, .rapidExpress, .semiRapid, .commuterRapid:
            return .yellow
        // Special Rapid trains - Orange
        case .defaultSpecialRapid, .specialRapid, .commuterSpecialRapid, .chuoSpecialRapid, .omeSpecialRapid, .accessExpress, .airportRapidLimitedExpress, .kawagoeLimitedExpress, .fLiner, .rapidLimitedExpress:
            return .orange
        // Limited Express trains - Pink
        case .defaultLimitedExpress, .limitedExpress, .commuterLimitedExpress:
            return .pink
        // Paid trains - Light Blue
        case .liner, .thLiner, .tjLiner, .haijimaLiner, .sTrain, .slTaiju, .eveningWing, .morningWing:
            return .ligblue
        }
    }
}
