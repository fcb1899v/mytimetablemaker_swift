//
//  signUpButton.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/15.
//

import SwiftUI

struct signUpButton: View {
        
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
    
    @State private var isSignUpAlert = false
    let primary = Color(DefaultColor.primary.rawValue.colorInt)
    let gray = Color(DefaultColor.gray.rawValue.colorInt)

    var body: some View {
        Button(action: {
            if (loginviewmodel.isTermsAgree) {
                loginviewmodel.signUpEmpty()
                isSignUpAlert = true
            }
        }) {
            Text("Signup".localized)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: UIScreen.screenWidth * 0.8, height: 50)
                .background((loginviewmodel.isTermsAgree) ? primary: gray)
                .cornerRadius(15.0)
        }
        .alert(isPresented: $isSignUpAlert) {
            switch loginviewmodel.alertType {
                case .select: return signUpSelectAlert
                default: return signUpAlert
            }
        }
    }

    private var signUpSelectAlert: Alert {
        return Alert(
            title: Text("Signup".localized),
            message: Text("Send an verification email?".localized),
            primaryButton: .cancel(Text("Cancel".localized)),
            secondaryButton: .default(Text("OK"),
                action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        loginviewmodel.signUp()
                        loginviewmodel.alertType = .complete
                        isSignUpAlert = true
                    }
                }
            )
        )
    }
    
    private var signUpAlert: Alert {
        return Alert(
            title: Text(loginviewmodel.title),
            message: Text(loginviewmodel.message),
            dismissButton: .default(Text("OK")) {
                if !self.loginviewmodel.isError {
                    firestoreviewmodel.resetFirestore()
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        )
    }

}

struct signUpButton_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        signUpButton(loginviewmodel, firestoreviewmodel)
    }
}
