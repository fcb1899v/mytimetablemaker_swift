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
    @ObservedObject private var myTransfer: MyTransfer
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore
    
    @State private var isShowLogIn = false
    @State private var showTransferSheet = false
    @State private var showLineSheet = false
    @State private var selectedRoute = "back1"

    init(
        _ myTransfer: MyTransfer,
        _ myLogin: MyLogin,
        _ myFirestore: MyFirestore
    ) {
        self.myTransfer = myTransfer
        self.myLogin = myLogin
        self.myFirestore = myFirestore
    }
    
        var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    // MARK: - Route Settings
                    Section(
                        header: Text("Route Settings".localized)
                            .font(.system(size: settingsHeaderFontSize, weight: .bold))
                            .foregroundColor(.gray)
                    ) {
                        // Home and Destination button
                        createSettingsButton(
                            title: "Setting home and destination".localized,
                            action: { showTransferSheet = true }
                        )

                        // Settings going home route
                        createRouteButton(goorback: "back1")
                        if (myTransfer.isShowBackRoute2) {
                            createRouteButton(goorback: "back2")
                        }
                        Toggle(isOn: $myTransfer.isShowBackRoute2){
                            Text("Display home route 2".localized)
                                .font(.system(size: settingsFontSize))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        .onChange(of: myTransfer.isShowBackRoute2) { _ in
                            myTransfer.saveRoute2Settings()
                        }

                        // Settings outgoing route
                        createRouteButton(goorback: "go1")
                        if (myTransfer.isShowGoRoute2) {
                            createRouteButton(goorback: "go2")
                        }
                        Toggle(isOn: $myTransfer.isShowGoRoute2){
                            Text("Display outgoing route 2".localized)
                                .font(.system(size: settingsFontSize))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        .onChange(of: myTransfer.isShowGoRoute2) { _ in
                            myTransfer.saveRoute2Settings()
                        }
                    }
                    
                    // MARK: - Account Management
                    Section(
                        header: Text("Account".localized)
                            .font(.system(size: settingsHeaderFontSize, weight: .bold))
                    ) {
                        if myLogin.isLoginSuccess {
                            GetFirestoreButton(myTransfer: myTransfer, myFirestore: myFirestore)
                            SetFirestoreButton(myTransfer: myTransfer, myFirestore: myFirestore)
                            LogOutButton(myLogin: myLogin)
                            DeleteAccountButton(myLogin: myLogin)
                        } else {
                            NavigationLink(destination: LoginContentView(myTransfer, myLogin, myFirestore)){
                                Text("Manage your data after login".localized)
                                    .font(.system(size: settingsFontSize))
                            }
                        }
                    }
                    
                    // MARK: - About Section
                    Section(
                        header: Text("About".localized).fontWeight(.bold)
                            .font(.system(size: settingsHeaderFontSize, weight: .bold))
                    ) {
                        // Version information
                        HStack {
                            Text("Version".localized)
                                .font(.system(size: settingsFontSize))
                                .foregroundColor(.black)
                            Spacer()
                            Text(version)
                                .font(.system(size: settingsFontSize))
                                .foregroundColor(.gray)
                        }
                        // Privacy Policy link
                        Button(action: {
                            if let yourURL = URL(string: termslink) {
                                UIApplication.shared.open(yourURL, options: [:], completionHandler: nil)
                            }
                        }) {
                           Text("Terms and privacy policy".localized)
                                .font(.system(size: settingsFontSize))
                                .foregroundColor(.black)
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
                        .cornerRadius(settingsLineSheetCornerRadius)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings".localized)
                    .font(.system(size: settingsTitleFontSize, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .navigationBarColor(
            backgroundColor: UIColor(Color.primaryColor),
            titleColor: .white,
        )
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showTransferSheet) {
            NavigationStack {
                SettingsTransferSheet()
            }
        }
        .sheet(isPresented: $showLineSheet) {
            NavigationStack {
                SettingsLineSheet(goorback: selectedRoute, lineIndex: 0)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                // Back button
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                     HStack {
                        Image(systemName: "arrow.left")
                            .font(.system(size: settingsHeaderFontSize, weight: .bold))
                            .foregroundColor(Color.white)
                        Text("Cancel".localized)
                            .font(.system(size: settingsFontSize, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Creates a settings button with consistent styling
    /// - Parameters:
    ///   - title: Button title text
    ///   - action: Action to perform when button is tapped
    /// - Returns: Configured button view
    @ViewBuilder
    private func createSettingsButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: settingsFontSize))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: settingsFontSize))
                    .foregroundColor(.gray)
            }
        }
    }
    
    /// Creates a route button for line settings
    /// - Parameter route: Route identifier (back1, back2, go1, go2)
    /// - Returns: Configured route button view
    @ViewBuilder
    private func createRouteButton(goorback: String) -> some View {
        createSettingsButton(
            title: goorback.routeTitle,
            action: {
                selectedRoute = goorback
                showLineSheet = true
            }
        )
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransfer = MyTransfer()
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        SettingsContentView(myTransfer, myLogin, myFirestore)
    }
}

