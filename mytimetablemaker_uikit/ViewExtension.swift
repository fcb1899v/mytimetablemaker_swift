//
//  ViewExtention.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/09/06.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIView Extensions
// Extensions for UIView styling and appearance
extension UIView {
    // MARK: - Border Properties
    // Border color property for Interface Builder inspection
    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColor.map { UIColor(cgColor: $0) }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    // Border width property for Interface Builder inspection
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    // Corner radius property for Interface Builder inspection
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

// MARK: - UIColor Extensions
// Extensions for UIColor creation and manipulation
extension UIColor {
    // MARK: - RGB Initialization
    // Creates UIColor from RGB integer value
    convenience init(_ rgb: Int) {
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >>  8) / 255.0
        let b = CGFloat( rgb & 0x0000FF       ) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
//    convenience init(rgba: Int) {
//        let r: CGFloat = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
//        let g: CGFloat = CGFloat((rgba & 0x00FF0000) >> 16) / 255.0
//        let b: CGFloat = CGFloat((rgba & 0x0000FF00) >>  8) / 255.0
//        let a: CGFloat = CGFloat( rgba & 0x000000FF       ) / 255.0
//        self.init(red: r, green: g, blue: b, alpha: a)
//    }
}

// MARK: - Color Picker Delegate Extension
// Extension for handling color picker interactions
extension MainViewController : UIColorPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ colorpicker: UIColorPickerViewController, label: UILabel, stackview: UIStackView){
        let color = colorpicker.selectedColor
        label.textColor = color
        stackview.backgroundColor = color
    }
}

// MARK: - UIButton Extensions
// Extensions for UIButton styling and color management
extension UIButton {
    // MARK: - Button Color Management
    // Sets button title color using RGB integer value
    func setButtonColor(_ color: Int) {
        self.setTitleColor(UIColor(color), for: UIControl.State.normal)
    }
    // Changes button color based on boolean flag
    func changeButtonColor(_ flag: Bool, _ truecolor: Int, _ falsecolor: Int) {
        (flag) ? self.setButtonColor(truecolor): self.setButtonColor(falsecolor)
    }
}

// MARK: - Boolean Extensions
// Extensions for boolean-based color selection
extension Bool {
    // MARK: - Color Selection
    // Returns color based on boolean value
    func changeLabelColor(_ truecolor: Int, _ falsecolor: Int) -> UIColor {
        return (self) ? UIColor(truecolor): UIColor(falsecolor)
    }
}

// MARK: - String Extensions
// Extensions for string validation
extension String {
    // MARK: - Integer Validation
    // Checks if string contains only valid integer characters
    var containsValidIntCharacter: Bool {
        guard self != "" else { return true }
        let hexSet = CharacterSet(charactersIn: "1234567890")
        let newSet = CharacterSet(charactersIn: self)
        return hexSet.isSuperset(of: newSet)
    }
}
