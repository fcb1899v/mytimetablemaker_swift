//
//  loginButton.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/12.
//

import SwiftUI
import FirebaseAuth

struct loginButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var loginviewmodel: LoginViewModel
    @ObservedObject private var firestoreviewmodel: FirestoreViewModel

    init(
        _ loginviewmodel: LoginViewModel,
        _ firestoreviewmodel: FirestoreViewModel
    ) {
        self.loginviewmodel = loginviewmodel
        self.firestoreviewmodel = firestoreviewmodel
    }
    
    @State private var isLoginAlert = false
    let primary = Color(DefaultColor.primary.rawValue.colorInt)

    var body: some View {
        Button(action: {
            loginviewmodel.login()
            isLoginAlert = true
        }) {
            Text("Login".localized)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: UIScreen.screenWidth * 0.8, height: 50)
                .background(primary)
                .cornerRadius(15.0)
        }.alert(isPresented: $isLoginAlert) {
            loginAlert
        }
    }
    
    private var loginAlert: Alert {
        Alert(
            title: Text(loginviewmodel.title),
            message: Text(loginviewmodel.message),
            dismissButton: .default(Text("OK")) {
                if !self.loginviewmodel.isError {
                    if firestoreviewmodel.isFirstLogin {
                        firestoreviewmodel.getFirestore()
                    } else {
                        firestoreviewmodel.isFirstLogin = true
                    }
                    UserDefaults.standard.set(true, forKey: "Login")
                }
            }
        )
    }
}

struct loginButton_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        loginButton(loginviewmodel, firestoreviewmodel)
    }
}
