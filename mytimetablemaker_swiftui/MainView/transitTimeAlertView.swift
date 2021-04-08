//
//  transitTimeAlertView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/25.
//

import SwiftUI

struct transitTimeAlertView: View {
    
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

        let gray = Color(DefaultColor.gray.rawValue.colorInt)
        let transitdepartstation = goorback.transitDepartStation(keytag).localized
        let transitarrivestation = goorback.transitArriveStation(keytag).localized
        let title = DialogTitle.transittime.rawValue.localized
        let message = "\("from ".localized)\(transitdepartstation)\(" to ".localized)\(transitarrivestation)"
        let key = "\(goorback)transittime\(keytag)"

        Button (action: {
            self.isShowingAlert = true
        }) {
            ZStack(alignment: .leading) {
                gray.frame(width: 30, height: 35.0)
                Image(uiImage: UIImage(named: "ic_clock2.png")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .foregroundColor(.white)
                    .padding(.leading, 2.5)
                numberFieldAlertView(
                    text: $text,
                    isShowingAlert: $isShowingAlert,
                    title: title,
                    message: message,
                    key: key,
                    maxnumber: 99
                )
            }.frame(width: 30, height: 35.0, alignment: .center)
        }
    }
}

struct transitTimeAlertView_Previews: PreviewProvider {
    static var previews: some View {
        transitTimeAlertView("back1", "1")
    }
}

