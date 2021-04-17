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
        let label = (goorback == "back1" || goorback == "back2") ? departurepoint: destination
        let title = DialogTitle.destination.rawValue.localized
        let message = ""
        let key = (goorback == "back1" || goorback == "back2") ? "departurepoint": "destination"

        settingsTextFieldAlertLabel(label, title, message, key)
    }
}

struct settingsDestination_Previews: PreviewProvider {
    static var previews: some View {
        settingsDestination("back1")
    }
}
