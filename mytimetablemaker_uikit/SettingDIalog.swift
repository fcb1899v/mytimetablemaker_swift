//
//  SettingDIalog.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/11/07.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Setting Dialog Structure
// Manages setting dialogs for various configuration options
struct SettingDialog: Display {
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
    let minutes = Unit.minites.rawValue.localized
    let maxchar = Int("20".localized)!
}

// MARK: - Setting Dialog Extensions
extension SettingDialog {
    
    // MARK: - Choice Action Handlers
    // Creates choice action for change line settings
    func setChoiceChangeLineAction(_ title: String, _ label: UILabel, _ key: String, _ value: Int) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            label.text = title
            UserDefaults.standard.set(value, forKey: key)
        }
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
    
    // MARK: - Transfer Line Dialog
    // Displays transfer count picker dialog
    func changeLinePickerDialog(_ taplabel: UILabel, _ setlabel: UILabel) {
        let title = DialogTitle.numtransit.rawValue.localized
        let message = taplabel.text
        let key = "\(goorback)changeline"
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let transittimearray: [String] = TransitTime.allCases.map{$0.rawValue.localized}
        let transitvaluearray: [Int] = TransitTime.allCases.map{$0.Number}
        for i in 0..<transittimearray.count {
            picker.addAction(setChoiceChangeLineAction(transittimearray[i], setlabel, key, transitvaluearray[i]))
        }
        picker.addAction(setCancelAction())
        viewcontroller.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Text Field Alert Configuration
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

    // MARK: - Text Field Dialog
    // Displays text field dialog for input
    func textFieldDialog(_ label: UILabel, _ title: String, _ message: String, _ key: String) {
        let alert = textFieldAlert(title, message, key)
        alert.addAction(setTextFieldRegisterAction(label, (alert.textFields?.first)!, key))
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }
 
    // MARK: - Location Setting Dialogs
    // Displays departure point setting dialog
    func prefDeparturePointTextFieldDialog(_ label: UILabel) {
        let title = DialogTitle.departplace.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "destination": "departurepoint"
        textFieldDialog(label, title, message, key)
    }

    // Displays departure station setting dialog
    func prefDepartStationTextFieldDialog(_ label: UILabel, _ keytag: String) {
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\("of departure station ".localized)\(keytag)"
        let key = "\(goorback)departstation\(keytag)"
        textFieldDialog(label, title, message, key)
    }
    
    // Displays arrival station setting dialog
    func prefArriveStationTextFieldDialog(_ label: UILabel, _ keytag: String) {
        let title = DialogTitle.stationname.rawValue.localized
        let message = "\("of arrival station ".localized)\(keytag)"
        let key = "\(goorback)arrivestation\(keytag)"
        textFieldDialog(label, title, message, key)
    }

    // Displays destination setting dialog
    func prefDestinationTextFieldDialog(_ label: UILabel) {
        let title = DialogTitle.destination.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
        textFieldDialog(label, title, message, key)
    }
    
    // MARK: - Line Name Setting Dialog
    // Displays line name setting dialog with color option
    func prefLineTextFieldDialog(_ linenamelabel: UILabel, _ ridetimelabel: UILabel, _ keytag: String) {
        let title = DialogTitle.linename.rawValue.localized
        let message = "\("line ".localized)\(keytag)"
        let key = "\(goorback)linename\(keytag)"
        let alert = textFieldAlert(title, message, key)
        // Register button: save and display input text
        alert.addAction(setTextFieldRegisterAction(linenamelabel, (alert.textFields?.first)!, key))
        // Cancel button: exit alert
        alert.addAction(setCancelAction())
        // Line color setting
        alert.addAction(prefLineColorDialogAction((alert.textFields?.first)!, linenamelabel, ridetimelabel, keytag))
        viewcontroller.present(alert, animated: true, completion: nil)
    }

    // MARK: - Line Color Dialog Action
    // Creates line color dialog action
    func prefLineColorDialogAction(_ textfield: UITextField, _ linenamelabel: UILabel, _ ridetimelabel: UILabel, _ keytag: String) -> UIAlertAction {
        let title = DialogTitle.linecolor.rawValue.localized
        let namekey = "\(goorback)linename\(keytag)"
        let colorkey = "\(goorback)linecolor\(keytag)"
        return UIAlertAction(title: title, style: .default) {
            (action: UIAlertAction) in
            if (textfield.text != nil || textfield.text != "") {
                linenamelabel.text = textfield.text!
                UserDefaults.standard.set(textfield.text, forKey: namekey)
            }
            prefColorPickerDialog(linenamelabel, ridetimelabel, colorkey, keytag)
        }
    }

    // MARK: - Color Register Action
    // Creates color register action
    func prefColorRegisterAction(_ colortitle: String, _ color: Int, _ linenamelabel: UILabel, _ ridetimelabel: UILabel, _ colorkey: String) -> UIAlertAction {
        return UIAlertAction(title: colortitle, style: .default) {
            (action: UIAlertAction) in
                linenamelabel.textColor = UIColor(color)
                ridetimelabel.textColor = UIColor(color)
                UserDefaults.standard.set(color, forKey: colorkey)
        }
    }

    // MARK: - Color Picker Dialog
    // Displays color picker dialog
    func prefColorPickerDialog(_ linenamelabel: UILabel, _ ridetimelabel: UILabel, _ colorkey: String, _ keytag: String) {
        let title = DialogTitle.linecolor.rawValue.localized
        let message = "\("of ".localized)\(goorback.lineName(keytag, "\("line ".localized)\(keytag)"))"
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let colorlistarray: [String] = CustomColor.allCases.map{$0.rawValue.localized}
        let colorvaluearray: [Int] = CustomColor.allCases.map{$0.RGB}
        picker.addAction(setCancelAction())
        for i in 0..<colorlistarray.count {
            picker.addAction(prefColorRegisterAction(colorlistarray[i], colorvaluearray[i], linenamelabel,ridetimelabel,colorkey))
        }
        viewcontroller.present(picker, animated: true, completion: nil)
    }

    // MARK: - Minutes Field Action Handlers
    // Creates register action for minutes field
    func setPrefMinutesFieldRegisterAction(_ textfield: UITextField, _ label: UILabel, _ key: String, _ unit: String) -> UIAlertAction {
        return UIAlertAction(title: register, style: .default) {
            (action: UIAlertAction) in
            if (Int(textfield.text!) ?? 100 >= 0 && Int(textfield.text!) ?? 100 < 100) {
                label.text = "\(textfield.text!)\(minutes)"
                UserDefaults.standard.set(textfield.text, forKey: key)
            }
        }
    }
    
    // MARK: - Ride Time Setting Dialog
    // Displays ride time setting dialog
    func prefRideTimeFieldDialog(_ label: UILabel, _ keytag: String, _ weekflag: Bool) {
        let title = DialogTitle.ridetime.rawValue.localized
        let message = "\("on ".localized)\(goorback.lineName(keytag, "\("line ".localized)\(keytag)"))"
        let key = "\(goorback)ridetime\(keytag)"
        let unit = minutes
        // Display text field alert
        let alert = minutesFieldAlert(title, message, key)
        let textfield = (alert.textFields?.first)!
        // Register button: save and display input text
        alert.addAction(setPrefMinutesFieldRegisterAction(textfield, label, key, unit))
        // Cancel button: exit alert
        alert.addAction(setCancelAction())
        // Timetable transition button
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

    // MARK: - Transport Setting Dialog
    // Displays transportation mode picker dialog
    func prefTransportPickerDialog(_ label: UILabel, _ keytag: String) {
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
    
    // MARK: - Choice Register Action
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

    // MARK: - Transit Time Setting Dialog
    // Displays transit time setting dialog
    func prefTransitTimeFieldDialog(_ label: UILabel, _ keytag: String) {
        let departstation = goorback.transitDepartStation(keytag)
        let arrivestation = goorback.transitArriveStation(keytag)
        let title = DialogTitle.transittime.rawValue.localized
        let message = "\("from ".localized)\(departstation)\(" to ".localized)\(arrivestation)"
        let key = "\(goorback)transittime\(keytag)"
        let unit = minutes
        // Display text field alert
        let alert = minutesFieldAlert(title, message, key)
        // Register button: save and display input text
        alert.addAction(setPrefMinutesFieldRegisterAction((alert.textFields?.first)!, label, key, unit))
        // Cancel button: exit alert
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }
}

