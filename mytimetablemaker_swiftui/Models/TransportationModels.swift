//
//  TransportationModels.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/08/26.
//

import Foundation

// MARK: - TransportationType
// Enumeration of available transportation methods for transfer.
enum TransportationType: String, CaseIterable {
    case car = "car"            // Car transportation
    case bicycle = "bicycle"    // Bicycle transportation
    case walking = "walking"    // Walking between stations
    case none = "none"          // No transfer required
    
    // MARK: - Transportation Method Display Name
    // Localized display name for each transportation method
    var transportationDisplayName: String {
        switch self {
            case .none: return "None".localized
            case .walking: return "Walking".localized
            case .bicycle: return "Bicycle".localized
            case .car: return "Car".localized
        }
    }
    
    // MARK: - Icon Properties
    // SF Symbol icon name for each transportation method
    var iconName: String {
        switch self {
            case .none: return "xmark.circle"
            case .walking: return "figure.walk"
            case .bicycle: return "bicycle"
            case .car: return "car"
        }
    }
}

// MARK: - Utility Functions
// Helper function to convert string labels to TransportationType enum values
func getTransportationType(label: String) -> TransportationType {
    switch label {
        case "none", "None", "none".localized, "None".localized: return .none
        case "walking", "Walking", "walking".localized, "Walking".localized: return .walking
        case "bicycle", "Bicycle", "bicycle".localized, "Bicycle".localized: return .bicycle
        case "car", "Car", "car".localized, "Car".localized: return .car
        default: return .walking // Default to walking instead of none
    }
}
