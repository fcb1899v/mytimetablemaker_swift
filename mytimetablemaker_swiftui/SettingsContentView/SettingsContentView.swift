//
//  SettingsContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/02/11.
//

import SwiftUI

// MARK: - Settings Content View
// Main settings screen with route configuration, account management, and app information
struct SettingsContentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var myTransit: MyTransit
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore
    
    @State private var isShowLogIn = false

    init(
        _ myTransit: MyTransit,
        _ myLogin: MyLogin,
        _ myFirestore: MyFirestore
    ) {
        self.myTransit = myTransit
        self.myLogin = myLogin
        self.myFirestore = myFirestore
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    // MARK: - Route Display Settings
                    Section(
                        header: Text("Display route 2".localized).fontWeight(.bold)
                    ) {
                        // Display or not going home route 2
                        Toggle(isOn: $myTransit.isShowBackRoute2){
                            Text("Going home route 2".localized)
                        }.toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        // Display or not outgoing route 2
                        Toggle(isOn: $myTransit.isShowGoRoute2){
                            Text("Outgoing route 2".localized)
                        }.toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                    }
                    
                    // MARK: - Line Change Settings
                    Section(
                        header: Text("Change line".localized).fontWeight(.bold)
                    ) {
                        // Setting change line of going home route 1
                        settingsChangeLine(myTransit, goorback: "back1")
                        // Setting change line of going home route 2
                        if (myTransit.isShowBackRoute2) {settingsChangeLine(myTransit, goorback: "back2")}
                        // Setting change line of outgoing route 1
                        settingsChangeLine(myTransit, goorback: "go1")
                        // Setting change line of outgoing route 2
                        if (myTransit.isShowGoRoute2) {settingsChangeLine(myTransit, goorback: "go2")}
                    }
                    
                    // MARK: - Various Settings
                    Section(
                        header: Text("Various settings".localized).fontWeight(.bold)
                    ) {
                        NavigationLink(destination: VariousSettingsContentView("back1")){
                            Text("back1".routeTitle)
                        }
                        if (myTransit.isShowBackRoute2) {
                            NavigationLink(destination: VariousSettingsContentView("back2")){
                                Text("back2".routeTitle)
                            }
                        }
                        NavigationLink(destination: VariousSettingsContentView("go1")){
                            Text("go1".routeTitle)
                        }
                        if (myTransit.isShowGoRoute2) {
                            NavigationLink(destination: VariousSettingsContentView("go2")){
                                Text("go2".routeTitle)
                            }
                        }
                    }
                    
                    // MARK: - Account Management
                    Section(
                        header: Text("Account".localized).fontWeight(.bold)
                    ) {
                        if myLogin.isLoginSuccess {
                            GetFirestoreButton(myTransit: myTransit, myFirestore: myFirestore)
                            SetFirestoreButton(myTransit: myTransit, myFirestore: myFirestore)
                            LogOutButton(myLogin: myLogin)
                            DeleteAccountButton(myLogin: myLogin)
                        } else {
                            NavigationLink(destination: LoginContentView(myTransit, myLogin, myFirestore)){
                                Text("Get your data after login".localized)
                            }
                            NavigationLink(destination: LoginContentView(myTransit, myLogin, myFirestore)){
                                Text("Save your data after login".localized)
                            }
                        }
                    }
                    
                    // MARK: - About Section
                    Section(
                        header: Text("About".localized).fontWeight(.bold)
                    ) {
                        // Version information
                        HStack {
                            Text("Version".localized)
                            Spacer()
                            Text(version).foregroundColor(Color.grayColor)
                        }
                        // Privacy Policy link
                        Button(action: {
                            if let yourURL = URL(string: termslink) {
                                UIApplication.shared.open(yourURL, options: [:], completionHandler: nil)
                            }
                        }) {
                           Text("Terms and privacy policy".localized).foregroundColor(.black)
                        }
                    }
                }
                
                // MARK: - Loading Indicator
                if myFirestore.isLoading {
                    Color.grayColor.opacity(0.8)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
        }
        .navigationTitle("Settings".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor(backgroundColor: UIColor(Color.primaryColor), titleColor: .white)
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                // Back button
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image("arrow_back_ios").resizable().frame(width: 10, height: 18)
                        Text("Back".localized).foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = MyTransit()
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        SettingsContentView(myTransit, myLogin, myFirestore)
    }
}

