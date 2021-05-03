//
//  emailPlusTextField.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/12.
//

import SwiftUI

struct emailPlusTextField: View {
    
    @ObservedObject private var loginviewmodel: LoginViewModel
    
    init(
        _ loginviewmodel: LoginViewModel
    ) {
        self.loginviewmodel = loginviewmodel
    }

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email".localized, text: $loginviewmodel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(Color.white)
                .frame(width: .loginbuttonwidth)
            SecureField("Password".localized, text: $loginviewmodel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(Color.white)
                .frame(width: .loginbuttonwidth)
            SecureField("Confirm Password".localized, text: $loginviewmodel.passwordconfirm)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(Color.white)
                .frame(width: .loginbuttonwidth)
        }
    }
}

struct emailPlusTextField_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        emailPlusTextField(loginviewmodel)
    }
}

