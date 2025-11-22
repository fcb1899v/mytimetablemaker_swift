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
    
    // MARK: - Environment & Observed Objects
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var myTransfer: TransferViewModel
    @ObservedObject private var myLogin: LoginViewModel
    @ObservedObject private var myFirestore: FirestoreViewModel
    
    // MARK: - State Properties
    // Control visibility of sheets, alerts, and navigation state
    @State private var isShowLogIn = false
    @State private var showTransferSheet = false
    @State private var showLineSheet = false
    @State private var selectedRoute = "back1"
    @State private var isNavigateToMain = false
    @State private var isShowLogoutAlert = false
    @State private var isShowDeleteAlert = false
    @State private var isShowGetFirestoreAlert = false
    @State private var isShowSaveFirestoreAlert = false
    // Route 2 display setting (controls both back2 and go2)
    @State private var showRoute2: Bool = false

    // MARK: - Initialization
    // Initialize with view models for transfer, login, and Firestore operations
    init(
        _ myTransfer: TransferViewModel,
        _ myLogin: LoginViewModel,
        _ myFirestore: FirestoreViewModel
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

                    // Route 2 display toggle
                    HStack {
                        Text("Another route".localized)
                            .font(.system(size: screen.settingsFontSize))
                            .foregroundColor(.black)
                        Spacer()
                        CustomToggle(
                            isLeftSelected: Binding(
                                get: { !showRoute2 },
                                set: { newValue in
                                    showRoute2 = !newValue
                                    saveRoute2Setting(!newValue)
                                }
                            ),
                            leftText: "Hide".localized,
                            leftColor: .gray,
                            rightText: "Display".localized,
                            rightColor: .primary,
                            circleColor: .white,
                            offColor: .gray
                        )
                    }

                    // Firestore data management buttons (only shown when logged in)
                    if myLogin.isLoginSuccess {
                        firestoreButton(isSaveFirestore: false)
                        firestoreButton(isSaveFirestore: true)
                    }
                }
                
                // MARK: - Account Management
                Section(
                    header: Text("Account".localized)
                        .font(.system(size: screen.settingsHeaderFontSize, weight: .bold))
                ) {
                    if myLogin.isLoginSuccess {
                        accountButton(isDeleteAccount: false)
                        accountButton(isDeleteAccount: true)
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
        // MARK: - Navigation & Toolbar Configuration
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
        // MARK: - Sheet Presentations
        // Present transfer and line settings sheets based on user actions
        .adaptiveSheet(isPresented: $showTransferSheet) {
            NavigationStack {
                SettingsTransferSheet()
            }
        }
        .adaptiveSheet(isPresented: $showLineSheet) {
            NavigationStack {
                SettingsLineSheet(goorback: selectedRoute, lineIndex: 0)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                CustomBackButton(action: { isNavigateToMain = true })
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
        // MARK: - Confirmation Alerts
        // Alert dialogs for logout, account deletion, and Firestore operations
        .alert("Logout".localized, isPresented: $isShowLogoutAlert) {
            Button("OK".localized, role: .none) {
                isShowLogoutAlert = false
                myLogin.logOut()
            }
            Button("Cancel".localized, role: .cancel) {
                isShowLogoutAlert = false
            }
        } message: {
            Text("Logout your account?".localized)
        }
        // MARK: - Delete Account Alert
        .alert("Delete Account".localized, isPresented: $isShowDeleteAlert) {
            Button("OK".localized, role: .destructive) {
                isShowDeleteAlert = false
                myLogin.delete()
            }
            Button("Cancel".localized, role: .cancel) {
                isShowDeleteAlert = false
            }
        } message: {
            Text("⚠️ " + "Delete your account?".localized)
        }
        // MARK: - Get Firestore Alert
        .alert("Get saved data".localized, isPresented: $isShowGetFirestoreAlert) {
            Button("OK".localized, role: .destructive) {
                myFirestore.getFirestore()
                isShowGetFirestoreAlert = false
            }
            Button("Cancel".localized, role: .cancel) {
                isShowGetFirestoreAlert = false
            }
        } message: {
            Text("⚠️ " + "Overwritten current data?".localized)
        }
        // MARK: - Save Firestore Alert
        .alert("Save current data".localized, isPresented: $isShowSaveFirestoreAlert) {
            Button("OK".localized, role: .destructive) {
                myFirestore.setFirestore()
                isShowSaveFirestoreAlert = false
            }
            Button("Cancel".localized, role: .cancel) {
                isShowSaveFirestoreAlert = false
            }
        } message: {
            Text("⚠️ " + "Overwritten saved data?".localized)
        }
        // MARK: - Load Route 2 Setting
        .onAppear {
            loadRoute2Setting()
        }
    }
    
    // MARK: - Helper Functions
    
    /// Load Route 2 display setting from UserDefaults
    /// Checks both back2 and go2 settings, uses OR logic
    private func loadRoute2Setting() {
        let back2Route2Value = UserDefaults.standard.object(forKey: "back2".isShowRoute2Key) != nil ?
            UserDefaults.standard.bool(forKey: "back2".isShowRoute2Key) : false
        let go2Route2Value = UserDefaults.standard.object(forKey: "go2".isShowRoute2Key) != nil ?
            UserDefaults.standard.bool(forKey: "go2".isShowRoute2Key) : false
        
        // Use OR logic: show Route 2 if either back2 or go2 is enabled
        showRoute2 = back2Route2Value || go2Route2Value
    }
    
    /// Save Route 2 display setting to UserDefaults and update ViewModel
    /// Saves the same value to both back2 and go2
    /// - Parameter value: New Route 2 display state
    private func saveRoute2Setting(_ value: Bool) {
        // Save to UserDefaults for both routes
        UserDefaults.standard.set(value, forKey: "back2".isShowRoute2Key)
        UserDefaults.standard.set(value, forKey: "go2".isShowRoute2Key)
        
        // Update TransferViewModel
        myTransfer.isShowBackRoute2 = value
        myTransfer.isShowGoRoute2 = value
    }
    
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
    
    /// Creates an account button (logout or delete account) with alert confirmation
    /// - Parameter isDeleteAccount: Whether this is a delete account button (true) or logout button (false)
    /// - Returns: Configured button view
    @ViewBuilder
    private func accountButton(isDeleteAccount: Bool) -> some View {
        Button(action: {
            if isDeleteAccount {
                isShowDeleteAlert = true
            } else {
                isShowLogoutAlert = true
            }
        }) {
            Text(isDeleteAccount ? "Delete Account".localized: "Logout".localized)
                .font(.system(size: screen.settingsFontSize))
                .foregroundColor(.black)
        }
    }
    
    /// Creates a Firestore button (get or save data) with alert confirmation
    /// - Parameter isSaveFirestore: Whether this is a save button (true) or get button (false)
    /// - Returns: Configured button view
    @ViewBuilder
    private func firestoreButton(isSaveFirestore: Bool) -> some View {
        Button(action: {
            if isSaveFirestore {
                isShowSaveFirestoreAlert = true
            } else {
                isShowGetFirestoreAlert = true
            }
        }) {
            Text(isSaveFirestore ? "Save current data".localized: "Get saved data".localized)
                .font(.system(size: screen.settingsFontSize))
                .foregroundColor(.black)
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransfer = TransferViewModel()
        let myLogin = LoginViewModel()
        let myFirestore = FirestoreViewModel()
        SettingsContentView(myTransfer, myLogin, myFirestore)
    }
}

