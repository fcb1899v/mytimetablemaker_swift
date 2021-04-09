//
//  settingsChangeLine.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/16.
//

import SwiftUI

struct settingsChangeLine: View {
    
    @State private var isShowingPicker = false
    
    private let goorback: String
    @Binding var changeline: String

    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ changeline: Binding<String>
    ){
        self.goorback = goorback
        self._changeline = changeline
    }
    
    var body: some View {
    
        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
        let gray = Color(DefaultColor.gray.rawValue.colorInt)

        let title = DialogTitle.numtransit.rawValue.localized
        let message = goorback.routeTitle
        let key = "\(goorback)changeline"
        let list = TransitTime.allCases.map{$0.rawValue.localized}
        let value = TransitTime.allCases.map{$0.Number}
        let color = (key.userDefaultsValue("") == "") ? gray: Color.black

            
        HStack {
            Button(
                goorback.routeTitle
            ) {
                self.isShowingPicker = true
            }
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
                        value: value,
                        key: key
                    )
                )
            }
            Spacer()
            Text(changeline)
                .foregroundColor(color)
                .font(.subheadline)
                .padding(5)
                .onReceive(timer) { (_) in
                    changeline = key.userDefaultsInt(0).stringChangeLine
                }
        }
    }
}

