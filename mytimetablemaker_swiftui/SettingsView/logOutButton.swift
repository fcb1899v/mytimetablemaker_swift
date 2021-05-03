//
//  logoutButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/13.
//

import SwiftUI
import FirebaseAuth

struct logOutButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var isLogOutAlert = false
    @State private var title = ""
    @State private var message = ""
    @ObservedObject private var loginviewmodel: LoginViewModel
    @ObservedObject private var firestoreviewmodel: FirestoreViewModel

    init(
        _ loginviewmodel: LoginViewModel,
        _ firestoreviewmodel: FirestoreViewModel
    ) {
        self.loginviewmodel = loginviewmodel
        self.firestoreviewmodel = firestoreviewmodel
    }

    var body: some View {

        Button(action: {
            isLogOutAlert = true
            loginviewmodel.alertType = .select
        }) {
            Text("Logout".localized)
            .font(.subheadline)
            .foregroundColor(.black)
            .padding(5)
        }
        .alert(isPresented: $isLogOutAlert) {
            switch loginviewmodel.alertType {
                case .complete: return logOutCompleteAlert
                default: return logOutSelectAlert
            }
        }
    }
    
    private var logOutSelectAlert: Alert {
        return Alert(
            title: Text("Logout".localized),
            message: Text("Logout your account?"),
            primaryButton: .cancel(Text("Cancel".localized)),
            secondaryButton: .default(Text("OK"),
                action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        title = "Logged out".localized
                        do {
                            try Auth.auth().signOut()
                            firestoreviewmodel.resetFirestore()
                            loginviewmodel.isMoveSettings = false
                            UserDefaults.standard.set(false, forKey: "Login")
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            title = "Logout error".localized
                        }
                        loginviewmodel.alertType = .complete
                        isLogOutAlert = true
                    }
                }
            )
        )
    }
    
    private var logOutCompleteAlert: Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(Text("OK"))
        )
    }
}

struct logOutButton_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        logOutButton(loginviewmodel, firestoreviewmodel)
    }
}

