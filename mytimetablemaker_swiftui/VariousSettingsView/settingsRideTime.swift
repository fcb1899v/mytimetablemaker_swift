//
//  settingsRideTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/01.
//

import SwiftUI

struct settingsRideTime: View {
    
    @State private var isShowingAlert = false
    @State private var isShowingNextAlert = false
    @State private var text = ""

    private let goorback: String
    private let weekflag: Bool
    private let keytag: String
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ keytag: String
    ){
        self.goorback = goorback
        self.weekflag = weekflag
        self.keytag = keytag
    }
    
    var body: some View {

        let label = "\("Line ".localized)\(keytag)"
        let title = DialogTitle.ridetime.rawValue.localized
        let message = "\("on ".localized)\(goorback.lineName(keytag, "\("Line ".localized)\(keytag)"))"
        let key = "\(goorback)ridetime\(keytag)"
        let color = goorback.lineColor(keytag, DefaultColor.gray.rawValue)
        let addtitle = DialogTitle.timetable.rawValue.localized

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
                    numberFieldPlusAlertView(
                        text: $text,
                        isShowingAlert: $isShowingAlert,
                        isShowingNextAlert: $isShowingNextAlert,
                        title: title,
                        message: message,
                        key: key,
                        addtitle: addtitle,
                        maxnumber: 99
                    )
                }.sheet(isPresented: $isShowingNextAlert) {
                    TimetableContentView(
                        goorback: goorback,
                        weekflag: weekflag,
                        keytag: keytag
                    )
                }
                Spacer()
                Text((text == "") ? goorback.rideTimeString(keytag): text)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(color)
                    .padding(5)
            }
        }
    }
}

struct settingsRideTime_Previews: PreviewProvider {
    static var previews: some View {
        settingsRideTime("back1", false, "1")
    }
}
