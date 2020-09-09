//
//  MainViewController.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/05.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var timeflag = true
    var goorbackflag = true
    
    @IBOutlet weak var datebutton: UIButton!
    @IBOutlet weak var timebutton: UIButton!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var gobutton: UIButton!
    @IBOutlet weak var startbutton: UIButton!
    @IBOutlet weak var stopbutton: UIButton!
    
    @IBAction func backbutton(_ sender: Any) {
        goorbackflag = DateAndTime.setButtonCondition(
            flag: true,
            button1: backbutton,
            button2: gobutton,
            color1: UIColor(rgb: 0x3700B3),
            color2: UIColor(rgb: 0x8E8E93)
        )
    }
    
    @IBAction func gobutton(_ sender: Any) {
        goorbackflag = DateAndTime.setButtonCondition(
            flag: false,
            button1: backbutton,
            button2: gobutton,
            color1: UIColor(rgb: 0x8E8E93),
            color2: UIColor(rgb: 0x3700B3)
        )
    }
    
    @IBAction func startbutton(_ sender: Any) {
        timeflag = DateAndTime.setButtonCondition(
            flag: true,
            button1: startbutton,
            button2: stopbutton,
            color1: UIColor(rgb: 0x03DAC5),
            color2: UIColor(rgb: 0x8E8E93)
        )
        datebutton.isEnabled = false
        timebutton.isEnabled = false
    }
    
    @IBAction func stopbutton(_ sender: Any) {
        timeflag = DateAndTime.setButtonCondition(
            flag: false,
            button1: startbutton,
            button2: stopbutton,
            color1: UIColor(rgb: 0x8E8E93),
            color2: UIColor(rgb: 0x03DAC5)
        )
        datebutton.isEnabled = true
        timebutton.isEnabled = true
    }
    
    @IBAction func datebutton(_ sender: Any) {
        if timeflag == false {
            present(DateAndTime.setDatePickerDialog(
                datebutton: datebutton,
                stringformat: "E, MMM d, yyyy"),
                animated: true,
                completion: nil
            )
        }
    }
    
    @IBAction func timebutton(_ sender: Any) {
        if timeflag == false {
            present(DateAndTime.setTimePickerDialog(
                timebutton: timebutton,
                stringformat: "HH:mm"),
                animated: true,
                completion: nil)
        }
    }
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                if self.timeflag == true {
                    //現在日付の表示
                    DateAndTime.getCurrentDate(datebutton: self.datebutton)
                    //現在時刻の表示
                    DateAndTime.getCurrentTime(timebutton: self.timebutton)
                }
            })
    }
        
    //ステータスバーの色を白に変更
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
