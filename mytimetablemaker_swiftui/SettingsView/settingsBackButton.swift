//
//  settingsBackButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/15.
//

import SwiftUI

struct settingsBackButton: View {
    
    @ObservedObject private var loginviewmodel: LoginViewModel

    init(
        _ loginviewmodel: LoginViewModel
    ) {
        self.loginviewmodel = loginviewmodel
    }
    
    var body: some View {
        Button(action: {
            self.loginviewmodel.isMoveSettings = false
        }) {
            HStack {
                Image("arrow_back_ios")
                    .resizable()
                    .frame(width: 10, height: 18, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Text("back".localized)
                    .foregroundColor(Color.white)
            }
        }
    }
}

struct settingsBackButton_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        settingsBackButton(loginviewmodel)
            .background(Color.black)
    }
}

