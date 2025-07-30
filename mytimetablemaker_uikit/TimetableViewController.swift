//
//  TimetableViewController.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/09/05.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit
import Combine

// MARK: - Timetable View Controller
// Manages the timetable view for time editing and display
class TimetableViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    // Timer and state properties
    var timer = Timer()
    var goorback: String?
    var keytag: String?
    var weekflag: Bool?
    
    // MARK: - Color Constants
    // Color values for UI styling
    let primary = DefaultColor.primary.rawValue
    let white = DefaultColor.white.rawValue
    let red = DefaultColor.red.rawValue
    
    // MARK: - Header Labels
    // Labels for timetable header information
    @IBOutlet weak var settingtimetabletitle: UILabel!
    @IBOutlet weak var departstationlabel: UILabel!
    @IBOutlet weak var lineforarrivestationlabel: UILabel!
    @IBOutlet weak var weeklabel: UILabel!
    @IBOutlet weak var weekbutton: UIButton!

    // MARK: - Timetable Labels
    // Labels for each hour of the timetable (4-25)
    @IBOutlet weak var timetable04h: UILabel!
    @IBOutlet weak var timetable05h: UILabel!
    @IBOutlet weak var timetable06h: UILabel!
    @IBOutlet weak var timetable07h: UILabel!
    @IBOutlet weak var timetable08h: UILabel!
    @IBOutlet weak var timetable09h: UILabel!
    @IBOutlet weak var timetable10h: UILabel!
    @IBOutlet weak var timetable11h: UILabel!
    @IBOutlet weak var timetable12h: UILabel!
    @IBOutlet weak var timetable13h: UILabel!
    @IBOutlet weak var timetable14h: UILabel!
    @IBOutlet weak var timetable15h: UILabel!
    @IBOutlet weak var timetable16h: UILabel!
    @IBOutlet weak var timetable17h: UILabel!
    @IBOutlet weak var timetable18h: UILabel!
    @IBOutlet weak var timetable19h: UILabel!
    @IBOutlet weak var timetable20h: UILabel!
    @IBOutlet weak var timetable21h: UILabel!
    @IBOutlet weak var timetable22h: UILabel!
    @IBOutlet weak var timetable23h: UILabel!
    @IBOutlet weak var timetable24h: UILabel!
    @IBOutlet weak var timetable25h: UILabel!

    // MARK: - Image View
    // Image view for background picture
    @IBOutlet weak var pictureview: UIImageView!

    // MARK: - Timetable Array
    // Array to hold all timetable labels
    var timetablearray: [UILabel] = []

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let timetable = Timetable(self.goorback!, self.weekflag!, self.keytag!)

        // MARK: - Header Setup
        // Configure header labels
        settingtimetabletitle.text = "Setting your timetable".localized
        departstationlabel.text = timetable.timetableDepartStation
        lineforarrivestationlabel.text = timetable.timetableTitle

        // MARK: - Week Display Setup
        // Configure week display
        self.weeklabel.text = timetable.weekLabelText
        self.weeklabel.textColor = timetable.weekLabelColor(self.white, self.red)
        timetable.weekButtonTitle(self.weekbutton)
        timetable.weekButtonColor(self.weekbutton, self.red, self.primary)

        // MARK: - Timetable Array Setup
        // Initialize timetable array with all hour labels
        timetablearray = [
            self.timetable04h, self.timetable05h, self.timetable06h, self.timetable07h,
            self.timetable08h, self.timetable09h, self.timetable10h, self.timetable11h,
            self.timetable12h, self.timetable13h, self.timetable14h, self.timetable15h,
            self.timetable16h, self.timetable17h, self.timetable18h, self.timetable19h,
            self.timetable20h, self.timetable21h, self.timetable22h, self.timetable23h,
            self.timetable24h, self.timetable25h
        ]
        
        // MARK: - Timetable Display
        // Display timetable times for all hours
        for hour in 4...25 {
            timetablearray[hour - 4].text = timetable.timetableTime(hour)
        }
    }

    // MARK: - Week Button Action
    // Handles week button tap to switch between weekday/weekend
    @IBAction func weekbutton(_ sender: Any) {

        let weekflag = (self.weeklabel.text == "Weekend".localized) ? true: false
        let timetable = Timetable(self.goorback!, weekflag, self.keytag!)

        self.weeklabel.text = timetable.weekLabelText
        self.weeklabel.textColor = timetable.weekLabelColor(self.white, self.red)
        timetable.weekButtonTitle(self.weekbutton)
        timetable.weekButtonColor(self.weekbutton, self.red, self.primary)

        for hour in 4...25 {
            timetablearray[hour - 4].text = timetable.timetableTime(hour)
        }
    }
    
    // MARK: - Timetable Hour Actions
    // Actions for each hour of the timetable (4-25)
    @IBAction func timetable04h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 4, timetablearray)
    }
    
    @IBAction func timetable05h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable05h, 5, timetablearray)
    }

    @IBAction func timetable06h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable06h, 6, timetablearray)
    }
    
    @IBAction func timetable07h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable07h, 7, timetablearray)
    }

    @IBAction func timetable08h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable08h, 8, timetablearray)
    }

    @IBAction func timetable09h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable09h, 9, timetablearray)
    }

    @IBAction func timetable10h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable10h, 10, timetablearray)
    }

    @IBAction func timetable11h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable11h, 11, timetablearray)
    }

    @IBAction func timetable12h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable12h, 12, timetablearray)
    }

    @IBAction func timetable13h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable13h, 13, timetablearray)
    }

    @IBAction func timetable14h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable14h, 14, timetablearray)
    }

    @IBAction func timetable15h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable15h, 15, timetablearray)
    }

    @IBAction func timetable16h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable16h, 16, timetablearray)
    }

    @IBAction func timetable17h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable17h, 17, timetablearray)
    }

    @IBAction func timetable18h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable18h, 18, timetablearray)
    }

    @IBAction func timetable19h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable19h, 19, timetablearray)
    }

    @IBAction func timetable20h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable20h, 20, timetablearray)
    }

    @IBAction func timetable21h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable21h, 21, timetablearray)
    }

    @IBAction func timetable22h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable22h, 22, timetablearray)
    }

    @IBAction func timetable23h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable23h, 23, timetablearray)
    }

    @IBAction func timetable24h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable24h, 24, timetablearray)
    }

    @IBAction func timetable25h(_ sender: Any) {
        let weekflag = (self.weeklabel.text == "Weekday".localized) ? true: false
        TimetableDialog(self.goorback!, weekflag, self.keytag!)
        .setTimeFieldDialog(self, timetable25h, 25, timetablearray)
    }

    // MARK: - Image Picker
    // Opens image picker for background picture selection
    @IBAction func selectpicture(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
        self.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker Delegate
    // Displays selected image in image view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
        if let selectedImage = info[.originalImage] as? UIImage {
            // Display selected image from photo library
            pictureview.image = selectedImage
        }
        // Dismiss picker after displaying image
        self.dismiss(animated: true)
    }
    
    // MARK: - Image Picker Cancel
    // Handles image picker cancellation
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
