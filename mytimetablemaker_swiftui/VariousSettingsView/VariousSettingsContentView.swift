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
    private let weekflag = Date().weekFlag
    private let primary = Color(DefaultColor.primary.rawValue.colorInt)

    /// 値を指定して生成する
    init(
        _ goorback: String
    ){
        self.goorback = goorback
    }

    var body: some View {
        
        Form {
            Section(
                header: settingsTitle("\n" + DialogTitle.stationname.rawValue.localized)
            ) {
                settingsDepartPoint(goorback)
                ForEach(0..<3) { num in
                    settingsDepartStation(goorback, num)
                    settingsArriveStation(goorback, num)
                }
                settingsDestination(goorback)
            }
            Section(
                header: settingsTitle(DialogTitle.linename.rawValue.localized)
            ) {
                ForEach(0..<3) { num in
                    settingsLineName(goorback, num)
                }
            }
            Section(
                header: settingsTitle(DialogTitle.ridetime.rawValue.localized)
            ) {
                ForEach(0..<3) { num in
                    settingsRideTime(goorback, num)
                }
            }
            Section(
                header: settingsTitle(DialogTitle.transport.rawValue.localized)
            ) {
                ForEach(1..<4) { num in
                    settingsTransportation(goorback, num)
                }
                settingsTransportation(goorback, 0)
            }
            Section(
                header: settingsTitle(DialogTitle.transittime.rawValue.localized)
            ) {
                ForEach(1..<4) { num in
                    settingsTransitTime(goorback, num)
                }
                settingsTransitTime(goorback, 0)
            }
        }
        .navigationTitle(goorback.routeTitle.localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor(backgroundColor: UIColor(primary), titleColor: .white)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                variousSettingsBackButton()
            }
        }
    }
}

struct VariousSettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        VariousSettingsContentView("back1")
    }
}
