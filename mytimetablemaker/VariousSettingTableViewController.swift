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
        
    override func viewDidLoad() {
        super.viewDidLoad()

        let changeline = goorback!.changeLineInt
        let notset = Unit.notset.rawValue.localized
        let notuse = Unit.notuse.rawValue.localized
        let black = DefaultColor.black.rawValue
        let gray = DefaultColor.gray.rawValue
        let uigray = DefaultColor.gray.UI

        //VariousSettingsのタイトルを取得
        self.title = goorback!.variousSettingsTitle

        departplacelabel.text = goorback!.departurePoint(notset, notset)
        departstationlabel1.text = goorback!.departStation("1", notset)
        arrivalstationlabel1.text = goorback!.arriveStation("1", notset)
        departstationlabel2.text = goorback!.departStation("2", notset)
        arrivalstationlabel2.text = goorback!.arriveStation("2", notset)
        departstationlabel3.text = goorback!.departStation("3", notset)
        arrivalstationlabel3.text = goorback!.arriveStation("3", notset)
        destinationlabel.text = goorback!.destination(notset, notset)

        linenamelabel1.text = goorback!.lineName("1", notset)
        linenamelabel2.text = goorback!.lineName("2", notset)
        linenamelabel3.text = goorback!.lineName("3", notset)
        ridetimelabel1.text = goorback!.rideTimeString("1")
        ridetimelabel2.text = goorback!.rideTimeString("2")
        ridetimelabel3.text = goorback!.rideTimeString("3")

        linenamelabel1.textColor = goorback!.lineColor("1", black)
        linenamelabel2.textColor = goorback!.lineColor("2", black)
        linenamelabel3.textColor = goorback!.lineColor("3", black)
        ridetimelabel1.textColor = goorback!.lineColor("1", black)
        ridetimelabel2.textColor = goorback!.lineColor("2", black)
        ridetimelabel3.textColor = goorback!.lineColor("3", black)

        transportationlabel1.text = goorback!.transportation("1", "Walking".localized)
        transportationlabel2.text = goorback!.transportation("2", "Walking".localized)
        transportationlabel3.text = goorback!.transportation("3", "Walking".localized)
        transportationlabele.text = goorback!.transportation("e", "Walking".localized)
        transittimelabel1.text = goorback!.transitTimeString("1")
        transittimelabel2.text = goorback!.transitTimeString("2")
        transittimelabel3.text = goorback!.transitTimeString("3")
        transittimelabele.text = goorback!.transitTimeString("e")
        
        if (changeline < 1) {
            departstationlabel2.text = notuse
            arrivalstationlabel2.text = notuse
            linenamelabel2.text = notuse
            ridetimelabel2.text = notuse
            transportationlabel2.text = notuse
            transittimelabel2.text = notuse
            departstationlabel2.textColor = uigray
            arrivalstationlabel2.textColor = uigray
            linenamelabel2.textColor = uigray
            ridetimelabel2.textColor = uigray
            transportationlabel2.textColor = uigray
            transittimelabel2.textColor = uigray
            departstationbutton2.setButtonColor(gray)
            arrivalstationbutton2.setButtonColor(gray)
            linenamebutton2.setButtonColor(gray)
            ridetimebutton2.setButtonColor(gray)
            transportationbutton2.setButtonColor(gray)
            transittimebutton2.setButtonColor(gray)
        }
        
        if (changeline < 2) {
            departstationlabel3.text = notuse
            arrivalstationlabel3.text = notuse
            linenamelabel3.text = notuse
            ridetimelabel3.text = notuse
            transportationlabel3.text = notuse
            transittimelabel3.text = notuse
            departstationlabel3.textColor = uigray
            arrivalstationlabel3.textColor = uigray
            linenamelabel3.textColor = uigray
            ridetimelabel3.textColor = uigray
            transportationlabel3.textColor = uigray
            transittimelabel3.textColor = uigray
            departstationbutton3.setButtonColor(gray)
            arrivalstationbutton3.setButtonColor(gray)
            linenamebutton3.setButtonColor(gray)
            ridetimebutton3.setButtonColor(gray)
            transportationbutton3.setButtonColor(gray)
            transittimebutton3.setButtonColor(gray)
        }

        departstationbutton2.isEnabled = changeline.buttonEnabled(1)
        departstationbutton3.isEnabled = changeline.buttonEnabled(2)
        arrivalstationbutton2.isEnabled = changeline.buttonEnabled(1)
        arrivalstationbutton3.isEnabled = changeline.buttonEnabled(2)
        linenamebutton2.isEnabled = changeline.buttonEnabled(1)
        linenamebutton3.isEnabled = changeline.buttonEnabled(2)
        ridetimebutton2.isEnabled = changeline.buttonEnabled(1)
        ridetimebutton3.isEnabled = changeline.buttonEnabled(2)
        transportationbutton2.isEnabled = changeline.buttonEnabled(1)
        transportationbutton3.isEnabled = changeline.buttonEnabled(2)
        transittimebutton2.isEnabled = changeline.buttonEnabled(1)
        transittimebutton3.isEnabled = changeline.buttonEnabled(2)
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
