//
//  TransferInfomation.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/02/25.
//

import SwiftUI

// MARK: - Transfer Information View
// Displays transfer time and transportation mode with editing capabilities
// num = 0: Destination station settings
// num = 1: Departure station settings
struct TransferView: View {
    
    @State private var isShowingPicker = false
    @State private var showSettingsLineSheet = false
    @State private var showSettingsTransferSheet = false

    private let goorback: String
    private let num: Int
    private let transportationArray: [String]

    // MARK: - Initialization
    // Initialize with route identifier and transfer segment number
    // num = 0: Destination station (目的地)
    // num = 1: Departure station (出発地)
    init(
        _ goorback: String,
        _ num: Int,
    ){
        self.goorback = goorback
        self.num = num
        self.transportationArray = goorback.transportationArray
    }

    var body: some View {
        HStack {
            // MARK: - Transfer Time Button
            Button (action: {
                if num < 2 {
                    showSettingsTransferSheet = true
                } else {
                    showSettingsLineSheet = true
                }
                print("num: \(num)")
            }) {
                LineTimeImage(
                    lineColor: .gray,
                    lineCode: "",
                    isTransfer: true,
                    transportation: transportationArray[num],
                    transportationKind: nil as TransportationLine.Kind?
                )
            }

            Spacer()
        }
        .frame(height: screen.transferHeight)
        .sheet(isPresented: $showSettingsLineSheet) {
            NavigationStack {
                SettingsLineSheet(goorback: goorback, lineIndex: num - 2)
            }
        }
        .sheet(isPresented: $showSettingsTransferSheet) {
            NavigationStack {
                SettingsTransferSheet()
            }
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct TransferInfomation_Previews: PreviewProvider {
    static var previews: some View {
        TransferView("back1", 0)
    }
}

