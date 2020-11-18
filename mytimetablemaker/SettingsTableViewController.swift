//
//  SettingsTableViewController.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/04.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SettingsTableViewController: UITableViewController, UITextViewDelegate, GADBannerViewDelegate {

    var bannerView: GADBannerView!
    var back2switchflag = true
    var go2switchflag = true
    let black = DefaultColor.black.rawValue
    let gray = DefaultColor.gray.rawValue
    
    @IBOutlet weak var back2switch: UISwitch!
    @IBOutlet weak var go2switch: UISwitch!
    @IBOutlet weak var back1changelinelabel: UILabel!
    @IBOutlet weak var go1changelinelabel: UILabel!
    @IBOutlet weak var back2changelinelabel: UILabel!
    @IBOutlet weak var go2changelinelabel: UILabel!
    
    @IBOutlet weak var back2changelinetable: UILabel!
    @IBOutlet weak var go2changelinetable: UILabel!
    
    @IBOutlet weak var back1changelinetable: UILabel!
    @IBOutlet weak var go1changelinetable: UILabel!
    @IBOutlet weak var back2changeline: UITableViewCell!
    @IBOutlet weak var go2changeline: UITableViewCell!
    
    @IBOutlet weak var back1settings: UIButton!
    @IBOutlet weak var go1settings: UIButton!
    @IBOutlet weak var back2settings: UIButton!
    @IBOutlet weak var go2settings: UIButton!

    @IBOutlet var settingstableview: UITableView!
    @IBOutlet weak var versiontext: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //ルート２スイッチの表示
        back2switchflag = "back2".switchFlag
        back2switch.setOn(back2switchflag, animated: false)
        back2settings.isEnabled = back2switchflag
        go2switchflag = "go2".switchFlag
        go2switch.setOn(go2switchflag, animated: false)
        go2settings.isEnabled = go2switchflag
        //乗換回数のボタンの表示
        back2settings.changeButtonColor(back2switchflag, self.black, self.gray)
        go2settings.changeButtonColor(go2switchflag, self.black, self.gray)
        back2changelinetable.textColor = back2switchflag.changeLabelColor(self.black, self.gray)
        go2changelinetable.textColor = go2switchflag.changeLabelColor(self.black, self.gray)
        //乗換回数のラベルの表示
        back1changelinelabel.text = "back1".changeLine
        go1changelinelabel.text = "go1".changeLine
        back2changelinelabel.text = "back2".switchChangeLine(back2switchflag)
        go2changelinelabel.text = "go2".switchChangeLine(go2switchflag)
        back2changelinelabel.textColor = back2switchflag.changeLabelColor(self.black, self.gray)
        go2changelinelabel.textColor = go2switchflag.changeLabelColor(self.black, self.gray)
        //バージョン番号の表示
        versiontext.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    @IBAction func terms(_ sender: UIButton) {
        let url = URL(string: "https://landingpage-mytimetablemaker.web.app/privacypolicy.html")!
        if( UIApplication.shared.canOpenURL(url) ) {
          UIApplication.shared.open(url)
        }
    }
    
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
    
    @IBAction func back2displayswitch(_ sender: Any) {
        //ルート２スイッチの表示およびデータの保存
        let currentflag = (sender as AnyObject).isOn!
        UserDefaults.standard.set(currentflag, forKey: "back2switch")
        (sender as AnyObject).setOn(currentflag, animated: false)
        //乗換回数のボタンおよびラベルの表示
        back2settings.changeButtonColor(currentflag, self.black, self.gray)
        back2changelinetable.textColor = currentflag.changeLabelColor(self.black, self.gray)
        back2changelinelabel.text = "back2".switchChangeLine(currentflag)
        back2changelinelabel.textColor = currentflag.changeLabelColor(self.black, self.gray)
        //詳細設定のボタンの表示
        back2settings.isEnabled = currentflag
        back2settings.changeButtonColor(currentflag, self.black, self.gray)
    }
    
    @IBAction func go2displayswitch(_ sender: Any) {
        //ルート２スイッチの表示およびデータの保存
        let currentflag = (sender as AnyObject).isOn!
        UserDefaults.standard.set(currentflag, forKey: "go2switch")
        (sender as AnyObject).setOn(currentflag, animated: false)
        //乗換回数のボタンおよびラベルの表示
        go2settings.changeButtonColor(currentflag, self.black, self.gray)
        go2changelinetable.textColor = currentflag.changeLabelColor(self.black, self.gray)
        go2changelinelabel.text = "go2".switchChangeLine(currentflag)
        go2changelinelabel.textColor = currentflag.changeLabelColor(self.black, self.gray)
        //詳細設定のボタンの表示
        go2settings.isEnabled = currentflag
        go2settings.changeButtonColor(currentflag , self.black, self.gray)
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
        vc.goorback = identifier.seguegoorback
    }

    //TableViewのHeaderの書式変更
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //背景色の変更
        view.tintColor = DefaultColor.accent.UI
        // テキスト色を変更する
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = DefaultColor.white.UI
    }
}
