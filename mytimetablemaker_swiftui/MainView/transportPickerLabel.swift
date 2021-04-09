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
    private let keytag: String

    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ keytag: String
    ){
        self.goorback = goorback
        self.keytag = keytag
    }

    var body: some View {
        
        let list = Transportation.allCases.map{$0.rawValue.localized}
        let transitdepartstation = goorback.transitDepartStation(keytag).localized
        let transitarrivestation = goorback.transitArriveStation(keytag).localized

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
        .font(.subheadline)
        .lineLimit(1)
        .foregroundColor(gray)
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
        transportPickerLabel("back1", "1")
    }
}
