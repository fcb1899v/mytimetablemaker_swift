//
//  LogOutButton.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2023/10/09.
//

import SwiftUI
import FirebaseAuth

// MARK: - Log Out Button
// Button component for logging out current user account
struct LogOutButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var myLogin: MyLogin
    @State private var isShowAlert = false

    init(
        myLogin: MyLogin
    ) {
        self.myLogin = myLogin
    }

    var body: some View {
        Button(action: {
            isShowAlert = true
        }) {
            Text("Logout".localized).foregroundColor(.black)
        }
        // MARK: - Logout Confirmation Alert
        .alert("Logout".localized, isPresented: $isShowAlert) {
            // OK button
            Button(textOk, role: .none){
                myLogin.logOut()
                isShowAlert = false
            }
            // Cancel button
            Button(textCancel, role: .cancel){
                isShowAlert = false
            }
        } message: {
            Text("Logout your account?".localized)
        }
        // MARK: - Logout Result Alert
        .alert(myLogin.alertTitle, isPresented: $myLogin.isShowMessage) {
            Button(textOk, role: .none){
                myLogin.isShowMessage = false
                if (!myLogin.isLoginSuccess) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(myLogin.alertMessage)
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct LogOutButton_Previews: PreviewProvider {
    static var previews: some View {
        let myLogin = MyLogin()
        LogOutButton(myLogin: myLogin)
    }
}


