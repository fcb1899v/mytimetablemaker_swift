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
        // Initialize with empty string, will be updated by onChange
        self.label = ""
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.primaryColor
            HStack {
                // MARK: - Hour Display
                Color.white.frame(width: 1)
                Text(hour.addZeroTime)
                    .font(.system(size: screen.timetableTimeFontSize, weight: .bold))
                    .foregroundColor(Color.accentColor)
                    .frame(width: screen.timetableHourFrameWidth)
                Color.white.frame(width: 1)
                // MARK: - Time Edit Button
                Button (action: {
                    self.isShowingAlert = true
                    inputText = ""
                }) {
                    Text(label)
                        .font(.system(size: screen.timetableTimeFontSize, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .scaledToFit()
                        .onAppear {
                            // Load initial data
                            label = goorback.timetableTime(weekflag, num, hour)
                        }
                        .onChange(of: goorback.timetableTime(weekflag, num, hour)) {
                            newValue in label = newValue
                        }
                        // MARK: - Time Edit Alert
                        .alert("Add and delete departure time [min]".localized, isPresented: $isShowingAlert) {
                            TextField("Enter 0~59 [min]".localized, text: $inputText)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .lineLimit(1)
                            // Add button
                            Button("Add".localized, role: .none){
                                if (inputText.intText(min: 0, max: 59) > -1) {
                                    UserDefaults.standard.set(
                                        goorback.addTimeFromTimetable(inputText, weekflag, num, hour),
                                        forKey: goorback.timetableKey(weekflag, num, hour)
                                    )
                                }
                                isShowingAlert = false
                            }
                            // Copy button
                            Button("Copying your timetable".localized, role: .none) {
                                isShowingNextAlert = true
                                isShowingAlert = false
                            }
                            // Delete button
                            Button("Delete".localized, role: .destructive) {
                                if (inputText.intText(min: 0, max: 59) > -1) {
                                    UserDefaults.standard.set(
                                        goorback.deleteTimeFromTimetable(inputText, weekflag, num, hour),
                                        forKey: goorback.timetableKey(weekflag, num, hour)
                                    )
                                }
                                isShowingAlert = false
                            }
                            // Cancel button
                            Button("Cancel".localized, role: .cancel){
                                isShowingAlert = false
                            }
                        } message: {
                            Text(goorback.timetableAlertMessage(num, hour))
                        }
                        // MARK: - Copy Time Action Sheet
                        .actionSheet(isPresented: $isShowingNextAlert) {
                            ActionSheet(
                                title: Text("Copying your timetable".localized),
                                message: Text(""),
                                buttons: (((hour == 4) ? 1: 0)..<hour.choiceCopyTimeList(weekflag).count)
                                    .filter { !(hour == 25 && $0 == 1) }
                                    .map { i in .default(Text(hour.choiceCopyTimeList(weekflag)[i]),
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
                Spacer()
                Color.white.frame(width: 1)
            }
        }
        .frame(width: screen.customWidth, height: screen.timetableGridHeight)
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct TimetableGridView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableGridView("back1", !Date().isWeekday, 0, 4)
    }
}
