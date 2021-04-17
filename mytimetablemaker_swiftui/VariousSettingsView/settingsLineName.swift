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
        
        let keytag = "\(num + 1)"
        let label = "\("Line ".localized)\(keytag)"
        let title = DialogTitle.linename.rawValue.localized
        let message = "\("of ".localized)\("line ".localized)\(keytag)"
        let key = "\(goorback)linename\(keytag)"
        let addtitle = DialogTitle.linecolor.rawValue.localized

        var color = goorback.lineColor(keytag, DefaultColor.gray.rawValue)
        let colortitle = DialogTitle.linecolor.rawValue.localized
        let colormessage = goorback.lineName(keytag, "line ".localized + keytag)
        let colorlist = CustomColor.allCases.map{$0.rawValue.localized}
        let colorvalue = CustomColor.allCases.map{$0.RGB}
        let colorkey = "\(goorback)linecolor\(keytag)"

        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()

        if goorback.changeLineInt > num - 1 {
            
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
                    Spacer()
                    Text(text)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundColor(color)
                        .padding(5)
                        .onReceive(timer) { (_) in
                            text = key.userDefaultsValue("Not set".localized)
                            color = goorback.lineColor(keytag, DefaultColor.gray.rawValue)
                        }

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
