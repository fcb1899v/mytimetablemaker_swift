//
//  mainAlertPlusLabel.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/04.
//

import SwiftUI

struct lineNameAlertLabel: View {

    @State private var isShowingAlert = false
    @State private var isShowingNextAlert = false
    @State private var text = ""
    @State private var label = ""

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
        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()

        let title = DialogTitle.linename.rawValue.localized
        let message = "\("of ".localized)\("line ".localized)\(keytag)"
        let key = "\(goorback)linename\(keytag)"
        let addtitle = DialogTitle.linecolor.rawValue.localized
        let defaultvalue = "\("Line ".localized)\(keytag)"
        
        let colortitle = DialogTitle.linecolor.rawValue.localized
        let colormessage = goorback.lineName(keytag, "line ".localized + keytag)
        let colorlist = CustomColor.allCases.map{$0.rawValue.localized}
        let colorvalue = CustomColor.allCases.map{$0.RGB}
        let colorkey = "\(goorback)linecolor\(keytag)"
        let accent = DefaultColor.accent.rawValue
        var color = colorkey.userDefaultsColor(accent)

        Button (action: {
            isShowingAlert = true
        }) {
            ZStack (alignment: .leading) {
                Text(label)
                    .font(.footnote)
                    .lineLimit(1)
                    .foregroundColor(color)
                    .padding(.leading, 15.0)
                    .onReceive(timer) { _ in
                        label = key.userDefaultsValue(defaultvalue)
                        color = colorkey.userDefaultsColor(accent)
                    }
                textFieldPlusAlertView(
                    text: $text,
                    isShowingAlert: $isShowingAlert,
                    isShowingNextAlert: $isShowingNextAlert,
                    title: title,
                    message: message,
                    key: key,
                    addtitle: addtitle
                )
            }.actionSheet(isPresented: $isShowingNextAlert) {
                ActionSheet(
                    title: Text(colortitle),
                    message:  Text(colormessage),
                    buttons: ActionSheetButtons(
                        list: colorlist,
                        value: colorvalue,
                        key: colorkey
                    )
                )
            }
        }
    }
}

struct lineNameAlertLabel_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        lineNameAlertLabel(mainviewmodel.goorback1, 0)
    }
}
