//
//  FirestoreViewModel.swift
//  mytimetablemakers_swiftui
//
//  Created by Nakajima Masao on 2021/03/16.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Firestore Data Manager
// Handles data synchronization between UserDefaults and Firestore database
class MyFirestore: ObservableObject {
  
    @Published var title = ""
    @Published var message = ""
    @Published var isShowAlert = false
    @Published var isShowMessage = false
    @Published var isFirestoreSuccess = false
    @Published var isLoading = false

    // MARK: - Firestore Reference Helper
    // Creates Firestore document reference for current user and route
    private func getRef(_ goorback: String) -> DocumentReference {
        let db = Firestore.firestore()
        let userid = Auth.auth().currentUser!.uid
        let userdb = db.collection("users").document(userid)
        return userdb.collection("goorback").document(goorback)
    }
 
    // MARK: - Data Upload
    // Uploads all UserDefaults data to Firestore server
    func setFirestore() {
        isLoading = true
        isShowAlert = false
        isShowMessage = false
        isFirestoreSuccess = false
        title = "Save data error".localized
        message = "Data could not be saved".localized
        goorbackarray.forEach { goorback in
            (0..<3).forEach { linenumber in
                // Get available calendar types for this route and line
                let availableCalendarTypes = getAvailableCalendarTypesForRoute(goorback: goorback, num: linenumber)
                setTimetableFirestore(goorback, linenumber, availableCalendarTypes)
            }
            setLineInfoFirestore(goorback)
            print(goorback)
        }
    }
    
    // MARK: - Available Calendar Types Detection
    // Get available calendar types for specific route and line
    private func getAvailableCalendarTypesForRoute(goorback: String, num: Int) -> [ODPTCalendarType] {
        var availableTypes: [ODPTCalendarType] = []
        
        // Check which calendar types have data in UserDefaults
        for calendarType in ODPTCalendarType.allCases {
            var hasData = false
            for hour in 4...25 {
                let timetableKey = goorback.timetableKey(calendarType, num, hour)
                if UserDefaults.standard.string(forKey: timetableKey) != nil {
                    hasData = true
                    break
                }
            }
            if hasData {
                availableTypes.append(calendarType)
            }
        }
        
        // Fallback to basic types if no data found
        if availableTypes.isEmpty {
            availableTypes = [.weekday, .saturdayHoliday]
        }
        
        print("📅 Available calendar types for \(goorback) line \(num): \(availableTypes.map { $0.debugDisplayName })")
        return availableTypes
    }
    
    // MARK: - Timetable Upload
    // Uploads timetable data for specific route, line, and available calendar types to Firestore
    private func setTimetableFirestore(_ goorback: String, _ num: Int, _ availableCalendarTypes: [ODPTCalendarType]){
        for calendarType in availableCalendarTypes {
            let documentName = "timetable\(num + 1)\(calendarType.calendarTag)"
            let nextref = getRef(goorback).collection("timetable").document(documentName)
            
            print("🔍 setTimetableFirestore - goorback: \(goorback), num: \(num), calendarType: \(calendarType.debugDisplayName)")
            print("🔍 Calendar type: \(calendarType.debugDisplayName), tag: \(calendarType.calendarTag)")
            print("🔍 Document name: \(documentName)")
            print("🔍 Full path: \(nextref.path)")
            
            let batch = Firestore.firestore().batch()
            
            // Create comprehensive hour data with backward compatibility
            var hourData: [String: Any] = [:]
            
            for hour in 4...25 {
                let hourKey = "hour\(String(format: "%02d", hour))"
                let timetableKey = goorback.timetableKey(calendarType, num, hour)
                let timetableRideTimeKey = goorback.timetableRideTimeKey(calendarType, num, hour)
                let timetableTrainTypeKey = goorback.timetableTrainTypeKey(calendarType, num, hour)
                
                // Get data from UserDefaults
                let timetableData = UserDefaults.standard.string(forKey: timetableKey) ?? ""
                let rideTimeData = UserDefaults.standard.string(forKey: timetableRideTimeKey) ?? ""
                let trainTypeData = UserDefaults.standard.string(forKey: timetableTrainTypeKey) ?? ""
                
                // Save in both formats for backward compatibility
                // Legacy format (string) - for existing clients
                hourData[hourKey] = timetableData
                
                // New format (dictionary) - for enhanced data
                hourData["\(hourKey)_enhanced"] = [
                    "timetable": timetableData,
                    "rideTime": rideTimeData,
                    "trainType": trainTypeData
                ]
                
                if hour < 9 && !timetableData.isEmpty {
                    print("📊 Hour \(hour): timetable='\(timetableData)', rideTime='\(rideTimeData)', trainType='\(trainTypeData)'")
                }
            }
            
            print("🔍 Hour data count: \(hourData.count)")
            batch.setData(hourData, forDocument: nextref)
            batch.commit()
            
            print("✅ Uploaded timetable data to Firestore for \(calendarType.debugDisplayName)")
        }
    }
    
    // MARK: - Cleanup Unused Calendar Types
    // Removes Firestore documents for calendar types that are no longer available
    func cleanupUnusedCalendarTypes(_ goorback: String, _ num: Int, availableTypes: [ODPTCalendarType]) {
        let collection = getRef(goorback).collection("timetable")
        for calendarType in ODPTCalendarType.allCases {
            if !availableTypes.contains(calendarType) {
                let docRef = collection.document("timetable\(num + 1)\(calendarType.calendarTag)")
                docRef.delete { error in
                    if let error = error {
                        print("❌ Failed to delete unused calendar type \(calendarType.debugDisplayName): \(error)")
                    } else {
                        print("🗑️ Deleted unused calendar type: \(calendarType.debugDisplayName)")
                    }
                }
            }
        }
    }

    // MARK: - Line Information Upload
    // Uploads line information (stations, colors, times) to Firestore
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
                "linecode1" : goorback.lineCodeArray[0],
                "linecode2" : goorback.lineCodeArray[1],
                "linecode3" : goorback.lineCodeArray[2],
                "linekind1" : goorback.lineKindArray[0].rawValue,
                "linekind2" : goorback.lineKindArray[1].rawValue,
                "linekind3" : goorback.lineKindArray[2].rawValue,
                "ridetime1" : "\(goorback.rideTimeArray[0])",
                "ridetime2" : "\(goorback.rideTimeArray[1])",
                "ridetime3" : "\(goorback.rideTimeArray[2])",
                "transportation1" : goorback.transportationArray[1],
                "transportation2" : goorback.transportationArray[2],
                "transportation3" : goorback.transportationArray[3],
                "transportatione" : goorback.transportationArray[0],
                "transittime1" : "\(goorback.transferTimeArray[1])",
                "transittime2" : "\(goorback.transferTimeArray[2])",
                "transittime3" : "\(goorback.transferTimeArray[3])",
                "transittimee" : "\(goorback.transferTimeArray[0])"
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
        

    // MARK: - Data Download
    // Downloads all data from Firestore server to UserDefaults
    func getFirestore() {
        isLoading = true
        isShowAlert = false
        isShowMessage = false
        isFirestoreSuccess = false
        title = "Get data error".localized
        message = "Data could not be got".localized
        goorbackarray.forEach { goorback in
            (0..<3).forEach { linenumber in
                // Get available calendar types for this route and line
                let availableCalendarTypes = getAvailableCalendarTypesForRoute(goorback: goorback, num: linenumber)
                availableCalendarTypes.forEach { calendarType in
                    getTimetableFirestore(goorback, linenumber, calendarType)
                }
            }
            getLineInfoFirestore(goorback)
            print(goorback)
        }
    }
    
    // MARK: - Line Information Download
    // Downloads line information from Firestore and saves to UserDefaults
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
                    UserDefaults.standard.set(data["linecode\(num + 1)"], forKey: goorback.lineCodeKey(num))
                    UserDefaults.standard.set(data["linekind\(num + 1)"], forKey: goorback.lineKindKey(num))
                    UserDefaults.standard.set(data["ridetime\(num + 1)"], forKey: goorback.rideTimeKey(num))
                    UserDefaults.standard.set(data["transportation\(num + 1)"], forKey: goorback.transportationKey(num + 1))
                    UserDefaults.standard.set(data["transittime\(num + 1)"], forKey: goorback.transferTimeKey(num + 1))
                }
                UserDefaults.standard.set(data["transportatione"], forKey: goorback.transportationKey(0))
                UserDefaults.standard.set(data["transittimee"], forKey: goorback.transferTimeKey(0))
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
    
    // MARK: - Timetable Download
    // Downloads timetable data for specific route, line, and calendar type from Firestore
    private func getTimetableFirestore(_ goorback: String, _ num: Int, _ calendarType: ODPTCalendarType) {
        let documentName = "timetable\(num + 1)\(calendarType.calendarTag)"
        let nextref = getRef(goorback).collection("timetable").document(documentName)
        
        print("🔍 getTimetableFirestore - goorback: \(goorback), num: \(num), calendarType: \(calendarType.debugDisplayName)")
        print("🔍 Calendar type: \(calendarType.debugDisplayName), tag: \(calendarType.calendarTag)")
        print("🔍 Document name: \(documentName)")
        print("🔍 Full path: \(nextref.path)")
        
        nextref.getDocument { (document, error) in
            if let error = error {
                print("❌ Error getting document for \(calendarType.debugDisplayName): \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                print("✅ Document exists for \(calendarType.debugDisplayName) with \(document.data()?.count ?? 0) fields")
                if let data = document.data() {
                    // Set data from Firestore for all hours with backward compatibility
                    for hour in 4...25 {
                        let hourKey = "hour\(String(format: "%02d", hour))"
                        let enhancedHourKey = "\(hourKey)_enhanced"
                        let timetableKey = goorback.timetableKey(calendarType, num, hour)
                        let timetableRideTimeKey = goorback.timetableRideTimeKey(calendarType, num, hour)
                        let timetableTrainTypeKey = goorback.timetableTrainTypeKey(calendarType, num, hour)
                        
                        // Try to load enhanced format first (new format)
                        if let enhancedData = data[enhancedHourKey] as? [String: String] {
                            // New format with structured data
                            UserDefaults.standard.set(enhancedData["timetable"] ?? "", forKey: timetableKey)
                            UserDefaults.standard.set(enhancedData["rideTime"] ?? "", forKey: timetableRideTimeKey)
                            UserDefaults.standard.set(enhancedData["trainType"] ?? "", forKey: timetableTrainTypeKey)
                            
                            if hour < 9 && !(enhancedData["timetable"] ?? "").isEmpty {
                                print("📊 Downloaded Hour \(hour) (enhanced): timetable='\(enhancedData["timetable"] ?? "")', rideTime='\(enhancedData["rideTime"] ?? "")', trainType='\(enhancedData["trainType"] ?? "")'")
                            }
                        } else if let hourDataString = data[hourKey] as? String {
                            // Legacy format - only timetable data available
                            UserDefaults.standard.set(hourDataString, forKey: timetableKey)
                            // Clear ride time and train type for legacy data
                            UserDefaults.standard.set("", forKey: timetableRideTimeKey)
                            UserDefaults.standard.set("", forKey: timetableTrainTypeKey)
                            
                            if hour < 9 && !hourDataString.isEmpty {
                                print("📊 Downloaded Hour \(hour) (legacy): timetable='\(hourDataString)'")
                            }
                        }
                    }
                    print("✅ Downloaded timetable data from Firestore for \(calendarType.debugDisplayName)")
                }
            } else {
                print("❌ Document does not exist for \(calendarType.debugDisplayName): \(documentName)")
            }
        }
    }
    
    // MARK: - Local Data Clearing
    // Clear local UserDefaults data for all calendar types and line
    private func clearLocalTimetableData(goorback: String, num: Int) {
        for calendarType in ODPTCalendarType.allCases {
            for hour in 4...25 {
                let timetableKey = goorback.timetableKey(calendarType, num, hour)
                let timetableRideTimeKey = goorback.timetableRideTimeKey(calendarType, num, hour)
                let timetableTrainTypeKey = goorback.timetableTrainTypeKey(calendarType, num, hour)
                
                UserDefaults.standard.removeObject(forKey: timetableKey)
                UserDefaults.standard.removeObject(forKey: timetableRideTimeKey)
                UserDefaults.standard.removeObject(forKey: timetableTrainTypeKey)
            }
        }
        print("🗑️ Cleared local timetable data for all calendar types")
    }
    
}
