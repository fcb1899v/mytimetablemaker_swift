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
    @Published var isShowAlert = false
    @Published var isShowMessage = false
    @Published var isFirestoreSuccess = false
    @Published var isLoading = false

    private func getRef(_ goorback: String) -> DocumentReference {
        let db = Firestore.firestore()
        let userid = Auth.auth().currentUser!.uid
        let userdb = db.collection("users").document(userid)
        return userdb.collection("goorback").document(goorback)
    }
 
    //UserDefaultsに保存されているデータを、Firestoreサーバーに保存
    func setFirestore() {
        isLoading = true
        isShowAlert = false
        isShowMessage = false
        isFirestoreSuccess = false
        title = "Save data error".localized
        message = "Data could not be saved".localized
        goorbackarray.forEach { goorback in
            (0..<3).forEach { linenumber in
                (0..<2).forEach { day in setTimetableFirestore(goorback, linenumber, day) }
            }
            setLineInfoFirestore(goorback)
            print(goorback)
        }
    }

    //Firestoreサーバーに、UserDefaultsに保存された時刻表データを保存
    private func setTimetableFirestore(_ goorback: String, _ num: Int, _ day: Int){
        let nextref = getRef(goorback).collection("timetable").document("timetable\(num + 1)\(day.isWeekday.weekdayTag)")
        let batch = Firestore.firestore().batch()
        batch.setData(
            [
                "hour04" : goorback.timetableTime(day.isWeekday, num, 4),
                "hour05" : goorback.timetableTime(day.isWeekday, num, 5),
                "hour06" : goorback.timetableTime(day.isWeekday, num, 6),
                "hour07" : goorback.timetableTime(day.isWeekday, num, 7),
                "hour08" : goorback.timetableTime(day.isWeekday, num, 8),
                "hour09" : goorback.timetableTime(day.isWeekday, num, 9),
                "hour10" : goorback.timetableTime(day.isWeekday, num, 10),
                "hour11" : goorback.timetableTime(day.isWeekday, num, 11),
                "hour12" : goorback.timetableTime(day.isWeekday, num, 12),
                "hour13" : goorback.timetableTime(day.isWeekday, num, 13),
                "hour14" : goorback.timetableTime(day.isWeekday, num, 14),
                "hour15" : goorback.timetableTime(day.isWeekday, num, 15),
                "hour16" : goorback.timetableTime(day.isWeekday, num, 16),
                "hour17" : goorback.timetableTime(day.isWeekday, num, 17),
                "hour18" : goorback.timetableTime(day.isWeekday, num, 18),
                "hour19" : goorback.timetableTime(day.isWeekday, num, 19),
                "hour20" : goorback.timetableTime(day.isWeekday, num, 20),
                "hour21" : goorback.timetableTime(day.isWeekday, num, 21),
                "hour22" : goorback.timetableTime(day.isWeekday, num, 22),
                "hour23" : goorback.timetableTime(day.isWeekday, num, 23),
                "hour24" : goorback.timetableTime(day.isWeekday, num, 24),
                "hour25" : goorback.timetableTime(day.isWeekday, num, 25)
            ],
            forDocument: nextref
        )
        batch.commit()
//        { [self] error in
//            if error != nil {
//                title = "Save data error".localized
//                message = "Data could not be saved".localized
//            }
//        }
    }

    //Firestoreサーバーに、UserDefaultsに保存された路線データを保存
    private func setLineInfoFirestore(_ goorback: String){
        let batch = Firestore.firestore().batch()
        batch.setData(
            [
                "switch": goorback.isShowRoute2,
                "changeline" : "\(goorback.changeLineInt)",
                "departpoint" : goorback.departurePoint,
                "arrivalpoint" : goorback.destination,
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
            ],
            forDocument: getRef(goorback)
        )
        batch.commit() { [self] error in
            if error != nil {
                if (goorback == "go2") {
                    isLoading = false
                    isShowMessage = true
                }
            } else {
                if (goorback == "go2") {
                    title = "Data saved successfully".localized
                    message = ""
                    isFirestoreSuccess = true
                    isLoading = false
                    isShowMessage = true
                }
            }
        }
    }
        

    //Firestoreサーバーからデータを取得し、UserDefaultsに保存
    func getFirestore() {
        isLoading = true
        isShowAlert = false
        isShowMessage = false
        isFirestoreSuccess = false
        title = "Get data error".localized
        message = "Data could not be got".localized
        goorbackarray.forEach { goorback in
            (0..<3).forEach { linenumber in
                (0..<2).forEach { day in
                    (4..<26).forEach { hour in getTimetableFirestore(goorback, linenumber, day, hour) }
                }
            }
            getLineInfoFirestore(goorback)
            print(goorback)
        }
    }
    
    //Firestoreサーバーから路線データを取得し、UserDefaultsに保存
    private func getLineInfoFirestore(_ goorback: String) {
        getRef(goorback).getDocument { [self] (document, error) in
            if let document = document, document.exists, let data = document.data() {
                UserDefaults.standard.set(data["switch"], forKey: goorback.isShowRoute2Key)
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
                if (goorback == "go2") {
                    title = "Data got successfully".localized
                    message = ""
                    isFirestoreSuccess = true
                    isLoading = false
                    isShowMessage = true
                }
            } else {
                if (goorback == "go2") {
                    isLoading = false
                    isShowMessage = true
                }

            }
        }
    }
    
    //Firestoreサーバーから時刻表データを取得し、UserDefaultsに保存
    private func getTimetableFirestore(_ goorback: String, _ num: Int, _ day: Int, _ hour: Int) {
        let nextref = getRef(goorback).collection("timetable").document("timetable\(num + 1)\(day.isWeekday.weekdayTag)")
        nextref.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                UserDefaults.standard.setValue(data["hour\(hour.addZeroTime)"],
                    forKey: goorback.timetableKey(day.isWeekday, num, hour)
                )
            }
        }
    }
}
