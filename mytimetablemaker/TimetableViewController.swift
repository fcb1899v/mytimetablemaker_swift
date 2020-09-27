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
    var weekflag = true
    
    @IBOutlet weak var departstationlabel: UILabel!
    @IBOutlet weak var lineforarrivestationlabel: UILabel!
    @IBOutlet weak var weekbutton: UIButton!

    @IBOutlet weak var timetable04h: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let departstation = FileAndData.getDepartStation(
            goorback: goorback!, keytag: keytag!)
        let arrivestation = FileAndData.getArriveStation(
            goorback: goorback!, keytag: keytag!)
        let linename = FileAndData.getLinename(
            goorback: goorback!, keytag: keytag!)

        departstationlabel.text = departstation
        lineforarrivestationlabel.text = "(" + linename + " for " + arrivestation + ")"

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
            (timer) in
            self.timetable04h.text = FileAndData.getTimetableTime(goorback: self.goorback!, keytag: self.keytag!, weekflag: self.weekflag, timekeytag: "04")
        })
    }

    @IBAction func weekbutton(_ sender: Any) {
        weekflag = DateAndTime.setWeekButton(
            weekbutton: weekbutton,
            weekdaycolor: UIColor(rgb: 0x3700B3),
            weekendcolor: UIColor(rgb: 0xFF0000),
            weekflag: weekflag)
    }
    
    @IBAction func timetable04h(_ sender: Any) {
        CustomDialog.setTimeFieldDialog(
            viewcontroller: self,
            label: timetable04h,
            goorback: goorback!,
            weekflag: weekflag,
            keytag: keytag!,
            timekeytag: "04")
    }
    

}

