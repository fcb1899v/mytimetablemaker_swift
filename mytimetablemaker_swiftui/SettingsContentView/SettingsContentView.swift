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
    @ObservedObject private var myTransit: TransitViewModel
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
    @State private var getFirestorePassword = ""
    @State private var saveFirestorePassword = ""
    @State private var deleteAccountPassword = ""
    // Route 2 display setting (controls both back2 and go2)
    @State private var showRoute2: Bool = false

    // MARK: - Initialization
    // Initialize with view models for transit, login, and Firestore operations
    init(
        _ myTransit: TransitViewModel,
        _ myLogin: LoginViewModel,
        _ myFirestore: FirestoreViewModel
    ) {
        self.myTransit = myTransit
        self.myLogin = myLogin
        self.myFirestore = myFirestore
    }
    
    var body: some View {
        contentWithAlerts
    }

    // Split large view composition into smaller chunks
    // to avoid Swift compiler type-check timeouts.
    private var navigationConfiguredContent: some View {
        ZStack {
            mainContent
            
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
            MainContentView(myTransit, myLogin, myFirestore)
        }
    }

    private var contentWithStatusAlerts: some View {
        navigationConfiguredContent
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
        
        // MARK: - Firestore Result Alert
        .alert(myFirestore.title, isPresented: $myFirestore.isShowMessage) {
            Button("OK".localized, role: .none) {
                myFirestore.isShowMessage = false
                if (myFirestore.isFirestoreSuccess) {
                    // Update transfer data for GetFirestore operation
                    myTransit.setRoute2()
                    myTransit.setLineData()
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

    private var contentWithAlerts: some View {
        contentWithStatusAlerts
        // MARK: - Confirmation Alerts
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
        .alert("⚠️ \("Delete Account".localized)", isPresented: $isShowDeleteAlert) {
            SecureField("Enter your password".localized, text: $deleteAccountPassword)
            Button("Delete".localized, role: .destructive) {
                myLogin.delete()
                isShowDeleteAlert = false
                deleteAccountPassword = ""
            }
            Button("Cancel".localized, role: .cancel) {
                isShowDeleteAlert = false
                deleteAccountPassword = ""
            }
        } message: {
            Text("Delete your account?".localized)
        }
        .alert("⚠️ \("Get saved data".localized)", isPresented: $isShowGetFirestoreAlert) {
            SecureField("Enter your password".localized, text: $getFirestorePassword)
            Button("OK".localized, role: .none) {
                myFirestore.getFirestore()
                isShowGetFirestoreAlert = false
                getFirestorePassword = ""
            }
            Button("Cancel".localized, role: .cancel) {
                isShowGetFirestoreAlert = false
                getFirestorePassword = ""
            }
        } message: {
            Text("Overwritten current data?".localized)
        }
        .alert("⚠️ \("Save current data".localized)", isPresented: $isShowSaveFirestoreAlert) {
            SecureField("Enter your password".localized, text: $saveFirestorePassword)
            Button("OK".localized, role: .none) {
                myFirestore.setFirestore()
                isShowSaveFirestoreAlert = false
                saveFirestorePassword = ""
            }
            Button("Cancel".localized, role: .cancel) {
                isShowSaveFirestoreAlert = false
                saveFirestorePassword = ""
            }
        } message: {
            Text("Overwritten saved data?".localized)
        }
        .tint(.primary)
        // MARK: - Load Route 2 Setting
        .onAppear {
            loadRoute2Setting()
        }
    }
    
    // MARK: - View Components
    // Main content view with form and ad banner
    private var mainContent: some View {
        VStack(spacing: 0) {
            settingsForm
            
            Spacer()
            
            adBannerView
        }
        .background(.white)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // Settings form with all sections
    private var settingsForm: some View {
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
                    NavigationLink(destination: LoginContentView(myTransit, myLogin, myFirestore)){
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
                // Contact form link
                Button(action: {
                    if let contactURL = URL(string: contactlink) {
                        UIApplication.shared.open(contactURL, options: [:], completionHandler: nil)
                    }
                }) {
                    Text("Contact".localized)
                        .font(.system(size: screen.settingsFontSize))
                        .foregroundColor(.black)
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
            }
        }
    }
    
    // Ad banner view at bottom
    private var adBannerView: some View {
        ZStack {
            Color.primary
                .frame(maxWidth: .infinity)
                .frame(height: screen.admobBannerHeight)
//            AdMobBannerView()
//                .frame(minWidth: screen.admobBannerMinWidth)
//                .frame(width: screen.admobBannerWidth, height: screen.admobBannerHeight)
//                .background(Color.primary)
        }
        .frame(maxWidth: .infinity)
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
        
        // Update TransitViewModel
        myTransit.isShowBackRoute2 = value
        myTransit.isShowGoRoute2 = value
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
        let myTransit = TransitViewModel()
        let myLogin = LoginViewModel()
        let myFirestore = FirestoreViewModel()
        SettingsContentView(myTransit, myLogin, myFirestore)
    }
}

