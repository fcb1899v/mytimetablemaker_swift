//
//  moveSettingsButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/06.
//

import SwiftUI

struct moveSettingsButton: View {
    
    @ObservedObject private var loginviewmodel: LoginViewModel
    @ObservedObject private var mainviewmodel: MainViewModel
    @ObservedObject private var firestoreviewmodel: FirestoreViewModel

    init(
        _ loginviewmodel: LoginViewModel,
        _ mainviewmodel: MainViewModel,
        _ firestoreviewmodel: FirestoreViewModel
    ) {
        self.loginviewmodel = loginviewmodel
        self.mainviewmodel = mainviewmodel
        self.firestoreviewmodel = firestoreviewmodel
    }

    var body: some View {
        VStack (spacing: 0) {
            Button(action: {
                loginviewmodel.isMoveSettings = true
            }) {
                ZStack {
                    Image("ic_settings1")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                    NavigationLink(
                        destination: SettingsContentView(loginviewmodel, mainviewmodel, firestoreviewmodel),
                        isActive: $loginviewmodel.isMoveSettings,
                        label: {}
                    )
                }
            }
        }.frame(width: 20, height: 20, alignment: .center)
    }
}

struct moveSettingsButton_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        let mainviewmodel = MainViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        moveSettingsButton(loginviewmodel, mainviewmodel, firestoreviewmodel)
            .background(Color.myprimary)
    }
}
