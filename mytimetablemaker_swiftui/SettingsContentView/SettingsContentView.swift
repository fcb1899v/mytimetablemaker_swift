//
//  SettingsContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/11.
//

import SwiftUI

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
        
        let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!
        let termstitle = "Terms and privacy policy".localized
        let termslink = "https://nakajimamasao-appstudio.web.app/terms".localized

        NavigationView {
            
            //Form
            Form {
                Section(
                    header: Text("\n" + "Display route 2".localized).fontWeight(.bold)
                ) {
                    //Display or not going home route 2
                    Toggle(isOn: $myTransit.isShowBackRoute2){
                        Text("Going home route 2".localized).font(.subheadline)
                    }.toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                    //Display or not outgoing route 2
                    Toggle(isOn: $myTransit.isShowGoRoute2){
                        Text("Outgoing route 2".localized).font(.subheadline)
                    }.toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                }
                
                Section(
                    header: Text("Change line".localized).fontWeight(.bold)
                ) {
                    settingsChangeLine("back1")
                    if (myTransit.isShowBackRoute2) {settingsChangeLine("back2")}
                    settingsChangeLine("go1")
                    if (myTransit.isShowGoRoute2) {settingsChangeLine("go2")}
                }
                
                Section(
                    header: Text("Various settings".localized)
                        .fontWeight(.bold)
                ) {
                    NavigationLink(destination: VariousSettingsContentView("back1")){
                        Text("back1".routeTitle).padding(5)
                    }
                    if (myTransit.isShowBackRoute2) {
                        NavigationLink(destination: VariousSettingsContentView("back2")){
                            Text("back2".routeTitle).padding(5)
                        }
                    }
                    NavigationLink(destination: VariousSettingsContentView("go1")){
                        Text("go1".routeTitle).padding(5)
                    }
                    if (myTransit.isShowGoRoute2) {
                        NavigationLink(destination: VariousSettingsContentView("go2")){
                            Text("go2".routeTitle).padding(5)
                        }
                    }
                }
                .font(.subheadline)
                .foregroundColor(Color.black)

                Section(
                    header: Text("Account".localized).fontWeight(.bold)
                ) {
                    if myLogin.isLoginSuccess {
                        getDataButton(myFirestore)
                        setDataButton(myFirestore)
                        logOutButton(myLogin, myFirestore)
                        deleteAccountButton(myLogin, myFirestore)
                    } else {
//                        LoginContentView(myTransit, myLogin, myFirestore)
                    }
                }
                
                Section(
                    header: Text("About".localized).fontWeight(.bold)
                ) {
                    //Version
                    HStack {
                        Text("Version".localized).padding(5)
                        Spacer()
                        Text(version).foregroundColor(Color.grayColor).padding(5)
                    }
                    //Privacy Policy
                    Button(action: {
                        if let yourURL = URL(string: termslink) {
                            UIApplication.shared.open(yourURL, options: [:], completionHandler: nil)
                        }
                    }) {
                       Text(termstitle).foregroundColor(.black).padding(5)
                    }
                }.font(.subheadline)
            }
        }
        .navigationTitle("Settings".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor(backgroundColor: UIColor(Color.primaryColor), titleColor: .white)
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                //Back button
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image("arrow_back_ios").resizable().frame(width: 10, height: 18)
                        Text("back".localized).foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = MyTransit()
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        SettingsContentView(myTransit, myLogin, myFirestore)
    }
}

