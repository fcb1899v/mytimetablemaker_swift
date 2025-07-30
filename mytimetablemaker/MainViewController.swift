//
//  MainViewController.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/09/05.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol Calculation {
    var goorback: String { get }
    var weekflag: Bool { get }
}

protocol Display {
    var viewcontroller: UIViewController { get }
    var goorback: String { get }
}

class MainViewController: UIViewController, GADBannerViewDelegate {
//class MainViewController: UIViewController {

    var timer = Timer()
    var timeflag = true
    var weekflag = Date().weekFlag
    var goorbackflag = true
    var goorback1 = "back1"
    var goorback2 = "back2"
    let walk = Transportation.walking.rawValue.localized
    let primary = DefaultColor.primary.rawValue
    let accent = DefaultColor.accent.rawValue
    let gray = DefaultColor.gray.rawValue

    @IBOutlet weak var datebutton: UIButton!
    @IBOutlet weak var timebutton: UIButton!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var gobutton: UIButton!
    @IBOutlet weak var startbutton: UIButton!
    @IBOutlet weak var stopbutton: UIButton!
        
    @IBOutlet weak var display2stackview: UIStackView!
    @IBOutlet weak var centerlineview: UIView!
    
    @IBOutlet weak var stationlabel10: UILabel!
    @IBOutlet weak var stationlabel11: UILabel!
    @IBOutlet weak var stationlabel12: UILabel!
    @IBOutlet weak var stationlabel13: UILabel!
    @IBOutlet weak var stationlabel14: UILabel!
    @IBOutlet weak var stationlabel15: UILabel!
    @IBOutlet weak var stationlabel16: UILabel!
    @IBOutlet weak var stationlabel1e: UILabel!
    
    @IBOutlet weak var stationlabel20: UILabel!
    @IBOutlet weak var stationlabel21: UILabel!
    @IBOutlet weak var stationlabel22: UILabel!
    @IBOutlet weak var stationlabel23: UILabel!
    @IBOutlet weak var stationlabel24: UILabel!
    @IBOutlet weak var stationlabel25: UILabel!
    @IBOutlet weak var stationlabel26: UILabel!
    @IBOutlet weak var stationlabel2e: UILabel!
    
    @IBOutlet weak var linelabel11: UILabel!
    @IBOutlet weak var linelabel12: UILabel!
    @IBOutlet weak var linelabel13: UILabel!
    
    @IBOutlet weak var linelabel21: UILabel!
    @IBOutlet weak var linelabel22: UILabel!
    @IBOutlet weak var linelabel23: UILabel!
    
    @IBOutlet weak var linetimetable11: UIStackView!
    @IBOutlet weak var linetimetable12: UIStackView!
    @IBOutlet weak var linetimetable13: UIStackView!
    
    @IBOutlet weak var linetimetable21: UIStackView!
    @IBOutlet weak var linetimetable22: UIStackView!
    @IBOutlet weak var linetimetable23: UIStackView!
    
    @IBOutlet weak var transittimelabel11: UIStackView!
    @IBOutlet weak var transittimelabel12: UIStackView!
    @IBOutlet weak var transittimelabel13: UIStackView!
    @IBOutlet weak var transittimelabel1e: UIStackView!

    @IBOutlet weak var transittimelabel21: UIStackView!
    @IBOutlet weak var transittimelabel22: UIStackView!
    @IBOutlet weak var transittimelabel23: UIStackView!
    @IBOutlet weak var transittimelabel2e: UIStackView!

    @IBOutlet weak var transportlabel11: UILabel!
    @IBOutlet weak var transportlabel12: UILabel!
    @IBOutlet weak var transportlabel13: UILabel!
    @IBOutlet weak var transportlabel1e: UILabel!
    
    @IBOutlet weak var transportlabel21: UILabel!
    @IBOutlet weak var transportlabel22: UILabel!
    @IBOutlet weak var transportlabel23: UILabel!
    @IBOutlet weak var transportlabel2e: UILabel!
    
    @IBOutlet weak var linestackview12: UIStackView!
    @IBOutlet weak var linestackview13: UIStackView!
    @IBOutlet weak var linestackview22: UIStackView!
    @IBOutlet weak var linestackview23: UIStackView!
    
    @IBOutlet weak var countdown1: UILabel!
    @IBOutlet weak var timelabel10: UILabel!
    @IBOutlet weak var timelabel11: UILabel!
    @IBOutlet weak var timelabel12: UILabel!
    @IBOutlet weak var timelabel13: UILabel!
    @IBOutlet weak var timelabel14: UILabel!
    @IBOutlet weak var timelabel15: UILabel!
    @IBOutlet weak var timelabel16: UILabel!
    @IBOutlet weak var timelabel1e: UILabel!
    
    @IBOutlet weak var countdown2: UILabel!
    @IBOutlet weak var timelabel20: UILabel!
    @IBOutlet weak var timelabel21: UILabel!
    @IBOutlet weak var timelabel22: UILabel!
    @IBOutlet weak var timelabel23: UILabel!
    @IBOutlet weak var timelabel24: UILabel!
    @IBOutlet weak var timelabel25: UILabel!
    @IBOutlet weak var timelabel26: UILabel!
    @IBOutlet weak var timelabel2e: UILabel!

    @IBOutlet var bannerView: GADBannerView!

    var departstationlabelarray1: [UILabel] = []
    var departstationlabelarray2: [UILabel] = []
    var arrivalstationlabelarray1: [UILabel] = []
    var arrivalstationlabelarray2: [UILabel] = []
    var linenamelabelarray1: [UILabel] = []
    var linenamelabelarray2: [UILabel] = []
    var linetimetablearray1: [UIStackView] = []
    var linetimetablearray2: [UIStackView] = []
    var transportationlabelarray1: [UILabel] = []
    var transportationlabelarray2: [UILabel] = []
    var timelabelarray1: [UILabel] = []
    var timelabelarray2: [UILabel] = []

    //Main文
    override func viewDidLoad() {
        super.viewDidLoad()
                
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-1585283309075901/1821605177"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {
            (timer) in

            //定数の定義
            let office = "Office".localized
            let home = "Home".localized
            let depsta = "Dep. St.".localized
            let arrsta = "Arr. St.".localized
            let line = "Line ".localized
            let none = "--:--"
            let accent = self.accent
            let walk = self.walk
            let goorback1 = self.goorback1
            let goorback2 = self.goorback2
            let datebutton = self.datebutton!
            let timebutton = self.timebutton!
            let timeflag = self.timeflag
            
            let dateandtime = DateAndTime(datebutton, timebutton, timeflag)
            let currenttime = dateandtime.currentHHmmssFromTimeButton
            let weekflag = dateandtime.dateFromDateButton.weekFlag
            let changeline1 = goorback1.changeLineInt
            let changeline2 = goorback2.changeLineInt
            let calctime1 = CalcTime(goorback1, weekflag, changeline1)
            let calctime2 = CalcTime(goorback2, weekflag, changeline2)

            //現在日付・時刻の表示
            dateandtime.setCurrentDate()
            dateandtime.setCurrentTime()

            //表示ラベルの配列化
            self.departstationlabelarray1 = [self.stationlabel11, self.stationlabel13, self.stationlabel15]
            self.departstationlabelarray2 = [self.stationlabel21, self.stationlabel23, self.stationlabel25]
            self.arrivalstationlabelarray1 = [self.stationlabel12, self.stationlabel14, self.stationlabel16]
            self.arrivalstationlabelarray2 = [self.stationlabel22, self.stationlabel24, self.stationlabel26]
            self.linenamelabelarray1 = [self.linelabel11, self.linelabel12, self.linelabel13]
            self.linenamelabelarray2 = [self.linelabel21, self.linelabel22, self.linelabel23]
            self.linetimetablearray1 = [self.linetimetable11, self.linetimetable12, self.linetimetable13]
            self.linetimetablearray2 = [self.linetimetable21, self.linetimetable22, self.linetimetable23]
            self.transportationlabelarray1 = [self.transportlabel1e, self.transportlabel11, self.transportlabel12, self.transportlabel13]
            self.transportationlabelarray2 = [self.transportlabel2e, self.transportlabel21, self.transportlabel22, self.transportlabel23]
            self.timelabelarray1 = [self.timelabel1e, self.timelabel10, self.timelabel11, self.timelabel12, self.timelabel13, self.timelabel14, self.timelabel15, self.timelabel16]
            self.timelabelarray2 = [self.timelabel2e, self.timelabel20, self.timelabel21, self.timelabel22, self.timelabel23, self.timelabel24, self.timelabel25, self.timelabel26]

            //各種表示
            self.stationlabel10.text = goorback1.departurePoint(office, home)
            self.stationlabel20.text = goorback2.departurePoint(office, home)
            self.stationlabel1e.text = goorback1.destination(home, office)
            self.stationlabel2e.text = goorback2.destination(home, office)
            self.transportationlabelarray1[0].text = goorback1.transportation("e", walk)
            self.transportationlabelarray2[0].text = goorback2.transportation("e", walk)
            for i in 0...2 {
                self.departstationlabelarray1[i].text = goorback1.departStation("\(i + 1)", "\(depsta)\(i + 1)")
                self.departstationlabelarray2[i].text = goorback2.departStation("\(i + 1)", "\(depsta)\(i + 1)")
                self.arrivalstationlabelarray1[i].text = goorback1.arriveStation("\(i + 1)", "\(arrsta)\(i + 1)")
                self.arrivalstationlabelarray2[i].text = goorback2.arriveStation("\(i + 1)", "\(arrsta)\(i + 1)")
                self.transportationlabelarray1[i + 1].text = goorback1.transportation("\(i + 1)", walk)
                self.transportationlabelarray2[i + 1].text = goorback2.transportation("\(i + 1)", walk)
                self.linenamelabelarray1[i].text = goorback1.lineName("\(i + 1)", "\(line)\(i + 1)")
                self.linenamelabelarray2[i].text = goorback2.lineName("\(i + 1)", "\(line)\(i + 1)")
                self.linenamelabelarray1[i].textColor = goorback1.lineColor("\(i + 1)", accent)
                self.linenamelabelarray2[i].textColor = goorback2.lineColor("\(i + 1)", accent)
                self.linetimetablearray1[i].backgroundColor = goorback1.lineColor("\(i + 1)", accent)
                self.linetimetablearray2[i].backgroundColor = goorback2.lineColor("\(i + 1)", accent)
            }

            //帰宅・外出ルート2の表示・非表示
            self.display2stackview.isHidden = !(goorback2.switchFlag)
            self.centerlineview.isHidden = !(goorback2.switchFlag)
            self.linestackview12.isHidden = changeline1.viewHidden(1)
            self.linestackview13.isHidden = changeline1.viewHidden(2)
            self.linestackview22.isHidden = changeline2.viewHidden(1)
            self.linestackview23.isHidden = changeline2.viewHidden(2)
            
            //＜各時刻の計算＞
            //乗車可能時刻[0]・各発車時刻[1]・各到着時刻[2]と出発時刻
            let time1 = calctime1.displayTimeArray(currenttime)
            let time2 = calctime2.displayTimeArray(currenttime)
            let departuretime1 = calctime1.departureTime(currenttime)
            let departuretime2 = calctime2.departureTime(currenttime)

            //時刻1の表示
            self.timelabelarray1[1].text = (time1[1] == none) ? none: time1[1]
            for i in 0...2 {
                if (changeline1 >= i) {
                    self.timelabelarray1[2 * i + 2].text =
                        (self.timelabelarray1[2 * i + 1].text == none) ? none: time1[2 * i + 2]
                    self.timelabelarray1[2 * i + 3].text =
                        (self.timelabelarray1[2 * i + 2].text == none) ? none: time1[2 * i + 3]
                    self.timelabelarray1[0].text =
                        (self.timelabelarray1[2 * i + 3].text == none) ? none: time1[0]
                }
            }
            self.timelabelarray1[1].text = (self.timelabelarray1[3].text == none) ? none: time1[1]
            //カウントダウン1
            self.countdown1.text = currenttime.countdownTime(departuretime1)
            self.countdown1.textColor = currenttime.countdownColor(departuretime1)

            //時刻2の表示
            self.timelabelarray2[1].text = (time2[1] == none) ? none: time2[1]
            for i in 0...2 {
                if (changeline2 >= i) {
                    self.timelabelarray2[2 * i + 2].text =
                        (self.timelabelarray2[2 * i + 1].text == none) ? none: time2[2 * i + 2]
                    self.timelabelarray2[2 * i + 3].text =
                        (self.timelabelarray2[2 * i + 2].text == none) ? none: time2[2 * i + 3]
                    self.timelabelarray2[0].text =
                        (self.timelabelarray2[2 * i + 3].text == none) ? none: time2[0]
                }
            }
            self.timelabelarray2[1].text = (self.timelabelarray2[3].text == none) ? none: time2[1]
            //カウントダウン2
            self.countdown2.text = currenttime.countdownTime(departuretime2)
            self.countdown2.textColor = currenttime.countdownColor(departuretime2)
       })
    }
    
    //帰宅ルートの表示ボタン
    @IBAction func backbutton(_ sender: Any) {
        backbutton.isEnabled = false
        gobutton.isEnabled = true
        backbutton.setButtonColor(self.primary)
        gobutton.setButtonColor(self.gray)
        goorbackflag = true
        goorback1 = "back1"
        goorback2 = "back2"
    }

    //外出ルートの表示ボタン
    @IBAction func gobutton(_ sender: Any) {
        backbutton.isEnabled = true
        gobutton.isEnabled = false
        backbutton.setButtonColor(self.gray)
        gobutton.setButtonColor(self.primary)
        goorbackflag = false
        goorback1 = "go1"
        goorback2 = "go2"
    }
    
    //現在時刻の再開ボタン
    @IBAction func startbutton(_ sender: Any) {
        startbutton.isEnabled = false
        stopbutton.isEnabled = true
        startbutton.setButtonColor(self.accent)
        stopbutton.setButtonColor(self.gray)
        timeflag = true
        datebutton.isEnabled = false
        timebutton.isEnabled = false
    }

    //現在時刻の停止ボタン
    @IBAction func stopbutton(_ sender: Any) {
        startbutton.isEnabled = true
        stopbutton.isEnabled = false
        startbutton.setButtonColor(self.gray)
        stopbutton.setButtonColor(self.accent)
        timeflag = false
        datebutton.isEnabled = true
        timebutton.isEnabled = true
    }
    
    //日時の変更ボタン
    @IBAction func datebutton(_ sender: Any) {
        DateAndTime(self.datebutton!, self.timebutton!, self.timeflag).datePickerDialog(self)
    }
    
    //時刻の変更ボタン
    @IBAction func timebutton(_ sender: Any) {
        DateAndTime(self.datebutton!, self.timebutton!, self.timeflag).timePickerDialog(self)
    }

    @IBAction func stationlabel10(_ sender: Any) {
        MainViewDialog(self, goorback1).departurePointTextFieldDialog(stationlabel10)
    }
    
    @IBAction func stationlabel11(_ sender: Any) {
        MainViewDialog(self, goorback1).departStationTextFieldDialog(stationlabel11, "1")
    }
    
    @IBAction func stationlabel12(_ sender: Any) {
        MainViewDialog(self, goorback1).arriveStationTextFieldDialog(stationlabel12, "1")
    }
    
    @IBAction func stationlabel13(_ sender: Any) {
        MainViewDialog(self, goorback1).departStationTextFieldDialog(stationlabel13, "2")
    }
    
    @IBAction func stationlabel14(_ sender: Any) {
        MainViewDialog(self, goorback1).arriveStationTextFieldDialog(stationlabel14, "2")
    }
    
    @IBAction func stationlabel15(_ sender: Any) {
        MainViewDialog(self, goorback1).departStationTextFieldDialog(stationlabel15, "3")
    }
    
    @IBAction func stationlabel16(_ sender: Any) {
        MainViewDialog(self, goorback1).arriveStationTextFieldDialog(stationlabel16, "3")
    }
    
    @IBAction func stationlabel1e(_ sender: Any) {
        MainViewDialog(self, goorback1).destinationTextFieldDialog(stationlabel1e)
    }
    
    @IBAction func stationlabel20(_ sender: Any) {
        MainViewDialog(self, goorback2).departurePointTextFieldDialog(stationlabel20)
    }
    
    @IBAction func stationlabel21(_ sender: Any) {
        MainViewDialog(self, goorback2).departStationTextFieldDialog(stationlabel21, "1")
    }
    
    @IBAction func stationlabel22(_ sender: Any) {
        MainViewDialog(self, goorback2).arriveStationTextFieldDialog(stationlabel22, "1")
    }
    
    @IBAction func stationlabel23(_ sender: Any) {
        MainViewDialog(self, goorback2).departStationTextFieldDialog(stationlabel23, "2")
    }
    
    @IBAction func stationlabel24(_ sender: Any) {
        MainViewDialog(self, goorback2).arriveStationTextFieldDialog(stationlabel24, "2")
    }
    
    @IBAction func stationlabel25(_ sender: Any) {
        MainViewDialog(self, goorback2).departStationTextFieldDialog(stationlabel25, "3")
    }
    
    @IBAction func stationlabel26(_ sender: Any) {
        MainViewDialog(self, goorback2).arriveStationTextFieldDialog(stationlabel26, "3")
    }
    
    @IBAction func stationlabel2e(_ sender: Any) {
        MainViewDialog(self, goorback2).destinationTextFieldDialog(stationlabel2e)
    }
    
    @IBAction func linelabel11(_ sender: Any) {
        MainViewDialog(self, goorback1).lineTextFieldDialog(linelabel11, linetimetable11, "1")
    }
    
    @IBAction func linelabel12(_ sender: Any) {
        MainViewDialog(self, goorback1).lineTextFieldDialog(linelabel12, linetimetable12, "2")
    }
    
    @IBAction func linelabel13(_ sender: Any) {
        MainViewDialog(self, goorback1).lineTextFieldDialog(linelabel13, linetimetable13, "3")
    }
    
    @IBAction func linelabel21(_ sender: Any) {
        MainViewDialog(self, goorback2).lineTextFieldDialog(linelabel21, linetimetable21, "1")
   }
    
    @IBAction func linelabel22(_ sender: Any) {
        MainViewDialog(self, goorback2).lineTextFieldDialog(linelabel22, linetimetable22, "2")
    }
    
    @IBAction func linelabel23(_ sender: Any) {
        MainViewDialog(self, goorback2).lineTextFieldDialog(linelabel23, linetimetable23, "3")
    }
    
    @IBAction func linetimetable11(_ sender: Any) {
        MainViewDialog(self, goorback1).rideTimeFieldDialog(linetimetable11, "1", weekflag)
    }
    
    
    @IBAction func linetimetable12(_ sender: Any) {
        MainViewDialog(self, goorback1).rideTimeFieldDialog(linetimetable12, "2", weekflag)
    }

    @IBAction func linetimetable13(_ sender: Any) {
        MainViewDialog(self, goorback1).rideTimeFieldDialog(linetimetable13, "3", weekflag)
    }
    
    @IBAction func linetimetable21(_ sender: Any) {
        MainViewDialog(self, goorback2).rideTimeFieldDialog(linetimetable21, "1", weekflag)
    }
    
    @IBAction func linetimetable22(_ sender: Any) {
        MainViewDialog(self, goorback2).rideTimeFieldDialog(linetimetable22, "2", weekflag)
    }

    @IBAction func linetimetable23(_ sender: Any) {
        MainViewDialog(self, goorback2).rideTimeFieldDialog(linetimetable23, "3", weekflag)
    }
    
    @IBAction func transportlabel11(_ sender: Any) {
        MainViewDialog(self, goorback1).transportPickerDialog(transportlabel11, "1")
    }
    
    @IBAction func transportlabel12(_ sender: Any) {
        MainViewDialog(self, goorback1).transportPickerDialog(transportlabel12, "2")
    }
    
    @IBAction func transportlabel13(_ sender: Any) {
        MainViewDialog(self, goorback1).transportPickerDialog(transportlabel13, "3")
    }
    
    @IBAction func transportlabel1e(_ sender: Any) {
        MainViewDialog(self, goorback1).transportPickerDialog(transportlabel1e, "e")
    }

    @IBAction func transportlabel21(_ sender: Any) {
        MainViewDialog(self, goorback2).transportPickerDialog(transportlabel21, "1")
    }
    
    @IBAction func transportlabel22(_ sender: Any) {
        MainViewDialog(self, goorback2).transportPickerDialog(transportlabel22, "2")
    }
    
    @IBAction func transportlabel23(_ sender: Any) {
        MainViewDialog(self, goorback2).transportPickerDialog(transportlabel23, "3")
    }
    
    @IBAction func transportlabel2e(_ sender: Any) {
        MainViewDialog(self, goorback2).transportPickerDialog(transportlabel2e, "e")
    }
    
    @IBAction func transittimelabel11(_ sender: Any) {
        MainViewDialog(self, goorback1).transitTimeFieldDialog("1")
    }
    
    @IBAction func transittomelabel12(_ sender: Any) {
        MainViewDialog(self, goorback1).transitTimeFieldDialog("2")
    }
    
    @IBAction func transittimelabel13(_ sender: Any) {
        MainViewDialog(self, goorback1).transitTimeFieldDialog("3")
    }
    
    @IBAction func transittimelabel1e(_ sender: Any) {
        MainViewDialog(self, goorback1).transitTimeFieldDialog("e")
    }
    
    @IBAction func transittimelabel21(_ sender: Any) {
        MainViewDialog(self, goorback2).transitTimeFieldDialog("1")
    }
    
    @IBAction func transittimelabel22(_ sender: Any) {
        MainViewDialog(self, goorback2).transitTimeFieldDialog("2")
    }
    
    @IBAction func transittimelabel23(_ sender: Any) {
        MainViewDialog(self, goorback2).transitTimeFieldDialog("3")
    }
    
    @IBAction func transittimelabel2e(_ sender: Any) {
        MainViewDialog(self, goorback2).transitTimeFieldDialog("e")
    }
    
    //ステータスバーの色を白に変更
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //ADMob広告の追加
    func addBannerViewToView(_ bannerView: GADBannerView) {
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bannerView)
            view.addConstraints([
                NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            ])
        }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
}
