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
    @State private var inputText = ""
    @State private var label: String
    @State private var color: Color

    private let goorback: String
    private let num: Int

    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ num: Int
    ){
        self.goorback = goorback
        self.num = num
        self.label = goorback.lineNameSettingsArray[num]
        self.color = goorback.lineColorSettingsArray[num]
    }
    
    var body: some View {
        Button (action: {
            self.isShowingAlert = true
            inputText = ""
        }) {
            HStack {
                Text(lineNameDefault(num)).foregroundColor(.black)
                Spacer()
                Text(label).foregroundColor(color)
                    .lineLimit(1)
                    .onChange(of: goorback.lineNameSettingsArray[num]) {
                        newValue in label = newValue
                    }
                    .onChange(of: goorback.lineColorSettingsArray[num] ) {
                        newValue in color = newValue
                    }
            }
            //Setting line name alert
            .alert(lineNameAlertTitle, isPresented: $isShowingAlert) {
                TextField(placeHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                //OK button
                Button(textOk, role: .none){
                    if (inputText != "") {
                        UserDefaults.standard.set(inputText, forKey: goorback.lineNameKey(num))
                    }
                    isShowingAlert = false
                }
                //Cancel button
                Button(textCancel, role: .cancel){
                    isShowingAlert = false
                }
                //Setting line color button
                Button(lineColorAlertTitle, role: .destructive){
                    if (inputText != "") {
                        UserDefaults.standard.set(inputText, forKey: goorback.lineNameKey(num))
                    }
                    isShowingNextAlert = true
                    isShowingAlert = false
                }
            } message: {
                Text(lineNameAlertMessage(num))
            }
        }
        //Setting line color action sheet
        .actionSheet(isPresented: $isShowingNextAlert) {
            ActionSheet(
                title: Text(lineColorAlertTitle),
                message: Text(goorback.lineNameArray[num]),
                buttons: CustomColor.allCases.map{$0.rawValue.localized}.indices.map { i in
                    .default(Text(CustomColor.allCases.map{$0.rawValue.localized}[i])) {
                        UserDefaults.standard.set(
                            CustomColor.allCases.map{$0.RGB}[i],
                            forKey: goorback.lineColorKey(num)
                        )
                    }
                } + [.cancel()]
            )
        }
    }
}

struct settingsLineName_Previews: PreviewProvider {
    static var previews: some View {
        settingsLineName("back1", 0)
    }
}
