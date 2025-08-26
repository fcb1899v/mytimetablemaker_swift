//
//  transitTimeAlertView.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/02/25.
//

import SwiftUI

// MARK: - Transit Information View
// Displays transit time and transportation mode with editing capabilities
struct transitInfomation: View {
    
    @State private var isShowingPicker = false
    @State private var transportation: String
    @State private var showSettingsTransitSheet = false
    @State private var transitTime: Int = 0

    private let goorback: String
    private let num: Int
    
    // MARK: - Initialization
    // Initialize with route identifier and transit segment number
    init(
        _ goorback: String,
        _ num: Int,
    ){
        self.goorback = goorback
        self.num = num
        self.transportation = goorback.transportationArray[num]
    }

    var body: some View {
        HStack {
            // MARK: - Transit Time Button
            Button (action: {
                showSettingsTransitSheet = true
            }) {
                lineTimeImage(
                    lineColor: Color.grayColor,
                    lineCode: "",
                    isTransit: true,
                    transportation: transportation
                )
            }
            Spacer()
        }
        .sheet(isPresented: $showSettingsTransitSheet) {
            SettingsTransitSheet(goorback: goorback, lineIndex: num)
        }
        .onAppear {
            updateData()
        }
        .onChange(of: showSettingsTransitSheet) { isPresented in
            if !isPresented {
                // SettingsTransitSheetが閉じられた後にデータを更新
                updateData()
            }
        }
    }
    
    // MARK: - Data Update
    // Update display data from UserDefaults
    private func updateData() {
        // Update transit time
        transitTime = goorback.transitTimeArray[num]
        transportation = goorback.transportationArray[num]
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct transitInfomation_Previews: PreviewProvider {
    static var previews: some View {
        transitInfomation("back1", 0)
    }
}

