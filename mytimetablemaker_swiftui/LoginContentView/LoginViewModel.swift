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
@MainActor
final class LoginViewModel : ObservableObject {

    // MARK: - Published Properties
    // User input and authentication state
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirm: String = ""
    @Published var isTermsAgree = false
    @Published var resetEmail: String = ""
    @Published var isLoading = false
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
        isShowMessage = false
        alertTitle = ValidationMessages.logoutErrorTitle
        alertMessage = ""
        if (isLoginSuccess) {
            isLoading = true
            do {
                try Auth.auth().signOut()
                alertTitle = ValidationMessages.logoutSuccess
                UserDefaults.standard.set(false, forKey: "Login")
                isLoginSuccess = false
                isLoading = false
                isShowMessage = true
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
        let validation = ValidationMessages.loginValidationMessage(email: email, password: password)
        alertTitle = validation.title
        alertMessage = validation.message
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
                Task { @MainActor in
                    if let user = authResult?.user {
                        if user.isEmailVerified {
                            alertTitle = ValidationMessages.loginSuccess
                            UserDefaults.standard.set(true, forKey: "Login")
                            isLoginSuccess = true
                            isLoading = false
                            isShowMessage = true
                            print("🔍 Login Debug: Login successful, isLoginSuccess = \(isLoginSuccess)")
                        } else {
                            alertTitle = ValidationMessages.notVerifiedAccount
                            alertMessage = ValidationMessages.confirmEmail
                            isLoading = false
                            isShowMessage = true
                            print("🔍 Login Debug: Email not verified")
                        }
                    } else {
                        if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                            alertTitle = ValidationMessages.loginErrorTitle
                            alertMessage = errorCode.localizedMessage
                            isLoading = false
                            isShowMessage = true
                        }
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
        let validation = ValidationMessages.signUpValidationMessage(
            email: email,
            password: password,
            passwordConfirm: passwordConfirm,
            isTermsAgree: isTermsAgree
        )
        alertTitle = validation.title
        alertMessage = validation.message
        isValidSignUp = (alertTitle.isEmpty && alertMessage.isEmpty)
    }

    // MARK: - Sign Up Authentication
    // Creates new user account with Firebase Auth and sends verification email
    func signUp() {
        if isValidSignUp {
            alertTitle = ""
            alertMessage = ""
            isSignUpSuccess = false
            isLoading = true
            isShowMessage = false
            Auth.auth().createUser(withEmail: email, password: password) { [self] authResult, error in
                Task { @MainActor in
                    if let user = authResult?.user {
                        do {
                            try await user.sendEmailVerification()
                            alertTitle = ValidationMessages.signUpSuccess
                            alertMessage = ValidationMessages.verificationEmailSent
                            isSignUpSuccess = true
                            isLoading = false
                            isShowMessage = true
                        } catch {
                            alertTitle = ValidationMessages.signUpErrorTitle
                            alertMessage = ValidationMessages.verificationEmailNotSent
                            isLoading = false
                            isShowMessage = true
                        }
                    } else {
                        if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                            alertTitle = ValidationMessages.signUpErrorTitle
                            alertMessage = errorCode.localizedMessage
                            isLoading = false
                            isShowMessage = true
                        }
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
        if (resetEmail.isValidEmail) {
            alertTitle = ""
            alertMessage = ""
            isLoading = true
            isShowMessage = false
            Auth.auth().sendPasswordReset(withEmail: resetEmail) { [self] error in
                Task { @MainActor in
                    if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                        alertTitle = ValidationMessages.passwordResetErrorTitle
                        alertMessage = errorCode == .userNotFound ? ValidationMessages.incorrectEmail : 
                                       errorCode.localizedMessage
                        isLoading = false
                        isShowMessage = true
                    } else {
                        alertTitle = ValidationMessages.passwordResetTitle
                        alertMessage = ValidationMessages.passwordResetSent
                        isLoading = false
                        isShowMessage = true
                    }
                }
            }
        } else {
            alertTitle = ValidationMessages.inputError
            alertMessage = ValidationMessages.enterEmailAgain
            isLoading = false
            isShowMessage = true
        }
    }

    // MARK: - Terms Agreement Toggle
    // Toggles terms agreement state with haptic feedback
    func toggle() {
        isTermsAgree = !isTermsAgree
        // Suppress haptic feedback to avoid console errors
        // UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        signUpCheck()
    }
    
    // MARK: - Account Deletion
    // Deletes current user account from Firebase Auth
    func delete() {
        isShowMessage = false
        isLoading = true
        alertTitle = ValidationMessages.deleteAccountErrorTitle
        alertMessage = ValidationMessages.accountNotDeleted
        Auth.auth().currentUser?.delete { [self] error in
            Task { @MainActor in
                if error != nil {
                    isLoading = false
                    isShowMessage = true
                } else {
                    alertTitle = ValidationMessages.deleteAccountSuccess
                    alertMessage = ValidationMessages.accountDeletedSuccess
                    logOut()
                }
            }
        }
    }
}
