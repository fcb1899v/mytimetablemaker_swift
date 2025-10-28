//
//  TimetableEachGridView.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2021/03/02.
//

import SwiftUI

// MARK: - Timetable Grid View
// Individual grid cell for editing timetable times with add/delete/copy functionality
struct TimetableGridView: View {

    @State private var isShowingTimetableSheet = false
    @State private var label: String
    @State private var transportationTimes: [any TransportationTime] = []

    private let goorback: String
    @Binding private var selectedCalendarType: ODPTCalendarType
    private let num: Int
    private let hour: Int

    init(
        _ goorback: String,
        _ selectedCalendarType: Binding<ODPTCalendarType>,
        _ num: Int,
        _ hour: Int
    ) {
        self.goorback = goorback
        self._selectedCalendarType = selectedCalendarType
        self.num = num
        self.hour = hour
        self.label = ""
    }

    var body: some View {
        // MARK: - Time Edit Button
        HStack(spacing: 0) {
            // MARK: - Hour Display
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Color.white.frame(width: 1)
                    Spacer()
                    Text(hour.addZeroTime)
                        .font(.system(size: screen.timetableHourFontSize, weight: .semibold))
                        .foregroundColor(.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .scaledToFit()
                    Spacer()
                    Color.white.frame(width: 1)
                }
                .frame(width: screen.timetableHourFrameWidth, height: screen.calculateContentHeight(transportationTimes.count))
                .background(Color.black.opacity(0.25))
            }
            
            
            Button (action: {
                self.isShowingTimetableSheet = true
            }) {
                timetableGridContent()
                    .contentShape(Rectangle()) // Make entire area tappable
            }
            .frame(width: screen.timetableMinuteFrameWidth)
            .onAppear {
                // Load initial data
                label = goorback.timetableTime(selectedCalendarType, num, hour)
                transportationTimes = goorback.loadTransportationTimes(selectedCalendarType, num, hour)
            }
            .onChange(of: goorback.timetableTime(selectedCalendarType, num, hour)) { newValue in
                label = newValue
                transportationTimes = goorback.loadTransportationTimes(selectedCalendarType, num, hour)
            }
            .onChange(of: selectedCalendarType) { _ in
                label = goorback.timetableTime(selectedCalendarType, num, hour)
                transportationTimes = goorback.loadTransportationTimes(selectedCalendarType, num, hour)
            }
            // Listen for timetable data updates from API
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TimetableDataUpdated"))) { _ in
                transportationTimes = goorback.loadTransportationTimes(selectedCalendarType, num, hour)
            }
            
            Color.white
                .frame(width: 1, height: screen.calculateContentHeight(transportationTimes.count))
        }
        .frame(width: screen.customWidth)
        .sheet(isPresented: $isShowingTimetableSheet) {
            SettingsTimetableSheet(
                goorback: goorback,
                selectedCalendarType: selectedCalendarType,
                num: num,
                hour: hour
            )
        }
    }
    
    
    // MARK: - Grid Content View
    // Train times display grid with proper wrapping
    @ViewBuilder
    private func timetableGridContent() -> some View {
        let availableWidth = screen.timetableMinuteFrameWidth - (screen.timetableMinuteSpacing * 2)
        let itemsPerRow = 10
        let itemWidth = availableWidth / CGFloat(itemsPerRow)
        let columns = Array(repeating: GridItem(.fixed(itemWidth), spacing: 0), count: itemsPerRow)
        
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(transportationTimes.indices, id: \.self) { index in
                HStack(spacing: 0) {
                    Text(transportationTimes[index].departureTime.minutesOnly)
                        .font(.system(size: screen.timetableMinuteFontSize, weight: .semibold))
                        .foregroundColor(Color.colorForTrainType((transportationTimes[index] as? TrainTime)?.trainType))
                    
                    Text("(\(String(transportationTimes[index].rideTime)))")
                        .font(.system(size: screen.timetableRideTimeFontSize, weight: .semibold))
                        .foregroundColor(Color.white)
                }
                .frame(width: itemWidth, height: screen.timetableNumberHeight)
                .minimumScaleFactor(0.8)
            }
        }
        .frame(width: screen.timetableMinuteFrameWidth, alignment: .leading)
        .padding(.horizontal, screen.timetableMinuteSpacing)
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct TimetableGridView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableGridView("back1", .constant(Date().odpTCalendarType), 0, 4)
            .background(Color.primary)
    }
}
