//
//  VariousSettingsTableViewController.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/09/04.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

// MARK: - Various Settings Table View Controller
// Manages detailed settings for route configuration
class VariousSettingsTableViewController: UITableViewController {

    // MARK: - Properties
    // Route direction and week flag
    var goorback: String?
    var weekflag = Date().weekFlag

    // MARK: - Constants
    // Localized unit and color constants
    let notset = Unit.notset.rawValue.localized
    let notuse = Unit.notuse.rawValue.localized
    let black = DefaultColor.black.rawValue
    let gray = DefaultColor.gray.rawValue
    let uigray = DefaultColor.gray.UI
    
    // MARK: - Location Labels
    // Labels for departure and arrival locations
    @IBOutlet weak var departplacelabel: UILabel!
    @IBOutlet weak var departstationlabel1: UILabel!
    @IBOutlet weak var arrivalstationlabel1: UILabel!
    @IBOutlet weak var departstationlabel2: UILabel!
    @IBOutlet weak var arrivalstationlabel2: UILabel!
    @IBOutlet weak var departstationlabel3: UILabel!
    @IBOutlet weak var arrivalstationlabel3: UILabel!
    @IBOutlet weak var destinationlabel: UILabel!
    
    // MARK: - Line and Time Labels
    // Labels for line names and ride times
    @IBOutlet weak var linenamelabel1: UILabel!
    @IBOutlet weak var linenamelabel2: UILabel!
    @IBOutlet weak var linenamelabel3: UILabel!
    @IBOutlet weak var ridetimelabel1: UILabel!
    @IBOutlet weak var ridetimelabel2: UILabel!
    @IBOutlet weak var ridetimelabel3: UILabel!
    
    // MARK: - Transportation Labels
    // Labels for transportation modes
    @IBOutlet weak var transportationlabel1: UILabel!
    @IBOutlet weak var transportationlabel2: UILabel!
    @IBOutlet weak var transportationlabel3: UILabel!
    @IBOutlet weak var transportationlabele: UILabel!
    
    // MARK: - Transit Time Labels
    // Labels for transit times
    @IBOutlet weak var transittimelabel1: UILabel!
    @IBOutlet weak var transittimelabel2: UILabel!
    @IBOutlet weak var transittimelabel3: UILabel!
    @IBOutlet weak var transittimelabele: UILabel!
    
    // MARK: - Action Buttons
    // Buttons for station settings
    @IBOutlet weak var departstationbutton2: UIButton!
    @IBOutlet weak var arrivalstationbutton2: UIButton!
    @IBOutlet weak var departstationbutton3: UIButton!
    @IBOutlet weak var arrivalstationbutton3: UIButton!
    
    // Buttons for line and time settings
    @IBOutlet weak var linenamebutton2: UIButton!
    @IBOutlet weak var linenamebutton3: UIButton!
    @IBOutlet weak var ridetimebutton2: UIButton!
    @IBOutlet weak var ridetimebutton3: UIButton!
    
    // Buttons for transportation and transit time settings
    @IBOutlet weak var transportationbutton2: UIButton!
    @IBOutlet weak var transportationbutton3: UIButton!
    @IBOutlet weak var transittimebutton2: UIButton!
    @IBOutlet weak var transittimebutton3: UIButton!

    // MARK: - Label Arrays
    // Arrays to hold all labels for easy access
    var departstationlabelarray: [UILabel] = []
    var arrivalstationlabelarray: [UILabel] = []
    var linenamelabelarray: [UILabel] = []
    var ridetimelabelarray: [UILabel] = []
    var transportationlabelarray: [UILabel] = []
    var transittimelabelarray: [UILabel] = []

    // MARK: - Button Arrays
    // Arrays to hold all buttons for easy access
    var departstationbuttonarray: [UIButton] = []
    var arrivalstationbuttonarray: [UIButton] = []
    var linenamebuttonarray: [UIButton] = []
    var ridetimebuttonarray: [UIButton] = []
    var transportationbuttonarray: [UIButton] = []
    var transittimebuttonarray: [UIButton] = []

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let changeline = goorback!.changeLineInt

        // MARK: - Array Initialization
        // Initialize label arrays
        departstationlabelarray = [departstationlabel1, departstationlabel2, departstationlabel3]
        arrivalstationlabelarray = [arrivalstationlabel1, arrivalstationlabel2, arrivalstationlabel3]
        linenamelabelarray = [linenamelabel1, linenamelabel2, linenamelabel3]
        ridetimelabelarray = [ridetimelabel1, ridetimelabel2, ridetimelabel3]
        transportationlabelarray = [transportationlabele, transportationlabel1, transportationlabel2, transportationlabel3]
        transittimelabelarray = [transittimelabele, transittimelabel1, transittimelabel2, transittimelabel3]

        // Initialize button arrays
        departstationbuttonarray = [departstationbutton2, departstationbutton3]
        arrivalstationbuttonarray = [arrivalstationbutton2, arrivalstationbutton3]
        linenamebuttonarray = [linenamebutton2, linenamebutton3]
        ridetimebuttonarray = [ridetimebutton2, ridetimebutton3]
        transportationbuttonarray = [transportationbutton2, transportationbutton3]
        transittimebuttonarray = [transittimebutton2, transittimebutton3]

        // MARK: - Display Configuration
        // Get various settings title
        self.title = goorback!.variousSettingsTitle

        // Configure various settings display
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

        // MARK: - Change Line Display Logic
        // Modify display based on number of transfers
        for i in 1...2 {
            if (changeline < i) {
                // MARK: - Hide Unused Segments
                // Hide unused segments by setting text to "Not use"
                departstationlabelarray[i].text = notuse
                arrivalstationlabelarray[i].text = notuse
                linenamelabelarray[i].text = notuse
                ridetimelabelarray[i].text = notuse
                transportationlabelarray[i + 1].text = notuse
                transittimelabelarray[i + 1].text = notuse
                
                // MARK: - Gray Out Unused Labels
                // Gray out unused labels
                departstationlabelarray[i].textColor = uigray
                arrivalstationlabelarray[i].textColor = uigray
                linenamelabelarray[i].textColor = uigray
                ridetimelabelarray[i].textColor = uigray
                transportationlabelarray[i + 1].textColor = uigray
                transittimelabelarray[i + 1].textColor = uigray
                
                // MARK: - Disable Unused Buttons
                // Disable unused buttons and set gray color
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
    
    // MARK: - Departure Place Button Action
    // Handles departure place button tap
    @IBAction func departplacebutton(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefDeparturePointTextFieldDialog(departplacelabel)
    }
    
    // MARK: - Station Button Actions
    // Actions for departure station buttons
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
    
    // MARK: - Destination Button Action
    // Handles destination button tap
    @IBAction func destinationbutton(_ sender: Any) {
        SettingDialog(self, goorback!)
            .prefDestinationTextFieldDialog(destinationlabel)
    }
    
    // MARK: - Line Name Button Actions
    // Actions for line name buttons
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
    
    // MARK: - Ride Time Button Actions
    // Actions for ride time buttons
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
    
    // MARK: - Transportation Button Actions
    // Actions for transportation buttons
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
    
    // MARK: - Transit Time Button Actions
    // Actions for transit time buttons
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
    
    // MARK: - Table View Header Styling
    // Customize table view header appearance
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = DefaultColor.accent.UI
        let header = view as! UITableViewHeaderFooterView
        // MARK: - Header Text Color
        // Set header text color
        header.textLabel?.textColor = DefaultColor.white.UI
    }
}
