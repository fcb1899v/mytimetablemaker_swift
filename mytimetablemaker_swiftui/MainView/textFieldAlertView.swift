//
//  textFieldAlertView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/07.
//

import SwiftUI

struct textFieldAlertView: UIViewControllerRepresentable {
    
    @Binding var text: String
    @Binding var isShowingAlert: Bool
    
    let title: String
    let message: String
    let key: String
    let placeholder = Hint.maxchar.rawValue
    let isSecureTextEntry = false

    let leftButtonTitle = "Cancel".localized
    let rightButtonTitle = "OK".localized
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<textFieldAlertView>) -> some UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<textFieldAlertView>) {
        
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
            textField.text = text
            textField.delegate = context.coordinator
            textField.isSecureTextEntry = isSecureTextEntry
            textField.textAlignment = .center
        }
        
        alert.addAction(UIAlertAction(title: leftButtonTitle, style: .cancel) { _ in
            alert.dismiss(animated: true) {
                isShowingAlert = false
            }
        })

        alert.addAction(UIAlertAction(title: rightButtonTitle, style: .default) { _ in
            if let textField = alert.textFields?.first, let text = textField.text {
                self.text = text
            }
            alert.dismiss(animated: true) {
                isShowingAlert = false
                if let textField = alert.textFields?.first, let text = textField.text {
                    UserDefaults.standard.set(text, forKey: key)
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
    
    func makeCoordinator() -> textFieldAlertView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        var alert: UIAlertController?
        var view: textFieldAlertView
        
        init(_ view: textFieldAlertView) {
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
