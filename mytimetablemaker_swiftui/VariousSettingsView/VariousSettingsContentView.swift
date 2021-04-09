//
//  VariousSettingsContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/14.
//

import SwiftUI

struct VariousSettingsContentView: View {
    
    @Environment(\.presentationMode) var presentationMode

    private let goorback: String
    private let weekflag: Bool
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ weekflag: Bool
    ){
        self.goorback = goorback
        self.weekflag = weekflag
    }
    
    let primary = Color(DefaultColor.primary.rawValue.colorInt)
    
    var body: some View {
            Form {
                Section(
                    header: settingsTitle("\n" + DialogTitle.stationname.rawValue.localized)
                ) {
                    settingsDepartPoint(goorback)
                    settingsDepartStation(goorback, "1")
                    settingsArriveStation(goorback, "1")
                    if goorback.changeLineInt > 0 {
                        settingsDepartStation(goorback, "2")
                        settingsArriveStation(goorback, "2")
                    }
                    if goorback.changeLineInt > 1 {
                        settingsDepartStation(goorback, "3")
                        settingsArriveStation(goorback, "3")
                    }
                    settingsDestination(goorback)
                }
                Section(
                    header: settingsTitle(DialogTitle.linename.rawValue.localized)
                ) {
                    settingsLineName(goorback, "1")
                    if goorback.changeLineInt > 0 {
                        settingsLineName(goorback, "2")
                    }
                    if goorback.changeLineInt > 1 {
                        settingsLineName(goorback, "3")
                    }
                }
                Section(
                    header: settingsTitle(DialogTitle.ridetime.rawValue.localized)
                ) {
                    settingsRideTime(goorback, weekflag, "1")
                    if goorback.changeLineInt > 0 {
                        settingsRideTime(goorback, weekflag, "2")
                    }
                    if goorback.changeLineInt > 1 {
                        settingsRideTime(goorback, weekflag, "3")
                    }
                }
                Section(
                    header: settingsTitle(DialogTitle.transport.rawValue.localized)
                ) {
                    settingsTransportation(goorback, "1")
                    if goorback.changeLineInt > 0 {
                        settingsTransportation(goorback, "2")
                    }
                    if goorback.changeLineInt > 1 {
                        settingsTransportation(goorback, "3")
                    }
                    settingsTransportation(goorback, "e")
                }
                Section(
                    header: settingsTitle(DialogTitle.transittime.rawValue.localized)
                ) {
                    settingsTransitTime(goorback, "1")
                    if goorback.changeLineInt > 0 {
                        settingsTransitTime(goorback, "2")
                    }
                    if goorback.changeLineInt > 1 {
                        settingsTransitTime(goorback, "3")
                    }
                    settingsTransitTime(goorback, "e")
                }
            }
            .navigationTitle(goorback.routeTitle.localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(backgroundColor: UIColor(primary), titleColor: .white)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    settingsBackButton(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, Color.white)
                }
            }
    }
}

struct VariousSettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        VariousSettingsContentView("back1", false)
    }
}
