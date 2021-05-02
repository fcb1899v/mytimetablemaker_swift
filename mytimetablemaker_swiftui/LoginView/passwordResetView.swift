//
//  passwordResetView.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/10.
//

import SwiftUI
import FirebaseAuth

struct passwordResetView: View {
              
    @State private var isShowingAlert = false
    @State private var isSendingEmail = false
    @State private var title = ""
    @State private var message = ""
    @ObservedObject private var loginviewmodel: LoginViewModel
    
    init(
        _ loginviewmodel: LoginViewModel
    ) {
        self.loginviewmodel = loginviewmodel
    }
    
    var body: some View {
        
        Button(action: {
            isShowingAlert = true
        }) {
            ZStack(alignment: .top) {
                Text("Forgot Password?".localized)
                    .underline(color: Color.white)
                    .font(.headline)
                    .foregroundColor(Color.white)
                passwordResetAlertView(
                    email: $loginviewmodel.email,
                    isShowingAlert: $isShowingAlert,
                    isSendingEmail: $isSendingEmail,
                    title: $title,
                    message: $message
                )
                .alert(isPresented: $isSendingEmail) {
                    Alert(
                        title: Text(title),
                        message: Text(message)
                    )
                }
            }.frame(height: 25)
        }
    }
}

struct passwordResetView_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        passwordResetView(loginviewmodel)
            .background(Color.accent)
    }
}

