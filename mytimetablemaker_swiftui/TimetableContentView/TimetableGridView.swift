//
//  TimetableEachGridView.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/03/02.
//

import SwiftUI

// MARK: - Timetable Grid View
// Individual grid cell for editing timetable times with add/delete/copy functionality
struct TimetableGridView: View {

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
        self.label = goorback.timetableTime(weekflag, num, hour)
    }

    var body: some View {
        ZStack {
            Color.white
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 2) {
                HStack(spacing: 1) {
                    Color.white.frame(width: 0)
                    // MARK: - Hour Display
                    ZStack {
                        Color.primaryColor.frame(width: 30)
                        Text(hour.addZeroTime).foregroundColor(Color.accentColor)
                    }
                    
                    // MARK: - Time Edit Button
                    Button (action: {
                        self.isShowingAlert = true
                        inputText = ""
                    }) {
                        ZStack(alignment: .leading) {
                            Color.primaryColor
                            Text(label)
                                .padding(.leading, 2)
                                .foregroundColor(.white)
                                .onChange(of: goorback.timetableTime(weekflag, num, hour)) {
                                    newValue in label = newValue
                                }
                        }
                        // MARK: - Time Edit Alert
                        .alert(addAndDeleteTimeTitle, isPresented: $isShowingAlert) {
                            TextField(minutePlaceHolder, text: $inputText)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .lineLimit(1)
                            // Add button
                            Button(textAdd, role: .none){
                                if (inputText.intText(min: 0, max: 59) > -1) {
                                    UserDefaults.standard.set(
                                        goorback.addTimeFromTimetable(inputText, weekflag, num, hour),
                                        forKey: goorback.timetableKey(weekflag, num, hour)
                                    )
                                }
                                isShowingAlert = false
                            }
                            // Copy button
                            Button(choiceCopyTimeTitle, role: .none) {
                                isShowingNextAlert = true
                                isShowingAlert = false
                            }
                            // Delete button
                            Button(textDelete, role: .destructive) {
                                if (inputText.intText(min: 0, max: 59) > -1) {
                                    UserDefaults.standard.set(
                                        goorback.deleteTimeFromTimetable(inputText, weekflag, num, hour),
                                        forKey: goorback.timetableKey(weekflag, num, hour)
                                    )
                                }
                                isShowingAlert = false
                            }
                            // Cancel button
                            Button(textCancel, role: .cancel){
                                isShowingAlert = false
                            }
                        } message: {
                            Text(goorback.timetableAlertMessage(num, hour))
                        }
                        
                        // MARK: - Copy Time Action Sheet
                        .actionSheet(isPresented: $isShowingNextAlert) {
                            ActionSheet(
                                title: Text(choiceCopyTimeTitle),
                                message: Text(""),
                                buttons: (((hour == 4) ? 1: 0)..<choiceCopyTimeList(weekflag, hour).count)
                                    .filter { !(hour == 25 && $0 == 1) }
                                    .map { i in .default(Text(choiceCopyTimeList(weekflag, hour)[i]),
                                        action: {
                                            UserDefaults.standard.set(
                                                goorback.choiceCopyTime(weekflag, num, hour, i),
                                                forKey: goorback.timetableKey(weekflag, num, hour)
                                            )
                                        }
                                    )
                                } + [.cancel()]
                            )
                        }
                    }
                    Color.white.frame(width: 0)
                }
            }
        }.frame(width: customWidth)
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct TimetableGridView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableGridView("back1", !Date().isWeekday, 0, 4)
    }
}
