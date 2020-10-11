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
    var weekflag = DateAndTime.getWeekFlag()
    
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
        //VariousSettingsのタイトルを取得
        self.title = FileAndData.getVariousSettingsTitle(goorback: goorback!)
        let changeline = FileAndData.getIntChangeLine(goorback: goorback!)
    
        departplacelabel.text = SettingPreference.getPrefDepartPlace(
            goorback: goorback!)
        departstationlabel1.text = SettingPreference.getPrefDepartStation(
            goorback: goorback!,
            keytag: "1")
        arrivalstationlabel1.text = SettingPreference.getPrefArriveStation(
            goorback: goorback!,
            keytag: "1")
        departstationlabel2.text = SettingPreference.getPrefDepartStation(
            goorback: goorback!,
            keytag: "2")
        arrivalstationlabel2.text = SettingPreference.getPrefArriveStation(
            goorback: goorback!,
            keytag: "2")
        departstationlabel3.text = SettingPreference.getPrefDepartStation(
            goorback: goorback!,
            keytag: "3")
        arrivalstationlabel3.text = SettingPreference.getPrefArriveStation(
            goorback: goorback!,
            keytag: "3")
        destinationlabel.text = SettingPreference.getPrefDestination(
            goorback: goorback!)

        linenamelabel1.text = SettingPreference.getLineName(
            goorback: goorback!,
            keytag: "1")
        linenamelabel2.text = SettingPreference.getLineName(
            goorback: goorback!,
            keytag: "2")
        linenamelabel3.text = SettingPreference.getLineName(
            goorback: goorback!,
            keytag: "3")
        ridetimelabel1.text = SettingPreference.getStringRideTime(
            goorback: goorback!,
            keytag: "1")
        ridetimelabel2.text = SettingPreference.getStringRideTime(
            goorback: goorback!,
            keytag: "2")
        ridetimelabel3.text = SettingPreference.getStringRideTime(
            goorback: goorback!,
            keytag: "3")

        linenamelabel1.textColor = SettingPreference.getLineColor(
            goorback: goorback!,
            keytag: "1")
        linenamelabel2.textColor = SettingPreference.getLineColor(
            goorback: goorback!,
            keytag: "2")
        linenamelabel3.textColor = SettingPreference.getLineColor(
            goorback: goorback!,
            keytag: "3")
        ridetimelabel1.textColor = SettingPreference.getLineColor(
            goorback: goorback!,
            keytag: "1")
        ridetimelabel2.textColor = SettingPreference.getLineColor(
            goorback: goorback!,
            keytag: "2")
        ridetimelabel3.textColor = SettingPreference.getLineColor(
            goorback: goorback!,
            keytag: "3")

        transportationlabel1.text = SettingPreference.getTransportation(
            goorback: goorback!,
            keytag: "1")
        transportationlabel2.text = SettingPreference.getTransportation(
            goorback: goorback!,
            keytag: "2")
        transportationlabel3.text = SettingPreference.getTransportation(
            goorback: goorback!,
            keytag: "3")
        transportationlabele.text = SettingPreference.getTransportation(
            goorback: goorback!,
            keytag: "e")
        transittimelabel1.text = SettingPreference.getStringTransitTime(
            goorback: goorback!,
            keytag: "1")
        transittimelabel2.text = SettingPreference.getStringTransitTime(
            goorback: goorback!,
            keytag: "2")
        transittimelabel3.text = SettingPreference.getStringTransitTime(
            goorback: goorback!,
            keytag: "3")
        transittimelabele.text = SettingPreference.getStringTransitTime(
            goorback: goorback!,
            keytag: "e")
        
        SettingPreference.setPreferenceCondition(
            label: departstationlabel2,
            button: departstationbutton2,
            changeline: changeline,
            keytag: "2")
        SettingPreference.setPreferenceCondition(
            label: arrivalstationlabel2,
            button: arrivalstationbutton2,
            changeline: changeline,
            keytag: "2")
        SettingPreference.setPreferenceCondition(
            label: departstationlabel3,
            button: departstationbutton3,
            changeline: changeline,
            keytag: "3")
        SettingPreference.setPreferenceCondition(
            label: arrivalstationlabel3,
            button: arrivalstationbutton3,
            changeline: changeline,
            keytag: "3")
        
        SettingPreference.setPreferenceCondition(
            label: linenamelabel2,
            button: linenamebutton2,
            changeline: changeline,
            keytag: "2")
        SettingPreference.setPreferenceCondition(
            label: ridetimelabel2,
            button: ridetimebutton2,
            changeline: changeline,
            keytag: "2")
        SettingPreference.setPreferenceCondition(
            label: linenamelabel3,
            button: linenamebutton3,
            changeline: changeline,
            keytag: "3")
        SettingPreference.setPreferenceCondition(
            label: ridetimelabel3,
            button: ridetimebutton3,
            changeline: changeline,
            keytag: "3")
        
        SettingPreference.setPreferenceCondition(
            label: transportationlabel2,
            button: transportationbutton2,
            changeline: changeline,
            keytag: "2")
        SettingPreference.setPreferenceCondition(
            label: transittimelabel2,
            button: transittimebutton2,
            changeline: changeline,
            keytag: "2")
        SettingPreference.setPreferenceCondition(
            label: transportationlabel3,
            button: transportationbutton3,
            changeline: changeline,
            keytag: "3")
        SettingPreference.setPreferenceCondition(
            label: transittimelabel3,
            button: transittimebutton3,
            changeline: changeline,
            keytag: "3")
     }
    
    @IBAction func departplacebutton(_ sender: Any) {
        CustomDialog.departurepointTextFieldDialog(
            viewcontroller: self,
            label: departplacelabel,
            goorback: goorback!)
    }
    
    @IBAction func departstationbutton1(_ sender: Any) {
        CustomDialog.prefDepartStationTextFieldDialog(
            viewcontroller:self,
            label: departstationlabel1,
            goorback: goorback!,
            keytag: "1")
    }
    
    @IBAction func arrivalstationbutton1(_ sender: Any) {
        CustomDialog.prefArriveStationTextFieldDialog(
            viewcontroller:self,
            label: arrivalstationlabel1,
            goorback: goorback!,
            keytag: "1")
    }
    
    @IBAction func departstationbutton2(_ sender: Any) {
        CustomDialog.prefDepartStationTextFieldDialog(
            viewcontroller:self,
            label: departstationlabel2,
            goorback: goorback!,
            keytag: "2")
    }
    
    @IBAction func arrivalstationbutton2(_ sender: Any) {
        CustomDialog.prefArriveStationTextFieldDialog(
            viewcontroller:self,
            label: arrivalstationlabel2,
            goorback: goorback!,
            keytag: "2")
    }
    
    @IBAction func departstationbutton3(_ sender: Any) {
        CustomDialog.prefDepartStationTextFieldDialog(
            viewcontroller:self,
            label: departstationlabel3,
            goorback: goorback!,
            keytag: "3")
    }
    
    @IBAction func arrivalstationbutton3(_ sender: Any) {
        CustomDialog.prefArriveStationTextFieldDialog(
            viewcontroller:self,
            label: arrivalstationlabel3,
            goorback: goorback!,
            keytag: "3")
    }
    
    @IBAction func destinationbutton(_ sender: Any) {
        CustomDialog.destinationTextFieldDialog(
            viewcontroller: self,
            label: destinationlabel,
            goorback: goorback!)
    }
    
    @IBAction func linenamebutton1(_ sender: Any) {
        CustomDialog.prefLineTextFieldDialog(
            viewcontroller: self,
            linenamelabel: linenamelabel1,
            ridetimelabel: ridetimelabel1,
            goorback: goorback!,
            keytag: "1")
    }
    
    @IBAction func linenamebutton2(_ sender: Any) {
        CustomDialog.prefLineTextFieldDialog(
            viewcontroller: self,
            linenamelabel: linenamelabel2,
            ridetimelabel: ridetimelabel2,
            goorback: goorback!,
            keytag: "2")
    }
    
    @IBAction func linenamebutton3(_ sender: Any) {
        CustomDialog.prefLineTextFieldDialog(
            viewcontroller: self,
            linenamelabel: linenamelabel3,
            ridetimelabel: ridetimelabel3,
            goorback: goorback!,
            keytag: "3")
    }
    
    @IBAction func ridetimebutton1(_ sender: Any) {
        CustomDialog.prefRideTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback!,
            keytag: "1",
            weekflag: weekflag)
        ridetimelabel1.text = SettingPreference.getStringRideTime(
            goorback: goorback!,
            keytag: "1")
    }
    
    @IBAction func ridetimebutton2(_ sender: Any) {
        CustomDialog.prefRideTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback!,
            keytag: "2",
            weekflag: weekflag)
        ridetimelabel2.text = SettingPreference.getStringRideTime(
            goorback: goorback!,
            keytag: "2")
    }
    
    @IBAction func ridetimebutton3(_ sender: Any) {
        CustomDialog.prefRideTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback!,
            keytag: "3",
            weekflag: weekflag)
        ridetimelabel3.text = SettingPreference.getStringRideTime(
            goorback: goorback!,
            keytag: "3")
    }
    
    @IBAction func transportationbutton1(_ sender: Any) {
        CustomDialog.prefTransportPickerDialog(
            viewcontroller: self,
            label: transportationlabel1,
            goorback: goorback!,
            keytag: "1")
    }
    
    @IBAction func transportationbutton2(_ sender: Any) {
        CustomDialog.prefTransportPickerDialog(
            viewcontroller: self,
            label: transportationlabel2,
            goorback: goorback!,
            keytag: "2")
    }
    
    @IBAction func transportationbutton3(_ sender: Any) {
        CustomDialog.prefTransportPickerDialog(
            viewcontroller: self,
            label: transportationlabel3,
            goorback: goorback!,
            keytag: "3")
    }
    
    @IBAction func transportationbuttone(_ sender: Any) {
        CustomDialog.prefTransportPickerDialog(
            viewcontroller: self,
            label: transportationlabele,
            goorback: goorback!,
            keytag: "e")
    }
    
    @IBAction func transittimebutton1(_ sender: Any) {
        CustomDialog.prefTransitTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback!,
            keytag: "1")
        transittimelabel1.text = SettingPreference.getStringTransitTime(
            goorback: goorback!,
            keytag: "1")
    }
    
    @IBAction func transittimebutton2(_ sender: Any) {
        CustomDialog.prefTransitTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback!,
            keytag: "2")
        transittimelabel2.text = SettingPreference.getStringTransitTime(
            goorback: goorback!,
            keytag: "2")
    }
    
    @IBAction func transittimebutton3(_ sender: Any) {
        CustomDialog.prefTransitTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback!,
            keytag: "3")
        transittimelabel3.text = SettingPreference.getStringTransitTime(
            goorback: goorback!,
            keytag: "3")
    }
    
    @IBAction func transittimebuttone(_ sender: Any) {
        CustomDialog.prefTransitTimeFieldDialog(
            viewcontroller: self,
            goorback: goorback!,
            keytag: "e")
        transittimelabele.text = SettingPreference.getStringTransitTime(
            goorback: goorback!,
            keytag: "e")
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(rgb: 0x03DAC5)
        let header = view as! UITableViewHeaderFooterView
        // テキスト色を変更する
        header.textLabel?.textColor = UIColor(rgb: 0xFFFFFF)
    }
}
