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
        let transitdepartstation = goorback.transitDepartStation(num).localized
        let transitarrivestation = goorback.transitArriveStation(num).localized
        let gray = Color(DefaultColor.gray.rawValue.colorInt)
        
        let label = (num == 1) ? "\("from ".localized)\(transitdepartstation)\(" to ".localized)":
            "\("To ".localized)\(transitarrivestation)\("he".localized)"
        let title = DialogTitle.transittime.rawValue.localized
        let message = "\("from ".localized)\(transitdepartstation)\(" to ".localized)\(transitarrivestation)"
        let key = "\(goorback)transittime\(keytag)"
        var color = (key.userDefaultsValue("") == "") ? gray: Color.black

        if goorback.changeLineInt > num - 2 || num == 0 {

            let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
            
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
                    Text(text)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundColor(color)
                        .padding(5)
                        .onReceive(timer) { _ in
                            text = goorback.transitTimeString(keytag)
                            color = (key.userDefaultsValue("") == "") ? gray: Color.black
                        }
                }
            }
        }
    }
}

struct settingsTransitTime_Previews: PreviewProvider {
    static var previews: some View {
        settingsTransitTime("back1", 0)
    }
}
