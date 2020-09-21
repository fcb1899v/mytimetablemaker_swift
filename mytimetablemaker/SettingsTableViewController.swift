//
//  SettingsTableViewController.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/04.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {


    @IBOutlet weak var back2changelinetable: UITableViewCell!
    @IBOutlet weak var go2changelinetable: UITableViewCell!
    @IBOutlet weak var back2switch: UISwitch!
    @IBOutlet weak var go2switch: UISwitch!
    
    var back2switchflag = true
    var go2switchflag = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        back2switchflag = UserDefaults.standard.bool(forKey: "back2switch")
        go2switchflag = UserDefaults.standard.bool(forKey: "go2switch")
        back2switch.setOn(back2switchflag, animated: false)
        go2switch.setOn(go2switchflag, animated: false)
    }
    
    @IBAction func back2displayswitch(_ sender: Any) {
        back2switchflag = (sender as AnyObject).isOn
        UserDefaults.standard.set((sender as AnyObject).isOn, forKey: "back2switch")
        print("back2 : " + String(back2switchflag))
    }
    
    @IBAction func go2displayswitch(_ sender: Any) {
        go2switchflag = (sender as AnyObject).isOn
        UserDefaults.standard.set((sender as AnyObject).isOn, forKey: "go2switch")
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
