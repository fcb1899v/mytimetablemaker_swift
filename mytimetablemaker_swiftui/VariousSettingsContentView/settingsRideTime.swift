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
    
    init(
        _ goorback: String,
        _ num: Int
    ){
        self.goorback = goorback
        self.num = num
        self.title = goorback.lineNameArray[num]
        self.label = goorback.rideTimeStringSettingsArray[num]
        self.color = goorback.rideTimeColorSettingsArray[num]
    }
    
    var body: some View {
        Button (action: {
            self.isShowingAlert = true
            inputText = ""
        }) {
            HStack {
                Text(title).foregroundColor(.black)
                    .onChange(of: goorback.lineNameArray[num]) {
                        newValue in title = newValue
                    }
                Spacer()
                Text(label).foregroundColor(label.settingsColor)
                    .lineLimit(1)
                    .onChange(of: goorback.rideTimeStringSettingsArray[num]) {
                        newValue in label = newValue
                    }
            }
            //Setting ride time alert
            .alert(rideTimeAlertTitle, isPresented: $isShowingAlert) {
                TextField(numberPlaceHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .lineLimit(1)
                //OK button
                Button(textOk, role: .none){
                    if (inputText.intText(min: 1, max: 99) > 0) {
                        UserDefaults.standard.set(inputText, forKey: goorback.rideTimeKey(num))
                    }
                    isShowingAlert = false
                }
                //Cancel button
                Button(textCancel, role: .cancel){
                    isShowingAlert = false
                }
                //Change Timetable button
                Button(timetableAlertTitle, role: .destructive){
                    if (inputText.intText(min: 1, max: 99) > 0) {
                        UserDefaults.standard.set(inputText, forKey: goorback.rideTimeKey(num))
                    }
                    isShowingNextAlert = true
                    isShowingAlert = false
                }
            } message: {
                Text(goorback.rideTimeAlertMessage(num))
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
