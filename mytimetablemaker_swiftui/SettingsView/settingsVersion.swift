//
//  settingsVersion.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/16.
//

import SwiftUI

struct settingsVersion: View {
        
    var body: some View {

        let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!

        HStack {
            Text("Version".localized)
                .font(.subheadline)
                .padding(5)
            Spacer()
            Text(version)
                .font(.subheadline)
                .foregroundColor(.mygray)
                .padding(5)
        }
    }
}

struct settingsVersion_Previews: PreviewProvider {
    static var previews: some View {
        settingsVersion()
    }
}

