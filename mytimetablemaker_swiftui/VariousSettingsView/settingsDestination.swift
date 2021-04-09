//
//  settingsDestination.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/01.
//

import SwiftUI

struct settingsDestination: View {
    
    private let goorback: String
    
    /// 値を指定して生成する
    init(
        _ goorback: String
    ){
        self.goorback = goorback
    }

    var body: some View {

        let departurepoint = "Departure place".localized
        let destination = "Destination".localized
        let gray = Color(DefaultColor.gray.rawValue.colorInt)
        
        let label = (goorback == "back1" || goorback == "back2") ? departurepoint: destination
        let title = DialogTitle.destination.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"
        let color = (key.userDefaultsValue("") == "") ? gray: Color.black

        settingsTextFieldAlertLabel(label, title, message, key, color)
    }
}

struct settingsDestination_Previews: PreviewProvider {
    static var previews: some View {
        settingsDestination("back1")
    }
}
