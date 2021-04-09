//
//  mainAlertPlusLabel.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/04.
//

import SwiftUI

struct mainAlertPlusLabel: View {

    @State private var isShowingAlert = false
    @State private var isShowingNextAlert = false
    @State private var text = ""
    @State private var color = Color(DefaultColor.accent.rawValue.colorInt)

    private let title: String
    private let message: String
    private let key: String
    private let addtitle: String
    private let defaultvalue: String
    private let colortitle: String
    private let colormessage: String
    private let colorlist: [String]
    private let colorvalue: [String]
    private let colorkey: String

    /// 値を指定して生成する
    init(
        _ title: String,
        _ message: String,
        _ key: String,
        _ addtitle: String,
        _ defaultvalue: String,
        _ colortitle: String,
        _ colormessage: String,
        _ colorlist: [String],
        _ colorvalue: [String],
        _ colorkey: String
    ){
        self.title = title
        self.message = message
        self.key = key
        self.addtitle = addtitle
        self.defaultvalue = defaultvalue
        self.colortitle = colortitle
        self.colormessage = colormessage
        self.colorlist = colorlist
        self.colorvalue = colorvalue
        self.colorkey = colorkey
    }

    var body: some View {
        
        let accent = DefaultColor.accent.rawValue
        
        Button (action: {
            isShowingAlert = true
        }) {
            ZStack (alignment: .leading) {
                Text((text == "") ? key.userDefaultsValue(defaultvalue): text)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(colorkey.userDefaultsColor(accent))
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

struct mainAlertPlusLabel_Previews: PreviewProvider {
    static var previews: some View {
        mainAlertPlusLabel(DialogTitle.linename.rawValue, "", "back1linename1",
                           DialogTitle.linecolor.rawValue, "Line 1",
                           DialogTitle.linecolor.rawValue, "",
                           CustomColor.allCases.map{$0.rawValue.localized},
                           CustomColor.allCases.map{$0.RGB}, "back1linecolor1"
        )
    }
}
