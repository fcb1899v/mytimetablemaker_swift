//
//  settingsTransitTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI

struct settingsTransitTime: View {
    
    @State private var isShowingAlert = false
    @State private var isShowingNext1Alert = false
    @State private var isShowingNext2Alert = false
    @State private var text = ""

    private let goorback: String
    private let keytag: String
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ keytag: String
    ){
        self.goorback = goorback
        self.keytag = keytag
    }
    
    var body: some View {
        
        let transitdepartstation = goorback.transitDepartStation(keytag).localized
        let transitarrivestation = goorback.transitArriveStation(keytag).localized

        let label = "\("To ".localized)\(transitarrivestation)\("he".localized)"
        let title = DialogTitle.transittime.rawValue.localized
        let message = "\("from ".localized)\(transitdepartstation)\(" to ".localized)\(transitarrivestation)"
        let key = "\(goorback)transittime\(keytag)"
        let color = (goorback.transitTimeString(keytag) == "Not set".localized) ? Color(DefaultColor.gray.rawValue.colorInt): Color.black

        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                ZStack (alignment: .leading) {
                    Text(label)
                        .frame(alignment: .leading)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(5)
                    numberFieldAlertView(
                        text: $text,
                        isShowingAlert: $isShowingAlert,
                        title: title,
                        message: message,
                        key: key,
                        maxnumber: 99
                    )
                }
                Spacer()
                Text((text == "") ? goorback.transitTimeString(keytag): text)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(color)
                    .padding(5)
            }
        }
    }
}
