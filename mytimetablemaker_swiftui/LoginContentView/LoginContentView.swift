//
//  LoginContentView.swift
//  mytimetablemakers_swiftui
//
//  Created by Nakajima Masao on 2021/03/09.
//
import Foundation
import SwiftUI
import FirebaseAuth

// MARK: - Login Content View
// Main login screen with authentication form and navigation
struct LoginContentView: View {

    // MARK: - Observed Objects
    // Core data models for app state management
    @ObservedObject private var myTransfer: TransferViewModel
    @ObservedObject private var myLogin: LoginViewModel
    @ObservedObject private var myFirestore: FirestoreViewModel

    // MARK: - State Variables
    // UI state flags for navigation and modal presentation
    @State private var isShowSignUp = false
    @State private var isShowReset = false
    @State private var isPasswordVisible = false
    @State private var isNavigateToMain = false
    @State private var isNavigateToSettings = false
    @State private var isShowLoginResultAlert = false

    // MARK: - Initialization
    // Initialize with required data models
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
        NavigationStack {
            ZStack(alignment: .top) {
            // MARK: - Background and Ad Banner
            VStack(spacing: 0) {
                Spacer()
                Image("splash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(0)
                    .frame(width: screen.screenWidth)
                // AdMob banner at bottom
                ZStack {
                    Color.primary
                        .frame(width: screen.screenWidth)
                    AdMobBannerView()
                        .frame(minWidth: screen.admobBannerMinWidth)
                        .frame(width: screen.admobBannerWidth)
                }
                .frame(height: screen.admobBannerHeight)
            }
            .background(Color.accent)
            
            // MARK: - Login Form
            VStack(spacing: screen.loginMargin) {
                // MARK: - Title Section
                // Login screen title
                Text("Login".localized)
                    .font(.system(size: screen.loginTitleFontSize))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, screen.loginTitleTopMargin)
                    .padding(.bottom, screen.loginTitleBottomMargin)

                // MARK: - Email Input Field
                // Text field for email address entry
                TextField("Email".localized, text: $myLogin.email)
                    .font(.system(size: screen.loginTextFieldFontSize))
                    .lineLimit(1)
                    .padding()
                    .frame(height: screen.loginTextHeight)
                    .background(CustomBackground(backgroundColor: .white))
                    .overlay(CustomBorder())
                    .onChange(of: myLogin.email) { _ in myLogin.loginCheck() }
                    .frame(width: screen.loginButtonWidth)
                
                // MARK: - Password Input Field
                // Secure text field with visibility toggle for password entry
                HStack {
                    if isPasswordVisible {
                        TextField("Password (8+ chars: alnum !@#$&~)".localized, text: $myLogin.password)
                            .font(.system(size: screen.loginTextFieldFontSize))
                            .lineLimit(1)
                    } else {
                        SecureField("Password (8+ chars: alnum !@#$&~)".localized, text: $myLogin.password)
                            .font(.system(size: screen.loginTextFieldFontSize))
                            .lineLimit(1)
                    }
                    
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: screen.loginEyeIconSize))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .frame(height: screen.loginTextHeight)
                .background(CustomBackground(backgroundColor: .white))
                .overlay(CustomBorder())
                .onChange(of: myLogin.password)  { _ in myLogin.loginCheck() }
                .frame(width: screen.loginButtonWidth)
                
                // MARK: - Login Button
                CustomButton(
                    title: "Login".localized,
                    backgroundColor: myLogin.isValidLogin ? Color.primary : Color.gray,
                    isEnabled: myLogin.isValidLogin,
                    action: myLogin.login
                )
                .frame(width: screen.loginButtonWidth)
                .alert(myLogin.alertTitle, isPresented: $isShowLoginResultAlert) {
                    Button("OK".localized, role: .none){
                        isShowLoginResultAlert = false
                        if myLogin.isLoginSuccess {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isNavigateToSettings = true
                            }
                        }
                    }
                } message: {
                    Text(myLogin.alertMessage)
                }
                .tint(.primary)
                
                // MARK: - Sign Up Button
                CustomButton(
                    title: "Signup".localized,
                    backgroundColor: Color.white,
                    textColor: Color.primary,
                    action: { isShowSignUp = true }
                )
                .frame(width: screen.loginButtonWidth)
                .sheet(isPresented: $isShowSignUp) {
                    SignUpContentView(myLogin)
                }
                
                // MARK: - Password Reset Button
                // Button to trigger password reset flow
                Button(action: { isShowReset = true }) {
                    Text("Forgot Password?".localized)
                        .underline(color: .white)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                // Password reset confirmation alert with email input
                .alert("Password Reset".localized, isPresented: $isShowReset) {
                    TextField("Email".localized, text: $myLogin.resetEmail)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    // OK button
                    Button("OK".localized, role: .none){
                        myLogin.reset()
                    }
                    // Cancel button
                    Button("Cancel".localized, role: .cancel){
                        isShowReset = false
                    }
                } message: {
                    Text("Reset your password?".localized)
                }
                .tint(.primary)
                
                // MARK: - Message Alert
                // Alert for displaying login result messages
                .alert(myLogin.alertTitle, isPresented: $myLogin.isShowMessage) {
                    Button("OK".localized, role: .none){
                        myLogin.isShowMessage = false
                    }
                } message: {
                    Text(myLogin.alertMessage)
                }
                .tint(.primary)
                Spacer()
            }
            
            // MARK: - Loading Indicator
            // Display loading overlay during authentication process
            if myLogin.isLoading {
                ZStack {
                    Color.gray.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                }
            }
            }
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.all)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    CustomBackButton(foregroundColor: .primary,
                        action: { 
                            isNavigateToMain = true 
                        }
                    )
                }
            }
            // MARK: - Lifecycle
            // Clear fields and validate on appear
            .onAppear {
                myLogin.email = ""
                myLogin.password = ""
                myLogin.loginCheck()
            }
            // Handle login result message changes
            .onChange(of: myLogin.isShowMessage) { newValue in
                if newValue {
                    isShowLoginResultAlert = true
                    myLogin.isShowMessage = false
                }
            }
            .navigationDestination(isPresented: $isNavigateToSettings) {
                SettingsContentView(myTransfer, myLogin, myFirestore)
            }
            .navigationDestination(isPresented: $isNavigateToMain) {
                MainContentView(myTransfer, myLogin, myFirestore)
            }
            .toolbarBackground(Color.accent, for: .navigationBar)
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct LoginContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myLogin = LoginViewModel()
        let myTransfer = TransferViewModel()
        let myFirestore = FirestoreViewModel()
        LoginContentView(myTransfer, myLogin, myFirestore)
    }
}
