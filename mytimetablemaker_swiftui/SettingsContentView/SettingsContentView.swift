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

                    // MARK: - Direction Settings
                    Section(
                        header: Text("Various settings".localized)
                            .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.top, screen.settingsHeaderFontSize)
                    ) {
                        // Home and Destination button
                        createSettingsButton(
                            title: "Home & Destination Settings".localized,
                            action: { showTransferSheet = true }
                        )
                        // Settings route
                        createSettingsButton(
                            title: "Route Settings".localized,
                            action: {
                                selectedRoute = "back1"
                                showLineSheet = true
                            }
                        )
                        if myLogin.isLoginSuccess {
                            GetFirestoreButton(myTransfer: myTransfer, myFirestore: myFirestore)
                            SetFirestoreButton(myTransfer: myTransfer, myFirestore: myFirestore)
                        }
                    }
                    
                    // MARK: - Account Management
                    Section(
                        header: Text("Account".localized)
                            .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                    ) {
                        if myLogin.isLoginSuccess {
                            LogOutButton(myLogin: myLogin)
                            DeleteAccountButton(myLogin: myLogin)
                        } else {
                            NavigationLink(destination: LoginContentView(myTransfer, myLogin, myFirestore)){
                                Text("Manage your data after login".localized)
                                    .font(.system(size: screen.settingsFontSize))
                            }
                        }
                    }
                    
                    // MARK: - About Section
                    Section(
                        header: Text("About".localized).fontWeight(.bold)
                            .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                    ) {
                        // Version information
                        HStack {
                            Text("Version".localized)
                                .font(.system(size: screen.settingsFontSize))
                                .foregroundColor(.black)
                            Spacer()
                            Text(version)
                                .font(.system(size: screen.settingsFontSize))
                                .foregroundColor(.gray)
                        }
                        // Privacy Policy link
                        Button(action: {
                            if let yourURL = URL(string: termslink) {
                                UIApplication.shared.open(yourURL, options: [:], completionHandler: nil)
                            }
                        }) {
                           Text("Terms and privacy policy".localized)
                                .font(.system(size: screen.settingsFontSize))
                                .foregroundColor(.black)
                        }
                    }
                }
                
                // MARK: - Loading Indicator
                if myFirestore.isLoading {
                    Color.gray.opacity(0.8)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(screen.settingsSheetCornerRadius)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings".localized)
                    .font(.system(size: screen.settingsTitleFontSize, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .navigationBarColor(
            backgroundColor: UIColor(.primary),
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
                        Image(systemName: "arrowshape.backward.fill")
                            .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                            .foregroundColor(.white)
                        Text("Back to homepage".localized)
                            .font(.system(size: screen.settingsFontSize, weight: .bold))
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
                    .font(.system(size: screen.settingsFontSize))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: screen.settingsFontSize))
                    .foregroundColor(.gray)
            }
        }
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

