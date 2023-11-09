//
//  LogOutButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2023/10/09.
//

import SwiftUI
import FirebaseAuth

struct LogOutButton: View {
    
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
            Text("Logout".localized).foregroundColor(.black)
        }
        .alert("Logout".localized, isPresented: $isShowAlert) {
            //Ok button
            Button(textOk, role: .none){
                myLogin.logOut()
                isShowAlert = false
            }
            //Cancel button
            Button(textCancel, role: .cancel){
                isShowAlert = false
            }
        } message: {
            Text("Logout your account?".localized)
        }
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

struct LogOutButton_Previews: PreviewProvider {
    static var previews: some View {
        let myLogin = MyLogin()
        LogOutButton(myLogin: myLogin)
    }
}


