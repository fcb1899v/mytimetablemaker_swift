//
//  stationAndTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/05/01.
//

import SwiftUI
import Foundation
import Combine

struct stationAndTime: View {
    
    private var cancellable: AnyCancellable?
    
    @State private var isShowingAlert = false
    @State private var inputText = ""
    @State private var label: String

    private let goorback: String
    private let num: Int
    private let time: String

    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ num: Int,
        _ time: String
    ){
        self.goorback = goorback
        self.num = num
        self.time = time
        self.label = goorback.stationArray[num]
    }

    var body: some View {
        HStack {
            Button (action: {
                self.isShowingAlert = true
                inputText = ""
            }) {
                Text(label)
                    .font(.system(size: routeStationFontSize))
                    .lineLimit(1)
                    .onChange(of: goorback.stationArray[num]) {
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
            Spacer()
            Text(time)
                .font(.custom("GenEiGothicN-Regular", size: routeTimeFontSize))
        }.foregroundColor(Color.primaryColor)
    }
}

struct stationAndTime_Previews: PreviewProvider {
    static var previews: some View {
        stationAndTime("back1", 0, "0800")
    }
}
