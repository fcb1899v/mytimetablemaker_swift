//
//  VariousSettingsViewModel.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/16.
//

import SwiftUI

class VariousSettingsViewModel: ObservableObject {
    
    @Published var linecolor1 = Color(DefaultColor.gray.rawValue.colorInt)
    @Published var linecolor2 = Color(DefaultColor.gray.rawValue.colorInt)
    @Published var linecolor3 = Color(DefaultColor.gray.rawValue.colorInt)
        
    private let goorback: String

    init(
        _ goorback: String
    ) {
        self.goorback = goorback
    }
}
