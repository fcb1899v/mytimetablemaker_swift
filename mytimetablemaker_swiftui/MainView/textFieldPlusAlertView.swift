//
//  textFieldPlusAlertView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/07.
//

import SwiftUI

struct textFieldPlusAlertView: UIViewControllerRepresentable {
    
    @Binding var text: String
    @Binding var isShowingAlert: Bool
    @Binding var isShowingNextAlert: Bool

    let title: String
    let message: String
    let key: String
    let addtitle: String
    
    let placeholder = Hint.maxchar.rawValue.localized
    let isSecureTextEntry = false
    let cancelButtonTitle = Action.cancel.rawValue.localized
    let registerButtonTitle = Action.ok.rawValue.localized

    func makeUIViewController(context: UIViewControllerRepresentableContext<textFieldPlusAlertView>) -> some UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<textFieldPlusAlertView>) {
        
        guard context.coordinator.alert == nil else {
            return
        }
        
        if !isShowingAlert {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        context.coordinator.alert = alert
        
        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = key.userDefaultsValue("")
            textField.delegate = context.coordinator
            textField.isSecureTextEntry = isSecureTextEntry
            textField.textAlignment = .center
        }
        
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            alert.dismiss(animated: true) {
                self.text = UserDefaults.standard.string(forKey: key) ?? ""
                isShowingAlert = false
            }
        })

        alert.addAction(UIAlertAction(title: registerButtonTitle, style: .default) { _ in
            if let textField = alert.textFields?.first,
               let text = textField.text
            {
                alert.dismiss(animated: true) {
                    if text != "" {
                        UserDefaults.standard.set(text, forKey: key)
                    }
                    isShowingAlert = false
                }
            } else {
                alert.dismiss(animated: true) {
                    isShowingAlert = false
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: addtitle, style: .destructive) { _ in
            if let textField = alert.textFields?.first,
               let text = textField.text
            {
                alert.dismiss(animated: true) {
                    if text != "" {
                        UserDefaults.standard.set(text, forKey: key)
                    }
                    isShowingAlert = false
                    isShowingNextAlert = true
                }
            } else {
                alert.dismiss(animated: true) {
                    isShowingAlert = false
                    isShowingNextAlert = true
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
    
    func makeCoordinator() -> textFieldPlusAlertView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        var alert: UIAlertController?
        var view: textFieldPlusAlertView
        
        init(_ view: textFieldPlusAlertView) {
            self.view = view
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let text = textField.text as NSString? {
                self.view.text = text.replacingCharacters(in: range, with: string)
            } else {
                self.view.text = ""
            }
            return true
        }
    }
}
