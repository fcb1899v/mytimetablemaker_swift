//
//  VariousSettingsTableViewController.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/04.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class VariousSettingsTableViewController: UITableViewController {

    var goorback: String?
    var weekflag = Date().weekFlag

    let notset = Unit.notset.rawValue.localized
    let notuse = Unit.notuse.rawValue.localized
    let black = DefaultColor.black.rawValue
    let gray = DefaultColor.gray.rawValue
    let uigray = DefaultColor.gray.UI
    
    @IBOutlet weak var departplacelabel: UILabel!
    @IBOutlet weak var departstationlabel1: UILabel!
    @IBOutlet weak var arrivalstationlabel1: UILabel!
    @IBOutlet weak var departstationlabel2: UILabel!
    @IBOutlet weak var arrivalstationlabel2: UILabel!
    @IBOutlet weak var departstationlabel3: UILabel!
    @IBOutlet weak var arrivalstationlabel3: UILabel!
    @IBOutlet weak var destinationlabel: UILabel!
    
    @IBOutlet weak var linenamelabel1: UILabel!
    @IBOutlet weak var linenamelabel2: UILabel!
    @IBOutlet weak var linenamelabel3: UILabel!
    @IBOutlet weak var ridetimelabel1: UILabel!
    @IBOutlet weak var ridetimelabel2: UILabel!
    @IBOutlet weak var ridetimelabel3: UILabel!
    
    @IBOutlet weak var transportationlabel1: UILabel!
    @IBOutlet weak var transportationlabel2: UILabel!
    @IBOutlet weak var transportationlabel3: UILabel!
    @IBOutlet weak var transportationlabele: UILabel!
    
    @IBOutlet weak var transittimelabel1: UILabel!
    @IBOutlet weak var transittimelabel2: UILabel!
    @IBOutlet weak var transittimelabel3: UILabel!
    @IBOutlet weak var transittimelabele: UILabel!
    
    @IBOutlet weak var departstationbutton2: UIButton!
    @IBOutlet weak var arrivalstationbutton2: UIButton!
    @IBOutlet weak var departstationbutton3: UIButton!
    @IBOutlet weak var arrivalstationbutton3: UIButton!
    
    @IBOutlet weak var linenamebutton2: UIButton!
    @IBOutlet weak var linenamebutton3: UIButton!
    @IBOutlet weak var ridetimebutton2: UIButton!
    @IBOutlet weak var ridetimebutton3: UIButton!
    
    @IBOutlet weak var transportationbutton2: UIButton!
    @IBOutlet weak var transportationbutton3: UIButton!
    @IBOutlet weak var transittimebutton2: UIButton!
    @IBOutlet weak var transittimebutton3: UIButton!

    var departstationlabelarray: [UILabel] = []
    var arrivalstationlabelarray: [UILabel] = []
    var linenamelabelarray: [UILabel] = []
    var ridetimelabelarray: [UILabel] = []
    var transportationlabelarray: [UILabel] = []
    var transittimelabelarray: [UILabel] = []

    var departstationbuttonarray: [UIButton] = []
    var arrivalstationbuttonarray: [UIButton] = []
    var linenamebuttonarray: [UIButton] = []
    var ridetimebuttonarray: [UIButton] = []
    var transportationbuttonarray: [UIButton] = []
    var transittimebuttonarray: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let changeline = goorback!.changeLineInt

        departstationlabelarray = [departstationlabel1, departstationlabel2, departstationlabel3]
        arrivalstationlabelarray = [arrivalstationlabel1, arrivalstationlabel2, arrivalstationlabel3]
        linenamelabelarray = [linenamelabel1, linenamelabel2, linenamelabel3]
        ridetimelabelarray = [ridetimelabel1, ridetimelabel2, ridetimelabel3]
        transportationlabelarray = [transportationlabele, transportationlabel1, transportationlabel2, transportationlabel3]
        transittimelabelarray = [transittimelabele, transittimelabel1, transittimelabel2, transittimelabel3]

        departstationbuttonarray = [departstationbutton2, departstationbutton3]
        arrivalstationbuttonarray = [arrivalstationbutton2, arrivalstationbutton3]
        linenamebuttonarray = [linenamebutton2, linenamebutton3]
        ridetimebuttonarray = [ridetimebutton2, ridetimebutton3]
        transportationbuttonarray = [transportationbutton2, transportationbutton3]
        transittimebuttonarray = [transittimebutton2, transittimebutton3]

        //VariousSettingsのタイトルを取得
        self.title = goorback!.variousSettingsTitle

        //VariousSettingsの各種表示
        departplacelabel.text = goorback!.departurePoint(notset, notset)
        destinationlabel.text = goorback!.destination(notset, notset)
        for i in 0...2 {
            departstationlabelarray[i].text = goorback!.departStation("\(i + 1)", notset)
            arrivalstationlabelarray[i].text = goorback!.arriveStation("\(i + 1)", notset)
            linenamelabelarray[i].text = goorback!.lineName("\(i + 1)", notset)
            ridetimelabelarray[i].text = goorback!.rideTimeString("\(i + 1)")
            linenamelabelarray[i].textColor = goorback!.lineColor("\(i + 1)", black)
            ridetimelabelarray[i].textColor = goorback!.lineColor("\(i + 1)", black)
            transportationlabelarray[i + 1].text = goorback!.transportation("\(i + 1)", notset)
            transittimelabelarray[i + 1].text = goorback!.transitTimeString("\(i + 1)")
        }
        transportationlabelarray[0].text = goorback!.transportation("e", notset)
        transittimelabelarray[0].text = goorback!.transitTimeString("e")

        //乗換回数に応じて表示を変更
        for i in 1...2 {
            if (changeline < i) {
                departstationlabelarray[i].text = notuse
                arrivalstationlabelarray[i].text = notuse
                linenamelabelarray[i].text = notuse
                ridetimelabelarray[i].text = notuse
                transportationlabelarray[i + 1].text = notuse
                transittimelabelarray[i + 1].text = notuse
                departstationlabelarray[i].textColor = uigray
                arrivalstationlabelarray[i].textColor = uigray
                linenamelabelarray[i].textColor = uigray
                ridetimelabelarray[i].textColor = uigray
                transportationlabelarray[i + 1].textColor = uigray
                transittimelabelarray[i + 1].textColor = uigray
                departstationbuttonarray[i - 1].setButtonColor(gray)
                arrivalstationbuttonarray[i - 1].setButtonColor(gray)
                linenamebuttonarray[i - 1].setButtonColor(gray)
                ridetimebuttonarray[i - 1].setButtonColor(gray)
                transportationbuttonarray[i - 1].setButtonColor(gray)
                transittimebuttonarray[i - 1].setButtonColor(gray)
                departstationbuttonarray[i - 1].isEnabled = false
                arrivalstationbuttonarray[i - 1].isEnabled = false
                linenamebuttonarray[i - 1].isEnabled = false
                ridetimebuttonarray[i - 1].isEnabled = false
                transportationbuttonarray[i - 1].isEnabled = false
                transittimebuttonarray[i - 1].isEnabled = false
            }
        }
     }
    
    @IBAction func departplacebutton(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefDeparturePointTextFieldDialog(departplacelabel)
    }
    
    @IBAction func departstationbutton1(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefDepartStationTextFieldDialog(departstationlabel1, "1")
    }
    
    @IBAction func arrivalstationbutton1(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefArriveStationTextFieldDialog(arrivalstationlabel1, "1")
    }
    
    @IBAction func departstationbutton2(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefDepartStationTextFieldDialog(departstationlabel2, "2")
    }
    
    @IBAction func arrivalstationbutton2(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefArriveStationTextFieldDialog(arrivalstationlabel2, "2")
    }
    
    @IBAction func departstationbutton3(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefDepartStationTextFieldDialog(departstationlabel3, "3")
    }
    
    @IBAction func arrivalstationbutton3(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefArriveStationTextFieldDialog(arrivalstationlabel3, "3")
    }
    
    @IBAction func destinationbutton(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefDestinationTextFieldDialog(destinationlabel)
    }
    
    @IBAction func linenamebutton1(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefLineTextFieldDialog(linenamelabel1, ridetimelabel1, "1")
    }
    
    @IBAction func linenamebutton2(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefLineTextFieldDialog(linenamelabel2, ridetimelabel2, "2")
    }
    
    @IBAction func linenamebutton3(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefLineTextFieldDialog(linenamelabel3, ridetimelabel3, "3")
    }
    
    @IBAction func ridetimebutton1(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefRideTimeFieldDialog(ridetimelabel1, "1", weekflag)
    }
    
    @IBAction func ridetimebutton2(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefRideTimeFieldDialog(ridetimelabel2, "2", weekflag)
    }
    
    @IBAction func ridetimebutton3(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefRideTimeFieldDialog(ridetimelabel3, "3", weekflag)
    }
    
    @IBAction func transportationbutton1(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefTransportPickerDialog(transportationlabel1, "1")
    }
    
    @IBAction func transportationbutton2(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefTransportPickerDialog(transportationlabel2, "2")
    }
    
    @IBAction func transportationbutton3(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefTransportPickerDialog(transportationlabel3, "3")
    }
    
    @IBAction func transportationbuttone(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefTransportPickerDialog(transportationlabele, "e")
    }
    
    @IBAction func transittimebutton1(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefTransitTimeFieldDialog(transittimelabel1, "1")
    }
    
    @IBAction func transittimebutton2(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefTransitTimeFieldDialog(transittimelabel2, "2")
    }
    
    @IBAction func transittimebutton3(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefTransitTimeFieldDialog(transittimelabel3, "3")
    }
    
    @IBAction func transittimebuttone(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefTransitTimeFieldDialog(transittimelabele, "e")
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = DefaultColor.accent.UI
        let header = view as! UITableViewHeaderFooterView
        // テキスト色を変更する
        header.textLabel?.textColor = DefaultColor.white.UI
    }
}
