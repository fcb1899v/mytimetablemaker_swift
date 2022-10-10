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

        let title = goorback.stationAlertLabelArray[num]
        let alertTitle = goorback.stationAlertTitleArray[num]
        let alertMessage = goorback.stationAlertMessageArray[num]
        let key = goorback.stationKeyArray[num]
        let placeHolder = Hint.maxchar.rawValue.localized
        
        //Setting station name button
        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                Text(title)
                    .foregroundColor(.black)
                    .padding(5)
                Spacer()
                Text(label)
                    .lineLimit(1)
                    .foregroundColor(label.settingsColor)
                    .padding(5)
                    .onChange(of: goorback.stationSettingsArray[num]) { newValue in label = newValue }
            }.font(.subheadline)
            //Setting station name alert
            .alert(alertTitle, isPresented: $isShowingAlert) {
                TextField(placeHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                //OK button
                Button(Action.ok.rawValue.localized, role: .none){
                    if (inputText != "") { UserDefaults.standard.set(inputText, forKey: key) }
                    isShowingAlert = false
                    inputText = ""
                }
                //Cancel button
                Button(Action.cancel.rawValue.localized, role: .cancel){
                    isShowingAlert = false
                    inputText = ""
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct settingsStations_Previews: PreviewProvider {
    static var previews: some View {
        settingsStations("back1", 0)
    }
}
