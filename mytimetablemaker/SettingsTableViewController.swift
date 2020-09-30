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
    
    @IBOutlet weak var back1settings: UIButton!
    @IBOutlet weak var go1settings: UIButton!
    @IBOutlet weak var back2settings: UIButton!
    @IBOutlet weak var go2settings: UIButton!
    
    
    @IBOutlet var settingstableview: UITableView!
    
    var back2switchflag = true
    var go2switchflag = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        back2switchflag = UserDefaults.standard.bool(forKey: "back2switch")
        go2switchflag = UserDefaults.standard.bool(forKey: "go2switch")
        
        back2switch.setOn(back2switchflag, animated: false)
        go2switch.setOn(go2switchflag, animated: false)
        
        back1changelinelabel.text = FileAndData.getUserDefaultValue(
            key: "back1changeline", defaultvalue: "Not set")
        go1changelinelabel.text = FileAndData.getUserDefaultValue(
            key: "go1changeline", defaultvalue: "Not set")
        back2changelinelabel.text = (back2switchflag) ? FileAndData.getUserDefaultValue(
            key: "back2changeline", defaultvalue: "Not set"): "Not use"
        go2changelinelabel.text = (go2switchflag) ? FileAndData.getUserDefaultValue(
            key: "go2changeline", defaultvalue: "Not set"): "Not use"
        
        back2changelinetable.textColor = (back2switchflag) ? UIColor(rgb: 0x000000): UIColor(rgb: 0x8E8E93)
        go2changelinetable.textColor = (go2switchflag) ? UIColor(rgb: 0x000000): UIColor(rgb: 0x8E8E93)
        back2changelinelabel.textColor = (back2switchflag) ? UIColor(rgb: 0x000000): UIColor(rgb: 0x8E8E93)
        go2changelinelabel.textColor = (go2switchflag) ? UIColor(rgb: 0x000000): UIColor(rgb: 0x8E8E93)

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
        if (back2switchflag) {
            CustomDialog.changeLinePickerDialog(
                viewcontroller: self,
                taplabel: back2changelinetable,
                setlabel: back2changelinelabel,
                goorback: "back2")
        }
    }
    
    @IBAction func go2changelinetable(_ sender: Any) {
        if (go2switchflag) {
            CustomDialog.changeLinePickerDialog(
                viewcontroller: self,
                taplabel: go2changelinetable,
                setlabel: go2changelinelabel,
                goorback: "go2")
        }
    }

    @IBAction func back2displayswitch(_ sender: Any) {
        back2switchflag = (sender as AnyObject).isOn
        UserDefaults.standard.set((sender as AnyObject).isOn, forKey: "back2switch")
        back2changelinelabel.text = (back2switchflag) ? FileAndData.getUserDefaultValue(
            key: "back2changeline", defaultvalue: "Not set"): "Not use"
        back2changelinetable.textColor = (back2switchflag) ? UIColor(rgb: 0x000000): UIColor(rgb: 0x8E8E93)
        back2changelinelabel.textColor = (back2switchflag) ? UIColor(rgb: 0x000000): UIColor(rgb: 0x8E8E93)
    }
    
    @IBAction func go2displayswitch(_ sender: Any) {
        go2switchflag = (sender as AnyObject).isOn
        UserDefaults.standard.set((sender as AnyObject).isOn, forKey: "go2switch")
        go2changelinelabel.text = (go2switchflag) ? FileAndData.getUserDefaultValue(
            key: "go2changeline", defaultvalue: "Not set"): "Not use"
        go2changelinetable.textColor = (go2switchflag) ? UIColor(rgb: 0x000000): UIColor(rgb: 0x8E8E93)
        go2changelinelabel.textColor = (go2switchflag) ? UIColor(rgb: 0x000000): UIColor(rgb: 0x8E8E93)
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
        switch (identifier) {
            case "seguevsgo1": vc.goorback = "go1"
            case "seguevsback1": vc.goorback = "back1"
            case "seguevsgo2": vc.goorback = "go2"
            default : vc.goorback = "back1"
        }
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
