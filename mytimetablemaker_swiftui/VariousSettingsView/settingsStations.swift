//
//  settingsStations.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/30.
//

import SwiftUI

struct settingsStations: View {
    
    @State private var isShowingAlert = false
    @State private var text = ""
    @State private var label = ""
    @State private var color = Color(DefaultColor.gray.rawValue.colorInt)

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

        let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                ZStack (alignment: .leading) {
                    Text(goorback.stationAlertLabelArray[num])
                        .frame(alignment: .leading)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(5)
                    textFieldAlertView(
                        text: $text,
                        isShowingAlert: $isShowingAlert,
                        title: goorback.stationAlertTitleArray[num],
                        message: goorback.stationAlertMessageArray[num],
                        key: goorback.stationKeyArray[num]
                    )
                }
                Spacer()
                Text(label)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(color)
                    .padding(5)
                    .onReceive(timer) { _ in
                        label = goorback.stationSettingsArray[num]
                        color = goorback.stationSettingsArray[num].settingsColor
                    }
            }
        }
    }
}

