//
//  FirestoreViewModel.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/16.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class MyFirestore: ObservableObject {
  
    @Published var title = ""
    @Published var message = ""
    @Published var isFirstLogin = false
    
    //UserDefaultsに保存されているデータを、Firestoreサーバーに保存
    func setFirestore() {
        let goorbackarray: [String] = ["back1", "go1", "back2", "go2"]
        for num in 0..<4 {
            for linenumber in 0..<3 {
                for day in 0..<2 {
                    setTimetableFirestore(goorbackarray[num], linenumber, day)
                }
            }
            setLineInfoFirestore(goorbackarray[num])
        }
    }

    //Firestoreサーバーからデータを取得し、UserDefaultsに保存
    func getFirestore() {
        let goorbackarray: [String] = ["back1", "go1", "back2", "go2"]
        for num in 0..<4 {
            for linenumber in 0..<3 {
                for day in 0..<2 {
                    for hour in 4..<26 {
                        getTimetableFirestore(goorbackarray[num], linenumber, day, hour)
                    }
                }
            }
            getLineInfoFirestore(goorbackarray[num])
        }
    }
    
    //UserDefaultsに保存されたデータをリセット
    func resetFirestore() {
        let goorbackarray: [String] = ["back1", "go1", "back2", "go2"]
        for num in 0..<4 {
            for linenumber in 0..<3 {
                for day in 0..<2 {
                    for hour in 4..<26 {
                        resetTimetableFirestore(goorbackarray[num], linenumber, day, hour)
                    }
                }
            }
            resetLineInfoFirestore(goorbackarray[num])
        }
    }

    //Firestoreサーバーに、UserDefaultsに保存された路線データを保存
    private func setLineInfoFirestore(_ goorback: String){
        let db = Firestore.firestore()
        let userid = Auth.auth().currentUser!.uid
        let userdb = db.collection("users").document(userid)
        let ref = userdb.collection("goorback").document(goorback)
        let batch = db.batch()
        batch.setData(setLineInfo(goorback), forDocument: ref)
        batch.commit() { error in
            self.title = "Data saved successfully".localized
            if error != nil {
                self.title = "Save data error".localized
                self.message = "Data could not be saved".localized
            }
        }
    }
    
    //UserDefaultsに保存された路線データを取得
    private func setLineInfo(_ goorback: String) -> [String : Any] {
        return [
            "switch": goorback.route2Flag,
            "changeline" : "\(goorback.changeLineInt)",
            "departpoint" : goorback.departurePoint,
            "arrivalpoint" : goorback.destinationPoint,
            "departstation1" : goorback.departStationArray[0],
            "departstation2" : goorback.departStationArray[1],
            "departstation3" : goorback.departStationArray[2],
            "arrivalstation1" : goorback.arriveStationArray[0],
            "arrivalstation2" : goorback.arriveStationArray[1],
            "arrivalstation3" : goorback.arriveStationArray[2],
            "linename1" : goorback.lineNameArray[0],
            "linename2" : goorback.lineNameArray[1],
            "linename3" : goorback.lineNameArray[2],
            "linecolor1" : goorback.lineColorStringArray[0],
            "linecolor2" : goorback.lineColorStringArray[1],
            "linecolor3" : goorback.lineColorStringArray[2],
            "ridetime1" : "\(goorback.rideTimeArray[0])",
            "ridetime2" : "\(goorback.rideTimeArray[1])",
            "ridetime3" : "\(goorback.rideTimeArray[2])",
            "transportation1" : goorback.transportationArray[1],
            "transportation2" : goorback.transportationArray[2],
            "transportation3" : goorback.transportationArray[3],
            "transportatione" : goorback.transportationArray[0],
            "transittime1" : "\(goorback.transitTimeArray[1])",
            "transittime2" : "\(goorback.transitTimeArray[2])",
            "transittime3" : "\(goorback.transitTimeArray[3])",
            "transittimee" : "\(goorback.transitTimeArray[0])"
        ]
    }
    
    //Firestoreサーバーから路線データを取得し、UserDefaultsに保存
    private func getLineInfoFirestore(_ goorback: String) {
        let db = Firestore.firestore()
        let userid = Auth.auth().currentUser!.uid
        let userdb = db.collection("users").document(userid)
        let ref = userdb.collection("goorback").document(goorback)
        ref.getDocument { (document, error) in
            self.title = "Data got successfully".localized
            if let document = document, document.exists, let data = document.data() {
                UserDefaults.standard.set(data["switch"], forKey: goorback.route2FlagKey)
                UserDefaults.standard.set(data["changeline"], forKey: goorback.changeLineKey)
                UserDefaults.standard.set(data["departpoint"], forKey: goorback.departurePointKey)
                UserDefaults.standard.set(data["arrivalpoint"], forKey: goorback.destinationKey)
                for num in 0..<3 {
                    UserDefaults.standard.set(data["departstation\(num + 1)"], forKey: goorback.departStationKey(num))
                    UserDefaults.standard.set(data["arrivalstation\(num + 1)"], forKey: goorback.arriveStationKey(num))
                    UserDefaults.standard.set(data["linename\(num + 1)"], forKey: goorback.lineNameKey(num))
                    UserDefaults.standard.set(data["linecolor\(num + 1)"], forKey: goorback.lineColorKey(num))
                    UserDefaults.standard.set(data["ridetime\(num + 1)"], forKey: goorback.rideTimeKey(num))
                    UserDefaults.standard.set(data["transportation\(num + 1)"], forKey: goorback.transportationKey(num + 1))
                    UserDefaults.standard.set(data["transittime\(num + 1)"], forKey: goorback.transitTimeKey(num + 1))
                }
                UserDefaults.standard.set(data["transportatione"], forKey: goorback.transportationKey(0))
                UserDefaults.standard.set(data["transittimee"], forKey: goorback.transitTimeKey(0))
            } else {
                self.title = "Get data error".localized
                self.message = "Data could not be got".localized
            }
        }
    }
    
    //UserDefaultsに保存された路線データをリセット
    private func resetLineInfoFirestore(_ goorback: String) {
        UserDefaults.standard.set(true, forKey: goorback.route2FlagKey)
        UserDefaults.standard.set("2", forKey: goorback.changeLineKey)
        UserDefaults.standard.set(goorback.departurePointDefault, forKey: goorback.departurePointKey)
        UserDefaults.standard.set(goorback.destinationDefault, forKey: goorback.destinationKey)
        for num in 0..<3 {
            UserDefaults.standard.set(goorback.departStationDefault(num), forKey: goorback.departStationKey(num))
            UserDefaults.standard.set(goorback.arriveStationDefault(num), forKey: goorback.arriveStationKey(num))
            UserDefaults.standard.set(goorback.lineNameDefault(num), forKey: goorback.lineNameKey(num))
            UserDefaults.standard.set("#03DAC5", forKey: goorback.lineColorKey(num))
            UserDefaults.standard.set("0", forKey: goorback.rideTimeKey(num))
        }
        for num in 0..<4 {
            UserDefaults.standard.set("Walking".localized, forKey: goorback.transportationKey(num))
            UserDefaults.standard.set("0", forKey: goorback.transitTimeKey(num))
        }
    }

    //Firestoreサーバーに、UserDefaultsに保存された時刻表データを保存
    private func setTimetableFirestore(_ goorback: String, _ num: Int, _ day: Int){
        let db = Firestore.firestore()
        let userid = Auth.auth().currentUser!.uid
        let userdb = db.collection("users").document(userid)
        let ref = userdb.collection("goorback").document(goorback)
        let nextref = ref.collection("timetable").document("timetable\(num + 1)\(day.weekDayOrEnd)")
        let batch = db.batch()
        batch.setData(setTimetableHour(goorback, num, day), forDocument: nextref)
        batch.commit() { error in
            self.title = "Data saved successfully".localized
            if error != nil {
                self.title = "Save data error".localized
                self.message = "Data could not be saved".localized
            }
        }
    }
    
    //UserDefaultsに保存された時刻表データを取得
    private func setTimetableHour(_ goorback: String, _ num: Int, _ day: Int)  -> [String : String] {
        let timetable = Timetable(goorback, day.weekDayOrEndFlag, num)
        return [
            "hour04" : timetable.timetableTime(4),
            "hour05" : timetable.timetableTime(5),
            "hour06" : timetable.timetableTime(6),
            "hour07" : timetable.timetableTime(7),
            "hour08" : timetable.timetableTime(8),
            "hour09" : timetable.timetableTime(9),
            "hour10" : timetable.timetableTime(10),
            "hour11" : timetable.timetableTime(11),
            "hour12" : timetable.timetableTime(12),
            "hour13" : timetable.timetableTime(13),
            "hour14" : timetable.timetableTime(14),
            "hour15" : timetable.timetableTime(15),
            "hour16" : timetable.timetableTime(16),
            "hour17" : timetable.timetableTime(17),
            "hour18" : timetable.timetableTime(18),
            "hour19" : timetable.timetableTime(19),
            "hour20" : timetable.timetableTime(20),
            "hour21" : timetable.timetableTime(21),
            "hour22" : timetable.timetableTime(22),
            "hour23" : timetable.timetableTime(23),
            "hour24" : timetable.timetableTime(24),
            "hour25" : timetable.timetableTime(25)
        ]
    }
    
    //Firestoreサーバーから時刻表データを取得し、UserDefaultsに保存
    private func getTimetableFirestore(_ goorback: String, _ num: Int, _ day: Int, _ hour: Int) {
        let db = Firestore.firestore()
        let userid = Auth.auth().currentUser!.uid
        let userdb = db.collection("users").document(userid)
        let ref = userdb.collection("goorback").document(goorback)
        let nextref = ref.collection("timetable").document("timetable\(num + 1)\(day.weekDayOrEnd)")
        nextref.getDocument { (document, error) in
            self.title = "Data got successfully".localized
            if let document = document, document.exists, let data = document.data() {
                UserDefaults.standard.setValue(data["hour\(hour.addZeroTime)"],
                    forKey: Timetable(goorback, day.weekDayOrEndFlag, num).timetableKey(hour)
                )
            } else {
                self.title = "Get data error".localized
                self.message = "Data could not be got".localized
            }
        }
    }
    
    //UserDefaultsに保存された時刻表データをリセット
    private func resetTimetableFirestore(_ goorback: String, _ num: Int, _ day: Int, _ hour: Int) {
        UserDefaults.standard.setValue("",
            forKey: Timetable(goorback, day.weekDayOrEndFlag, num).timetableKey(hour)
        )
    }
}
