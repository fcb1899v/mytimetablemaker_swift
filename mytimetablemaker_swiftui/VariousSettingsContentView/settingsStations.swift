//
//  settingsStations.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/30.
//

import SwiftUI

struct settingsStations: View {
    
    @State private var isShowingAlert = false
    @State private var inputText = ""
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
        self.label = goorback.stationSettingsArray[num]
    }
    
    var body: some View {
        Button (action: {
            self.isShowingAlert = true
            inputText = ""
        }) {
            HStack {
                Text(goorback.stationLabelArray[num]).foregroundColor(.black)
                Spacer()
                Text(label).foregroundColor(label.settingsColor)
                    .lineLimit(1)
                    .onChange(of: goorback.stationSettingsArray[num]) {
                        newValue in label = newValue
                    }
            }
            //Setting station name alert
            .alert(stationAlertTitleArray[num], isPresented: $isShowingAlert) {
                TextField(placeHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                //OK button
                Button(textOk, role: .none){
                    if (inputText != "") {
                        UserDefaults.standard.set(inputText, forKey: goorback.stationKeyArray[num])
                    }
                    isShowingAlert = false
                }
                //Cancel button
                Button(textCancel, role: .cancel){
                    isShowingAlert = false
                }
            } message: {
                Text(stationAlertMessageArray[num])
            }
        }
    }
}

struct settingsStations_Previews: PreviewProvider {
    static var previews: some View {
        settingsStations("back1", 0)
    }
}
