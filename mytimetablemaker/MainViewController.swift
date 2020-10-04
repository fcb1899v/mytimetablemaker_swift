//
//  MainViewController.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/05.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var timer = Timer()
    var timeflag = true
    var weekflag = DateAndTime.getWeekFlag()
    var goorbackflag = true
    var goorback1 = "back1"
    var goorback2 = "back2"

    @IBOutlet weak var datebutton: UIButton!
    @IBOutlet weak var timebutton: UIButton!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var gobutton: UIButton!
    @IBOutlet weak var startbutton: UIButton!
    @IBOutlet weak var stopbutton: UIButton!
        
    @IBOutlet weak var display2stackview: UIStackView!
    @IBOutlet weak var centerlineview: UIView!
    
    
    
    @IBOutlet weak var stationlabel10: UILabel!
    @IBOutlet weak var stationlabel11: UILabel!
    @IBOutlet weak var stationlabel12: UILabel!
    @IBOutlet weak var stationlabel13: UILabel!
    @IBOutlet weak var stationlabel14: UILabel!
    @IBOutlet weak var stationlabel15: UILabel!
    @IBOutlet weak var stationlabel16: UILabel!
    @IBOutlet weak var stationlabel1e: UILabel!
    
    @IBOutlet weak var stationlabel20: UILabel!
    @IBOutlet weak var stationlabel21: UILabel!
    @IBOutlet weak var stationlabel22: UILabel!
    @IBOutlet weak var stationlabel23: UILabel!
    @IBOutlet weak var stationlabel24: UILabel!
    @IBOutlet weak var stationlabel25: UILabel!
    @IBOutlet weak var stationlabel26: UILabel!
    @IBOutlet weak var stationlabel2e: UILabel!
    
    @IBOutlet weak var linelabel11: UILabel!
    @IBOutlet weak var linelabel12: UILabel!
    @IBOutlet weak var linelabel13: UILabel!
    
    @IBOutlet weak var linelabel21: UILabel!
    @IBOutlet weak var linelabel22: UILabel!
    @IBOutlet weak var linelabel23: UILabel!
    
    @IBOutlet weak var linetimetable11: UIStackView!
    @IBOutlet weak var linetimetable12: UIStackView!
    @IBOutlet weak var linetimetable13: UIStackView!
            
    @IBOutlet weak var linetimetable21: UIStackView!
    @IBOutlet weak var linetimetable22: UIStackView!
    @IBOutlet weak var linetimetable23: UIStackView!
    
    @IBOutlet weak var transittimelabel11: UIStackView!
    @IBOutlet weak var transittimelabel12: UIStackView!
    @IBOutlet weak var transittimelabel13: UIStackView!
    @IBOutlet weak var transittimelabel1e: UIStackView!

    @IBOutlet weak var transittimelabel21: UIStackView!
    @IBOutlet weak var transittimelabel22: UIStackView!
    @IBOutlet weak var transittimelabel23: UIStackView!
    @IBOutlet weak var transittimelabel2e: UIStackView!

    @IBOutlet weak var transportlabel11: UILabel!
    @IBOutlet weak var transportlabel12: UILabel!
    @IBOutlet weak var transportlabel13: UILabel!
    @IBOutlet weak var transportlabel1e: UILabel!
    
    @IBOutlet weak var transportlabel21: UILabel!
    @IBOutlet weak var transportlabel22: UILabel!
    @IBOutlet weak var transportlabel23: UILabel!
    @IBOutlet weak var transportlabel2e: UILabel!
    
    @IBOutlet weak var linestackview12: UIStackView!
    @IBOutlet weak var linestackview13: UIStackView!
    @IBOutlet weak var linestackview22: UIStackView!
    @IBOutlet weak var linestackview23: UIStackView!
    
    @IBOutlet weak var countdown1: UILabel!
    @IBOutlet weak var timelabel10: UILabel!
    @IBOutlet weak var timelabel11: UILabel!
    @IBOutlet weak var timelabel12: UILabel!
    @IBOutlet weak var timelabel13: UILabel!
    @IBOutlet weak var timelabel14: UILabel!
    @IBOutlet weak var timelabel15: UILabel!
    @IBOutlet weak var timelabel16: UILabel!
    @IBOutlet weak var timelabel1e: UILabel!
    
    @IBOutlet weak var countdown2: UILabel!
    @IBOutlet weak var timelabel20: UILabel!
    @IBOutlet weak var timelabel21: UILabel!
    @IBOutlet weak var timelabel22: UILabel!
    @IBOutlet weak var timelabel23: UILabel!
    @IBOutlet weak var timelabel24: UILabel!
    @IBOutlet weak var timelabel25: UILabel!
    @IBOutlet weak var timelabel26: UILabel!
    @IBOutlet weak var timelabel2e: UILabel!
    
    //Main文
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {
            (timer) in

            if (self.timeflag) {
                //現在日付の表示
                DateAndTime.setCurrentDate(datebutton: self.datebutton)
                //現在時刻の表示
                DateAndTime.setCurrentTime(timebutton: self.timebutton)
            }
            
            let currenttime = DateAndTime.getCurrentHHmmssFromTimeButton(
                timebutton: self.timebutton, timeflag: self.timeflag)
            
            let weekflag = DateAndTime.getWeekFlagFromDateButton(datebutton: self.datebutton)
            
            self.stationlabel10.text = FileAndData.getDeparturePoint(
                goorback: self.goorback1)
            self.stationlabel11.text = FileAndData.getDepartStation(
                goorback: self.goorback1, keytag: "1")
            self.stationlabel12.text = FileAndData.getArriveStation(
                goorback: self.goorback1, keytag: "1")
            self.stationlabel13.text = FileAndData.getDepartStation(
                goorback: self.goorback1, keytag: "2")
            self.stationlabel14.text = FileAndData.getArriveStation(
                goorback: self.goorback1, keytag: "2")
            self.stationlabel15.text = FileAndData.getDepartStation(
                goorback: self.goorback1, keytag: "3")
            self.stationlabel16.text = FileAndData.getArriveStation(
                goorback: self.goorback1, keytag: "3")
            self.stationlabel1e.text = FileAndData.getDestination(
                goorback: self.goorback1)
            self.stationlabel20.text = FileAndData.getDeparturePoint(
                goorback: self.goorback2)
            self.stationlabel21.text = FileAndData.getDepartStation(
                goorback: self.goorback2, keytag: "1")
            self.stationlabel22.text = FileAndData.getArriveStation(
                goorback: self.goorback2, keytag: "1")
            self.stationlabel23.text = FileAndData.getDepartStation(
                goorback: self.goorback2, keytag: "2")
            self.stationlabel24.text = FileAndData.getArriveStation(
                goorback: self.goorback2, keytag: "2")
            self.stationlabel25.text = FileAndData.getDepartStation(
                goorback: self.goorback2, keytag: "3")
            self.stationlabel26.text = FileAndData.getArriveStation(
                goorback: self.goorback2, keytag: "3")
            self.stationlabel2e.text = FileAndData.getDestination(
                goorback: self.goorback2)
            
            self.linelabel11.text = FileAndData.getLinename(
                goorback: self.goorback1, keytag: "1")
            self.linelabel12.text = FileAndData.getLinename(
                goorback: self.goorback1, keytag: "2")
            self.linelabel13.text = FileAndData.getLinename(
                goorback: self.goorback1, keytag: "3")
            self.linelabel21.text = FileAndData.getLinename(
                goorback: self.goorback2, keytag: "1")
            self.linelabel22.text = FileAndData.getLinename(
                goorback: self.goorback2, keytag: "2")
            self.linelabel23.text = FileAndData.getLinename(
                goorback: self.goorback2, keytag: "3")

            self.linelabel11.textColor = FileAndData.getLineColor(
                goorback: self.goorback1, keytag: "1", defaultcolor: 0x03DAC5)
            self.linelabel12.textColor = FileAndData.getLineColor(
                goorback: self.goorback1, keytag: "2", defaultcolor: 0x03DAC5)
            self.linelabel13.textColor = FileAndData.getLineColor(
                goorback: self.goorback1, keytag: "3", defaultcolor: 0x03DAC5)
            self.linelabel21.textColor = FileAndData.getLineColor(
                goorback: self.goorback2, keytag: "1", defaultcolor: 0x03DAC5)
            self.linelabel22.textColor = FileAndData.getLineColor(
                goorback: self.goorback2, keytag: "2", defaultcolor: 0x03DAC5)
            self.linelabel23.textColor = FileAndData.getLineColor(
                goorback: self.goorback2, keytag: "3", defaultcolor: 0x03DAC5)

            self.linetimetable11.backgroundColor = FileAndData.getLineColor(
                goorback: self.goorback1, keytag: "1", defaultcolor: 0x03DAC5)
            self.linetimetable12.backgroundColor = FileAndData.getLineColor(
                goorback: self.goorback1, keytag: "2", defaultcolor: 0x03DAC5)
            self.linetimetable13.backgroundColor = FileAndData.getLineColor(
                goorback: self.goorback1, keytag: "3", defaultcolor: 0x03DAC5)
            self.linetimetable21.backgroundColor = FileAndData.getLineColor(
                goorback: self.goorback2, keytag: "1", defaultcolor: 0x03DAC5)
            self.linetimetable22.backgroundColor = FileAndData.getLineColor(
                goorback: self.goorback2, keytag: "2", defaultcolor: 0x03DAC5)
            self.linetimetable23.backgroundColor = FileAndData.getLineColor(
                goorback: self.goorback2, keytag: "3", defaultcolor: 0x03DAC5)
            
            let changeline1 = FileAndData.getIntChangeLine(goorback: self.goorback1)
            let changeline2 = FileAndData.getIntChangeLine(goorback: self.goorback2)

            //時刻表
            let timetable1 = Timetable.getTimetableArray(
                goorback: self.goorback1, changeline: changeline1, weekflag: weekflag)
            let timetable2 = Timetable.getTimetableArray(
                goorback: self.goorback2, changeline: changeline2, weekflag: weekflag)

            //乗車時間
            let ridetime1 = DateAndTime.getRideTimeArray(
                goorback: self.goorback1, changeline: changeline1)
            let ridetime2 = DateAndTime.getRideTimeArray(
                goorback: self.goorback2, changeline: changeline2)

            //乗換時間
            let transittime1 = DateAndTime.getTransitTimeArray(
                goorback: self.goorback1, changeline: changeline1)
            let transittime2 = DateAndTime.getTransitTimeArray(
                goorback: self.goorback2, changeline: changeline2)
            
            //＜各時刻の計算＞
            //乗車可能時刻[0]・各発車時刻[1]・各到着時刻[2]
            let time1 = DateAndTime.getTimeArray(currenttime: currenttime, changeline: changeline1, transittime: transittime1, ridetime: ridetime1, timetable: timetable1)
            let time2 = DateAndTime.getTimeArray(currenttime: currenttime, changeline: changeline2, transittime: transittime2, ridetime: ridetime2, timetable: timetable2)

            //出発時刻
            let departtime1 = DateAndTime.getMinusHHMM(time1: time1[0][1], time2: transittime1[0])
            let departtime2 = DateAndTime.getMinusHHMM(time1: time2[0][1], time2: transittime2[0])
            
            //到着時刻
            let hometime1 = DateAndTime.getPlusHHMM(time1: time1[changeline1][2], time2: transittime1[changeline1 + 1])
            let hometime2 = DateAndTime.getPlusHHMM(time1: time2[changeline2][2], time2: transittime2[changeline2 + 1])
            
            //帰宅・外出ルートの表示・非表示
            self.display2stackview.isHidden = !UserDefaults.standard.bool(forKey: self.goorback2 + "switch")
            self.centerlineview.isHidden = !UserDefaults.standard.bool(forKey: self.goorback2 + "switch")
            
            if (DateAndTime.getStringTime(time: time1[0][1]) == "27:00"){
                self.timelabel10.text = "--:--"
                self.timelabel11.text = "--:--"
                self.timelabel12.text = "--:--"
                self.timelabel1e.text = "--:--"
                self.countdown1.text = "--:--"
            } else if (changeline1 > 0 && DateAndTime.getStringTime(time: time1[1][1]) == "27:00") {
                self.timelabel13.text = "--:--"
                self.timelabel14.text = "--:--"
            } else if (changeline1 > 1 && DateAndTime.getStringTime(time: time1[2][1]) == "27:00") {
                self.timelabel15.text = "--:--"
                self.timelabel16.text = "--:--"
            } else {
                //カウントダウン
                self.countdown1.text = DateAndTime.getCountdownTime(
                    currenthhmmss: currenttime,
                    departtime: departtime1,
                    timeflag: self.timeflag)
                self.countdown1.textColor = DateAndTime.getCountDownColor(
                    currenthhmmss: currenttime,
                    departtime: departtime1,
                    timeflag: self.timeflag)
                //時刻の表示
                self.timelabel10.text = DateAndTime.getStringTime(time: departtime1)
                self.timelabel11.text = DateAndTime.getStringTime(time: time1[0][1])
                self.timelabel12.text = DateAndTime.getStringTime(time: time1[0][2])
                switch (changeline1) {
                    case 2: do {
                        self.timelabel13.text = DateAndTime.getStringTime(time: time1[1][1])
                        self.timelabel14.text = DateAndTime.getStringTime(time: time1[1][2])
                        self.timelabel15.text = DateAndTime.getStringTime(time: time1[2][1])
                        self.timelabel16.text = DateAndTime.getStringTime(time: time1[2][2])
                    }
                    case 1: do {
                        self.timelabel13.text = DateAndTime.getStringTime(time: time1[1][1])
                        self.timelabel14.text = DateAndTime.getStringTime(time: time1[1][2])
                    }
                    default: do {
                    }
                }
                self.timelabel1e.text = DateAndTime.getStringTime(time: hometime1)
            }

            if (DateAndTime.getStringTime(time: time2[0][1]) == "27:00"){
                self.timelabel20.text = "--:--"
                self.timelabel21.text = "--:--"
                self.timelabel22.text = "--:--"
                self.timelabel2e.text = "--:--"
                self.countdown2.text = "--:--"
            } else if (changeline2 > 0 && DateAndTime.getStringTime(time: time2[1][1]) == "27:00") {
                self.timelabel23.text = "--:--"
                self.timelabel24.text = "--:--"
            } else if (changeline2 > 1 && DateAndTime.getStringTime(time: time2[2][1]) == "27:00") {
                self.timelabel25.text = "--:--"
                self.timelabel26.text = "--:--"
            } else {
                //カウントダウン
                self.countdown2.text = DateAndTime.getCountdownTime(
                    currenthhmmss: currenttime,
                    departtime: departtime2,
                    timeflag: self.timeflag)
                //時刻の表示
                self.countdown2.textColor = DateAndTime.getCountDownColor(
                    currenthhmmss: currenttime,
                    departtime: departtime2,
                    timeflag: self.timeflag)

                self.timelabel20.text = DateAndTime.getStringTime(time: departtime2)
                self.timelabel21.text = DateAndTime.getStringTime(time: time2[0][1])
                self.timelabel22.text = DateAndTime.getStringTime(time: time2[0][2])
                self.timelabel2e.text = DateAndTime.getStringTime(time: hometime2)
                switch (changeline2) {
                    case 2: do {
                        self.timelabel23.text = DateAndTime.getStringTime(time: time2[1][1])
                        self.timelabel24.text = DateAndTime.getStringTime(time: time2[1][2])
                        self.timelabel25.text = DateAndTime.getStringTime(time: time2[2][1])
                        self.timelabel26.text = DateAndTime.getStringTime(time: time2[2][2])
                    }
                    case 1: do {
                        self.timelabel23.text = DateAndTime.getStringTime(time: time2[1][1])
                        self.timelabel24.text = DateAndTime.getStringTime(time: time2[1][2])
                    }
                    default: do {
                    }
                }
            }
            
            //乗換回数に応じた表示
            FileAndData.changeDisplayLine(changeline: changeline1, stackview2: self.linestackview12, stackview3: self.linestackview13)
            FileAndData.changeDisplayLine(changeline: changeline2, stackview2: self.linestackview22, stackview3: self.linestackview23)
        })
    }
    
    //帰宅ルートの表示ボタン
    @IBAction func backbutton(_ sender: Any) {
        DateAndTime.setButtonEnabled(flag: false, button: backbutton, color: 0x3700B3)
        DateAndTime.setButtonEnabled(flag: true, button: gobutton, color: 0x8E8E93)
        goorbackflag = true
        goorback1 = "back1"
        goorback2 = "back2"
    }

    //外出ルートの表示ボタン
    @IBAction func gobutton(_ sender: Any) {
        DateAndTime.setButtonEnabled(flag: true, button: backbutton, color: 0x8E8E93)
        DateAndTime.setButtonEnabled(flag: false, button: gobutton, color: 0x3700B3)
        goorbackflag = false
        goorback1 = "go1"
        goorback2 = "go2"
    }
    
    //現在時刻の再開ボタン
    @IBAction func startbutton(_ sender: Any) {
        DateAndTime.setButtonEnabled(flag: false, button: startbutton, color: 0x03DAC5)
        DateAndTime.setButtonEnabled(flag: true, button: stopbutton, color: 0x8E8E93)
        timeflag = true
        datebutton.isEnabled = false
        timebutton.isEnabled = false
    }

    //現在時刻の停止ボタン
    @IBAction func stopbutton(_ sender: Any) {
        DateAndTime.setButtonEnabled(flag: true, button: startbutton, color: 0x8E8E93)
        DateAndTime.setButtonEnabled(flag: false, button: stopbutton, color: 0x03DAC5)
        timeflag = false
        datebutton.isEnabled = true
        timebutton.isEnabled = true
    }
    
    //日時の変更ボタン
    @IBAction func datebutton(_ sender: Any) {
        if (!timeflag) {
            CustomDialog.setDatePickerDialog(
                viewcontroller: self,
                datepickermode: .date,
                datebutton: datebutton,
                stringformat: "E, MMM d, yyyy")
        }
    }
    
    //時刻の変更ボタン
    @IBAction func timebutton(_ sender: Any) {
        if (!timeflag) {
            CustomDialog.setDatePickerDialog(
                viewcontroller: self,
                datepickermode: .time,
                datebutton: timebutton,
                stringformat: "HH:mm")
        }
    }

    @IBAction func stationlabel10(_ sender: Any) {
        CustomDialog.departurepointTextFieldDialog(
            viewcontroller: self,
            label: stationlabel10,
            goorback: goorback1)
    }
    
    @IBAction func stationlabel11(_ sender: Any) {
        CustomDialog.departStationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel11,
            goorback: goorback1,
            keytag: "1")
    }
    
    @IBAction func stationlabel12(_ sender: Any) {
        CustomDialog.arriveStationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel12,
            goorback: goorback1,
            keytag: "1")
    }
    
    @IBAction func stationlabel13(_ sender: Any) {
        CustomDialog.departStationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel13,
            goorback: goorback1,
            keytag: "2")
    }
    
    @IBAction func stationlabel14(_ sender: Any) {
        CustomDialog.arriveStationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel14,
            goorback: goorback1,
            keytag: "2")
    }
    
    @IBAction func stationlabel15(_ sender: Any) {
        CustomDialog.departStationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel15,
            goorback: goorback1,
            keytag: "3")
    }
    
    @IBAction func stationlabel16(_ sender: Any) {
        CustomDialog.arriveStationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel16,
            goorback: goorback1,
            keytag: "3")
    }
    
    @IBAction func stationlabel1e(_ sender: Any) {
        CustomDialog.destinationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel1e,
            goorback: goorback1)
    }
    
    @IBAction func stationlabel20(_ sender: Any) {
        CustomDialog.departurepointTextFieldDialog(
            viewcontroller: self,
            label: stationlabel20,
            goorback: goorback2)
    }
    
    @IBAction func stationlabel21(_ sender: Any) {
        CustomDialog.departStationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel21,
            goorback: goorback2,
            keytag: "1")
    }
    
    @IBAction func stationlabel22(_ sender: Any) {
        CustomDialog.arriveStationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel22,
            goorback: goorback2,
            keytag: "1")
    }
    
    @IBAction func stationlabel23(_ sender: Any) {
        CustomDialog.departStationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel23,
            goorback: goorback2,
            keytag: "2")
    }
    
    @IBAction func stationlabel24(_ sender: Any) {
        CustomDialog.arriveStationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel24,
            goorback: goorback2,
            keytag: "2")
    }
    
    @IBAction func stationlabel25(_ sender: Any) {
        CustomDialog.departStationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel25,
            goorback: goorback2,
            keytag: "3")
    }
    
    @IBAction func stationlabel26(_ sender: Any) {
        CustomDialog.arriveStationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel26,
            goorback: goorback2,
            keytag: "3")
    }
    
    @IBAction func stationlabel2e(_ sender: Any) {
        CustomDialog.destinationTextFieldDialog(
            viewcontroller: self,
            label: stationlabel2e,
            goorback: goorback2)
    }
    
    @IBAction func linelabel11(_ sender: Any) {
        CustomDialog.lineTextFieldDialog(
            viewcontroller: self,
            label: linelabel11,
            stackview: linetimetable11,
            goorback: goorback1,
            keytag: "1")
    }
    
    @IBAction func linelabel12(_ sender: Any) {
        CustomDialog.lineTextFieldDialog(
            viewcontroller: self,
            label: linelabel12,
            stackview: linetimetable12,
            goorback: goorback1,
            keytag: "2")
    }
    
    @IBAction func linelabel13(_ sender: Any) {
        CustomDialog.lineTextFieldDialog(
            viewcontroller: self,
            label: linelabel13,
            stackview: linetimetable13,
            goorback: goorback1,
            keytag: "3")
    }
    
    @IBAction func linelabel21(_ sender: Any) {
        CustomDialog.lineTextFieldDialog(
            viewcontroller: self,
            label: linelabel21,
            stackview: linetimetable21,
            goorback: goorback2,
            keytag: "1")
    }
    
    @IBAction func linelabel22(_ sender: Any) {
        CustomDialog.lineTextFieldDialog(
            viewcontroller: self,
            label: linelabel22,
            stackview: linetimetable22,
            goorback: goorback2,
            keytag: "2")
    }
    
    @IBAction func linelabel23(_ sender: Any) {
        CustomDialog.lineTextFieldDialog(
            viewcontroller: self,
            label: linelabel23,
            stackview: linetimetable23,
            goorback: goorback2,
            keytag: "3")
    }
    
    @IBAction func linetimetable11(_ sender: Any) {
        CustomDialog.rideTimeFieldDialog(
            viewcontroller: self,
            stackview: linetimetable11,
            goorback: goorback1,
            keytag: "1",
            weekflag: weekflag)
    }
    
    
    @IBAction func linetimetable12(_ sender: Any) {
        CustomDialog.rideTimeFieldDialog(
            viewcontroller: self,
            stackview: linetimetable12,
            goorback: goorback1,
            keytag: "2",
            weekflag: weekflag)
    }

    @IBAction func linetimetable13(_ sender: Any) {
        CustomDialog.rideTimeFieldDialog(
            viewcontroller: self,
            stackview: linetimetable13,
            goorback: goorback1,
            keytag: "3",
            weekflag: weekflag)
    }
    
    @IBAction func linetimetable21(_ sender: Any) {
        CustomDialog.rideTimeFieldDialog(
            viewcontroller: self,
            stackview: linetimetable21,
            goorback: goorback2,
            keytag: "1",
            weekflag: weekflag)
    }
    
    @IBAction func linetimetable22(_ sender: Any) {
        CustomDialog.rideTimeFieldDialog(
            viewcontroller: self,
            stackview: linetimetable22,
            goorback: goorback2,
            keytag: "2",
            weekflag: weekflag)
    }
    
    @IBAction func linetimetable23(_ sender: Any) {
        CustomDialog.rideTimeFieldDialog(
            viewcontroller: self,
            stackview: linetimetable23,
            goorback: goorback2,
            keytag: "3",
            weekflag: weekflag)
    }

    @IBAction func transportlabel11(_ sender: Any) {
        CustomDialog.transportPickerDialog(
            viewcontroller: self,
            label: transportlabel11,
            goorback: goorback1,
            keytag: "1")
    }
    
    @IBAction func transportlabel12(_ sender: Any) {
        CustomDialog.transportPickerDialog(
            viewcontroller: self,
            label: transportlabel13,
            goorback: goorback1,
            keytag: "2")
    }
    
    @IBAction func transportlabel13(_ sender: Any) {
        CustomDialog.transportPickerDialog(
            viewcontroller: self,
            label: transportlabel13,
            goorback: goorback1,
            keytag: "3")
    }
    
    @IBAction func transportlabel1e(_ sender: Any) {
        CustomDialog.transportPickerDialog(
            viewcontroller: self,
            label: transportlabel1e,
            goorback: goorback1,
            keytag: "e")
    }

    @IBAction func transportlabel21(_ sender: Any) {
        CustomDialog.transportPickerDialog(
            viewcontroller: self,
            label: transportlabel21,
            goorback: goorback2,
            keytag: "1")
    }
    
    @IBAction func transportlabel22(_ sender: Any) {
        CustomDialog.transportPickerDialog(
            viewcontroller: self,
            label: transportlabel22,
            goorback: goorback2,
            keytag: "2")
    }
    
    @IBAction func transportlabel23(_ sender: Any) {
        CustomDialog.transportPickerDialog(
            viewcontroller: self,
            label: transportlabel23,
            goorback: goorback2,
            keytag: "3")
    }
    
    @IBAction func transportlabel2e(_ sender: Any) {
        CustomDialog.transportPickerDialog(
            viewcontroller: self,
            label: transportlabel2e,
            goorback: goorback2,
            keytag: "e")
    }
    
    @IBAction func transittimelabel11(_ sender: Any) {
        CustomDialog.transitTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback1,
            keytag: "1")
    }
    
    @IBAction func transittomelabel12(_ sender: Any) {
        CustomDialog.transitTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback1,
            keytag: "2")
    }
    
    @IBAction func transittimelabel13(_ sender: Any) {
        CustomDialog.transitTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback1,
            keytag: "3")
    }
    
    @IBAction func transittimelabel1e(_ sender: Any) {
        CustomDialog.transitTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback1,
            keytag: "e")
    }
    
    @IBAction func transittimelabel21(_ sender: Any) {
        CustomDialog.transitTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback2,
            keytag: "1")
    }
    
    @IBAction func transittimelabel22(_ sender: Any) {
        CustomDialog.transitTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback2,
            keytag: "2")
    }
    
    @IBAction func transittimelabel23(_ sender: Any) {
        CustomDialog.transitTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback2,
            keytag: "3")
    }
    
    @IBAction func transittimelabel2e(_ sender: Any) {
        CustomDialog.transitTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback2,
            keytag: "e")
    }
    
    //ステータスバーの色を白に変更
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
