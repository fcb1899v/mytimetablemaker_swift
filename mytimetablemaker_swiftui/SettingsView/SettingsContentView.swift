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
    @ObservedObject var back2setting = SettingsViewModel("back2")
    @ObservedObject var go2setting = SettingsViewModel("go2")
    @State private var isShowLogIn = false
    private let primary = Color(DefaultColor.primary.rawValue.colorInt)
    private let goorbackarray = ["back1", "back2", "go1", "go2"]

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
        NavigationView {
            Form {
                Section(
                    header: settingsTitle("\n" + "Display route 2".localized)
                ) {
                    settingsSwitchRoute2("back2", $back2setting.route2flag)
                    settingsSwitchRoute2("go2", $go2setting.route2flag)
                }
                Section(
                    header: settingsTitle("Change line".localized)
                ) {
                    ForEach(goorbackarray, id: \.self) { goorback in
                        if goorback.route2Flag {
                            settingsChangeLine(goorback)
                        }
                    }
                }
                Section(
                    header: settingsTitle("Various settings".localized)
                ) {
                    ForEach(goorbackarray, id: \.self) { goorback in
                        if goorback.route2Flag {
                            SettingsViewModel(goorback).VariousSettingsEachView
                        }
                    }
                }
                Section(
                    header: settingsTitle("Account".localized)
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
                    settingsBackButton(loginviewmodel)
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

