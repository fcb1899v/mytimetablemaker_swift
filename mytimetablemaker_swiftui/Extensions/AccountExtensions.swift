//
//  AccountExtensions.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2025/09/03.
//

import Foundation

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

