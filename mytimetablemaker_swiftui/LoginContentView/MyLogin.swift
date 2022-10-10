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

    enum AlertType {
        case empty
        case select
        case complete
    }

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirm: String = ""
    @Published var resetEmail: String = ""
    @Published var alertTitle: String = "Input error".localized
    @Published var alertMessage: String = "Enter your email".localized
    @Published var alertType: AlertType = .empty
    @Published var isShowMessage = false
    @Published var isLoading = false
    @Published var isLoginAlert = false
    @Published var isLoginSuccess = "Login".userDefaultsBool(false)
    @Published var isFistLogin = "firstlogin".userDefaultsBool(false)
    @Published var isSignUpAlert = false
    @Published var isSignUpSuccess = false
    @Published var isResetAlert = false
    @Published var isResetSuccess = false
    @Published var isTermsAgree = false
    
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
    
    func loginCheck() {
        alertTitle = ""
        alertMessage = ""
        alertType = .empty
        if email.isEmpty {
            alertTitle = "Input error".localized
            alertMessage = "Enter your email".localized
        } else if !isValidEmail(email) {
            alertTitle = "Input error".localized
            alertMessage = "Confirm your email".localized
        } else if password.isEmpty {
            alertTitle = "Input error".localized
            alertMessage = "Enter your password".localized
        } else if !isValidPassword(password) {
            alertTitle = "Input error".localized
            alertMessage = "Confirm your password".localized
        } else {
            alertType = .select
        }
    }
    
    func login() {
        isShowMessage = false
        if alertType == .select {
            alertTitle = ""
            alertMessage = ""
            isLoginSuccess = false
            isLoading = true
            Auth.auth().signIn(withEmail: email, password: password) { [self] authResult, error in
                if let user = authResult?.user {
                    if user.isEmailVerified {
                        alertTitle = "Login successfully".localized
                        alertType = .complete
                        isLoginSuccess = true
                        isShowMessage = true
                    } else {
                        alertTitle = "Not verified account".localized
                        alertMessage = "Check your email".localized
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
                        isShowMessage = true
                    }
                }
                isLoading = false
            }
        } else {
            isShowMessage = true
        }
    }

    func signUpCheck() {
        alertTitle = ""
        alertMessage = ""
        alertType = .empty
        if !isTermsAgree {
            alertTitle = "Check error".localized
            alertMessage = "Please check the terms and privacy policy".localized
        } else if email.isEmpty {
            alertTitle = "Input error".localized
            alertMessage = "Enter your email".localized
        } else if !isValidEmail(email) {
            alertTitle = "Input error".localized
            alertMessage = "Confirm your email".localized
        } else if password.isEmpty {
            alertTitle = "Input error".localized
            alertMessage = "Enter your password".localized
        } else if passwordConfirm.isEmpty {
            alertTitle = "Input error".localized
            alertMessage = "Enter your confirm password".localized
        } else if !isValidPassword(password) {
            alertTitle = "Input error".localized
            alertMessage = "Confirm your password".localized
        } else if password.compare(passwordConfirm) != .orderedSame {
            alertTitle = "Input error".localized
            alertMessage = "Confirm password don't match".localized
        } else {
            alertType = .select
        }
    }

    func signUp() {
        isShowMessage = false
        if alertType == .select {
            alertTitle = ""
            alertMessage = ""
            isSignUpSuccess = false
            isLoading = true
            Auth.auth().createUser(withEmail: email, password: password) { [self] authResult, error in
                if let user = authResult?.user {
                    user.sendEmailVerification(completion: { [self] error in
                        alertTitle = "Signup successfully".localized
                        alertMessage = "Verification email Sent successfully".localized
                        alertType = .empty
                        isSignUpSuccess = true
                        isShowMessage = true
                    })
                } else {
                    if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                        alertTitle = "Signup error".localized
                        switch errorCode {
                            case .invalidEmail: alertMessage = "Incorrect email format".localized
                            case .emailAlreadyInUse: alertMessage = "This email has already been registered".localized
                            case .weakPassword: alertMessage = "Password must be at least 6 characters".localized
                            default: alertMessage = error.domain
                        }
                        isShowMessage = true
                    }
                }
                isLoading = false
            }
        } else {
            isShowMessage = true
        }
    }
    
    func reset() {
        isShowMessage = false
        if (isValidEmail(resetEmail)) {
            alertTitle = ""
            alertMessage = ""
            isResetSuccess = false
            isLoading = true
            Auth.auth().sendPasswordReset(withEmail: resetEmail) { [self] error in
                if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                    alertTitle = "Password reset error".localized
                    switch errorCode {
                        case .invalidEmail: alertMessage = "Incorrect email format".localized
                        case .userNotFound: alertMessage = "Incorrect email".localized
                        case .userDisabled: alertMessage = "This account is disabled".localized
                        default: alertMessage = "Password reset email could not be sent".localized
                    }
                    isShowMessage = true
                } else {
                    alertTitle = "Password Reset".localized
                    alertMessage = "Password reset email Sent successfully".localized
                    alertType = .empty
                    isResetSuccess = true
                    isShowMessage = true
                    isResetAlert = false
                }
                isLoading = false
            }
        } else {
            alertTitle = "Input error".localized
            alertMessage = "Enter your email again".localized
            isShowMessage = true
        }
    }

   func toggle() -> Void {
       isTermsAgree = !isTermsAgree
       UIImpactFeedbackGenerator(style: .medium).impactOccurred()
       signUpCheck()
   }

}
