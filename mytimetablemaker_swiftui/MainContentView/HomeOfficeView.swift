//
//  stationAndTime.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/05/01.
//

import SwiftUI
import Foundation
import Combine

// MARK: - Station and Time View
// Displays station name and departure time with editing capability
struct HomeOfficeView: View {
    
    private let goorback: String
    private let num: Int
    private let time: String

    // MARK: - Initialization
    // Initialize with route identifier, station number, and time
    init(
        _ goorback: String,
        _ num: Int,
        _ time: String
    ){
        self.goorback = goorback
        self.num = num
        self.time = time
    }

    var body: some View {
        HStack {
            // MARK: - Station Name Button
            Text(num == 0 ? goorback.destination: goorback.departurePoint)
                .font(.system(size: stationFontSize))
                .lineLimit(1)
            Spacer()
            // MARK: - Time Display
            Text(time)
                .font(.custom("GenEiGothicN-Regular", size: timeFontSize))
        }
        .foregroundColor(Color.primaryColor)
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct stationAndTime_Previews: PreviewProvider {
    static var previews: some View {
        HomeOfficeView("back1", 0, "0800")
    }
}
