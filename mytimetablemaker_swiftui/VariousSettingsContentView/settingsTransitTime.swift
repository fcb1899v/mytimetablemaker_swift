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
        Button (action: {
            self.isShowingAlert = true
            inputText = ""
        }) {
            HStack {
                Text(title).foregroundColor(.black)
                    .onChange(of: goorback.transportationLabel(num)) {
                        newValue in title = newValue
                    }
                Spacer()
                Text(label).foregroundColor(label.settingsColor)
                    .lineLimit(1)
                    .onChange(of: goorback.transitTimeStringArray[num]) {
                        newValue in label = newValue
                    }
            }
            //Setting transit time alert
            .alert(transitTimeAlertTitle, isPresented: $isShowingAlert) {
                TextField(numberPlaceHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .lineLimit(1)
                //OK button
                Button(textOk, role: .none){
                    if (inputText.intText(min: 1, max: 99) > 0) {
                        UserDefaults.standard.set(inputText, forKey: goorback.transitTimeKey(num))
                    }
                    isShowingAlert = false
                }
                //Cancel button
                Button(textCancel, role: .cancel){
                    isShowingAlert = false
                }
            } message: {
                Text(goorback.transportationMessage(num))
            }
        }
    }
}

struct settingsTransitTime_Previews: PreviewProvider {
    static var previews: some View {
        settingsTransitTime("back1", 0)
    }
}
