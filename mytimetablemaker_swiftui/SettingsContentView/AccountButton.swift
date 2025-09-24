//
//  LogOutButton.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2023/10/09.
//

import SwiftUI
import FirebaseAuth

// MARK: - Log Out Button
// Button component for logging out current user account
struct AccountButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var myLogin: MyLogin
    private let isDeleteAccount: Bool
    @State private var isShowAlert = false
    
    init(
        myLogin: MyLogin,
        isDeleteAccount: Bool
    ) {
        self.myLogin = myLogin
        self.isDeleteAccount = isDeleteAccount
    }
    
    var body: some View {
        Button(action: {
            isShowAlert = true
        }) {
            Text(isDeleteAccount ? "Delete Account".localized: "Logout".localized)
                .font(.system(size: screen.settingsFontSize))
                .foregroundColor(.black)
        }
        // MARK: - Logout Confirmation Alert
        .alert(isDeleteAccount ? "Delete Account".localized: "Logout".localized, isPresented: $isShowAlert) {
            // OK button
            Button("OK".localized, role:  isDeleteAccount ? .destructive: .none) {
                isShowAlert = false
                isDeleteAccount ? myLogin.delete(): myLogin.logOut()
            }
            // Cancel button
            Button("Cancel".localized, role: .cancel) {
                isShowAlert = false
            }
        } message: {
            Text(isDeleteAccount ? ("⚠️ " + "Delete your account?".localized): "Logout your account?".localized)
                .foregroundColor(isDeleteAccount ? .red: .primary)
        }
        .tint(.primary)
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct AccountButton_Previews: PreviewProvider {
    static var previews: some View {
        let myLogin = MyLogin()
        AccountButton(myLogin: myLogin, isDeleteAccount: false)
    }
}


