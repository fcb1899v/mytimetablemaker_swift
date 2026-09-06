//
//  AccountExtensions.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2025/09/03.
//

import Foundation
import FirebaseAuth

// MARK: - String Extensions for Account Validation
// Extensions for email and password validation
extension String {
    
    // MARK: - Email Validation
    // Validates email format using regex pattern
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    // MARK: - Password Validation
    // Validates password strength (minimum 8 characters with special characters)
    var isValidPassword: Bool {
        let passwordRegex = "^(?=.*[A-Za-z0-9])(?=.*[!@#$&~]).{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: self)
    }
    
    // MARK: - Password Comparison
    // Checks if password matches confirmation password
    func isMatching(_ confirmPassword: String) -> Bool {
        return self.compare(confirmPassword) == .orderedSame
    }
}

// MARK: - Firebase Auth Extensions
// Helper extensions for Firebase Authentication user management
extension Auth {
    
    // MARK: - Current User ID
    // Safely retrieves current authenticated user ID, returns nil if not logged in
    var currentUserID: String? {
        return currentUser?.uid
    }
    
    // MARK: - Authentication State
    // Checks if user is currently authenticated
    var isAuthenticated: Bool {
        return currentUser != nil
    }
}

// MARK: - AuthErrorCode Extensions
// Helper extensions for Firebase Authentication error handling
// Firebase 11 folded AuthErrorCode.Code into AuthErrorCode itself
extension AuthErrorCode {
    
    // MARK: - Localized Error Message
    // Converts Firebase Auth error code to localized user-friendly message
    var localizedMessage: String {
        switch self {
        case .invalidEmail:
            return "Incorrect email format".localized
        case .userNotFound:
            return "Incorrect email or password".localized
        case .wrongPassword:
            return "Incorrect email or password".localized
        case .userDisabled:
            return "This account is disabled".localized
        case .emailAlreadyInUse:
            return "This email has already been registered".localized
        case .weakPassword:
            return "Incorrect password format".localized
        default:
            return "Authentication error occurred".localized
        }
    }
}

// MARK: - Validation Message Helpers
// Helper functions for generating validation error messages
struct ValidationMessages {
    
    // MARK: - Common Messages
    // Standard validation error messages for form inputs
    static let inputError = "Input error".localized
    static let checkError = "Check error".localized
    static let enterEmail = "Enter your email".localized
    static let enterPassword = "Enter your password".localized
    static let enterConfirmPassword = "Enter your confirm password".localized
    static let incorrectEmailFormat = "Incorrect email format".localized
    static let incorrectPasswordFormat = "Incorrect password format".localized
    static let passwordMismatch = "Confirm password don't match".localized
    static let checkTerms = "Check the terms and privacy policy".localized
    static let enterEmailAgain = "Enter your email again".localized
    
    // MARK: - Success Messages
    // Success messages for authentication operations
    static let loginSuccess = "Login successfully".localized
    static let logoutSuccess = "Logged out successfully".localized
    static let signUpSuccess = "Signup successfully".localized
    static let verificationEmailSent = "Verification email Sent successfully".localized
    static let passwordResetSent = "Password reset email Sent successfully".localized
    static let deleteAccountSuccess = "Delete account successfully".localized
    static let accountDeletedSuccess = "Account deleted successfully".localized
    
    // MARK: - Error Titles
    // Error titles for authentication operations
    static let loginErrorTitle = "Login error".localized
    static let logoutErrorTitle = "Logout error".localized
    static let signUpErrorTitle = "Signup error".localized
    static let passwordResetErrorTitle = "Password reset error".localized
    static let deleteAccountErrorTitle = "Delete account error".localized
    
    // MARK: - Error Messages
    // Error messages for authentication operations
    static let notVerifiedAccount = "Not verified account".localized
    static let confirmEmail = "Confirm your email".localized
    static let verificationEmailNotSent = "Verification email could not be sent".localized
    static let accountNotDeleted = "Account could not be deleted".localized
    static let passwordResetTitle = "Password Reset".localized
    static let incorrectEmail = "Incorrect email".localized
    
    // MARK: - Login Validation
    // Generates validation messages for login form
    static func loginValidationMessage(email: String, password: String) -> (title: String, message: String) {
        if email.isEmpty {
            return (inputError, enterEmail)
        } else if !email.isValidEmail {
            return (inputError, incorrectEmailFormat)
        } else if password.isEmpty {
            return (inputError, enterPassword)
        } else if !password.isValidPassword {
            return (inputError, incorrectPasswordFormat)
        }
        return ("", "")
    }
    
    // MARK: - Sign Up Validation
    // Generates validation messages for sign up form
    static func signUpValidationMessage(
        email: String,
        password: String,
        passwordConfirm: String,
        isTermsAgree: Bool
    ) -> (title: String, message: String) {
        if !isTermsAgree {
            return (checkError, checkTerms)
        } else if email.isEmpty {
            return (inputError, enterEmail)
        } else if !email.isValidEmail {
            return (inputError, incorrectEmailFormat)
        } else if password.isEmpty {
            return (inputError, enterPassword)
        } else if passwordConfirm.isEmpty {
            return (inputError, enterConfirmPassword)
        } else if !password.isValidPassword {
            return (inputError, incorrectPasswordFormat)
        } else if !password.isMatching(passwordConfirm) {
            return (inputError, passwordMismatch)
        }
        return ("", "")
    }
}

