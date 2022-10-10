//
//  mainAlertPlusLabel.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/04.
//

import SwiftUI

struct lineInfomation: View {
    
    @State private var isShowingRideTimeAlert = false
    @State private var isShowingTimetableAlert = false
    @State private var isShowingLineNameAlert = false
    @State private var isShowingLineColorAlert = false
    @State private var inputText = ""
    @State private var label: String
    @State private var color : Color

    private let goorback: String
    private let weekflag: Bool
    private let num: Int
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ num: Int
    ){
        self.goorback = goorback
        self.weekflag = weekflag
        self.num = num
        self.label = goorback.lineNameArray[num]
        self.color = goorback.lineColorArray[num]
    }

    var body: some View {
        
        let rideTimeTitle = DialogTitle.ridetime.rawValue.localized
        let rideTimeMessage = goorback.rideTimeAlertMessage(num)
        let rideTimeKey = goorback.rideTimeKey(num)
        let timetableTitle = DialogTitle.timetable.rawValue.localized
        let lineNameTitle = DialogTitle.linename.rawValue.localized
        let lineNameMessage = goorback.lineNameAlertMessage(num)
        let lineNameKey = goorback.lineNameKey(num)
        let lineColorTitle = DialogTitle.linecolor.rawValue.localized
        let lineColorMessage = goorback.lineNameArray[num]
        let lineColorKey = goorback.lineColorKey(num)
        let numberPlaceHolder = Hint.to99min.rawValue.localized
        let placeHolder = Hint.maxchar.rawValue.localized
        
        HStack {
            Button (action: {
                self.isShowingRideTimeAlert = true
            }) {
                lineTimeImage(color: color)
                    .sheet(isPresented: $isShowingTimetableAlert) {
                        TimetableContentView(goorback, num)
                    }
            }
            //Setting ride time alert
            .alert(rideTimeTitle, isPresented: $isShowingRideTimeAlert) {
                TextField(numberPlaceHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .lineLimit(1)
                //OK button
                Button(Action.ok.rawValue.localized, role: .none) {
                    let inputTextInt: Int = inputText.intText(min: 1, max: 99)
                    if (inputTextInt > 0) { UserDefaults.standard.set(inputText, forKey: rideTimeKey) }
                    isShowingRideTimeAlert = false
                    inputText = ""
                }
                //Cancel button
                Button(Action.cancel.rawValue.localized, role: .cancel){
                    isShowingRideTimeAlert = false
                    inputText = ""
                }
                //Change Timetable button
                Button(timetableTitle, role: .destructive) {
                    isShowingTimetableAlert = true
                    isShowingRideTimeAlert = false
                    inputText = ""
                }
            } message: {
                Text(rideTimeMessage)
            }

            Button (action: {
                isShowingLineNameAlert = true
            }) {
                Text(label)
                    .font(.system(size: routeLineFontSize))
                    .foregroundColor(color)
                    .lineLimit(1)
                    .onChange(of: goorback.lineNameArray[num]) { newValue in label = newValue }
                    .onChange(of: goorback.lineColorArray[num]) { newColor in color = newColor }
            }
            //Setting line name alert
            .alert(lineNameTitle, isPresented: $isShowingLineNameAlert) {
                TextField(placeHolder, text: $inputText)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                //OK button
                Button(Action.ok.rawValue.localized, role: .none){
                    if (inputText != "") { UserDefaults.standard.set(inputText, forKey: lineNameKey) }
                    isShowingLineNameAlert = false
                    inputText = ""
                }
                //Cancel button
                Button(Action.cancel.rawValue.localized, role: .cancel){
                    isShowingLineNameAlert = false
                    inputText = ""
                }
                //Setting line color button
                Button(DialogTitle.linecolor.rawValue.localized, role: .destructive){
                    if (inputText != "") { UserDefaults.standard.set(inputText, forKey: lineNameKey) }
                    isShowingLineColorAlert = true
                    isShowingLineNameAlert = false
                    inputText = ""
                }
            } message: {
                Text(lineNameMessage)
            }
            .padding(.leading, routeLineImageLeftPadding)
            .actionSheet(isPresented: $isShowingLineColorAlert) {
                ActionSheet(
                    title: Text(lineColorTitle),
                    message: Text(lineColorMessage),
                    buttons: CustomColor.allCases.map{$0.rawValue.localized}.indices.map { i in
                        .default(Text(CustomColor.allCases.map{$0.rawValue.localized}[i])) {
                            UserDefaults.standard.set(CustomColor.allCases.map{$0.RGB}[i], forKey: lineColorKey)
                        }
                    } + [.cancel()]
                )
            }
            Spacer()
        }
    }
}

struct lineInfomation_Previews: PreviewProvider {
    static var previews: some View {
        lineInfomation("back1", true, 0)
    }
}
