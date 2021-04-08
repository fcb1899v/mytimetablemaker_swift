//
//  LoginViewModel.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/15.
//

import Foundation
import SwiftUI
import FirebaseAuth

/// ログイン画面のViewModel
class LoginViewModel : ObservableObject {

    @Environment(\.presentationMode) var presentationMode

    enum AlertType {
        case empty
        case select
        case complete
    }

    /// メールアドレス
    @Published var email: String = ""
    /// パスワード
    @Published var password: String = ""
    /// パスワード確認
    @Published var passwordconfirm: String = ""
    /// アラートタイトル
    @Published var title: String = ""
    /// アラートメッセージ
    @Published var message: String = ""
    /// 入力されているか
    @Published var alertType: AlertType = .empty
    /// エラー状態かどうか
    @Published var isError = true
    /// 設定画面へ移動するかどうか
    @Published var isMoveSettings = false
    /// 利用規約およびプライバシーポリシーの確認
    @Published var isTermsAgree = false

    func login() {
        title = ""
        message = ""
        isError = true
        if email.isEmpty {
            title = "Login error".localized
            message = "Enter your email".localized
        } else if password.isEmpty {
            title = "Login error".localized
            message = "Enter your password".localized
        } else {
            loginAuth()
        }
    }

    func loginAuth() {
        Auth.auth().signIn(withEmail: email, password: password) { [self] authResult, error in
            if let user = authResult?.user {
                if user.isEmailVerified {
                    self.title = "Login successfully".localized
                    self.isError = false
                } else {
                    self.title = "Not verified account".localized
                    self.message = "Check your email".localized
                }
            } else {
                if let error = error as NSError?, let errorCode = AuthErrorCode(rawValue: error.code) {
                    title = "Login error".localized
                    switch errorCode {
                        case .invalidEmail: self.message = "Incorrect email format".localized
                        case .userNotFound: self.message = "Incorrect email or password".localized
                        case .wrongPassword: self.message = "Incorrect email or password".localized
                        case .userDisabled: self.message = "This account is disabled".localized
                        default: self.message = error.domain
                    }
                }
            }
        }
    }

    func signUpEmpty() {
        title = ""
        message = ""
        isError = true
        alertType = .empty
        if email.isEmpty {
            title = "Signup error".localized
            message = "Enter your email".localized
        } else if password.isEmpty {
            title = "Signup error".localized
            message = "Enter your password".localized
        } else if passwordconfirm.isEmpty {
            title = "Signup error".localized
            message = "Enter your confirm password".localized
        } else if password.compare(passwordconfirm) != .orderedSame {
            title = "Signup error".localized
            message = "Confirm password don't match".localized
        } else {
            alertType = .select
        }
    }

    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user {
                user.sendEmailVerification(completion: { error in
                    self.title = "Signup successfully".localized
                    self.message = "Verification email Sent successfully".localized
                    self.isError = false
                })
            } else {
                if let error = error as NSError?, let errorCode = AuthErrorCode(rawValue: error.code) {
                    self.title = "Signup error".localized
                    switch errorCode {
                        case .invalidEmail: self.message = "Incorrect email format".localized
                        case .emailAlreadyInUse: self.message = "This email has already been registered".localized
                        case .weakPassword: self.message = "Password must be at least 6 characters".localized
                        default: self.message = error.domain
                    }
                }
            }
        }
    }
}
