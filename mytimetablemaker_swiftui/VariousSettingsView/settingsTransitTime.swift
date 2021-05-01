//
//  settingsTransitTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI

struct settingsTransitTime: View {
    
    @State private var isShowingAlert = false
    @State private var isShowingNext1Alert = false
    @State private var isShowingNext2Alert = false
    @State private var text = ""
    @State private var title = "To Office"
    @State private var label = "Not set".localized
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
        
        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
        
        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                ZStack (alignment: .leading) {
                    Text(title)
                        .frame(alignment: .leading)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(5)
                        .onReceive(timer) { _ in
                            title = goorback.transportationLabel(num)
                        }
                    numberFieldAlertView(
                        text: $text,
                        isShowingAlert: $isShowingAlert,
                        title: DialogTitle.transittime.rawValue.localized,
                        message: goorback.transportationMessage(num),
                        key: goorback.transitTimeKey(num),
                        maxnumber: 99
                    )
                }
                Spacer()
                Text(label)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(color)
                    .padding(5)
                    .onReceive(timer) { _ in
                        label = goorback.transitTimeStringArray[num]
                        color = label.settingsColor
                    }
            }
        }
    }
}

struct settingsTransitTime_Previews: PreviewProvider {
    static var previews: some View {
        settingsTransitTime("back1", 0)
    }
}
