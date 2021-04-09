//
//  numberFieldAlertView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/07.
//

import SwiftUI

struct numberFieldAlertView: UIViewControllerRepresentable {
    
    @Binding var text: String
    @Binding var isShowingAlert: Bool
    
    let title: String
    let message: String
    let key: String
    let maxnumber: Int
    
    let placeholder = Hint.to99min.rawValue.localized
    let isSecureTextEntry = false
    let leftButtonTitle = "Cancel".localized
    let rightButtonTitle = "OK".localized
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<numberFieldAlertView>) -> some UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<numberFieldAlertView>) {
        
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
            textField.keyboardType = .numberPad
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
                if let inttext = Int(text)  {
                    if inttext >= 0 && inttext <= maxnumber {
                        UserDefaults.standard.set(text, forKey: key)
                    }
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
    
    func makeCoordinator() -> numberFieldAlertView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        var alert: UIAlertController?
        var view: numberFieldAlertView
        
        init(_ view: numberFieldAlertView) {
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
