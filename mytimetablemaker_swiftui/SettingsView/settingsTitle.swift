//
//  settingsTitle.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/16.
//

import SwiftUI

struct settingsTitle: View {
    
    private let title: String
    
    init(
        _ title: String
    ) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .fontWeight(.bold)
            .foregroundColor(Color.black)
    }
}

struct settingsTitle_Previews: PreviewProvider {
    static var previews: some View {
        settingsTitle("Display route 2".localized)
    }
}

