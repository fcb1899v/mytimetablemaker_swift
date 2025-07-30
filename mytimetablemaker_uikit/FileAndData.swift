//
//  FIleAndData.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/09/06.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import UIKit

// MARK: - File and Data Management
// Handles file operations and UserDefaults data access with default value retrieval
class FileAndData: NSObject {

    // MARK: - Settings Title Management
    // Gets various settings title based on route direction
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
    
    // MARK: - UserDefaults Data Access
    // Retrieves string values from UserDefaults with fallback defaults
    class func getUserDefaultValue(key: String, defaultvalue: String) -> String? {
        return UserDefaults.standard.string(forKey: key) ?? defaultvalue
    }

    // Retrieves integer values from UserDefaults with fallback defaults
    class func getUserDefaultInt(key: String, defaultvalue: Int) -> Int? {
        return UserDefaults.standard.integer(forKey: key) ?? defaultvalue
    }

    // Retrieves color data from UserDefaults with fallback defaults
    class func getUserDefaultColor(key: String, defaultvalue: Int) -> UIColor? {
        return (UserDefaults.standard.string(forKey: key) != nil) ?
            UIColor(rgb: UserDefaults.standard.integer(forKey: key)):
            UIColor(rgb: defaultvalue)
    }
    
    // MARK: - Location Data Access
    // Retrieves departure point from UserDefaults
    class func getDeparturePoint(goorback: String) -> String {
        let key = (goorback == "back1" || goorback == "back2") ?
            "destination":
            "departurepoint"
        let defaultvalue = (goorback == "back1" || goorback == "back2") ?
            "Office":
            "Home"
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
    }

    // Retrieves destination from UserDefaults
    class func getDestination(goorback: String) -> String {
        let key = (goorback == "back1" || goorback == "back2") ?
            "departurepoint":
            "destination"
        let defaultvalue = (goorback == "back1" || goorback == "back2") ?
            "Home":
            "Office"
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
    }

    // MARK: - Station Data Access
    // Gets default value for departure station name
    class func getDepartStationDefaultvalue(goorback: String, keytag: String) -> String {    
        return (goorback == "back2" || goorback == "go2") ?
            "Dep. St.2-" + keytag:
            "Dep. St.1-" + keytag
    }

    // Retrieves departure station name from UserDefaults
    class func getDepartStation(goorback: String, keytag: String) -> String {
        return getUserDefaultValue(
            key: goorback + "departstation" + keytag, 
            defaultvalue: getDepartStationDefaultvalue(goorback: goorback, keytag: keytag))!
    }

    // Gets default value for arrival station name
    class func getArriveStationDefaultvalue(goorback: String, keytag: String) -> String {    
        return (goorback == "back2" || goorback == "go2") ?
            "Arr. St.2-" + keytag:
            "Arr. St.1-" + keytag
    }

    // Retrieves arrival station name from UserDefaults
    class func getArriveStation(goorback: String, keytag: String) -> String {
        return getUserDefaultValue(
            key: goorback + "arrivestation" + keytag, 
            defaultvalue: getArriveStationDefaultvalue(goorback: goorback, keytag: keytag))!
    }
    
    // MARK: - Transfer Information Access
    // Retrieves number of transfers from UserDefaults with string to integer conversion
    class func getIntChangeLine(goorback: String) -> Int {
        let changelinekey = goorback + "changeline"
        let changeline = FileAndData.getUserDefaultValue(key: changelinekey, defaultvalue: "Zero")
        var intchangeline = 0
        switch (changeline) {
            case "Once": intchangeline = 1
            case "Twice": intchangeline = 2
            default : intchangeline = 0
        }
        return intchangeline
    }

    // Retrieves transit departure station from UserDefaults
    class func getTransitDepartStation(goorback: String, keytag: String) -> String {
        let intchangeline = getIntChangeLine(goorback: goorback)
        let intkeytag = Int(keytag) ?? intchangeline + 2
        let keytag0 = (intkeytag > intchangeline + 2) ? String(intchangeline + 1): String(intkeytag - 1)
        var key = goorback + "arrivestation" + keytag0
        var defaultvalue = getArriveStationDefaultvalue(goorback: goorback, keytag: keytag0)
        if (keytag0 == "0") {
            key = (goorback == "back1" || goorback == "back2") ? "destination": "departurepoint"
            defaultvalue = (goorback == "back1" || goorback == "back2") ? "Office": "Home"
        }
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
    }
    
    // Retrieves transit arrival station from UserDefaults
    class func getTransitArriveStation(goorback: String, keytag: String) -> String {
        let intchangeline = getIntChangeLine(goorback: goorback)
        let intkeytag = Int(keytag) ?? intchangeline + 2
        let keytag0 = (intkeytag > intchangeline + 1) ? "e": keytag
        var key = goorback + "departstation" + keytag0
        var defaultvalue = getDepartStationDefaultvalue(goorback: goorback, keytag: keytag0)
        if (keytag0 == "e") {
            key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
            defaultvalue = (goorback == "back1" || goorback == "back2") ? "Home": "Office"
        }
        return getUserDefaultValue(key: key, defaultvalue: defaultvalue)!
    }
    
    // MARK: - Line Name Management
    // Gets default value for line name
    class func getLinenameDefaultvalue(goorback: String, keytag: String) -> String {
        return (goorback == "back2" || goorback == "go2") ?
            "Line 2-" + keytag:
            "Line 1-" + keytag
    }

    // Retrieves line name from UserDefaults
    class func getLinename(goorback: String, keytag: String) -> String {
        return getUserDefaultValue(
            key: goorback + "linename" + keytag, 
            defaultvalue: getLinenameDefaultvalue(goorback: goorback, keytag: keytag))!
    }
    
    // Retrieves line color from UserDefaults
    class func getLineColor(goorback: String, keytag: String, defaultcolor: Int) -> UIColor {
        return getUserDefaultColor(
            key: goorback + "linecolor" + keytag, 
            defaultvalue: defaultcolor)!
    }

    // MARK: - Display Flag Management
    // Gets display flag for route 2
    class func getDisplayBool(goorback2: String) -> Bool {
        let key = goorback2 + "display"
        return (UserDefaults.standard.string(forKey: key) != nil) ?
            UserDefaults.standard.bool(forKey: key):
            false
    }
    
    // Changes display based on number of transfers
    class func changeDisplayLine(intchangeline: Int, stackview2: UIStackView, stackview3: UIStackView) {
        switch (intchangeline) {
            case 1:
                stackview2.isHidden = false
                stackview3.isHidden = true
             