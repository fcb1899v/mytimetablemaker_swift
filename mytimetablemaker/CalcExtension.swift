//
//  CalcExtension.swift
//  mytimetablemaker
//
//  Created by 中島正雄 on 2020/10/30.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import Foundation
import UIKit

//＜時刻の変換＞
extension Int {
    //Int型時刻HHMMをMMに変換する関数
    var HHMMtoMM: Int {
        return self / 100 * 60 + self % 100
    }
    //Int型時刻MMをHHMMに変換する関数
    var MMtoHHMM: Int {
        return self / 60 * 100 + self % 60
    }
    //Int型時刻MMSSをSSに変換する関数
    var MMSStoSS: Int {
        return self / 100 * 60 + self % 100
    }
    //Int型時刻SSをMMSSに変換する関数
    var SStoMMSS: Int {
        return self / 60 * 100 + self % 60
    }
    //Int型時刻HHMMSSをSSに変換する関数
    var HHMMSStoSS: Int {
        return self / 10000 * 3600 + (self % 10000) / 100 * 60 + self % 100
    }
    //Int型時刻SSをHHMMSSに変換する関数
    var SStoHHMMSS: Int {
        return self / 3600 * 10000 + (self % 3600) / 60 * 100 + self % 60
    }
    //Int型時刻HHMMSSをMMSSに変換する関数
    var HHMMSStoMMSS: Int {
        return (self / 10000 * 60 + (self % 10000) / 100) * 100 + self % 100
    }
    //Int型時刻MMSSをHHMMSSに変換する関数
    var MMSStoHHMMSS: Int {
        return (self / 100 / 60) * 10000 + (self / 100 % 60) * 100 + self % 100
    }
}

//＜時刻の計算＞
extension Int {
    
    //Int型時刻HHMMの足し算
    func plusHHMM(_ time: Int) -> Int {
        return (self.HHMMtoMM + time.HHMMtoMM).MMtoHHMM
    }
    //Int型時刻HHMMSSの足し算
    func plusHHMMSS(_ time: Int) -> Int {
        return (self.HHMMSStoSS + time.HHMMSStoSS).SStoHHMMSS
    }
    //Int型時刻MMSSの足し算
    func plusMMSS(_ time: Int) -> Int {
        return (self.MMSStoSS + time.MMSStoSS).SStoMMSS
    }
    //Int型時刻HHMMの引き算をする関数
    func minusHHMM(_ time: Int) -> Int {
        return (self.HHMMtoMM < time.HHMMtoMM) ?
            ((self + 2400).HHMMtoMM - time.HHMMtoMM).MMtoHHMM:
            (self.HHMMtoMM - time.HHMMtoMM).MMtoHHMM
    }
    //Int型時刻HHMMSSの引き算をする関数
    func minusHHMMSS(_ time: Int) -> Int {
        return (self.HHMMSStoSS < time.HHMMSStoSS) ?
            ((self + 240000).HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS:
            (self.HHMMSStoSS - time.HHMMSStoSS).SStoHHMMSS
    }
    //Int型時刻HHMMの引き算をする関数
    func minusMMSS(_ time: Int) -> Int {
        return (self.MMSStoSS - time.MMSStoSS).SStoMMSS
    }
}

//＜時刻の表示＞
extension Int {
    //1桁のときに0を追加
    var addZeroTime: String {
        return (0...9 ~= self) ? "0" + String(self): String(self)
    }
    //Int型時刻HHMMから表示時刻に変換
    var stringTime: String {
        let stringtimehh = (self / 100 + (self % 100) / 60).addZeroTime
        let stringtimemm = (self % 100 % 60).addZeroTime
        let stringtime = stringtimehh + ":" + stringtimemm
        if (stringtime != "27:00") {
            return stringtimehh + ":" + stringtimemm
        } else {
            return "--:--"
        }
    }
    //Int型時刻MMSSからカウントダウンに変換
    var countdown: String{
        var intcountdowntime = self
        switch (self) {
            case 0...9999: break
            default: intcountdowntime = -1000000
        }
        let countdownmm: String = (intcountdowntime / 100).addZeroTime
        let countdownss: String = (intcountdowntime % 100).addZeroTime
        if (intcountdowntime == -1000000) {
            return "--:--"
        } else {
            return countdownmm + ":" + countdownss
        }
    }
    //カウントダウン時間（mm:ss）を取得
    func countdownTime(_ departtime: Int) -> String {
        //カウントダウン（出発時刻と現在時刻の差）を計算
        return (departtime * 100).minusHHMMSS(self).HHMMSStoMMSS.countdown
    }
    //カウントダウン表示の警告色を取得
    func countdownColor(_ departtime:Int) -> UIColor{
        return (departtime * 100).minusHHMMSS(self).HHMMSStoMMSS.countdownColor!
    }
    //
    var countdownColor: UIColor? {
        if (self % 2 == 0) {
            switch (self) {
                case 1000...9999: return DefaultColor.accent.UI
                case 500...999: return DefaultColor.yellow.UI
                case 0...499: return DefaultColor.red.UI
                default: return DefaultColor.gray.UI
            }
        }
        return DefaultColor.gray.UI
    }
}

