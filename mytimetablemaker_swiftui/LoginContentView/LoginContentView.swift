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

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var myTransfer: MyTransfer
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore

    @State private var isShowSignUp = false
    @State private var isShowReset = false
    @State private var isShowSplash = true

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
                // Title
                Text("Login".localized)
                    .font(.system(size: screen.loginTitleFontSize))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, screen.loginTitleTopMargin)
                    .padding(.bottom, screen.loginTitleBottomMargin)

                // Email text field
                TextField("Email".localized, text: $myLogin.email)
                    .font(.subheadline)
                    .lineLimit(1)
                    .padding()
                    .frame(height: screen.loginTextHeight)
                    .background(CustomBackground(backgroundColor: .white))
                    .overlay(CustomBorder())
                    .onChange(of: myLogin.email) { _ in myLogin.loginCheck() }
                    .frame(width: screen.loginButtonWidth)
                
                // Password text field
                SecureField("Password (8+ chars: alnum & !@#$&~)".localized, text: $myLogin.password)
                    .font(.subheadline)
                    .lineLimit(1)
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
                .alert(myLogin.alertTitle, isPresented: $myLogin.isShowMessage) {
                    Button("OK".localized, role: .none){
                        myLogin.isShowMessage = false
                        if myLogin.isLoginSuccess {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } message: {
                    Text(myLogin.alertMessage)
                }
                
                // MARK: - Sign Up Button
                CustomButton(
                    title: "Signup".localized,
                    backgroundColor: Color.primary,
                    action: { isShowSignUp = true }
                )
                .frame(width: screen.loginButtonWidth)
                .sheet(isPresented: $isShowSignUp) {
                    SignUpContentView(myLogin)
                }
                
                // MARK: - Password Reset Button
                Button(action: { isShowReset = true }) {
                    Text("Forgot Password?".localized)
                        .underline(color: .white)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                // Password Reset alert
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
                // Message alert
                .alert(myLogin.alertTitle, isPresented: $myLogin.isShowMessage) {
                    Button("OK".localized, role: .none){
                        myLogin.isShowMessage = false
                    }
                } message: {
                    Text(myLogin.alertMessage)
                }
                Spacer()
                Spacer()
            }
            
            // MARK: - Loading Indicator
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
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct LoginContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myLogin = MyLogin()
        let myTransfer = MyTransfer()
        let myFirestore = MyFirestore()
        LoginContentView(myTransfer, myLogin, myFirestore)
    }
}
