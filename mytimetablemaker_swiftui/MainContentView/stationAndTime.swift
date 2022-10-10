//
//  stationAndTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/05/01.
//

import SwiftUI

struct stationAndTime: View {
    
    @State private var isShowingAlert = false
    @State private var inputText = ""
    @State private var label: String
    @State private var time: String

    private let goorback: String
    private let weekflag: Bool
    private let currenttime: Int
    private let num: Int

    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ currenttime: Int,
        _ num: Int
    ){
        self.goorback = goorback
        self.weekflag = weekflag
        self.currenttime = currenttime
        self.num = num
        self.label = goorback.stationArray[num]
        self.time = CalcTime(goorback, weekflag).displayTimeArray(currenttime)[num]
    }

    var body: some View {
        
        let alertTitle = goorback.stationAlertTitleArray[num]
        let alertMessage = goorback.stationAlertMessageArray[num]
        let key = goorback.stationKeyArray[num]
        let placeHolder = Hint.maxchar.rawValue.localized
        
        HStack {
            Button (action: {
                self.isShowingAlert = true
            }) {
                Text(label)
                    .font(.system(size: routeStationFontSize))
                    .lineLimit(1)
                    .onChange(of: goorback.stationArray[num]) { newValue in label = newValue }
            }.alert(alertTitle, isPresented: $isShowingAlert) {
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
            Spacer()
            Text(time)
                .font(.custom("GenEiGothicN-Regular", size: routeTimeFontSize))
                .onChange(of: CalcTime(goorback, weekflag).displayTimeArray(currenttime)[num]) { newValue in time = newValue }
        }.foregroundColor(Color.primaryColor)
    }
}

struct stationAndTime_Previews: PreviewProvider {
    static var previews: some View {
        stationAndTime("back1", true, 100000, 0)
    }
}
