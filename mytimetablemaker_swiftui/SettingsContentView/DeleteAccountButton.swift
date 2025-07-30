//
//  DeleteAccountButton.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2023/10/09.
//

import SwiftUI
import FirebaseAuth

// MARK: - Delete Account Button
// Button component for deleting current user account
struct DeleteAccountButton: View {
    
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
            Text("Delete Account".localized).foregroundColor(.black)
        }
        // MARK: - Delete Account Confirmation Alert
        .alert("Delete Account".localized, isPresented: $isShowAlert) {
            // OK button
            Button(textOk, role: .destructive){
                myLogin.delete()
                isShowAlert = false
            }
            // Cancel button
            Button(textCancel, role: .cancel){
                isShowAlert = false
            }
        } message: {
            Text("Delete your account?".localized)
        }
        // MARK: - Delete Account Result Alert
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
struct DeleteAccountButton_Previews: PreviewProvider {
    static var previews: some View {
        let myLogin = MyLogin()
        DeleteAccountButton(myLogin: myLogin)
    }
}



