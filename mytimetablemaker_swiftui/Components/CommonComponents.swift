//
//  CommonComponent.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2025/08/24.
//  Common UI components used across the application
//  Provides reusable UI elements for consistent design
//

import SwiftUI

// MARK: - UI Components
// Small tag display component for showing metadata
struct Tag: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(Capsule().fill(Color(.secondarySystemFill)))
    }
}

