//
//  TimetableViewController.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/05.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class TimetableViewController: UIViewController {

    var timer = Timer()
    var goorback: String?
    var keytag: String?
    var weekflag: Bool?
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        departstationlabel.text = FileAndData.getDepartStation(
            goorback: goorback!,
            keytag: keytag!)
        
        lineforarrivestationlabel.text = Timetable.getTimetableTitle(
            goorback: goorback!,
            keytag: keytag!)
        

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {
            (timer) in

            Timetable.setWeekButton(
                weeklabel: self.weeklabel,
                weekbutton: self.weekbutton,
                weekdaycolor: 0x3700B3,
                weekendcolor: 0xFF0000,
                weekflag: self.weekflag!)

            self.timetable04h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "04")
            self.timetable05h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "05")
            self.timetable06h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "06")
            self.timetable07h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "07")
            self.timetable08h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "08")
            self.timetable09h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "09")
            self.timetable10h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "10")
            self.timetable11h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "11")
            self.timetable12h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "12")
            self.timetable13h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "13")
            self.timetable14h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "14")
            self.timetable15h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "15")
            self.timetable16h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "16")
            self.timetable17h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "17")
            self.timetable18h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "18")
            self.timetable19h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "19")
            self.timetable20h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "20")
            self.timetable21h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "21")
            self.timetable22h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "22")
            self.timetable23h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "23")
            self.timetable24h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "24")
            self.timetable25h.text = Timetable.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag!, timekeytag: "25")
        })
    }

    @IBAction func weekbutton(_ sender: Any) {
        weekflag = Timetable.getWeekButton(
            weeklabel: weeklabel,
            weekbutton: weekbutton,
            weekdaycolor: 0x3700B3,
            weekendcolor: 0xFF0000,
            weekflag: weekflag!)
    }
    
    @IBAction func timetable04h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable04h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "04")
    }
    
    @IBAction func timetable05h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable05h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "05")
    }

    @IBAction func timetable06h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable06h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "06")
    }
    
    @IBAction func timetable07h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable07h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "07")
    }
    
    @IBAction func timetable08h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable08h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "08")
    }
    
    @IBAction func timetable09h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable09h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "09")
    }
    
    @IBAction func timetable10h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable10h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "10")
    }
    
    @IBAction func timetable11h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable11h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "11")
    }
    
    @IBAction func timetable12h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable12h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "12")
    }
    
    @IBAction func timetable13h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable13h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "13")
    }
    
    @IBAction func timetable14h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable14h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "14")
    }
    
    @IBAction func timetable15h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable15h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "15")
    }
    
    @IBAction func timetable16h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable16h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "16")
    }
    
    @IBAction func timetable17h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable17h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "17")
    }
    
    @IBAction func timetable18h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable18h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "18")
    }
    
    @IBAction func timetable19h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable19h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "19")
    }
    
    @IBAction func timetable20h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable20h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "20")
    }
    
    @IBAction func timetable21h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable21h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "21")
    }
    
    @IBAction func timetable22h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable22h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "22")
    }
    
    @IBAction func timetable23h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable23h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "23")
    }
    
    @IBAction func timetable24h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable24h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "24")
    }
    
    @IBAction func timetable25h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable25h,
            goorback: goorback!,
            weekflag: weekflag!,
            keytag: keytag!,
            timekeytag: "25")
    }    
}
