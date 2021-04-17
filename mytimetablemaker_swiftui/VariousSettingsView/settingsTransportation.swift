//
//  settingsTransportation.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI

struct settingsTransportation: View {

    @State private var isShowingAlert = false

    private let goorback: String
    private let num: Int
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ num: Int
    ){
        self.goorback = goorback
        self.num = num
    }

    var body: some View {

        let keytag = (num == 0) ? "e": "\(num)"
        let list = Transportation.allCases.map{$0.rawValue.localized}
        let transitdepartstation = goorback.transitDepartStation(num).localized
        let transitarrivestation = goorback.transitArriveStation(num).localized

        let label = (num == 1) ? "\("from ".localized)\(transitdepartstation)\(" to ".localized)":
            "\("To ".localized)\(transitarrivestation)\("he".localized)"
        let title = DialogTitle.transport.rawValue.localized
        let message = "\("from ".localized)\(transitdepartstation)\(" to ".localized)\(transitarrivestation)"
        let key = "\(goorback)transport\(keytag)"
        
        if goorback.changeLineInt > num - 2 || num == 0 {
            settingActionSheet(label, title, message, key, list, list)
        }
    }
}

struct settingsTransportation_Previews: PreviewProvider {
    static var previews: some View {
        settingsTransportation("back1", 0)
    }
}
