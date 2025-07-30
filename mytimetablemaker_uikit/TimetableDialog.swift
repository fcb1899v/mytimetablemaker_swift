//
//  TimetableDialog.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/11/07.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Timetable Dialog Structure
// Manages timetable dialog functionality for time management
struct TimetableDialog: Calculation{
    var goorback: String
    var weekflag: Bool
    var keytag: String
    
    // MARK: - Initialization
    // Initialize with route direction, week flag, and key tag
    init(_ goorback: String, _ weekflag: Bool, _ keytag: String){
        self.goorback = goorback
        self.weekflag = weekflag
        self.keytag = keytag
    }
    
    // MARK: - Constants
    // Localized action and hint strings
    let register = Action.register.rawValue.localized
    let cancel = Action.cancel.rawValue.localized
    let add = Action.add.rawValue.localized
    let delete = Action.delete.rawValue.localized
    let copy = Action.copy.rawValue.localized
    let to59min = Hint.to59min.rawValue.localized
}

// MARK: - Timetable Dialog Extensions
extension TimetableDialog {

    // MARK: - Week Tag Management
    // Returns week tag based on week flag
    var weektag: String {
        return (self.weekflag) ? "weekday": "weekend"
    }

    // Returns reverse week tag
    var reverseweektag: String {
        return !(self.weekflag) ? "weekday": "weekend"
    }

    // MARK: - Timetable Key Generation
    // Generates timetable key for specific hour
    func timetableKey(_ hour: Int) -> String {
        return "\(goorback)line\(keytag)\(weektag)\(String(hour))"
    }

    // MARK: - Timetable Data Access
    // Retrieves timetable time for specific hour from UserDefaults
    func timetableTime(_ hour: Int) -> String {
        return timetableKey(hour).userDefaultValue("")
    }
    
    // MARK: - Time Addition/Deletion/Copy Operations
    // Adds time to timetable
    func addTimeFromTimetable(_ label: UILabel, _ addtext: String, _ key: String) -> String {
        let currenttext = key.userDefaultValue("").dropFirst(1)
        let temptext = ("\(currenttext) \(addtext)").trimmingCharacters(in: .whitespaces)
        let textarray = temptext.timeSorting(charactersin: " ")
        let edittext = " \(textarray.joined(separator: " "))"
        UserDefaults.standard.set(edittext, forKey: key)
        return edittext
    }
    
    // Deletes time from timetable
    func deleteTimeFromTimetable(_ label: UILabel, _ deletetext: String, _ key: String) -> String {
        let currenttext = key.userDefaultValue("").dropFirst(1)
        let temptext = currenttext.trimmingCharacters(in: .whitespaces)
        let textarray = temptext.timeSorting(charactersin: " ").filter{$0 != deletetext}
        let edittext = " \(textarray.joined(separator: " "))"
        UserDefaults.standard.set(edittext, forKey: key)
        return edittext
    }

    // MARK: - Alert Configuration
    // Creates time field alert with configuration
    func getTimeFieldAlert(_ title: String, _ message: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {
            (textfield: UITextField!) in
            textfield.textAlignment = NSTextAlignment.center
            textfield.placeholder = to59min
            textfield.keyboardType = .phonePad})
        return alert
    }

    // MARK: - Action Handlers
    // Creates add time action
    func addTimeFieldRegisterAction(_ viewcontroller: UIViewController, _ textfield: UITextField, _ label: UILabel, _ key: String, _ hour: Int, _ labelarray: [UILabel]) -> UIAlertAction {
        return UIAlertAction(title: add, style: .default) {
            (action: UIAlertAction) in
            let edittext = addTimeFromTimetable(label, textfield.text ?? "", key)
            label.text = edittext
            setTimeFieldDialog(viewcontroller, label, hour, labelarray)
        }
    }

    // Creates delete time action
    func deleteTimeFieldRegisterAction(_ viewcontroller: UIViewController, _ textfield: UITextField, _ label: UILabel, _ key: String, _ hour: Int, _ labelarray: [UILabel]) -> UIAlertAction {
        return UIAlertAction(title: delete, style: .destructive) {
            (action: UIAlertAction) in
            let edittext = deleteTimeFromTimetable(label, textfield.text ?? "", key)
            label.text = edittext
            setTimeFieldDialog(viewcontroller, label, hour, labelarray)
        }
    }

    // Creates copy time action
    func setCopyTimeAction(_ viewcontroller: UIViewController, _ label: UILabel, _ key: String, _ hour: Int, _ labelarray: [UILabel]) -> UIAlertAction {
        return UIAlertAction(title: copy, style: .default) {
            (action: UIAlertAction) in
            choiceCopyTimeDialog(viewcontroller, label, key, hour, labelarray)
        }
    }
    
    // MARK: - Cancel Action
    // Creates cancel action
    func setCancelAction() -> UIAlertAction {
        return UIAlertAction(title: cancel, style: .cancel, handler: nil)
    }
    
    // MARK: - Time Copy Choice/Key Generation/Dialog
    // Generates copy time choice titles
    func choiceCopyTimeTitle(_ hour: Int) -> [String] {
        return [
            "\(String(hour - 1))\("Hour".localized)",
            "\(String(hour + 1))\("Hour".localized)",
            (!weekflag) ? "Weekday".localized: "Weekend".localized,
            "Other route of line 1".localized,
            "Other route of line 2".localized,
            "Other route of line 3".localized
        ]
    }
    
    // Generates copy time choice keys
    func choiceCopyTimeKey(_ hour: Int) -> [String] {
        return [
            "\(goorback)line\(keytag)\(weektag)\(String(hour - 1))",
            "\(goorback)line\(keytag)\(weektag)\(String(hour + 1))",
            "\(goorback)line\(keytag)\(reverseweektag)\(String(hour))",
            "\(goorback.otherroute)line1\(weektag)\(String(hour))",
            "\(goorback.otherroute)line2\(weektag)\(String(hour))",
            "\(goorback.otherroute)line3\(weektag)\(String(hour))"
        ]
    }
    
    // Displays copy time choice dialog
    func choiceCopyTimeDialog (_ viewcontroller: UIViewController, _ label: UILabel, _ key: String, _ hour: Int, _ labelarray: [UILabel]) {
        let title = DialogTitle.copytime.rawValue.localized
        let message = ""
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let choicetitle = choiceCopyTimeTitle(hour)
        let choicekey = choiceCopyTimeKey(hour)
        
        if (hour != 4) {
            picker.addAction(setChoiceCopyTimeAction(label, key, choicetitle[0], choicekey[0]))
        }
        if (hour != 25) {
            picker.addAction(setChoiceCopyTimeAction(label, key, choicetitle[1], choicekey[1]))
        }
        for i in 2...5 {
            picker.addAction(setChoiceCopyTimeAction2(viewcontroller, label, key, choicetitle[i], choicekey[i], labelarray, i))
        }
        picker.addAction(setCancelAction())
        viewcontroller.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Choice Copy Time Actions
    // Creates choice copy time action
    func setChoiceCopyTimeAction(_ label: UILabel, _ key: String, _ choicetitle: String, _ choicekey: String) -> UIAlertAction {
            return UIAlertAction(title: choicetitle, style: .default) {
                (action: UIAlertAction) in
                label.text = choicekey.userDefaultValue("")
                UserDefaults.standard.set(label.text, forKey: key)
            }
    }

    // Creates choice copy time action with all copy option
    func setChoiceCopyTimeAction2(_ viewcontroller: UIViewController, _ label: UILabel, _ key: String, _ choicetitle: String, _ choicekey: String, _ labelarray: [UILabel], _ i: Int) -> UIAlertAction {
            return UIAlertAction(title: choicetitle, style: .default) {
                (action: UIAlertAction) in
                label.text = choicekey.userDefaultValue("")
                UserDefaults.standard.set(label.text, forKey: key)
                setAllCopyDialog(viewcontroller, labelarray, i)
            }
    }

    // MARK: - All Copy Dialog/Action
    // Displays all copy dialog
    func setAllCopyDialog(_ viewcontroller: UIViewController, _ labelarray: [UILabel], _ i: Int) {
        let title = DialogTitle.allcopytime.rawValue.localized
        let message = ""
        let picker = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        picker.addAction(allCopyAction(labelarray, i))
        picker.addAction(setCancelAction())
        viewcontroller.present(picker, animated: true, completion: nil)
    }

    // Creates all copy action
    func allCopyAction(_ labelarray: [UILabel], _ i: Int) -> UIAlertAction {
        return UIAlertAction(title: Action.yes.rawValue.localized, style: .default) {
            (action: UIAlertAction) in
            for hour in 4...25 {
                let copytime = choiceCopyTimeKey(hour)[i].userDefaultValue("")
                UserDefaults.standard.set(copytime, forKey: timetableKey(hour))
                labelarray[hour - 4].text = copytime
            }
        }
    }

    // MARK: - Time Field Dialog
    // Displays time field dialog for add/delete/copy operations
    func setTimeFieldDialog(_ viewcontroller: UIViewController, _ label: UILabel, _ hour: Int, _ labelarray: [UILabel]) {
        let title = DialogTitle.adddeletime.rawValue.localized
        let message = "\(goorback.lineName(keytag, "Line ".localized + keytag)) (\(String(hour))\("Hour".localized))"
        let key = timetableKey(hour)
        // Display text field alert
        let alert = getTimeFieldAlert(title, message)
        // Add button: save and display input text
        alert.addAction(addTimeFieldRegisterAction(viewcontroller, (alert.textFields?.first)!, label, key, hour, labelarray))
        // Delete button: delete input text
        alert.addAction(deleteTimeFieldRegisterAction(viewcontroller, (alert.textFields?.first)!, label, key, hour, labelarray))
        alert.addAction(setCopyTimeAction(viewcontroller, label, key, hour, labelarray))
        // Cancel button: exit alert
        alert.addAction(setCancelAction())
        viewcontroller.present(alert, animated: true, completion: nil)
    }
}
