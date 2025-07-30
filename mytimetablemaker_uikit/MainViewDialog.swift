//
//  AlertDialog.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/09/11.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//
import Foundation
import UIKit

// MARK: - Main View Dialog Structure
// Manages dialog functionality for main view interactions
struct MainViewDialog: Display {
    var viewcontroller: UIViewController
    var goorback: String
    
    // MARK: - Initialization
    // Initialize with view controller and route direction
    init(_ viewcontroller: UIViewController, _ goorback: String) {
        self.viewcontroller = viewcontroller
        self.goorback = goorback
    }
    
    // MARK: - Constants
    // Localized action and unit strings
    let register = Action.register.rawValue.localized
    let cancel = Action.cancel.rawValue.localized
    let minites = Unit.minites.rawValue.localized
    let maxchar = Int("20".localized)!
}

// MARK: - Main View Dialog Extensions
extension MainViewDialog {
    
    // MARK: - Text Field Dialog Management
    // Displays text field dialog for input
    func textFieldDialog(_ label: UILabel, _ title: String, _ message: String, _ key: String) {
        let alert = textFieldAlert(title, message, key)
        alert.addAction(setTextFieldRegisterAction(label, (alert.textFields?.first)!, key))
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }
 
    // MARK: - Alert Configuration
    // Creates text field alert with configuration
    func textFieldAlert(_ title: String, _ message: String, _ key: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {
            (textfield: UITextField!) in
            textfield.text = key.userDefaultValue("")
            textfield.textAlignment = NSTextAlignment.center
            textfield.placeholder = Hint.maxchar.rawValue.localized
            textfield.keyboardType = .default})
        return alert
    }

    // MARK: - Text Field Action Handlers
    // Creates register action for text field input
    func setTextFieldRegisterAction(_ label: UILabel, _ textfield: UITextField, _ key: String) -> UIAlertAction {
        return UIAlertAction(title: register, style: .default) {
            (action: UIAlertAction) in
            if (textfield.text != nil || textfield.text != "" || textfield.text!.count <= maxchar) {
                label.text = textfield.text!
                UserDefaults.standard.set(textfield.text, forKey: key)
            }
        }
    }

    // MARK: - Cancel Action
    // Creates cancel action for dialogs
    func setCancelAction() -> UIAlertAction {
        return UIAlertAction(title: cancel, style: .cancel, handler: nil)
    }
    
    // MARK: - Station and Location Dialogs
    // Displays departure point setting dialog
    func departurePointTextFieldDialog(_ label: UILabel) {
        let title = DialogTitle.departplace.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "destination": "departurepoint"
        textFieldDialog(label, title, message, key)
    }

    // Displays departure station setting dialog
    func departStationTextFieldDialog(_ label: UILabel, _ keytag: String) {
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\("of departure station ".localized)\(keytag)"
        let key = "\(goorback)departstation\(keytag)"
        textFieldDialog(label, title, message, key)
    }
    
    // Displays arrival station setting dialog
    func arriveStationTextFieldDialog(_ label: UILabel, _ keytag: String) {
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\("of arrival station ".localized)\(keytag)"
        let key = "\(goorback)arrivestation\(keytag)"
        textFieldDialog(label, title, message, key)
    }
    
    // Displays destination setting dialog
    func destinationTextFieldDialog(_ label: UILabel) {
        let title = DialogTitle.destination.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
        textFieldDialog(label, title, message, key)
    }

    // MARK: - Line and Route Dialogs
    // Displays line name setting dialog with color option
    func lineTextFieldDialog(_ label: UILabel, _ stackview: UIStackView, _ keytag: String) {
        let title = DialogTitle.linename.rawValue.localized
        let message = "\("of ".localized)\("line ".localized)\(keytag)"
        let key = "\(goorback)linename\(keytag)"
        let alert = textFieldAlert(title, message, key)
        // Register button: save and display input text
        alert.addAction(setTextFieldRegisterAction(label, (alert.textFields?.first)!, key))
        // Cancel button: exit alert
        alert.addAction(setCancelAction())
        // Line color setting
        alert.addAction(setLineColorDialogAction(label, (alert.textFields?.first)!, stackview, keytag))
        viewcontroller.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Line Color Dialog Action
    // Creates line color dialog action
    func setLineColorDialogAction(_ label: UILabel, _ textfield: UITextField, _ stackview: UIStackView, _ keytag: String) -> UIAlertAction {
        let title = DialogTitle.linecolor.rawValue.localized
        let namekey = "\(goorback)linename\(keytag)"
        let colorkey = "\(goorback)linecolor\(keytag)"
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            if (textfield.text != nil || textfield.text != "") {
                UserDefaults.standard.set(textfield.text, forKey: namekey)
            }
            colorPickerDialog(label, stackview, colorkey, keytag)
        }
    }
  
    // MARK: - Color Register Action
    // Creates color register action
    func setColorRegisterAction(_ colortitle: String, _ color: Int, _ label: UILabel, _ stackview: UIStackView, _ colorkey: String) -> UIAlertAction {
        return UIAlertAction(title: colortitle, style: .default) {
            (action: UIAlertAction) in
                label.textColor = UIColor(color)
                stackview.backgroundColor = UIColor(color)
                UserDefaults.standard.set(color, forKey: colorkey)
        }
    }
    
    // MARK: - Color Picker Dialog
    // Displays color picker dialog
    func colorPickerDialog(_ label: UILabel, _ stackview: UIStackView, _ colorkey: String, _ keytag: String) {
//        if #available(iOS 14.0, *) {
//            let colorpicker = UIColorPickerViewController()
//            colorpicker.supportsAlpha = false
//            colorpicker.delegate = viewcontroller as? UIColorPickerViewControllerDelegate
//            label.textColor = colorpicker.selectedColor
//            stackview.backgroundColor = colorpicker.selectedColor
//            viewcontroller.present(colorpicker, animated: true, completion: nil)
//        } else {
//        }
        let title = DialogTitle.linecolor.rawValue.localized
        let message = "\("of ".localized)\(goorback.lineName(keytag, "line ".localized + keytag))"
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let colorlistarray: [String] = CustomColor.allCases.map{$0.rawValue.localized}
        let colorvaluearray: [Int] = CustomColor.allCases.map{$0.RGB}
        for i in 0..<colorlistarray.count {
            picker.addAction(setColorRegisterAction(colorlistarray[i], colorvaluearray[i], label, stackview, colorkey))
        }
        picker.addAction(setCancelAction())
        viewcontroller.present(picker, animated: true, completion: nil)
    }

    // MARK: - Transport Setting Dialog
    // Displays transportation mode picker dialog
    func transportPickerDialog(_ label: UILabel, _ keytag: String) {
        let departstation = goorback.transitDepartStation(keytag)
        let arrivestation = goorback.transitArriveStation(keytag)
        let title = DialogTitle.transport.rawValue.localized
        let message = "\("from ".localized)\(departstation)\(" to ".localized)\(arrivestation)"
        let key = "\(goorback)transport\(keytag)"
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let transportationarray: [String] = Transportation.allCases.map{$0.rawValue.localized}
        for i in 0..<transportationarray.count {
            picker.addAction(setChoiceRegisterAction(transportationarray[i], label, key))
        }
        picker.addAction(setCancelAction())
        viewcontroller.present(picker, animated: true, completion: nil)
    }
 
    // MARK: - Choice Action Handlers
    // Creates choice register action
    func setChoiceRegisterAction(_ title: String, _ label: UILabel, _ key: String) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            if (title != "") {
                label.text = title
                UserDefaults.standard.set(title, forKey: key)
            }
        }
    }

    // MARK: - Minutes Field Alert Configuration
    // Creates minutes field alert with configuration
    func minutesFieldAlert(_ title: String, _ message: String, _ key: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {
            (textfield: UITextField!) in
            textfield.text = key.userDefaultValue("")
            textfield.textAlignment = NSTextAlignment.center
            textfield.placeholder = Hint.to99min.rawValue.localized
            textfield.keyboardType = .phonePad})
        return alert
    }

    // MARK: - Minutes Field Action Handlers
    // Creates register action for minutes field
    func setMinutesFieldRegisterAction(_ textfield: UITextField, _ key: String, _ unit: String) -> UIAlertAction {
        return UIAlertAction(title: Action.register.rawValue.localized, style: .default) {
            (action: UIAlertAction) in
            if (Int(textfield.text!) ?? 100 >= 0 && Int(textfield.text!) ?? 100 < 100) {
                UserDefaults.standard.set(textfield.text, forKey: key)
            }
        }
    }
    
    // MARK: - Transit Time Setting Dialog
    // Displays transit time setting dialog
    func transitTimeFieldDialog(_ keytag: String) {
        let departstation = goorback.transitDepartStation(keytag)
        let arrivestation = goorback.transitArriveStation(keytag)
        let title = DialogTitle.transittime.rawValue.localized
        let message = "\("from ".localized)\(departstation)\(" to ".localized)\(arrivestation)"
        let key = "\(goorback)transittime\(keytag)"
        let unit = minites
        // Display text field alert
        let alert = minutesFieldAlert(title, message, key)
        // Register button: save and display input text
        alert.addAction(setMinutesFieldRegisterAction((alert.textFields?.first)!, key, unit))
        // Cancel button: exit alert
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }

    // MARK: - Ride Time Setting Dialog
    // Displays ride time setting dialog
    func rideTimeFieldDialog(_ stackview: UIStackView, _ keytag: String, _ weekflag: Bool) {
        let title = DialogTitle.ridetime.rawValue.localized
        let message = "\("on ".localized)\(goorback.lineName(keytag, "\("Line ".localized)\(keytag)"))"
        let key = "\(goorback)ridetime\(keytag)"
        let unit = minites
        // Display text field alert
        let alert = minutesFieldAlert(title, message, key)
        let textfield = (alert.textFields?.first)!
        // Register button: save and display input text
        alert.addAction(setMinutesFieldRegisterAction(textfield, key, unit))
        // Cancel button: exit alert
        alert.addAction(setCancelAction())
        alert.addAction(storyboardTimetableAction(textfield, key, keytag, weekflag))
        viewcontroller.present(alert, animated: true, completion: nil)
    }

    // MARK: - Timetable Transition Action
    // Creates action to transition to timetable view
    func storyboardTimetableAction(_ textfield: UITextField, _ key: String, _ keytag: String, _ weekflag: Bool) -> UIAlertAction{
        let title = DialogTitle.timetable.rawValue.localized
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            if (textfield.text != "") {UserDefaults.standard.set(textfield.text, forKey: key)}
            let storyboard = viewcontroller.storyboard!
            let vc = storyboard.instantiateViewController(withIdentifier: "timetableview") as! TimetableViewController
            vc.goorback = goorback
            vc.keytag = keytag
            vc.weekflag = weekflag
            viewcontroller.present(vc, animated: true)
        }
    }
}
