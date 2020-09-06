//
//  FIleAndData.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/06.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class FileAndData: NSObject {

    //Various Settingsのタイトルを取得する関数
    class func getVariousSettingsTitle(goorback: String) -> String {
        var varioussettingstitle = { "Various settings on " }()
            switch goorback {
                case "go1": varioussettingstitle += "outgoing route 1"
                case "back2": varioussettingstitle += "route home 2"
                case "go2": varioussettingstitle += "outgoing route 2"
                default: varioussettingstitle += "route home 1"
        }
        return varioussettingstitle
    }
    
    
}
