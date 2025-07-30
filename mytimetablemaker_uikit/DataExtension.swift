//
//  DataExtension.swift
//  mytimetablemaker
//
//  Created by Masao Nakajima on 2020/10/30.
//  Copyright © 2020 com.nakajimamasao. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Localization Extension
// Provides localization support for strings
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: self)
    }
}

// MARK: - UserDefaults Key Extensions
// Extensions for UserDefaults data access with key-based operations
extension String{
    // MARK: - UserDefaults Data Retrieval
    // Retrieves string value from UserDefaults with fallback default
    func userDefaultValue(_ defaultvalue: String?) -> String {
        let defaultstring = (defaultvalue != nil) ? defaultvalue: ""
        return UserDefaults.standard.string(forKey: self) ?? defaultstring!
    }
    // Retrieves integer value from UserDefaults with fallback default
    func userDefaultInt(_ defaultvalue: Int?) -> Int {
        let defaultint = (defaultvalue != nil) ? defaultvalue: 0
        return (UserDefaults.standard.object(forKey: self) != nil) ?
            UserDefaults.standard.integer(forKey: self):
            defaultint!
    }
    // Retrieves boolean value from UserDefaults with fallback default
    func userDefaultBool(_ defaultvalue: Bool?) -> Bool {
        let defaultbool = (defaultvalue != nil) ? defaultvalue: false
        return (UserDefaults.standard.object(forKey: self) != nil) ?
            UserDefaults.standard.bool(forKey: self):
            defaultbool!
    }
    // Retrieves color value from UserDefaults with fallback default
    func userDefaultColor(_ defaultvalue: Int?) -> UIColor? {
        let defaultint = (defaultvalue != nil) ? defaultvalue: 0
        return (UserDefaults.standard.object(forKey: self) != nil) ?
            UIColor(UserDefaults.standard.integer(forKey: self)):
            UIColor(defaultint!)
    }
}

// MARK: - Route Direction Extensions (Main Screen)
// Extensions for handling route direction (go/back) in main screen
extension String{
    // MARK: - Route Direction Logic
    // Returns different string values based on route direction
    func stringGoOrBack(_ backstring: String, _ gostring: String) -> String {
        return (self == "back1" || self == "back2") ? backstring: gostring
    }
    // Retrieves departure point from UserDefaults based on route direction
    func departurePoint(_ backdefault: String, _ godefault: String) -> String {
        return self.stringGoOrBack(
            "destination".userDefaultValue(backdefault),
            "departurepoint".userDefaultValue(godefault)
        )
    }
    // Retrieves destination from UserDefaults based on route direction
    func destination(_ backdefault: String, _ godefault: String) -> String {
        return self.stringGoOrBack(
            "departurepoint".userDefaultValue(backdefault),
            "destination".userDefaultValue(godefault)
        )
    }
    
    // MARK: - Station Information
    // Retrieves departure station name from UserDefaults
    func departStation(_ keytag: String, _ depstadefault: String) -> String {
        return "\(self)departstation\(keytag)".userDefaultValue(depstadefault)
    }
    // Retrieves arrival station name from UserDefaults
    func arriveStation(_ keytag: String, _ arrstadefault: String) -> String {
        return "\(self)arrivestation\(keytag)".userDefaultValue(arrstadefault)
    }
    // Retrieves line name from UserDefaults
    func lineName(_ keytag: String, _ linedefault: String) -> String {
        return "\(self)linename\(keytag)".userDefaultValue(linedefault)
    }
    // Retrieves line color from UserDefaults
    func lineColor(_ keytag: String, _ colordefault: Int) -> UIColor? {
        return "\(self)linecolor\(keytag)".userDefaultColor(colordefault)
    }
    // Retrieves transportation mode from UserDefaults
    func transportation(_ keytag: String, _ transportdefalut: String) -> String {
        return "\(self)transport\(keytag)".userDefaultValue(transportdefalut)
    }
    
    // MARK: - Transfer Information
    // Retrieves transit departure station from UserDefaults
    func transitDepartStation(_ keytag: String) -> String {
        let intkeytag = Int(keytag) ?? self.changeLineInt + 2
        let keytag0 = (intkeytag > self.changeLineInt + 2) ?
            String(self.changeLineInt + 1): String(intkeytag - 1)
        return (keytag0 == "0") ? self.departurePoint("Office".localized, "Home".localized):
            "\(self)arrivestation\(keytag0)".userDefaultValue("\("Arr. St.".localized)\(keytag0)")
    }
    // Retrieves transit arrival station from UserDefaults
    func transitArriveStation(_ keytag: String) -> String {
        let intkeytag = Int(keytag) ?? self.changeLineInt + 2
        let keytag0 = (intkeytag > self.changeLineInt + 1) ? "e": keytag
        return (keytag0 == "e") ? self.destination("Home".localized, "Office".localized):
            "\(self)departstation\(keytag0)".userDefaultValue("\("Dep. St.".localized)\(keytag0)")
    }
    
    // MARK: - Time Information
    // Retrieves ride time from UserDefaults
    func rideTime(_ keytag: String) -> Int {
        return "\(self)ridetime\(keytag)".userDefaultInt(0)
    }
    // Retrieves ride time as string for settings screen
    func rideTimeString(_ keytag: String) -> String {
        return (self.rideTime(keytag) == 0) ? Unit.notset.rawValue.localized:
            "\(String(self.rideTime(keytag)))\(Unit.minites.rawValue.localized)"
    }
    // Retrieves transit time from UserDefaults
    func transitTime(_ keytag: String) -> Int {
        return "\(self)transittime\(keytag)".userDefaultInt(0)
    }
    // Retrieves transit time as string for settings screen
    func transitTimeString(_ keytag: String) -> String {
        return (self.transitTime(keytag) == 0) ? Unit.notset.rawValue.localized:
            "\(String(self.transitTime(keytag)))\(Unit.minites.rawValue.localized)"
    }
}

// MARK: - Route Direction Extensions (Settings Screen)
// Extensions for handling route direction in settings screen
extension String{
    
    // MARK: - Settings Title Management
    // Gets various settings title based on route direction
    var variousSettingsTitle: String {
        switch (self) {
            case "go1": return VariousSettingsTitle.go1.rawValue.localized
            case "back2": return VariousSettingsTitle.back2.rawValue.localized
            case "go2": return VariousSettingsTitle.go2.rawValue.localized
            default: return VariousSettingsTitle.back1.rawValue.localized
        }
    }
    // Converts segue identifier to route direction string
    var seguegoorback: String {
        switch (self) {
            case "seguevsgo1": return "go1"
            case "seguevsback2": return "back2"
            case "seguevsgo2": return "go2"
            default : return "back1"
        }
    }

    // MARK: - Settings Data Access
    // Retrieves switch state from UserDefaults
    var switchFlag: Bool {
        return "\(self)switch".userDefaultBool(false)
    }
    // Retrieves number of transfers from UserDefaults
    var changeLineInt: Int {
        return "\(self)changeline".userDefaultInt(0)
    }
    // Gets number of transfers as string
    var changeLine: String {
        return self.changeLineInt.stringChangeLine
    }
    // Gets number of transfers for settings screen display
    func switchChangeLine(_ switchflag: Bool) -> String {
        return (switchflag) ? self.changeLine: Unit.notuse.rawValue.localized
    }
}

// MARK: - Integer Extensions
// Extensions for integer-based operations
extension Int {
    // MARK: - Transfer Count Display
    // Converts transfer count to localized string
    var stringChangeLine: String {
        switch(self) {
            case 0: return TransitTime.zero.rawValue.localized
            case 1: return TransitTime.once.rawValue.localized
            case 2: return TransitTime.twice.rawValue.localized
            default: return Unit.notset.rawValue.localized
        }
    }
    // Determines if view should be hidden based on count
    func viewHidden(_ number: Int) -> Bool {
        return (self < number) ? true: false
    }
}
