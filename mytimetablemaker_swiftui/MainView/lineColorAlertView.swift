//
//  lineColorAlertView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/07.
//

import SwiftUI

struct lineColorAlertView: View {

    @State private var isShowingAlert = false
    @State private var isShowingNextAlert = false
    @State private var text = ""

    private let goorback: String
    private let weekflag: Bool
    private let num: Int
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ num: Int
    ){
        self.goorback = goorback
        self.weekflag = weekflag
        self.num = num
    }

    var body: some View {
        
        let keytag = "\(num + 1)"
//        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
        let accent = DefaultColor.accent.rawValue

        let ridetimetitle = DialogTitle.ridetime.rawValue.localized
        let ridetimemessage = "\("on ".localized)\(goorback.lineName(keytag, "\("Line ".localized)\(keytag)"))"
        let ridetimekey = "\(goorback)ridetime\(keytag)"
        let timetabletitle = DialogTitle.timetable.rawValue.localized
        let colorkey = "\(goorback)linecolor\(keytag)"
        var color = colorkey.userDefaultsColor(accent)
        
        Button (action: {
            self.isShowingAlert = true
        }) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: 22, height: 30)
                    .foregroundColor(color)
                Image(uiImage: UIImage(named: "ic_clock2.png")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundColor(.white)
                    .padding(.leading, 1)
                numberFieldPlusAlertView(
                    text: $text,
                    isShowingAlert: $isShowingAlert,
                    isShowingNextAlert: $isShowingNextAlert,
                    title: ridetimetitle,
                    message: ridetimemessage,
                    key: ridetimekey,
                    addtitle: timetabletitle,
                    maxnumber: 99
                ).sheet(isPresented: $isShowingNextAlert) {
                    TimetableContentView(goorback, num)
                }
            }
            .frame(width: 30, height: 35.0, alignment: .center)
            .padding(.leading, 10.0)
        }
    }
}

struct lineColorAlertView_Previews: PreviewProvider {
    static var previews: some View {
        lineColorAlertView("back1", false, 0)
    }
}

