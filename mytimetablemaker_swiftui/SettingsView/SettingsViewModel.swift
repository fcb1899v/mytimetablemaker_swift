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
    
    init(
        _ goorback: String
    ) {
        self.goorback = goorback
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

func ActionSheetButtons(list: [String], value: [Any], key: String) -> [ActionSheet.Button] {
    var buttonsArray: [ActionSheet.Button] = []
    for i in 0..<list.count {
        buttonsArray.append(.default(Text(list[i])) {
            UserDefaults.standard.set(value[i], forKey: key)
        })
    }
    buttonsArray.append(.cancel())
    return buttonsArray
}
