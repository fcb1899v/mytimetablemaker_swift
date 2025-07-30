//
//  SettingsTableViewController.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/09/04.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

// MARK: - Settings Table View Controller
// Manages the settings table view for route configuration
class SettingsTableViewController: UITableViewController, UITextViewDelegate {

    // MARK: - Properties
    // Switch flags for route 2 display
    var back2switchflag = true
    var go2switchflag = true
    let black = DefaultColor.black.rawValue
    let gray = DefaultColor.gray.rawValue
    
    // MARK: - Switch Controls
    // Route 2 display switches
    @IBOutlet weak var back2switch: UISwitch!
    @IBOutlet weak var go2switch: UISwitch!
    
    // MARK: - Change Line Labels
    // Labels for transfer count display
    @IBOutlet weak var back1changelinelabel: UILabel!
    @IBOutlet weak var go1changelinelabel: UILabel!
    @IBOutlet weak var back2changelinelabel: UILabel!
    @IBOutlet weak var go2changelinelabel: UILabel!
    
    // MARK: - Change Line Table Labels
    // Table labels for transfer count
    @IBOutlet weak var back2changelinetable: UILabel!
    @IBOutlet weak var go2changelinetable: UILabel!
    
    @IBOutlet weak var back1changelinetable: UILabel!
    @IBOutlet weak var go1changelinetable: UILabel!
    @IBOutlet weak var back2changeline: UITableViewCell!
    @IBOutlet weak var go2changeline: UITableViewCell!
    
    // MARK: - Settings Buttons
    // Buttons for detailed settings
    @IBOutlet weak var back1settings: UIButton!
    @IBOutlet weak var go1settings: UIButton!
    @IBOutlet weak var back2settings: UIButton!
    @IBOutlet weak var go2settings: UIButton!

    @IBOutlet var settingstableview: UITableView!
    @IBOutlet weak var versiontext: UILabel!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: - Route 2 Switch Configuration
        // Configure route 2 display switches
        back2switchflag = "back2".switchFlag
        back2switch.setOn(back2switchflag, animated: false)
        back2settings.isEnabled = back2switchflag
        go2switchflag = "go2".switchFlag
        go2switch.setOn(go2switchflag, animated: false)
        go2settings.isEnabled = go2switchflag
        
        // MARK: - Button Color Configuration
        // Configure button colors based on switch states
        back2settings.changeButtonColor(back2switchflag, self.black, self.gray)
        go2settings.changeButtonColor(go2switchflag, self.black, self.gray)
        back2changelinetable.textColor = back2switchflag.changeLabelColor(self.black, self.gray)
        go2changelinetable.textColor = go2switchflag.changeLabelColor(self.black, self.gray)
        
        // MARK: - Change Line Label Configuration
        // Configure transfer count labels
        back1changelinelabel.text = "back1".changeLine
        go1changelinelabel.text = "go1".changeLine
        back2changelinelabel.text = "back2".switchChangeLine(back2switchflag)
        go2changelinelabel.text = "go2".switchChangeLine(go2switchflag)
        back2changelinelabel.textColor = back2switchflag.changeLabelColor(self.black, self.gray)
        go2changelinelabel.textColor = go2switchflag.changeLabelColor(self.black, self.gray)
        
        // MARK: - Version Display
        // Display app version
        versiontext.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    // MARK: - Terms Action
    // Opens privacy policy in browser
    @IBAction func terms(_ sender: UIButton) {
        let url = URL(string: "https://landingpage-mytimetablemaker.web.app/privacypolicy.html")!
        if( UIApplication.shared.canOpenURL(url) ) {
          UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Change Line Table Actions
    // Actions for transfer count table cells
    @IBAction func back1changelinetable(_ sender: Any) {
        SettingDialog(self, "back1")
            .changeLinePickerDialog(back1changelinetable, back1changelinelabel)
    }
    
    @IBAction func go1changelinetable(_ sender: Any) {
        SettingDialog(self, "go1")
            .changeLinePickerDialog(go1changelinetable, go1changelinelabel)
    }
    
    @IBAction func back2changelinetable(_ sender: Any) {
        if (back2switchflag) {
            SettingDialog(self, "back2")
                .changeLinePickerDialog(back2changelinetable, back2changelinelabel)
        }
    }
    
    @IBAction func go2changelinetable(_ sender: Any) {
        if (go2switchflag) {
            SettingDialog(self, "go2")
                .changeLinePickerDialog(go2changelinetable, go2changelinelabel)
        }
    }
    
    // MARK: - Switch Actions
    // Actions for route 2 display switches
    @IBAction func back2displayswitch(_ sender: Any) {
        // MARK: - Route 2 Switch Display and Data Persistence
        // Update route 2 switch display and save data
        let currentflag = (sender as AnyObject).isOn!
        UserDefaults.standard.set(currentflag, forKey: "back2switch")
        (sender as AnyObject).setOn(currentflag, animated: false)
        
        // MARK: - Change Line Button and Label Display
        // Update transfer count button and label display
        back2settings.changeButtonColor(currentflag, self.black, self.gray)
        back2changelinetable.textColor = currentflag.changeLabelColor(self.black, self.gray)
        back2changelinelabel.text = "back2".switchChangeLine(currentflag)
        back2changelinelabel.textColor = currentflag.changeLabelColor(self.black, self.gray)
        
        // MARK: - Detailed Settings Button Display
        // Update detailed settings button display
        back2settings.isEnabled = currentflag
        back2settings.changeButtonColor(currentflag, self.black, self.gray)
    }
    
    @IBAction func go2displayswitch(_ sender: Any) {
        // MARK: - Route 2 Switch Display and Data Persistence
        // Update route 2 switch display and save data
        let currentflag = (sender as AnyObject).isOn!
        UserDefaults.standard.set(currentflag, forKey: "go2switch")
        (sender as AnyObject).setOn(currentflag, animated: false)
        
        // MARK: - Change Line Button and Label Display
        // Update transfer count button and label display
        go2settings.changeButtonColor(currentflag, self.black, self.gray)
        go2changelinetable.textColor = currentflag.changeLabelColor(self.black, self.gray)
        go2changelinelabel.text = "go2".switchChangeLine(currentflag)
        go2changelinelabel.textColor = currentflag.changeLabelColor(self.black, self.gray)
        
        // MARK: - Detailed Settings Button Display
        // Update detailed settings button display
        go2settings.isEnabled = currentflag
        go2settings.changeButtonColor(currentflag , self.black, self.gray)
    }
        
    // MARK: - Segue Preparation
    // Prepare data for navigation to detailed settings
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            // Stop processing if identifier cannot be retrieved
            return
        }
        // Get NavigationController from segue destination
        let nc = segue.destination as! UINavigationController
        // Get TableViewController from NavigationController
        let vc = nc.topViewController as! VariousSettingsTableViewController
        // Pass route direction to destination
        vc.goorback = identifier.seguegoorback
    }

    // MARK: - Table View Header Styling
    // Customize table view header appearance
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // MARK: - Header Background Color
        // Set header background color
        view.tintColor = DefaultColor.accent.UI
        // MARK: - Header Text Color
        // Set header text color
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = DefaultColor.white.UI
    }
}
