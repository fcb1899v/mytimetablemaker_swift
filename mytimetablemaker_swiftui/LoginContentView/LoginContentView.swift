//
//  LoginContentView.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/09.
//
import Foundation
import SwiftUI
import FirebaseAuth

struct LoginContentView: View {

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var myTransit: MyTransit
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore

    @State private var isShowSignUp = false
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

            Color.accentColor
            
            VStack(spacing: 20) {

                Text(MainTitle.main.rawValue.localized)
                    .font(.title)
                    .foregroundColor(Color.primaryColor)
                    .frame(height: 50)
                    .padding(.top, statusBarHeight + 50)

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

                //Login Button
                Button(action: myLogin.login) {
                    ZStack {
                        Text("Login".localized)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: loginButtonWidth, height: loginButtonHeight)
                            .background(myLogin.alertType == .select ? Color.primaryColor: Color.grayColor)
                            .cornerRadius(loginButtonCornerRadius)
                        if myLogin.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle())
                        }
                    }.padding(.bottom, 6)
                }
                .alert(myLogin.alertTitle, isPresented: $myLogin.isShowMessage) {
                    Button(Action.ok.rawValue.localized, role: .none){
                        if myLogin.isLoginSuccess {
                            if "firstlogin".userDefaultsBool(false) {
                                myFirestore.getFirestore()
                            } else {
                                UserDefaults.standard.set(true, forKey: "firstlogin")
                            }
                            UserDefaults.standard.set(true, forKey: "Login")
                        }
                        myLogin.isShowMessage = false
                    }
                } message: {
                    Text(myLogin.alertMessage)
                }

                //Show sign up
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

                //Password reset button
                Button(action: { myLogin.isResetAlert = true }) {
                    Text("Forgot Password?".localized)
                        .underline(color: .white)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                //Password Reset
                .alert("Password Reset".localized, isPresented: $myLogin.isResetAlert) {
                    TextField(Hint.email.rawValue.localized, text: $myLogin.resetEmail)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    //OK button
                    Button(Action.ok.rawValue.localized, role: .none){
                        myLogin.reset()
                    }
                    //Cancel button
                    Button(Action.cancel.rawValue.localized, role: .cancel){
                        myLogin.isResetAlert = false
                    }
                } message: {
                    Text("Reset your password?".localized)
                }
                //Message alert
                .alert(myLogin.alertTitle, isPresented: $myLogin.isShowMessage) {
                    Button(Action.ok.rawValue.localized, role: .none){
                        myLogin.isShowMessage = false
                        myLogin.isResetAlert = false
                    }
                } message: {
                    Text(myLogin.alertMessage)
                }

                Spacer()
                AdMobView()
            }
            .opacity(isShowSplash ? 0 : 1)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation() {
                        self.isShowSplash = false
                    }
                }
            }
        }.edgesIgnoringSafeArea(.top)
    }
}

struct LoginContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myLogin = MyLogin()
        let myTransit = MyTransit()
        let myFirestore = MyFirestore()
        LoginContentView(myTransit, myLogin, myFirestore)
    }
}
