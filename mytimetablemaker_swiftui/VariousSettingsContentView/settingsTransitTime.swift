//
//  settingsTransitTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI

struct settingsTransitTime: View {
    
    @State private var isShowingAlert = false
    @State private var inputText = ""
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
        self.label = goorback.transitTimeStringArray[num]
    }

    var body: some View {
        
        let alertTitle = DialogTitle.transittime.rawValue.localized
        let alertMessage = goorback.transportationMessage(num)
        let key = goorback.transitTimeKey(num)
        let placeHolder = Hint.to99min.rawValue.localized
        
        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                Text(title)
                    .foregroundColor(.black)
                    .padding(5)
                    .onChange(of: goorback.transportationLabel(num)) { newValue in title = newValue }
                Spacer()
                Text(label)
                    .lineLimit(1)
                    .foregroundColor(label.settingsColor)
                    .padding(5)
                    .onChange(of: goorback.transitTimeStringArray[num]) { newValue in label = newValue }
            }.font(.subheadline)
            //Setting transit time alert
            .alert(alertTitle, isPresented: $isShowingAlert) {
                TextField(placeHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .lineLimit(1)
                //OK button
                Button(Action.ok.rawValue.localized, role: .none){
                    let inputTextInt: Int = inputText.intText(min: 1, max: 99)
                    if (inputTextInt > 0) { UserDefaults.standard.set(inputText, forKey: key) }
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

struct settingsTransitTime_Previews: PreviewProvider {
    static var previews: some View {
        settingsTransitTime("back1", 0)
    }
}
