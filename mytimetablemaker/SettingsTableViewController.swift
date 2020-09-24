//
//  SettingsTableViewController.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/04.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {


    @IBOutlet weak var back2switch: UISwitch!
    @IBOutlet weak var go2switch: UISwitch!
    
    @IBOutlet weak var back1changelinelabel: UILabel!
    @IBOutlet weak var go1changelinelabel: UILabel!
    @IBOutlet weak var back2changelinelabel: UILabel!
    @IBOutlet weak var go2changelinelabel: UILabel!
    
    @IBOutlet weak var back1changelinetable: UILabel!
    @IBOutlet weak var go1changelinetable: UILabel!
    @IBOutlet weak var back2changelinetable: UILabel!
    @IBOutlet weak var go2changelinetable: UILabel!
    
    @IBOutlet weak var back2changeline: UITableViewCell!
    @IBOutlet weak var go2changeline: UITableViewCell!
    
    var back2switchflag = true
    var go2switchflag = true

    override func viewDidLoad() {
        super.viewDidLoad()
        back1changelinelabel.text = FileAndData.getUserDefaultValue(key: "back1changeline", defaultvalue: "Not set")
        go1changelinelabel.text = FileAndData.getUserDefaultValue(key: "go1changeline", defaultvalue: "Not set")
        back2changelinelabel.text = FileAndData.getUserDefaultValue(key: "back2changeline", defaultvalue: "Not set")
        go2changelinelabel.text = FileAndData.getUserDefaultValue(key: "go2changeline", defaultvalue: "Not set")
        back2switchflag = UserDefaults.standard.bool(forKey: "back2switch")
        go2switchflag = UserDefaults.standard.bool(forKey: "go2switch")
        back2switch.setOn(back2switchflag, animated: false)
        go2switch.setOn(go2switchflag, animated: false)
    }
    
    @IBAction func back1changelinetable(_ sender: Any) {
        CustomDialog.changeLinePickerDialog(
            viewcontroller: self,
            taplabel: back1changelinetable,
            setlabel: back1changelinelabel,
            goorback: "back1")
    }
    
    @IBAction func go1changelinetable(_ sender: Any) {
        CustomDialog.changeLinePickerDialog(
            viewcontroller: self,
            taplabel: go1changelinetable,
            setlabel: go1changelinelabel,
            goorback: "go1")
    }
    
    @IBAction func back2changelinetable(_ sender: Any) {
        CustomDialog.changeLinePickerDialog(
            viewcontroller: self,
            taplabel: back2changelinetable,
            setlabel: back2changelinelabel,
            goorback: "back2")
    }
    
    @IBAction func go2changelinetable(_ sender: Any) {
        CustomDialog.changeLinePickerDialog(
            viewcontroller: self,
            taplabel: go2changelinetable,
            setlabel: go2changelinelabel,
            goorback: "go2")
    }

    @IBAction func back2displayswitch(_ sender: Any) {
        back2switchflag = (sender as AnyObject).isOn
        UserDefaults.standard.set((sender as AnyObject).isOn, forKey: "back2switch")
        back2changeline.isHidden = !(sender as AnyObject).isOn
        print("back2 : " + String(back2switchflag))
    }
    
    @IBAction func go2displayswitch(_ sender: Any) {
        go2switchflag = (sender as AnyObject).isOn
        UserDefaults.standard.set((sender as AnyObject).isOn, forKey: "go2switch")
        go2changeline.isHidden = !(sender as AnyObject).isOn
        print("go2 : " + String(go2switchflag))
    }
    
    //画面遷移時の値渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            // identifierが取れなかったら処理やめる
            return
        }
        // segueから遷移先のNavigationControllerを取得
        let nc = segue.destination as! UINavigationController
        // NavigationControllerから遷移先のTableViewControllerを取得
        let vc = nc.topViewController as! VariousSettingsTableViewController
        //
        if (identifier == "seguevsgo1") { vc.goorback = "go1" }
        else if (identifier == "seguevsback2") { vc.goorback = "back2" }
        else if (identifier == "seguevsgo2") { vc.goorback = "go2" }
        else { vc.goorback = "back1" }
    }

    //TableViewのHeaderの書式変更
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //背景色の変更
        view.tintColor = UIColor(rgb: 0x03DAC5)
        // テキスト色を変更する
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(rgb: 0xFFFFFF)
    }

}
