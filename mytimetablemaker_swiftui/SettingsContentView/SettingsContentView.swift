//
//  SettingsContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2021/02/11.
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
    @State private var isNavigateToMain = false

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
                        FirestoreButton(myFirestore: myFirestore, isSaveFirestore: false)
                        FirestoreButton(myFirestore: myFirestore, isSaveFirestore: true)
                    }
                }
                
                // MARK: - Account Management
                Section(
                    header: Text("Account".localized)
                        .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                ) {
                    if myLogin.isLoginSuccess {
                        AccountButton(myLogin: myLogin, isDeleteAccount: false)
                        AccountButton(myLogin: myLogin, isDeleteAccount: true)
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
                    isNavigateToMain = true
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
        .navigationDestination(isPresented: $isNavigateToMain) {
            MainContentView(myTransfer, myLogin, myFirestore)
        }
        // MARK: - Logout Result Alert
        .alert(myLogin.alertTitle, isPresented: $myLogin.isShowMessage) {
            Button("OK".localized, role: .none) {
                myLogin.isShowMessage = false
                if (!myLogin.isLoginSuccess) {
                    // Add slight delay to ensure reliable navigation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isNavigateToMain = true
                    }
                }
            }
        } message: {
            Text(myLogin.alertMessage)
        }
        .tint(.primary)
        
        // MARK: - Firestore Result Alert
        .alert(myFirestore.title, isPresented: $myFirestore.isShowMessage) {
            Button("OK".localized, role: .none) {
                myFirestore.isShowMessage = false
                if (myFirestore.isFirestoreSuccess) {
                    // Update transfer data for GetFirestore operation
                    myTransfer.setRoute2()
                    myTransfer.setLineData()
                    // Add slight delay to ensure reliable navigation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isNavigateToMain = true
                    }
                }
            }
        } message: {
            Text(myFirestore.message)
        }
        .tint(.primary)
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

