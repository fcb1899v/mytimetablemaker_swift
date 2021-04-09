//
//  deleteAccountButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/19.
//

import SwiftUI
import FirebaseAuth

struct deleteAccountButton: View {
    
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
    
    @State private var isDeleteAlert = false
    @State private var title = ""
    @State private var message = ""

    var body: some View {

        Button(action: {
            isDeleteAlert = true
            loginviewmodel.alertType = .select
        }) {
            Text("Delete Account".localized)
            .font(.subheadline)
            .foregroundColor(Color.black)
            .padding(5)
        }
        .alert(isPresented: $isDeleteAlert) {
            switch loginviewmodel.alertType {
                case .complete: return deleteCompleteAlert
                default: return deleteSelectAlert
            }
        }
    }
    
    private var deleteSelectAlert: Alert {
        return Alert(
            title: Text("Delete Account".localized),
            message: Text("Delete your account?"),
            primaryButton: .cancel(Text("Cancel".localized)),
            secondaryButton: .default(Text("OK"),
                action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        Auth.auth().currentUser?.delete { error in
                            if error != nil {
                                title = "Delete account error".localized
                                message = "Account could not be deleted".localized
                            } else {
                                message = "Account deleted successfully".localized
                                firestoreviewmodel.resetFirestore()
                                loginviewmodel.isMoveSettings = false
                                UserDefaults.standard.set(false, forKey: "Login")
                            }
                        }
                        loginviewmodel.alertType = .complete
                        isDeleteAlert = true
                    }
                }
            )
        )
    }
    
    private var deleteCompleteAlert: Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(Text("OK")) {
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
}

struct deleteAccountButton_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        deleteAccountButton(loginviewmodel, firestoreviewmodel)
    }
}

