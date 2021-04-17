//
//  transportPickerLabel.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/24.
//

import SwiftUI

struct transportPickerLabel: View {
    
    @State private var selection = ""
    @State private var isShowingPicker = false

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
        
        let keytag = (num == 0) ? "e": "\(num)"
        let list = Transportation.allCases.map{$0.rawValue.localized}
        let transitdepartstation = goorback.transitDepartStation(num).localized
        let transitarrivestation = goorback.transitArriveStation(num).localized

        let title = DialogTitle.transport.rawValue.localized
        let message = "\("from ".localized)\(transitdepartstation)\(" to ".localized)\(transitarrivestation)"
        let key = "\(goorback)transport\(keytag)"
        let defaultvalue = "Walking".localized
        
        let transportation = goorback.transportation(keytag, defaultvalue)
        let gray = Color(DefaultColor.gray.rawValue.colorInt)
        
        Button(
            (transportation == "") ? list[0]: transportation
        ) {
            self.isShowingPicker = true
        }
        .frame(alignment: .leading)
        .font(.footnote)
        .lineLimit(1)
        .foregroundColor(gray)
        .padding(.leading, 15.0)
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
    }
}

struct transportPickerLabel_Previews: PreviewProvider {
    static var previews: some View {
        transportPickerLabel("back1", 0)
    }
}
