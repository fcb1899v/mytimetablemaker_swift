//
//  settingsTransportation.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI

struct settingsTransportation: View {

    @State private var isShowingAlert = false
    @State private var title: String
    @State private var label: String

    private let goorback: String
    private let num: Int
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ num: Int
    ){
        self.goorback = goorback
        self.num = num
        self.title = goorback.transportationLabel(num)
        self.label = goorback.transportationSettingsArray[num]
    }

    var body: some View {
        
        let actionTitle = DialogTitle.transport.rawValue.localized
        let actionMessage = goorback.transportationMessage(num)
        let actionKey = goorback.transportationKey(num)
        
        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                Text(title)
                    .lineLimit(1)
                    .foregroundColor(Color.black)
                    .padding(5)
                    .onChange(of: goorback.transportationLabel(num)) { newValue in title = newValue }
                Spacer()
                Text(label)
                    .lineLimit(1)
                    .foregroundColor(label.settingsColor)
                    .padding(5)
                    .onChange(of: goorback.transportationSettingsArray[num]) { newValue in label = newValue }
            }.font(.subheadline)
            //Setting transportation action sheet
            .actionSheet(isPresented: $isShowingAlert) {
                ActionSheet(
                    title: Text(actionTitle),
                    message: Text(actionMessage),
                    buttons: Transportation.allCases.map{$0.rawValue.localized}.indices.map { i in
                        .default(Text(Transportation.allCases.map{$0.rawValue.localized}[i])) {
                            UserDefaults.standard.set(Transportation.allCases.map{$0.rawValue.localized}[i], forKey: actionKey)
                        }
                    } + [.cancel()]
                )
            }
        }
    }
}

struct settingsTransportation_Previews: PreviewProvider {
    static var previews: some View {
        settingsTransportation("back1", 0)
    }
}
