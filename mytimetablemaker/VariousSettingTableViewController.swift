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

    override func viewDidLoad() {
        super.viewDidLoad()
        //VariousSettingsのタイトルを取得
        self.title = FileAndData.getVariousSettingsTitle(goorback: goorback!)
     }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(rgb: 0x03DAC5)
        let header = view as! UITableViewHeaderFooterView
        // テキスト色を変更する
        header.textLabel?.textColor = UIColor(rgb: 0xFFFFFF)
    }
}
