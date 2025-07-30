//
//  ViewExtention.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/06.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    // 枠線の色
    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColor.map { UIColor(cgColor: $0) }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    // 枠線のWidth
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    // 角丸設定
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

extension UIColor {
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

extension MainViewController : UIColorPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ colorpicker: UIColorPickerViewController, label: UILabel, stackview: UIStackView){
        let color = colorpicker.selectedColor
        label.textColor = color
        stackview.backgroundColor = color
    }
}

extension UIButton {
    //
    func setButtonColor(_ color: Int) {
        self.setTitleColor(UIColor(color), for: UIControl.State.normal)
    }
    //
    func changeButtonColor(_ flag: Bool, _ truecolor: Int, _ falsecolor: Int) {
        (flag) ? self.setButtonColor(truecolor): self.setButtonColor(falsecolor)
    }
}

extension Bool {
    //
    func changeLabelColor(_ truecolor: Int, _ falsecolor: Int) -> UIColor {
        return (self) ? UIColor(truecolor): UIColor(falsecolor)
    }
}

extension String {
    var containsValidIntCharacter: Bool {
        guard self != "" else { return true }
        let hexSet = CharacterSet(charactersIn: "1234567890")
        let newSet = CharacterSet(charactersIn: self)
        return hexSet.isSuperset(of: newSet)
    }
}
