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
class MyLogin : ObservableObject {

    @Environment(\.presentationMode) var presentationMode
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirm: String = ""
    @Published var isTermsAgree = false
    @Published var resetEmail: String = ""
    @Published var isLoading = false
    @Published var isShowAlert = false
    @Published var isShowMessage = false
    @Published var alertTitle: String = "Input error".localized
    @Published var alertMessage: String = "Enter your email".localized
    @Published var isValidLogin: Bool = false
    @Published var isValidSignUp: Bool = false
    @Published var isLoginSuccess = "Login".userDefaultsBool(false)
    @Published var isSignUpSuccess = false

    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
     }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z0-9])(?=.*[!@#$&~]).{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    func logOut() {
        isShowAlert = false
        isShowMessage = false
        alertTitle = "Logout error".localized
        alertMessage = ""
        if (isLoginSuccess) {
            isLoading = true
            do {
                try Auth.auth().signOut()
                alertTitle = "Logged out successfully".localized
                UserDefaults.standard.set(false, forKey: "Login")
                isLoginSuccess = false
                isLoading = false
                isShowMessage = true
                presentationMode.wrappedValue.dismiss()
            } catch {
                UserDefaults.standard.set(true, forKey: "Login")
                isLoginSuccess = true
                isLoading = false
                isShowMessage = true
            }
        } else {
            isShowMessage = true
        }
    }
    
    func loginCheck() {
        alertTitle = ""
        alertMessage = ""
        isValidLogin = false
        if email.isEmpty {
            alertTitle = "Input error".localized
            alertMessage = "Enter your email".localized
        } else if !isValidEmail(email) {
            alertTitle = "Input error".localized
            alertMessage = "Incorrect email format".localized
        } else if password.isEmpty {
            alertTitle = "Input error".localized
            alertMessage = "Enter your password".localized
        } else if !isValidPassword(password) {
            alertTitle = "Input error".localized
            alertMessage = "Incorrect password format".localized
        } else {
            isValidLogin = true
        }
    }
    
    func login() {
        isShowMessage = false
        if isValidLogin {
            alertTitle = ""
            alertMessage = ""
            isLoginSuccess = false
            isLoading = true
            Auth.auth().signIn(withEmail: email, password: password) { [self] authResult, error in
                if let user = authResult?.user {
                    if user.isEmailVerified {
                        alertTitle = "Login successfully".localized
                        UserDefaults.standard.set(true, forKey: "Login")
                        isLoginSuccess = true
                        isLoading = false
                        isShowMessage = true
                    } else {
                        alertTitle = "Not verified account".localized
                        alertMessage = "Confirm your email".localized
                        isLoading = false
                        isShowMessage = true
                    }
                } else {
                    if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                        alertTitle = "Login error".localized
                        switch errorCode {
                            case .invalidEmail: alertMessage = "Incorrect email format".localized
                            case .userNotFound: alertMessage = "Incorrect email or password".localized
                            case .wrongPassword: alertMessage = "Incorrect email or password".localized
                            case .userDisabled: alertMessage = "This account is disabled".localized
                            default: alertMessage = ""
                        }
                        isLoading = false
                        isShowMessage = true
                    }
                }
            }
        } else {
            isShowMessage = true
        }
    }

    func signUpCheck() {
        alertTitle = ""
        alertMessage = ""
        isValidSignUp = false
        if !isTermsAgree {
            alertTitle = "Check error".localized
            alertMessage = "Check the terms and privacy policy".localized
        } else if email.isEmpty {
            alertTitle = "Input error".localized
            alertMessage = "Enter your email".localized
        } else if !isValidEmail(email) {
            alertTitle = "Input error".localized
            alertMessage = "Incorrect email format".localized
        } else if password.isEmpty {
            alertTitle = "Input error".localized
            alertMessage = "Enter your password".localized
        } else if passwordConfirm.isEmpty {
            alertTitle = "Input error".localized
            alertMessage = "Enter your confirm password".localized
        } else if !isValidPassword(password) {
            alertTitle = "Input error".localized
            alertMessage = "Incorrect password format".localized
        } else if password.compare(passwordConfirm) != .orderedSame {
            alertTitle = "Input error".localized
            alertMessage = "Confirm password don't match".localized
        } else {
            isValidSignUp = true
        }
    }

    func signUp() {
        isShowAlert = false
        if isValidSignUp {
            alertTitle = ""
            alertMessage = ""
            isSignUpSuccess = false
            isLoading = true
            isShowMessage = false
            Auth.auth().createUser(withEmail: email, password: password) { [self] authResult, error in
                if let user = authResult?.user {
                    user.sendEmailVerification(completion: { [self] error in
                        alertTitle = "Signup successfully".localized
                        alertMessage = "Verification email Sent successfully".localized
                        isSignUpSuccess = true
                        isLoading = false
                        isShowMessage = true
                    })
                } else {
                    if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                        alertTitle = "Signup error".localized
                        switch errorCode {
                            case .invalidEmail: alertMessage = "Incorrect email format".localized
                            case .emailAlreadyInUse: alertMessage = "This email has already been registered".localized
                            case .weakPassword: alertMessage = "Incorrect password format".localized
                            default: alertMessage = error.domain
                        }
                        isLoading = false
                        isShowMessage = true
                    }
                }
            }
        } else {
            isShowMessage = true
        }
    }
    
    func reset() {
        isShowAlert = false
        if (isValidEmail(resetEmail)) {
            alertTitle = ""
            alertMessage = ""
            isLoading = true
            isShowMessage = false
            Auth.auth().sendPasswordReset(withEmail: resetEmail) { [self] error in
                if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                    alertTitle = "Password reset error".localized
                    switch errorCode {
                        case .invalidEmail: alertMessage = "Incorrect email format".localized
                        case .userNotFound: alertMessage = "Incorrect email".localized
                        case .userDisabled: alertMessage = "This account is disabled".localized
                        default: alertMessage = "Password reset email could not be sent".localized
                    }
                    isLoading = false
                    isShowMessage = true
                } else {
                    alertTitle = "Password Reset".localized
                    alertMessage = "Password reset email Sent successfully".localized
                    isLoading = false
                    isShowMessage = true
                }
            }
        } else {
            alertTitle = "Input error".localized
            alertMessage = "Enter your email again".localized
            isLoading = false
            isShowMessage = true
        }
    }

    func toggle() {
        isTermsAgree = !isTermsAgree
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        signUpCheck()
    }
    
    func delete() {
        isShowAlert = false
        isShowMessage = false
        isLoading = true
        alertTitle = "Delete account error".localized
        alertMessage = "Account could not be deleted".localized
        Auth.auth().currentUser?.delete { [self] error in
            if error != nil {
                isLoading = false
                isShowMessage = true
            } else {
                alertTitle = "Delete account successfully".localized
                alertMessage = "Account deleted successfully".localized
                logOut()
            }
        }
    }
}
