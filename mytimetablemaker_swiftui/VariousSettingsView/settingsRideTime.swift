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

        let keytag = "\(num + 1)"
        let gray = Color(DefaultColor.gray.rawValue.colorInt)
        
        let label = "\("Line ".localized)\(keytag)"
        let title = DialogTitle.ridetime.rawValue.localized
        let message = "\("on ".localized)\(goorback.lineName(keytag, "\("Line ".localized)\(keytag)"))"
        let key = "\(goorback)ridetime\(keytag)"
        let addtitle = DialogTitle.timetable.rawValue.localized
        var color = (key.userDefaultsValue("") == "") ? gray: Color.black

        if goorback.changeLineInt > num - 1 {
            
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
                        TimetableContentView(goorback, num)
                    }
                    Spacer()
                    Text(text)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundColor(color)
                        .padding(5)
                        .onReceive(timer) { _ in
                            text = goorback.rideTimeString(keytag)
                            color = (key.userDefaultsValue("") == "") ? gray: Color.black
                        }
                }
            }
        }
    }
}

struct settingsRideTime_Previews: PreviewProvider {
    static var previews: some View {
        settingsRideTime("back1", 0)
    }
}
