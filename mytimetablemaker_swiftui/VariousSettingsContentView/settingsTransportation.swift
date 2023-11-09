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
        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                Text(title).foregroundColor(Color.black)
                    .lineLimit(1)
                    .onChange(of: goorback.transportationLabel(num)) {
                        newValue in title = newValue
                    }
                Spacer()
                Text(label).foregroundColor(label.settingsColor)
                    .lineLimit(1)
                    .onChange(of: goorback.transportationSettingsArray[num]) {
                        newValue in label = newValue
                    }
            }
            //Setting transportation action sheet
            .actionSheet(isPresented: $isShowingAlert) {
                ActionSheet(
                    title: Text(transportationAlertTitle),
                    message: Text(goorback.transportationMessage(num)),
                    buttons: Transportation.allCases.map{$0.rawValue.localized}.indices.map { i in
                        .default(Text(Transportation.allCases.map{$0.rawValue.localized}[i])) {
                            UserDefaults.standard.set(
                                Transportation.allCases.map{$0.rawValue.localized}[i],
                                forKey: goorback.transportationKey(num)
                            )
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
