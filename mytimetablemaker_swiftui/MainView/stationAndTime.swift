//
//  stationAndTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/05/01.
//

import SwiftUI

struct stationAndTime: View {
    
    @State private var isShowingAlert = false
    @State private var text = ""
    @State private var label = "Office".localized
    @State private var time = "--:--"
    @State private var color = Color(DefaultColor.gray.rawValue.colorInt)

    private let goorback: String
    private let weekflag: Bool
    private let currenttime: Int
    private let num: Int

    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ currenttime: Int,
        _ num: Int
    ){
        self.goorback = goorback
        self.weekflag = weekflag
        self.currenttime = currenttime
        self.num = num
    }

    var body: some View {
        
        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
        let primary = Color(DefaultColor.primary.rawValue.colorInt)

        HStack {
            
            Button (action: {
                self.isShowingAlert = true
            }) {
                ZStack (alignment: .leading) {
                    Text(label)
                        .font(.footnote)
                        .lineLimit(1)
                        .foregroundColor(primary)
                    textFieldAlertView(
                        text: $text,
                        isShowingAlert: $isShowingAlert,
                        title: goorback.stationAlertTitleArray[num],
                        message: goorback.stationAlertMessageArray[num],
                        key: goorback.stationKeyArray[num]
                    ).onReceive(timer) { _ in
                        label = goorback.stationArray[num]
                    }
                }
            }
            
            Text(time)
                .font(Font.title2.monospacedDigit())
                .foregroundColor(primary)
                .onReceive(timer) { _ in
                    time = weekflag.displayTimeArray(goorback, currenttime)[num]
                }
        }
    }
}

struct stationAndTime_Previews: PreviewProvider {
    static var previews: some View {
        stationAndTime("back1", true, 100000, 0)
    }
}
