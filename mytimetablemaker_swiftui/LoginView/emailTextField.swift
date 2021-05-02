//
//  emailTextField.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/04/03.
//

import SwiftUI

struct emailTextField: View {
    
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
                .frame(width: UIScreen.screenWidth * 0.8)
            
            SecureField("Password".localized, text: $loginviewmodel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(Color.white)
                .frame(width: UIScreen.screenWidth * 0.8)
        }
    }
}

struct emailTextField_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        emailTextField(loginviewmodel)
    }
}

