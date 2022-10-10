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
        
        let title = goorback.lineNameDefault(num)
        let alertTitle = DialogTitle.linename.rawValue.localized
        let alertMessage = goorback.lineNameAlertMessage(num)
        let key = goorback.lineNameKey(num)
        let nextTitle = DialogTitle.linecolor.rawValue.localized
        let nextMessage = goorback.lineNameArray[num]
        let nextKey = goorback.lineColorKey(num)
        let placeHolder = Hint.maxchar.rawValue.localized
        
        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                //Setting line name button
                Text(title)
                    .foregroundColor(.black)
                    .padding(5)
                Spacer()
                Text(label)
                    .lineLimit(1)
                    .foregroundColor(color)
                    .padding(5)
                    .onChange(of: goorback.lineNameSettingsArray[num]) { newValue in label = newValue }
                    .onChange(of: goorback.lineColorSettingsArray[num] ) { newValue in color = newValue }
            }.font(.subheadline)
            //Setting line name alert
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
                //Setting line color button
                Button(DialogTitle.linecolor.rawValue.localized, role: .destructive){
                    if (inputText != "") { UserDefaults.standard.set(inputText, forKey: key) }
                    isShowingNextAlert = true
                    isShowingAlert = false
                    inputText = ""
                }
            } message: {
                Text(alertMessage)
            }
        }
        //Setting line color action sheet
        .actionSheet(isPresented: $isShowingNextAlert) {
            ActionSheet(
                title: Text(nextTitle),
                message: Text(nextMessage),
                buttons: CustomColor.allCases.map{$0.rawValue.localized}.indices.map { i in
                    .default(Text(CustomColor.allCases.map{$0.rawValue.localized}[i])) {
                        UserDefaults.standard.set(CustomColor.allCases.map{$0.RGB}[i], forKey: nextKey)
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
