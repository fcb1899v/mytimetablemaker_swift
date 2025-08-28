//
//  TransferInfomation.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/02/25.
//

import SwiftUI

// MARK: - Transfer Information View
// Displays transfe time and transportation mode with editing capabilities
struct TransferInfomation: View {
    
    @State private var isShowingPicker = false
    @State private var transportation: String
    @State private var showSettingsTransferSheet = false
    @State private var transferTime: Int = 0

    private let goorback: String
    private let num: Int
    
    // MARK: - Initialization
    // Initialize with route identifier and transfer segment number
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
            // MARK: - Transfer Time Button
            if num < 2 {
                Button (action: {
                    showSettingsTransferSheet = true
                }) {
                    lineTimeImage(
                        lineColor: Color.grayColor,
                        lineCode: "",
                        isTransfer: true,
                        transportation: transportation
                    )
                }
            } else {
                lineTimeImage(
                    lineColor: Color.grayColor,
                    lineCode: "",
                    isTransfer: true,
                    transportation: transportation
                )
            }
            Spacer()
        }
        .sheet(isPresented: $showSettingsTransferSheet) {
            SettingsTransferSheet(goorback: goorback, lineIndex: num)
        }
        .onAppear {
            updateData()
        }
        .onChange(of: showSettingsTransferSheet) { isPresented in
            if !isPresented {
                updateData()
            }
        }
    }
    
    // MARK: - Data Update
    // Update display data from UserDefaults
    private func updateData() {
        // Update transfer time
        transferTime = goorback.transferTimeArray[num]
        transportation = goorback.transportationArray[num]
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct TransferInfomation_Previews: PreviewProvider {
    static var previews: some View {
        TransferInfomation("back1", 0)
    }
}

