//
//  SettingsContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/11.
//

import SwiftUI

struct SettingsContentView: View {

    @Environment(\.presentationMode) var presentationMode
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

    @ObservedObject var back1setting = Settings("back1", true)
    @ObservedObject var go1setting = Settings("go1", true)
    @ObservedObject var back2setting = Settings("back2", true)
    @ObservedObject var go2setting = Settings("go2", true)


    @State var back1changeline = "back1".changeLine
    @State var go1changeline = "go1".changeLine
    @State var back2changeline = "back2".changeLine
    @State var go2changeline = "go2".changeLine
    @State private var isShowLogIn = false
    
    let primary = Color(DefaultColor.primary.rawValue.colorInt)
    let route2title = "\n" + "Display route 2".localized
    let changelinetitle = "Change line".localized
    let varioussettingstitle = "Various settings".localized
    let accounttitle = "Account".localized
    let back2label = "Going home route 2".localized
    let go2label = "Outgoing route 2".localized
    
    var body: some View {
        NavigationView {
            Form {
                Section(
                    header: settingsTitle(route2title)
                ) {
                    settingsSwitchRoute2(back2label, $back2setting.route2flag)
                    settingsSwitchRoute2(go2label, $go2setting.route2flag)
                }
                Section(
                    header: settingsTitle(changelinetitle)
                ) {
                    settingsChangeLine("back1", $back1changeline)
                    if back2setting.route2flag {
                        settingsChangeLine("back2", $back2changeline)
                    }
                    settingsChangeLine("go1", $go1changeline)
                    if go2setting.route2flag {
                        settingsChangeLine("go2", $go2changeline)
                    }
                }
                Section(
                    header: settingsTitle(varioussettingstitle)
                ) {
                    back1setting.VariousSettingsEachView
                    if back2setting.route2flag {
                        back2setting.VariousSettingsEachView
                    }
                    go1setting.VariousSettingsEachView
                    if go2setting.route2flag {
                        go2setting.VariousSettingsEachView
                    }
                }
                Section(
                    header: settingsTitle(accounttitle)
                ) {
                    getDataButton(firestoreviewmodel)
                    setDataButton(firestoreviewmodel)
                    logOutButton(loginviewmodel, firestoreviewmodel)
                    deleteAccountButton(loginviewmodel, firestoreviewmodel)
                }
                Section(
                    header: settingsTitle("About".localized)
                ) {
                    settingsVersion()
                    settingsLinkView()
                }
            }
            .navigationTitle("Settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(backgroundColor: UIColor(primary), titleColor: .white)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    settingsBackButton(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, Color.white)
                }
            }
        }
    }
}

struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        let mainviewmodel = MainViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        SettingsContentView(loginviewmodel, mainviewmodel, firestoreviewmodel)
    }
}

