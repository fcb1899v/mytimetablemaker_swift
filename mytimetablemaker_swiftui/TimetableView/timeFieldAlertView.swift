//
//  timeFieldAlertView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/07.
//

import SwiftUI

struct timeFieldAlertView: UIViewControllerRepresentable {
    
    @Binding var text: String
    @Binding var isShowingAlert: Bool
    @Binding var isShowingPicker: Bool

    let title: String
    let message: String
    let key: String
    let maxnumber: Int
    
    let placeholder = Hint.to59min.rawValue.localized
    let isSecureTextEntry = false
    let cancelButtonTitle = Action.cancel.rawValue.localized
    let addButtonTitle = Action.add.rawValue.localized
    let deleteButtonTitle = Action.delete.rawValue.localized
    let copyButtonTitle = DialogTitle.copytime.rawValue.localized
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<timeFieldAlertView>) -> some UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<timeFieldAlertView>) {
        
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
            textField.text = ""
            textField.delegate = context.coordinator
            textField.isSecureTextEntry = isSecureTextEntry
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            alert.dismiss(animated: true) {
                isShowingAlert = false
            }
        })

        alert.addAction(UIAlertAction(title: addButtonTitle, style: .default) { _ in
            if let textField = alert.textFields?.first,
               let text = textField.text,
               let inttext = Int(text)
            {
                alert.dismiss(animated: true) {
                    if inttext >= 0 && inttext <= maxnumber {
                        UserDefaults.standard.set(text.addTimeFromTimetable(key), forKey: key)
                    }
                    isShowingAlert = true
                }
            } else {
                alert.dismiss(animated: true) {
                    isShowingAlert = false
                }
            }
        })

        alert.addAction(UIAlertAction(title: deleteButtonTitle, style: .default) { _ in
            if let textField = alert.textFields?.first,
               let text = textField.text,
               let inttext = Int(text)
            {
                alert.dismiss(animated: true) {
                    if inttext >= 0 && inttext <= maxnumber {
                        UserDefaults.standard.set(text.deleteTimeFromTimetable(key), forKey: key)
                    }
                    isShowingAlert = true
                }
            } else {
                alert.dismiss(animated: true) {
                    isShowingAlert = false
                }
            }
        })

        alert.addAction(UIAlertAction(title: copyButtonTitle, style: .destructive) { _ in
            alert.dismiss(animated: true) {
                isShowingAlert = false
                isShowingPicker = true
            }
        })
        
        DispatchQueue.main.async {
            uiViewController.present(alert, animated: true, completion: {
                isShowingAlert = false
                context.coordinator.alert = nil
            })
        }
    }
    
    func makeCoordinator() -> timeFieldAlertView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        var alert: UIAlertController?
        var view: timeFieldAlertView
        
        init(_ view: timeFieldAlertView) {
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
