//
//  settingsLineName.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/01.
//

import SwiftUI

struct settingsLineName: View {
    
    @State private var isShowingAlert = false
    @State private var isShowingNextAlert = false
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
        
        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()

        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                ZStack (alignment: .leading) {
                    Text(goorback.lineNameDefault(num))
                        .frame(alignment: .leading)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(5)
                    textFieldPlusAlertView(
                        text: $text,
                        isShowingAlert: $isShowingAlert,
                        isShowingNextAlert: $isShowingNextAlert,
                        title: DialogTitle.linename.rawValue.localized,
                        message: goorback.lineNameAlertMessage(num),
                        key: goorback.lineNameKey(num),
                        addtitle: DialogTitle.linecolor.rawValue.localized
                    )
                }.actionSheet(isPresented: $isShowingNextAlert) {
                    ActionSheet(
                        title: Text(DialogTitle.linecolor.rawValue.localized),
                        message:  Text(goorback.lineNameArray[num]),
                        buttons: goorback.lineColorKey(num).ActionSheetButtons(
                            list: CustomColor.allCases.map{$0.rawValue.localized},
                            value: CustomColor.allCases.map{$0.RGB}
                        )
                    )
                }
                Spacer()
                Text(label)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(color)
                    .padding(5)
                    .onReceive(timer) { _ in
                        label = goorback.lineNameArray[num]
                        color = goorback.lineColorArray[num]
                    }
            }
        }

    }
}

struct settingsLineName_Previews: PreviewProvider {
    static var previews: some View {
        settingsLineName("back1", 0)
    }
}
