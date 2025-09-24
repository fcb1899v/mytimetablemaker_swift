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

    init(
        _ myLogin: MyLogin
    ) {
        self.myLogin = myLogin
    }

    var body: some View {
        VStack(spacing: screen.loginMargin) {
            // MARK: - Title
            Text("Create Account".localized)
                .font(.system(size: screen.loginTitleFontSize))
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, screen.loginTitleTopMargin)
                .padding(.bottom, screen.loginTitleBottomMargin)
            
            // MARK: - Email Input Field
            TextField("Email".localized, text: $myLogin.email)
                .font(.subheadline)
                .lineLimit(1)
                .padding()
                .frame(height: screen.loginTextHeight)
                .background(CustomBackground(backgroundColor: .white))
                .overlay(CustomBorder())
                .onChange(of: myLogin.email) { _ in myLogin.signUpCheck() }
                .frame(width: screen.loginButtonWidth)
            
            // MARK: - Password Input Field
            SecureField("Password (8+ chars: alnum & !@#$&~)".localized, text: $myLogin.password)
                .font(.subheadline)
                .lineLimit(1)
                .padding()
                .frame(height: screen.loginTextHeight)
                .background(CustomBackground(backgroundColor: .white))
                .overlay(CustomBorder())
                .onChange(of: myLogin.password) { _ in myLogin.signUpCheck() }
                .frame(width: screen.loginButtonWidth)
            
            // MARK: - Confirm Password Input Field
            SecureField("Confirm Password".localized, text: $myLogin.passwordConfirm)
                .font(.subheadline)
                .lineLimit(1)
                .padding()
                .frame(height: screen.loginTextHeight)
                .background(CustomBackground(backgroundColor: .white))
                .overlay(CustomBorder())
                .onChange(of: myLogin.passwordConfirm) { _ in myLogin.signUpCheck() }
                .frame(width: screen.loginButtonWidth)
            
            // MARK: - Sign Up Button
            CustomButton(
                title: "Signup".localized,
                backgroundColor: myLogin.isValidSignUp ? Color.primary : Color.gray,
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
            
            // MARK: - Terms and Conditions Agreement
            HStack(spacing: screen.settingsSheetHorizontalSpacing) {
                // Checkbox for terms agreement
                Button(action: myLogin.toggle) {
                    Image(systemName: myLogin.isTermsAgree ? "checkmark.square.fill": "square")
                        .foregroundColor(myLogin.isTermsAgree ? .primary: .white)
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

            Spacer()

            // MARK: - Ad Banner
            AdMobBannerView()
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.accent)
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

