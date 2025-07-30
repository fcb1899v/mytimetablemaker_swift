//
//  LoginContentView.swift
//  mytimetablemakers_swiftui
//
//  Created by Masao Nakajima on 2021/03/09.
//
import Foundation
import SwiftUI
import FirebaseAuth

// MARK: - Login Content View
// Main login screen with authentication form and navigation
struct LoginContentView: View {

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var myTransit: MyTransit
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore

    @State private var isShowSignUp = false
    @State private var isShowReset = false
    @State private var isShowSplash = true

    init(
        _ myTransit: MyTransit,
        _ myLogin: MyLogin,
        _ myFirestore: MyFirestore
    ) {
        self.myTransit = myTransit
        self.myLogin = myLogin
        self.myFirestore = myFirestore
    }

    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Background and Ad Banner
            VStack {
                Spacer()
                Image("splash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(0)
                    .frame(width: screenWidth)
                // AdMob banner at bottom
                AdMobBannerView()
                    .frame(minWidth: admobBannerMinWidth)
                    .frame(width: admobBannerWidth, height: admobBannerHeight)
                    .background(.white)
            }.background(Color.accentColor)
            
            // MARK: - Login Form
            VStack(spacing: loginMargin) {
                // Title
                Text("Login".localized)
                    .font(.system(size: loginTitleFontSize))
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryColor)
                    .padding(.top, loginTitleTopMargin)
                    .padding(.bottom, loginTitleBottomMargin)
                
                // Email text field
                ZStack {
                    Rectangle()
                        .foregroundColor(Color.white)
                        .cornerRadius(loginTextCornerRadius)
                        .frame(height: loginTextHeight)
                    TextField("Email".localized, text: $myLogin.email)
                        .font(.subheadline)
                        .lineLimit(1)
                        .padding()
                        .onChange(of: myLogin.email) { _ in myLogin.loginCheck() }
                }.frame(width: loginButtonWidth)
                
                // Password text field
                ZStack {
                    Rectangle()
                        .foregroundColor(Color.white)
                        .cornerRadius(loginTextCornerRadius)
                        .frame(height: loginTextHeight)
                    SecureField("Password (8+ chars: alnum & !@#$&~)".localized, text: $myLogin.password)
                        .font(.subheadline)
                        .lineLimit(1)
                        .padding()
                        .onChange(of: myLogin.password)  { _ in myLogin.loginCheck() }
                }.frame(width: loginButtonWidth).padding(.bottom, 6)
                
                // MARK: - Login Button
                Button(action: myLogin.login) {
                    ZStack {
                        Text("Login".localized)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: loginButtonWidth, height: loginButtonHeight)
                            .background(myLogin.isValidLogin ? Color.primaryColor: Color.grayColor)
                            .cornerRadius(loginButtonCornerRadius)
                    }.padding(.bottom, 6)
                }
                .alert(myLogin.alertTitle, isPresented: $myLogin.isShowMessage) {
                    Button(textOk, role: .none){
                        myLogin.isShowMessage = false
                        if myLogin.isLoginSuccess {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } message: {
                    Text(myLogin.alertMessage)
                }
                
                // MARK: - Sign Up Button
                Button(action: { isShowSignUp = true }) {
                    Text("Signup".localized)
                        .font(.headline)
                        .foregroundColor(Color.primaryColor)
                        .frame(width: loginButtonWidth, height: loginButtonHeight)
                        .background(.white)
                        .cornerRadius(loginButtonCornerRadius)
                        .padding(.bottom, 6)
                }.sheet(isPresented: $isShowSignUp) {
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
                    Button(textOk, role: .none){
                        myLogin.reset()
                    }
                    // Cancel button
                    Button(textCancel, role: .cancel){
                        isShowReset = false
                    }
                } message: {
                    Text("Reset your password?".localized)
                }
                // Message alert
                .alert(myLogin.alertTitle, isPresented: $myLogin.isShowMessage) {
                    Button(textOk, role: .none){
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
                    Color.grayColor.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(Color.white)
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
        let myTransit = MyTransit()
        let myFirestore = MyFirestore()
        LoginContentView(myTransit, myLogin, myFirestore)
    }
}
