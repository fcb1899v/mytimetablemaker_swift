//
//  transitTimeAlertView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/25.
//

import SwiftUI

struct transitInfomation: View {
    
    @State private var isShowingAlert = false
    @State private var isShowingPicker = false
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
        self.label = goorback.transportationArray[num]
    }

    var body: some View {
        
        let alertTitle = DialogTitle.transittime.rawValue.localized
        let alertMessage = goorback.transportationMessage(num)
        let alertKey = goorback.transitTimeKey(num)
        let actionTitle = DialogTitle.transport.rawValue.localized
        let actionMessage = goorback.transportationMessage(num)
        let actionKey = goorback.transportationKey(num)
        let placeHolder = Hint.to99min.rawValue.localized

        HStack {
            Button (action: {
                self.isShowingAlert = true
            }) {
                lineTimeImage(color: Color.grayColor)
            }            //Setting transit time alert
            .alert(alertTitle, isPresented: $isShowingAlert) {
                TextField(placeHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .lineLimit(1)
                //OK button
                Button(Action.ok.rawValue.localized, role: .none){
                    let inputTextInt: Int = inputText.intText(min: 1, max: 99)
                    if (inputTextInt > 0) { UserDefaults.standard.set(inputText, forKey: alertKey) }
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

            Button(action: {
                self.isShowingPicker = true
            }) {
                Text(label)
                    .font(.system(size: routeLineFontSize))
                    .foregroundColor(Color.grayColor)
                    .lineLimit(1)
                    .onChange(of: goorback.transportationArray[num]) { newValue in label = newValue }
            }
            .padding(.leading, routeLineImageLeftPadding)
            .actionSheet(isPresented: $isShowingPicker) {
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
            Spacer()
        }
    }
}

struct transitInfomation_Previews: PreviewProvider {
    static var previews: some View {
        transitInfomation("back1", 0)
    }
}

