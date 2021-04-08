//
//  mainAlertLabel.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/02/07.
//

import SwiftUI

struct mainAlertLabel: View {

    @State private var isShowingAlert = false
    @State private var text = ""
    
    private let title: String
    private let message: String
    private let key: String
    private let defaultvalue: String

    /// 値を指定して生成する
    init(
        _ title: String,
        _ message: String,
        _ key: String,
        _ defaultvalue: String
    ){
        self.title = title
        self.message = message
        self.key = key
        self.defaultvalue = defaultvalue
    }

    var body: some View {
        
        let primary = Color(DefaultColor.primary.rawValue.colorInt)

        Button (action: {
            self.isShowingAlert = true
        }) {
            ZStack (alignment: .leading) {
                Text((text == "") ? key.userDefaultsValue(defaultvalue): text)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(primary)
                textFieldAlertView(
                    text: $text,
                    isShowingAlert: $isShowingAlert,
                    title: title,
                    message: message,
                    key: key
                )
            }
        }
    }
}

struct mainAlertLabel_Previews: PreviewProvider {
    static var previews: some View {
        mainAlertLabel(DialogTitle.departplace.rawValue, "", "destination", "Office")
    }
}
