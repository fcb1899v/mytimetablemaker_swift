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
    @State private var color = Color(DefaultColor.accent.rawValue.colorInt)

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
        
        let title = DialogTitle.ridetime.rawValue.localized
        let message = "\("on ".localized)\(goorback.lineName(keytag, "\("Line ".localized)\(keytag)"))"
        let key = "\(goorback)ridetime\(keytag)"
        let timetabletitle = DialogTitle.timetable.rawValue.localized
        let accent = DefaultColor.accent.rawValue
        
        Button (action: {
            self.isShowingAlert = true
        }) {
            ZStack(alignment: .leading) {
                goorback.lineColor(keytag, accent)
                    .frame(width: 30, height: 35.0)
                Image(uiImage: UIImage(named: "ic_clock2.png")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .foregroundColor(.white)
                    .padding(.leading, 2.5)
                numberFieldPlusAlertView(
                    text: $text,
                    isShowingAlert: $isShowingAlert,
                    isShowingNextAlert: $isShowingNextAlert,
                    title: title,
                    message: message,
                    key: key,
                    addtitle: timetabletitle,
                    maxnumber: 99
                ).sheet(isPresented: $isShowingNextAlert) {
//                    TimetableContentView(
//                        goorback: goorback,
//                        weekflag: weekflag,
//                        keytag: keytag)
                }
            }.frame(width: 30, height: 35.0, alignment: .center)
        }
    }
}

struct lineColorAlertView_Previews: PreviewProvider {
    static var previews: some View {
        lineColorAlertView("back1", false, "1")
    }
}

