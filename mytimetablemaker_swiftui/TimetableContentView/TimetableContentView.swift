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
    
    @Environment(\.presentationMode) var presentationMode
    @State private var weekflag = true
    @State private var image = UIImage()
    @State private var isShowImagePicker = false

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
                Color.primaryColor
                VStack(alignment: .leading) {

                    // MARK: - Weekday/Weekend Toggle Button
                    HStack {
                        Spacer()
                        CustomToggle(
                            isLeftSelected: $weekflag,
                            leftText: "Weekdays".localized,
                            leftColor: .white,
                            rightText: "Sat/Sun/PH".localized,
                            rightColor: .redColor,
                            circleColor: .primaryColor
                        )
                    }
                    .padding(.horizontal, screen.timetablePadding)

                    // MARK: - Header Section
                    Text(goorback.stationArray[2 * num])
                        .font(.system(size: screen.timetableTitleFontSize, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.leading, screen.timetablePadding)

                    Text(goorback.timetableAlertTitle(num))
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
                                .foregroundColor(weekflag.weekLabelColor)
                                .fontWeight(.bold)
                            Spacer()
                            Color.white.frame(width: 1)
                        }
                        .frame(width: screen.customWidth, height: screen.timetableGridHeight)
                        Color.white.frame(width: screen.customWidth, height: 1)
                        ForEach(4...24, id: \.self) { hour in
                            TimetableGridView(goorback, weekflag, num, hour)
                            Color.white.frame(width: screen.customWidth, height: 1)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(
                backgroundColor: UIColor(Color.primaryColor),
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
                        presentationMode.wrappedValue.dismiss()
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
