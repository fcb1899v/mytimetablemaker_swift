//
//  settingsTextFieldAlertLabel.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/01.
//

import SwiftUI

struct settingsTextFieldAlertLabel: View {
    
    @State private var isShowingAlert = false
    @State private var text = ""

    private let label: String
    private let title: String
    private let message: String
    private let key: String
    private let color: Color

    /// 値を指定して生成する
    init(
        _ label: String,
        _ title: String,
        _ message: String,
        _ key: String,
        _ color: Color
    ){
        self.label = label
        self.title = title
        self.message = message
        self.key = key
        self.color = color
    }

    var body: some View {
        
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
                    textFieldAlertView(
                        text: $text,
                        isShowingAlert: $isShowingAlert,
                        title: title,
                        message: message,
                        key: key
                    )
                }
                Spacer()
                Text(text)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(color)
                    .padding(5)
                    .onReceive(timer) { (_) in
                        text = key.userDefaultsValue("Not set".localized)
                    }
            }
        }
    }
}
