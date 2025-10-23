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
        let maxItemsPerRow = 10 // Maximum 3 time entries per row
        let totalRows = (transportationTimes.count + maxItemsPerRow - 1) / maxItemsPerRow
        
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<totalRows, id: \.self) { rowIndex in
                timetableRowContent(startIndex: rowIndex * maxItemsPerRow, maxItems: maxItemsPerRow)
            }
        }
        .frame(width: screen.timetableMinuteFrameWidth, alignment: .leading)
    }
    
    // MARK: - Row Content
    // Individual row content with proper spacing
    @ViewBuilder
    private func timetableRowContent(startIndex: Int, maxItems: Int) -> some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: screen.timetableMinuteSpacing)
            ForEach(startIndex..<min(startIndex + maxItems, transportationTimes.count), id: \.self) { index in
                HStack(spacing: 0) {
                    Text(transportationTimes[index].departureTime.minutesOnly)
                        .font(.system(size: screen.timetableMinuteFontSize, weight: .semibold))
                        .foregroundColor(Color.colorForTrainType((transportationTimes[index] as? TrainTime)?.trainType))
                        .lineLimit(1)
                    
                    Text("(\(String(transportationTimes[index].rideTime)))")
                        .font(.system(size: screen.timetableRideTimeFontSize, weight: .semibold))
                        .foregroundColor(Color.white)
                        .lineLimit(1)
                    Spacer()
                        .frame(width: screen.timetableMinuteSpacing)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(width: screen.timetableMinuteFrameWidth, height: screen.timetableNumberHeight)
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
