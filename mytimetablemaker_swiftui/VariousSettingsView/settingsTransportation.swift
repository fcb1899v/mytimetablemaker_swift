//
//  settingsTransportation.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI

struct settingsTransportation: View {

    @State private var isShowingAlert = false
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
                Text(title)
                    .frame(alignment: .leading)
                    .font(.subheadline)
                    .foregroundColor(Color.black)
                    .padding(5)
                    .onReceive(timer) { _ in
                        title = goorback.transportationLabel(num)
                    }
                    .actionSheet(isPresented: $isShowingAlert) {
                        ActionSheet(
                            title: Text(DialogTitle.transport.rawValue.localized),
                            message:  Text(goorback.transportationMessage(num)),
                            buttons: goorback.transportationKey(num).ActionSheetButtons(
                                list: Transportation.allCases.map{$0.rawValue.localized},
                                value: Transportation.allCases.map{$0.rawValue.localized}
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
                        label = goorback.transportationSettingsArray[num]
                        color = label.settingsColor
                    }
            }
        }
    }
}

struct settingsTransportation_Previews: PreviewProvider {
    static var previews: some View {
        settingsTransportation("back1", 0)
    }
}
