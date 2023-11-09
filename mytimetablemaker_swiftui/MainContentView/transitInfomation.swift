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
        HStack {
            Button (action: {
                self.isShowingAlert = true
                inputText = ""
            }) {
                lineTimeImage(color: Color.grayColor)
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
                        UserDefaults.standard.set(inputText, forKey:goorback.transitTimeKey(num))
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
            Button(action: {
                self.isShowingPicker = true
            }) {
                Text(label)
                    .font(.system(size: routeLineFontSize))
                    .foregroundColor(Color.grayColor)
                    .lineLimit(1)
                    .onChange(of: goorback.transportationArray[num]) {
                        newValue in label = newValue
                    }
            }
            .padding(.leading, routeLineImageLeftPadding)
            //Setting transportation action sheet
            .actionSheet(isPresented: $isShowingPicker) {
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
            Spacer()
        }
    }
}

struct transitInfomation_Previews: PreviewProvider {
    static var previews: some View {
        transitInfomation("back1", 0)
    }
}

