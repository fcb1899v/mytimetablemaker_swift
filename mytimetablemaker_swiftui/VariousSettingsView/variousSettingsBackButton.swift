//
//  settingsBackButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/15.
//

import SwiftUI

struct variousSettingsBackButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image("arrow_back_ios")
                    .resizable()
                    .frame(width: 10, height: 18)
                Text("back".localized)
                    .foregroundColor(.white)
            }
        }
    }
}

struct variousSettingsBackButton_Previews: PreviewProvider {
    static var previews: some View {
        variousSettingsBackButton()
            .background(Color.primary)
    }
}
