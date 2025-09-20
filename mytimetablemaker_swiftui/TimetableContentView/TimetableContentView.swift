//
//  TimetableContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/03/02.
//

import SwiftUI
import GoogleMobileAds

// MARK: - Timetable Content View
// Main timetable editing screen with grid view and image picker
struct TimetableContentView: View {
    
    @State private var weekflag = Date().isWeekday
    @State private var image = UIImage()
    @State private var isShowImagePicker = false
    @Environment(\.dismiss) private var dismiss

    private let goorback: String
    private let num: Int

    init(
        _ goorback: String,
        _ num: Int
    ) {
        self.goorback = goorback
        self.num = num
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primary
                VStack(alignment: .leading) {


                    // MARK: - Weekday/Weekend Toggle Button
                    HStack {

                        Text(goorback.stationArray[2 * num])
                            .font(.system(size: screen.timetableTitleFontSize, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()
                        
                        CustomToggle(
                            isLeftSelected: Binding(
                                get: { weekflag },
                                set: { newValue in
                                    weekflag = newValue
                                    print("✅ Toggle updated: weekflag=\(weekflag), label='\(weekflag.weekdayLabel)'")
                                }
                            ),
                            leftText: "Weekdays".localized,
                            leftColor: .white,
                            rightText: "Sat/Sun/PH".localized,
                            rightColor: .red,
                            circleColor: .primary,
                            offColor: .secondary
                        )
                    }
                    .padding(.horizontal, screen.timetablePadding)

                    // MARK: - Header Section
                    Text(goorback.timetableLineTitle(num))
                        .font(.system(size: screen.timetableHeaderFontSize, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.leading, screen.timetablePadding)
                        .padding(.bottom, screen.timetableSpacing)

                    // MARK: - Timetable Grid
                    VStack(spacing: 0) {
                        Color.white.frame(width: screen.customWidth, height: 1)

                        HStack {
                            Color.white.frame(width: 1)
                            Spacer()
                            Text(weekflag.weekdayLabel)
                                .font(.system(size: screen.timetableHeaderFontSize, weight: .semibold))
                                .foregroundColor(weekflag.weekLabelColor)
                            Spacer()
                            Color.white.frame(width: 1)
                        }
                        .onAppear {
                            print("🔍 TimetableContentView: weekflag=\(weekflag), weekdayLabel='\(weekflag.weekdayLabel)', weekLabelColor=\(weekflag.weekLabelColor)")
                        }
                        .background(Color.black.opacity(0.5))
                        .frame(width: screen.customWidth, height: screen.timetableGridHeight)
    
                        Color.white.frame(width: screen.customWidth, height: 1)
                        
                        ForEach(4...24, id: \.self) { hour in
                            TimetableGridView(goorback, $weekflag, num, hour)
                            Color.white.frame(width: screen.customWidth, height: 1)
                        }
                    }
                    
                    ColorLegendView(trainTypes: loadTrainTypeList())
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(
                backgroundColor: UIColor(Color.primary),
                titleColor: .white,
            )
            .toolbarColorScheme(.light, for: .navigationBar)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.bottom)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Timetable Settings".localized)
                        .font(.system(size: screen.timetableTitleFontSize, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Back button
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrowshape.backward.fill")
                                .font(.system(size: screen.timetableHeaderFontSize, weight: .bold))
                                .foregroundColor(.white)
                            Text("Back to homepage".localized)
                                .font(.system(size: screen.timetableButtonFontSize, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .onAppear {
                // Set weekflag based on current date
                weekflag = Date().isWeekday
                print("📱 TimetableContentView loaded: weekflag=\(weekflag) (\(weekflag ? "Weekdays" : "Weekend")), label='\(weekflag.weekdayLabel)'")
            }
        }
    }
    
    // MARK: - Load Train Type List
    // Load unique train types list for the current line and direction
    private func loadTrainTypeList() -> [String] {
        let trainTypeListKey = goorback.trainTypeListKey(weekflag, num)

        if let trainTypeListString = UserDefaults.standard.string(forKey: trainTypeListKey),
           !trainTypeListString.isEmpty {
            let trainTypes = Array(Set(trainTypeListString.components(separatedBy: " ")
                .filter { !$0.isEmpty }))
                .sorted { trainType1, trainType2 in
                    let color1 = Color.colorForTrainType(trainType1)
                    let color2 = Color.colorForTrainType(trainType2)
                    
                    // Define color priority: white, yellow-green, orange, red, pink
                    let colorPriority: [Color: Int] = [
                        .white: 0,
                        .yelwgre: 1,
                        .yellow: 2,
                        .orange: 3,
                        .pink: 4,
                        .ligblue: 5
                    ]
                    
                    let priority1 = colorPriority[color1] ?? 999
                    let priority2 = colorPriority[color2] ?? 999
                    
                    if priority1 != priority2 {
                        return priority1 < priority2
                    } else {
                        return trainType1 < trainType2
                    }
                }
            return trainTypes
        } else {
            print("🔍 loadTrainTypeList: No train type list found for key='\(trainTypeListKey)'")
            return []
        }
    }
}

// MARK: - Color Legend View
// Displays color legend for train types based on saved train type list
struct ColorLegendView: View {
    let trainTypes: [String]
    
    // Filter out nil and empty train types
    private var validTrainTypes: [String] {
        return trainTypes.filter { !$0.isEmpty }
    }
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: screen.timetableSpacing) {
                ForEach(0..<((validTrainTypes.count + 2) / 3), id: \.self) { rowIndex in
                    HStack(spacing: screen.timetableSpacing) {
                        ForEach(0..<min(3, validTrainTypes.count - rowIndex * 3), id: \.self) { colIndex in
                            let trainTypeIndex = rowIndex * 3 + colIndex
                            let trainType = validTrainTypes[trainTypeIndex]
                            let displayText = trainType.components(separatedBy: ".").last ?? trainType
                            
                            HStack {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(Color.colorForTrainType(trainType))
                                    .font(.system(size: screen.timetableHeaderFontSize))
                                Text(displayText.localized)
                                    .font(.system(size: screen.timetableHeaderFontSize, weight: .medium))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .scaledToFit()
                            }
                            .padding(.horizontal, screen.timetableSpacing)
                        }
                    }
                }
            }
            .padding(.horizontal, screen.timetablePadding)
            .padding(.vertical, screen.timetableSpacing)
            Spacer()
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct TimetableContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableContentView("back1", 0)
    }
}
