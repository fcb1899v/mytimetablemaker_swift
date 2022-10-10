//
//  TimetableEachGridView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI

struct TimetableGridView: View {

    @ObservedObject private var timetable: Timetable
    @State private var isShowingAlert = false
    @State private var isShowingNextAlert = false
    @State private var inputText = ""
    @State private var label: String

    private let goorback: String
    private let weekflag: Bool
    private let num: Int
    private let hour: Int

    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ num: Int,
        _ hour: Int
    ) {
        self.goorback = goorback
        self.weekflag = weekflag
        self.num = num
        self.hour = hour
        self.timetable = Timetable(goorback, weekflag, num)
        self.label = Timetable(goorback, weekflag, num).timetableTime(hour)
    }

    var body: some View {
        
        let alertTitle = DialogTitle.adddeletime.rawValue.localized
        let alertMessage = timetable.timetableAlertMessage(hour)
        let alertKey = timetable.timetableKey(hour)
        let placeHolder = Hint.to59min.rawValue.localized
        let actionTitle = DialogTitle.copytime.rawValue.localized
        let actionList = timetable.choiceCopyTimeTitle(hour)
        let actionKey = timetable.choiceCopyTimeKey(hour)

        ZStack {
            Color.white
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 2) {
                HStack(spacing: 1) {
                    Color.white.frame(width: 0)
                    ZStack {
                        Color.primaryColor.frame(width: 30)
                        Text(hour.addZeroTime).foregroundColor(Color.accentColor)
                    }
                    Button (action: {
                        self.isShowingAlert = true
                    }) {
                        ZStack(alignment: .leading) {
                            Color.primaryColor
                            Button (action: {
                                self.isShowingAlert = true
                            }) {
                                Text(label)
                                    .padding(.leading, 2)
                                    .foregroundColor(.white)
                                    .onChange(of: timetable.timetableTime(hour)) { newValue in label = newValue }
                            }
                            //Setting time alert
                            .alert(alertTitle, isPresented: $isShowingAlert) {
                                TextField(placeHolder, text: $inputText)
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.numberPad)
                                    .lineLimit(1)
                                //Add button
                                Button(Action.add.rawValue.localized, role: .none){
                                    let inputTextInt: Int = inputText.intText(min: 0, max: 59)
                                    if (inputTextInt > -1) { UserDefaults.standard.set(inputText.addTimeFromTimetable(alertKey), forKey: alertKey) }
                                    isShowingAlert = false
                                    inputText = ""
                                }
                                //Copy button
                                Button(actionTitle, role: .none) {
                                    isShowingNextAlert = true
                                    isShowingAlert = false
                                    inputText = ""
                                }
                                //Delete button
                                Button(Action.delete.rawValue.localized, role: .destructive) {
                                    let inputTextInt: Int = inputText.intText(min: 0, max: 59)
                                    if (inputTextInt > -1) { UserDefaults.standard.set(inputText.deleteTimeFromTimetable(alertKey), forKey: alertKey) }
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
                        .actionSheet(isPresented: $isShowingNextAlert) {
                            ActionSheet(
                                title: Text(actionTitle),
                                message: Text(""),
                                buttons: (((hour == 4) ? 1: 0)..<actionList.count)
                                    .filter { !(hour == 25 && $0 == 1) }
                                    .map { i in .default(Text(actionList[i]),
                                        action: {
                                            UserDefaults.standard.set(actionKey[i].userDefaultsValue(""), forKey: alertKey)
                                        }
                                    )
                                } + [.cancel()]
                            )
                        }//.frame(maxWidth: 600)
                    }
                    Color.white.frame(width: 0)
                }
            }
        }.frame(width: customWidth)
    }
}

struct TimetableGridView_Previews: PreviewProvider {
    static var previews: some View {
        let weekflag = !Date().weekFlag
        TimetableGridView("back1", weekflag, 0, 4)
    }
}
