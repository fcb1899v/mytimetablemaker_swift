//
//  TimetableViewController.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/05.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit
import Combine

class TimetableViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var timer = Timer()
    var goorback: String?
    var keytag: String?
    var weekflag: Bool?
    
    let primary = DefaultColor.primary.rawValue
    let white = DefaultColor.white.rawValue
    let red = DefaultColor.red.rawValue
    
    @IBOutlet weak var settingtimetabletitle: UILabel!
    @IBOutlet weak var departstationlabel: UILabel!
    @IBOutlet weak var lineforarrivestationlabel: UILabel!
    @IBOutlet weak var weeklabel: UILabel!
    @IBOutlet weak var weekbutton: UIButton!

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

    @IBOutlet weak var pictureview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let weekflag = self.weekflag!
        let timetable = Timetable(self.goorback!, weekflag, self.keytag!)

        settingtimetabletitle.text = "Setting your timetable".localized
        departstationlabel.text = timetable.timetableDepartStation
        lineforarrivestationlabel.text = timetable.timetableTitle
        
        self.weeklabel.text = timetable.weekLabelText
        self.weeklabel.textColor = timetable.weekLabelColor(self.white, self.red)
        timetable.weekButtonTitle(self.weekbutton)
        timetable.weekButtonColor(self.weekbutton, self.red, self.primary)

        self.timetable04h.text = timetable.timetableTime(4)
        self.timetable05h.text = timetable.timetableTime(5)
        self.timetable06h.text = timetable.timetableTime(6)
        self.timetable07h.text = timetable.timetableTime(7)
        self.timetable08h.text = timetable.timetableTime(8)
        self.timetable09h.text = timetable.timetableTime(9)
        self.timetable10h.text = timetable.timetableTime(10)
        self.timetable11h.text = timetable.timetableTime(11)
        self.timetable12h.text = timetable.timetableTime(12)
        self.timetable13h.text = timetable.timetableTime(13)
        self.timetable14h.text = timetable.timetableTime(14)
        self.timetable15h.text = timetable.timetableTime(15)
        self.timetable16h.text = timetable.timetableTime(16)
        self.timetable17h.text = timetable.timetableTime(17)
        self.timetable18h.text = timetable.timetableTime(18)
        self.timetable19h.text = timetable.timetableTime(19)
        self.timetable20h.text = timetable.timetableTime(20)
        self.timetable21h.text = timetable.timetableTime(21)
        self.timetable22h.text = timetable.timetableTime(22)
        self.timetable23h.text = timetable.timetableTime(23)
        self.timetable24h.text = timetable.timetableTime(24)
        self.timetable25h.text = timetable.timetableTime(25)
    }

    @IBAction func weekbutton(_ sender: Any) {
        
        let weekflag = !self.weekflag!
        let timetable = Timetable(self.goorback!, weekflag, self.keytag!)

        self.weeklabel.text = timetable.weekLabelText
        self.weeklabel.textColor = timetable.weekLabelColor(self.white, self.red)
        timetable.weekButtonTitle(self.weekbutton)
        timetable.weekButtonColor(self.weekbutton, self.red, self.primary)
        
        self.timetable04h.text = timetable.timetableTime(4)
        self.timetable05h.text = timetable.timetableTime(5)
        self.timetable06h.text = timetable.timetableTime(6)
        self.timetable07h.text = timetable.timetableTime(7)
        self.timetable08h.text = timetable.timetableTime(8)
        self.timetable09h.text = timetable.timetableTime(9)
        self.timetable10h.text = timetable.timetableTime(10)
        self.timetable11h.text = timetable.timetableTime(11)
        self.timetable12h.text = timetable.timetableTime(12)
        self.timetable13h.text = timetable.timetableTime(13)
        self.timetable14h.text = timetable.timetableTime(14)
        self.timetable15h.text = timetable.timetableTime(15)
        self.timetable16h.text = timetable.timetableTime(16)
        self.timetable17h.text = timetable.timetableTime(17)
        self.timetable18h.text = timetable.timetableTime(18)
        self.timetable19h.text = timetable.timetableTime(19)
        self.timetable20h.text = timetable.timetableTime(20)
        self.timetable21h.text = timetable.timetableTime(21)
        self.timetable22h.text = timetable.timetableTime(22)
        self.timetable23h.text = timetable.timetableTime(23)
        self.timetable24h.text = timetable.timetableTime(24)
        self.timetable25h.text = timetable.timetableTime(25)
    }
    
    @IBAction func timetable04h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 4)
    }
    
    @IBAction func timetable05h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 5)
    }

    @IBAction func timetable06h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 6)
    }
    
    @IBAction func timetable07h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 7)
    }
    
    @IBAction func timetable08h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 8)
    }
    
    @IBAction func timetable09h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 9)
    }
    
    @IBAction func timetable10h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 10)
    }
    
    @IBAction func timetable11h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 11)
    }
    
    @IBAction func timetable12h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 12)
    }
    
    @IBAction func timetable13h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 13)
    }
    
    @IBAction func timetable14h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 14)
    }
    
    @IBAction func timetable15h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 15)
    }
    
    @IBAction func timetable16h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 16)
    }
    
    @IBAction func timetable17h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 17)
    }
    
    @IBAction func timetable18h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 18)
    }
    
    @IBAction func timetable19h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 19)
    }
    
    @IBAction func timetable20h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 20)
    }
    
    @IBAction func timetable21h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 21)
    }
    
    @IBAction func timetable22h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 22)
    }
    
    @IBAction func timetable23h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 23)
    }
    
    @IBAction func timetable24h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 24)
    }
    
    @IBAction func timetable25h(_ sender: Any) {
        TimetableDialog(self.goorback!, self.weekflag!, self.keytag!)
        .setTimeFieldDialog(self, timetable04h, 25)
    }
    
    @IBAction func selectpicture(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
        self.present(picker, animated: true, completion: nil)
    }
    
    // 画像が選択された時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
        if let selectedImage = info[.originalImage] as? UIImage {
            //imageViewにカメラロールから選んだ画像を表示する
            pictureview.image = selectedImage
        }
        //画像をImageViewに表示したらアルバムを閉じる
        self.dismiss(animated: true)
    }
    // 画像選択がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
