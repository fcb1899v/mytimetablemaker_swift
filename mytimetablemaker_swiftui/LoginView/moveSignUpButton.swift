///
//  moveSignUpButton.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/12.
//

import SwiftUI

struct moveSignUpButton: View {
    
    @State private var isShowSignUp = false
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
            isShowSignUp = true
        }) {
            Text("Signup".localized)
                .font(.headline)
                .foregroundColor(Color.primary)
                .frame(width: UIScreen.screenWidth * 0.8, height: 50)
                .background(Color.white)
                .cornerRadius(15.0)
        }.sheet(isPresented: $isShowSignUp) {
            signUpView(loginviewmodel, firestoreviewmodel)
        }
    }
}

struct moveSignUpButton_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        moveSignUpButton(loginviewmodel, firestoreviewmodel)
            .background(Color.accent)
    }
}

