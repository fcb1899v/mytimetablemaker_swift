//
//  SettingsClass.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/28.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    
    private let goorback: String

    @Published var route2flag: Bool {
        didSet {
            UserDefaults.standard.set(route2flag, forKey: goorback + "route2flag")
        }
    }

    @Published var changeline: String {
        didSet {
            UserDefaults.standard.set(changeline, forKey: goorback.changeLine)
        }
    }
    
    init(
        _ goorback: String
    ) {
        self.goorback = goorback
        self.changeline = goorback.changeLine
        self.route2flag = goorback.route2Flag
    }
    
    var VariousSettingsEachView: some View {
        NavigationLink(destination: VariousSettingsContentView(goorback)){
            if route2flag {
                Text(goorback.routeTitle)
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(5)
            }
        }
    }
}

