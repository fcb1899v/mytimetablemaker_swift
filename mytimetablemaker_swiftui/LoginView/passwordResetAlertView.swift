//
//  passwordResetAlertView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/18.
//

import SwiftUI
import FirebaseAuth

struct passwordResetAlertView: UIViewControllerRepresentable {
    
    @Binding var email: String
    @Binding var isShowingAlert: Bool
    @Binding var isSendingEmail: Bool
    @Binding var title: String
    @Binding var message: String

    let resettitle = "Password Reset".localized
    let resetmessage = "Reset your password?".localized
    let placeholder = Hint.email.rawValue.localized
    let isSecureTextEntry = false
    let cancelButtonTitle = Action.cancel.rawValue.localized
    let registerButtonTitle = Action.ok.rawValue.localized

    func makeUIViewController(context: UIViewControllerRepresentableContext<passwordResetAlertView>) -> some UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<passwordResetAlertView>) {
        
        guard context.coordinator.alert == nil else {
            return
        }
        
        if !isShowingAlert {
            return
        }
        
        let alert = UIAlertController(title: resettitle, message: resetmessage, preferredStyle: .alert)
        context.coordinator.alert = alert
        
        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = ""
            textField.delegate = context.coordinator
            textField.isSecureTextEntry = isSecureTextEntry
            textField.textAlignment = .center
        }
        
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            alert.dismiss(animated: true) {
                isShowingAlert = false
            }
        })

        alert.addAction(UIAlertAction(title: registerButtonTitle, style: .default) { _ in
            if let textField = alert.textFields?.first, let email = textField.text {
                alert.dismiss(animated: true) {
                    sendingResetPasswordEmail(email)
                    isShowingAlert = false
                    isSendingEmail = true
                }
            }
        })

        
        DispatchQueue.main.async {
            uiViewController.present(alert, animated: true, completion: {
                isShowingAlert = false
                context.coordinator.alert = nil
            })
        }
    }
    
    func sendingResetPasswordEmail(_ email: String) {
        title = ""
        message = ""
        if email.isEmpty {
            message = "Enter your email".localized
        } else {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error as NSError?, let errorCode = AuthErrorCode(rawValue: error.code) {
                    title = "Password reset error".localized
                    switch errorCode {
                        case .invalidEmail: message = "Incorrect email format".localized
                        case .userNotFound: message = "Incorrect email or password".localized
                        case .userDisabled: message = "This account is disabled".localized
                        default: message = "Password reset email could not be sent".localized
                    }
                } else {
                    title = "Password Reset".localized
                    message = "Password reset email Sent successfully".localized
                }
            }
        }
    }
    
    
    func makeCoordinator() -> passwordResetAlertView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        var alert: UIAlertController?
        var view: passwordResetAlertView
        
        init(_ view: passwordResetAlertView) {
            self.view = view
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let text = textField.text as NSString? {
                self.view.email = text.replacingCharacters(in: range, with: string)
            } else {
                self.view.email = ""
            }
            return true
        }
    }
}
