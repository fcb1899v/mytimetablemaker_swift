//
//  LoginViewModel.swift
//  mytimetablemakers_swiftui
//
//  Created by Nakajima Masao on 2021/03/15.
//

import Foundation
import SwiftUI
import FirebaseAuth

// MARK: - Authentication View Model
// Handles user authentication, registration, and account management
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

    // MARK: - Logout Function
    // Signs out current user and updates login state
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
    
    // MARK: - Login Validation
    // Validates login form inputs before authentication
    func loginCheck() {
        alertTitle = 
            (email.isEmpty || !email.isValidEmail || password.isEmpty || !password.isValidPassword) ? "Input error".localized: 
            ""
        alertMessage = 
            email.isEmpty ? "Enter your email".localized :
            !email.isValidEmail ? "Incorrect email format".localized :
            password.isEmpty ? "Enter your password".localized :
            !password.isValidPassword ? "Incorrect password format".localized :
            ""
        isValidLogin = (alertTitle.isEmpty && alertMessage.isEmpty)
    }
    
    // MARK: - Login Authentication
    // Authenticates user with Firebase Auth
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
                        alertMessage = 
                            errorCode == .invalidEmail ? "Incorrect email format".localized :
                            errorCode == .userNotFound ? "Incorrect email or password".localized :
                            errorCode == .wrongPassword ? "Incorrect email or password".localized :
                            errorCode == .userDisabled ? "This account is disabled".localized :
                            ""
                        isLoading = false
                        isShowMessage = true
                    }
                }
            }
        } else {
            isShowMessage = true
        }
    }

    // MARK: - Sign Up Validation
    // Validates sign up form inputs including terms agreement
    func signUpCheck() {
        alertTitle = 
            !isTermsAgree ? "Check error".localized:
            (email.isEmpty || !email.isValidEmail || password.isEmpty || passwordConfirm.isEmpty || !password.isValidPassword || !password.isMatching(passwordConfirm)) ? "Input error".localized:
            ""
        alertMessage = 
            !isTermsAgree ? "Check the terms and privacy policy".localized:
            email.isEmpty ? "Enter your email".localized:
            !email.isValidEmail ? "Incorrect email format".localized:
            password.isEmpty ? "Enter your password".localized:
            passwordConfirm.isEmpty ? "Enter your confirm password".localized:
            !password.isValidPassword ? "Incorrect password format".localized:
            !password.isMatching(passwordConfirm) ? "Confirm password don't match".localized:
            ""
        isValidSignUp = (alertTitle.isEmpty && alertMessage.isEmpty)
    }

    // MARK: - Sign Up Authentication
    // Creates new user account with Firebase Auth and sends verification email
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
                        alertMessage = 
                            errorCode == .invalidEmail ? "Incorrect email format".localized :
                            errorCode == .emailAlreadyInUse ? "This email has already been registered".localized :
                            errorCode == .weakPassword ? "Incorrect password format".localized :
                            error.domain
                        isLoading = false
                        isShowMessage = true
                    }
                }
            }
        } else {
            isShowMessage = true
        }
    }
    
    // MARK: - Password Reset
    // Sends password reset email to user's email address
    func reset() {
        isShowAlert = false
        if (resetEmail.isValidEmail) {
            alertTitle = ""
            alertMessage = ""
            isLoading = true
            isShowMessage = false
            Auth.auth().sendPasswordReset(withEmail: resetEmail) { [self] error in
                if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                    alertTitle = "Password reset error".localized
                    alertMessage = 
                        errorCode == .invalidEmail ? "Incorrect email format".localized :
                        errorCode == .userNotFound ? "Incorrect email".localized :
                        errorCode == .userDisabled ? "This account is disabled".localized :
                        "Password reset email could not be sent".localized
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

    // MARK: - Terms Agreement Toggle
    // Toggles terms agreement state with haptic feedback
    func toggle() {
        isTermsAgree = !isTermsAgree
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        signUpCheck()
    }
    
    // MARK: - Account Deletion
    // Deletes current user account from Firebase Auth
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
