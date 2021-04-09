//
//  settingsActionSheet.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI

struct settingActionSheet: View {
    
    @State private var isShowingPicker = false
    @State private var text = ""

    private let label: String
    private let title: String
    private let message: String
    private let key: String
    private let list: [String]
    private let value: [String]

    /// 値を指定して生成する
    init(
        _ label: String,
        _ title: String,
        _ message: String,
        _ key: String,
        _ list: [String],
        _ value: [String]
    ){
        self.label = label
        self.title = title
        self.message = message
        self.key = key
        self.list = list
        self.value = value
    }

    var body: some View {
        
        let gray = Color(DefaultColor.gray.rawValue.colorInt)
        let color = (key.userDefaultsValue("") == "") ? gray: Color.black
        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()

        Button (action: {
            self.isShowingPicker = true
        }) {
            HStack {
                Text(label)
                    .frame(alignment: .leading)
                    .font(.subheadline)
                    .foregroundColor(Color.black)
                    .padding(5)
                    .actionSheet(isPresented: $isShowingPicker) {
                        ActionSheet(
                            title: Text(title),
                            message:  Text(message),
                            buttons: ActionSheetButtons(
                                list: list,
                                value: list,
                                key: key
                            )
                        )
                    }
                Spacer()
                Text(key.userDefaultsValue("Not set".localized))
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

