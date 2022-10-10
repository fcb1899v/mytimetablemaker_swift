//
//  settingsRideTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/01.
//

import SwiftUI

struct settingsRideTime: View {
    
    @State private var isShowingAlert = false
    @State private var isShowingNextAlert = false
    @State private var inputText = ""
    @State private var title: String
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
        self.title = goorback.lineNameArray[num]
        self.label = goorback.rideTimeStringArray[num]
        self.color = goorback.rideTimeSettingsColor(num)
    }
    
    
    var body: some View {

        let alertTitle = DialogTitle.ridetime.rawValue.localized
        let alertMessage = goorback.rideTimeAlertMessage(num)
        let key = goorback.rideTimeKey(num)
        let nextTitle = DialogTitle.timetable.rawValue.localized
        let placeHolder = Hint.to99min.rawValue.localized

        //Setting ride time button
        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                Text(title)
                    .foregroundColor(.black)
                    .padding(5)
                    .onChange(of: goorback.lineNameArray[num]) { newValue in title = newValue }
                Spacer()
                Text(label)
                    .lineLimit(1)
                    .foregroundColor(label.settingsColor)
                    .padding(5)
                    .onChange(of: goorback.rideTimeStringArray[num]) { newValue in label = newValue }
            }.font(.subheadline)
            //Setting ride time alert
            .alert(alertTitle, isPresented: $isShowingAlert) {
                TextField(placeHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .lineLimit(1)
                //OK button
                Button(Action.ok.rawValue.localized, role: .none){
                    let inputTextInt: Int = inputText.intText(min: 1, max: 99)
                    if (inputTextInt > 0) { UserDefaults.standard.set(inputTextInt, forKey: key) }
                    isShowingAlert = false
                    inputText = ""
                }
                //Cancel button
                Button(Action.cancel.rawValue.localized, role: .cancel){
                    isShowingAlert = false
                    inputText = ""
                }
                //Change Timetable button
                Button(nextTitle, role: .destructive){
                    let inputTextInt: Int = (Int(inputText)! > 0 && Int(inputText)! < 100) ? Int(inputText)!: 0
                    if (inputTextInt > 0) { UserDefaults.standard.set(inputText, forKey: key) }
                    isShowingNextAlert = true
                    isShowingAlert = false
                    inputText = ""
                }
            } message: {
                Text(alertMessage)
            }
        }
        //Setting timetable
        .sheet(isPresented: $isShowingNextAlert) {
            TimetableContentView(goorback, num)
        }
    }
}

struct settingsRideTime_Previews: PreviewProvider {
    static var previews: some View {
        settingsRideTime("back1", 0)
    }
}
