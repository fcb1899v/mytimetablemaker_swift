//
//  signUpView.swift
//  mytimetablemakers_swiftui
//
//  Created by Nakajima Masao on 2021/03/12.
//

import SwiftUI
import FirebaseAuth
import GoogleMobileAds

// MARK: - Sign Up Content View
// User registration screen with form validation and terms agreement
struct SignUpContentView: View {
    
    // MARK: - Environment & Observed Objects
    // Dismisses the sheet when sign up is successful
    @Environment(\.presentationMode) var presentationMode
    // Login view model for authentication state management
    @ObservedObject private var myLogin: LoginViewModel
    
    // MARK: - State Variables
    // Password visibility toggle states for input fields
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false

    // MARK: - Initialization
    // Initialize with login view model
    init(
        _ myLogin: LoginViewModel
    ) {
        self.myLogin = myLogin
    }

    var body: some View {
        ZStack {
            // Background color for entire view
            Color.primary
                .ignoresSafeArea(.all)
            
            VStack(spacing: screen.loginMargin) {
            // MARK: - Title
            Text("Create Account".localized)
                .font(.system(size: screen.loginTitleFontSize))
                .fontWeight(.bold)
                .foregroundColor(.accent)
                .padding(.bottom, screen.loginTitleBottomMargin)
            
            // MARK: - Email Input Field
            // Text field for email address entry with validation
            TextField("Email".localized, text: $myLogin.email)
                .keyboardType(.default)
                .font(.system(size: screen.loginTextFieldFontSize))
                .lineLimit(1)
                .padding()
                .frame(height: screen.loginTextHeight)
                .background(CustomBackground(backgroundColor: .white))
                .overlay(CustomBorder())
                .onChange(of: myLogin.email) { _ in myLogin.signUpCheck() }
                .frame(width: screen.loginButtonWidth)
            
            // MARK: - Password Input Field
            // Secure text field with visibility toggle for password entry
            HStack {
                if isPasswordVisible {
                    TextField("Password (8+ chars: alnum !@#$&~)".localized, text: $myLogin.password)
                        .keyboardType(.default)
                        .font(.system(size: screen.loginTextFieldFontSize))
                        .lineLimit(1)
                } else {
                    SecureField("Password (8+ chars: alnum !@#$&~)".localized, text: $myLogin.password)
                        .font(.system(size: screen.loginTextFieldFontSize))
                        .lineLimit(1)
                }
                
                // Toggle password visibility button
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
            .onChange(of: myLogin.password) { _ in myLogin.signUpCheck() }
            .frame(width: screen.loginButtonWidth)
            
            // MARK: - Confirm Password Input Field
            // Secure text field with visibility toggle for password confirmation
            HStack {
                if isConfirmPasswordVisible {
                    TextField("Confirm Password".localized, text: $myLogin.passwordConfirm)
                        .keyboardType(.default)
                        .font(.system(size: screen.loginTextFieldFontSize))
                        .lineLimit(1)
                } else {
                    SecureField("Confirm Password".localized, text: $myLogin.passwordConfirm)
                        .font(.system(size: screen.loginTextFieldFontSize))
                        .lineLimit(1)
                }
                
                // Toggle confirm password visibility button
                Button(action: {
                    isConfirmPasswordVisible.toggle()
                }) {
                    Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: screen.loginEyeIconSize))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(width: screen.loginButtonWidth, height: screen.loginTextHeight)
            .background(CustomBackground(backgroundColor: .white))
            .overlay(CustomBorder())
            .onChange(of: myLogin.passwordConfirm) { _ in myLogin.signUpCheck() }
            
            // MARK: - Sign Up Button
            // Button to submit registration form with loading indicator
            CustomButton(
                title: "Signup".localized,
                backgroundColor: myLogin.isValidSignUp ? Color.accent : Color.gray,
                isEnabled: myLogin.isValidSignUp,
                action: myLogin.signUp
            )
            .frame(width: screen.loginButtonWidth)
            // Loading indicator overlay during sign up process
            .overlay(
                Group {
                    if myLogin.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
            )
            // Sign up result alert that dismisses sheet on success
            .alert(myLogin.alertTitle, isPresented: $myLogin.isShowMessage) {
                Button("OK".localized, role: .none){
                    myLogin.isShowMessage = false
                    if myLogin.isSignUpSuccess {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text(myLogin.alertMessage)
            }
            .tint(.primary)
            
            // MARK: - Terms and Conditions Agreement
            // Checkbox and link to terms and privacy policy
            HStack(spacing: screen.settingsSheetHorizontalSpacing) {
                // Checkbox button to toggle terms agreement
                Button(action: myLogin.toggle) {
                    Image(systemName: myLogin.isTermsAgree ? "checkmark.square.fill": "square")
                        .foregroundColor(myLogin.isTermsAgree ? .accent: .white)
                }
                // Button to open terms and privacy policy in browser
                Button(action: {
                    if let termsURL = URL(string: termslink) {
                        UIApplication.shared.open(termsURL, options: [:], completionHandler: nil)
                    }
                }) {
                    (
                        Text("I have read and agree to the ".localized)
                        + Text("terms and privacy policy".localized).underline(color: .white)
                        + Text("kakunin".localized)
                    )
                    .font(.subheadline)
                    .foregroundColor(.white)
                }
            }
            .frame(width: screen.loginButtonWidth, alignment: .top)
            }
        }
        // Set sheet height to 70% of screen
        .presentationDetents([.fraction(0.7)])
        // MARK: - Lifecycle
        // Clear form fields and validate on appear
        .onAppear {
            myLogin.email = ""
            myLogin.password = ""
            myLogin.passwordConfirm = ""
            myLogin.isTermsAgree = false
            myLogin.signUpCheck()
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        let myLogin = LoginViewModel()
        SignUpContentView(myLogin)
    }
}

