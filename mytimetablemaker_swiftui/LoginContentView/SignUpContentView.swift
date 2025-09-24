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
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var myLogin: MyLogin
    @State private var isSignUpAlert = false
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false

    init(
        _ myLogin: MyLogin
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
            TextField("Email".localized, text: $myLogin.email)
                .font(.system(size: screen.loginTextFieldFontSize))
                .lineLimit(1)
                .padding()
                .frame(height: screen.loginTextHeight)
                .background(CustomBackground(backgroundColor: .white))
                .overlay(CustomBorder())
                .onChange(of: myLogin.email) { _ in myLogin.signUpCheck() }
                .frame(width: screen.loginButtonWidth)
            
            // MARK: - Password Input Field
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
            .onChange(of: myLogin.password) { _ in myLogin.signUpCheck() }
            .frame(width: screen.loginButtonWidth)
            
            // MARK: - Confirm Password Input Field
            HStack {
                if isConfirmPasswordVisible {
                    TextField("Confirm Password".localized, text: $myLogin.passwordConfirm)
                        .font(.system(size: screen.loginTextFieldFontSize))
                        .lineLimit(1)
                } else {
                    SecureField("Confirm Password".localized, text: $myLogin.passwordConfirm)
                        .font(.system(size: screen.loginTextFieldFontSize))
                        .lineLimit(1)
                }
                
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
            CustomButton(
                title: "Signup".localized,
                backgroundColor: myLogin.isValidSignUp ? Color.accent : Color.gray,
                isEnabled: myLogin.isValidSignUp,
                action: myLogin.signUp
            )
            .frame(width: screen.loginButtonWidth)
            .overlay(
                Group {
                    if myLogin.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
            ).alert(myLogin.alertTitle, isPresented: $myLogin.isShowMessage) {
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
            HStack(spacing: screen.settingsSheetHorizontalSpacing) {
                // Checkbox for terms agreement
                Button(action: myLogin.toggle) {
                    Image(systemName: myLogin.isTermsAgree ? "checkmark.square.fill": "square")
                        .foregroundColor(myLogin.isTermsAgree ? .accent: .white)
                }
                // Terms and privacy policy link
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
        .presentationDetents([.fraction(0.7)])
        .onAppear {
            // Clear text fields when signup screen appears
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
        let myLogin = MyLogin()
        SignUpContentView(myLogin)
    }
}

