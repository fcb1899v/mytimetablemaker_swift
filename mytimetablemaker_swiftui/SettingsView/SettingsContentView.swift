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
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        NavigationView {
            VStack(spacing: 0) {
                settingsHeaderView(loginviewmodel)
                Form {
                    Section(
                        header: Text("\n" + "Display route 2".localized)
                            .fontWeight(.bold)
                    ) {
                        settingsSwitchRoute2("back2")
                        settingsSwitchRoute2("go2")
                    }
                    Section(
                        header: Text("Change line".localized)
                            .fontWeight(.bold)
                    ) {
                        ForEach(goorbackarray, id: \.self) { goorback in
                            if goorback.route2Flag {
                                settingsChangeLine(goorback)
                            }
                        }
                    }
                    Section(
                        header: Text("Various settings".localized)
                            .fontWeight(.bold)
                    ) {
                        ForEach(goorbackarray, id: \.self) { goorback in
                            if goorback.route2Flag {
                                SettingsViewModel(goorback).VariousSettingsEachView
                            }
                        }
                    }
                    Section(
                        header: Text("Account".localized)
                            .fontWeight(.bold)
                    ) {
                        getDataButton(firestoreviewmodel)
                        setDataButton(firestoreviewmodel)
                        logOutButton(loginviewmodel, firestoreviewmodel)
                        deleteAccountButton(loginviewmodel, firestoreviewmodel)
                    }
                    Section(
                        header: Text("About".localized)
                            .fontWeight(.bold)
                    ) {
                        settingsVersion()
                        settingsLinkView()
                    }
                }
                Spacer()
            }.padding(.top, -20 - statusBarHeight)
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
        .navigationViewStyle(StackNavigationViewStyle())
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

