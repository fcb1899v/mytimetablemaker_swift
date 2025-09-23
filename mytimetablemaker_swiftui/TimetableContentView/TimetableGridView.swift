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

    @State private var isShowingTimetableSheet = false
    @State private var label: String
    @State private var trainTimes: [TrainTime] = []

    private let goorback: String
    @Binding private var weekflag: Bool
    private let num: Int
    private let hour: Int
    init(
        _ goorback: String,
        _ weekflag: Binding<Bool>,
        _ num: Int,
        _ hour: Int
    ) {
        self.goorback = goorback
        self._weekflag = weekflag
        self.num = num
        self.hour = hour
        self.label = ""
    }

    var body: some View {
        // MARK: - Time Edit Button
        Button (action: {
            self.isShowingTimetableSheet = true
        }) {
            HStack {
                // MARK: - Hour Display
                HStack {
                    Color.white.frame(width: 1)
                    Text(hour.addZeroTime)
                        .font(.system(size: screen.timetableHourFontSize, weight: .semibold))
                        .foregroundColor(.accent)
                        .frame(width: screen.timetableHourFrameWidth)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .scaledToFit()
                    Color.white.frame(width: 1)
                }
                .background(Color.black.opacity(0.25))

                HStack(spacing: screen.timetableMinuteSpacing) {
                    ForEach(trainTimes, id: \.self) { trainTime in
                        Text(trainTime.departureTime.trimmingLeadingZero)
                            .font(.system(size: screen.timetableMinuteFontSize, weight: .semibold))
                            .foregroundColor(Color.colorForTrainType(trainTime.trainType))
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .scaledToFit()
                .contentShape(Rectangle()) // Make entire area tappable
                .onAppear {
                    // Load initial data
                    label = goorback.timetableTime(weekflag, num, hour)
                    trainTimes = goorback.loadTrainTimes(weekflag, num, hour)
                }
                .onChange(of: goorback.timetableTime(weekflag, num, hour)) {
                    newValue in 
                    label = newValue
                    trainTimes = goorback.loadTrainTimes(weekflag, num, hour)
                }
                .onChange(of: weekflag) { _ in
                    label = goorback.timetableTime(weekflag, num, hour)
                    trainTimes = goorback.loadTrainTimes(weekflag, num, hour)
                }
                // Listen for timetable data updates from API
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TimetableDataUpdated"))) { _ in
                    trainTimes = goorback.loadTrainTimes(weekflag, num, hour)
                }
                Spacer()
                Color.white.frame(width: 1)
            }
        }
        .frame(width: screen.customWidth, height: screen.timetableGridHeight)
        .sheet(isPresented: $isShowingTimetableSheet) {
            SettingsTimetableSheet(
                goorback: goorback,
                weekflag: weekflag,
                num: num,
                hour: hour
            )
        }
    }    
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct TimetableGridView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableGridView("back1", .constant(!Date().isWeekday), 0, 4)
            .background(Color.primary)
    }
}
