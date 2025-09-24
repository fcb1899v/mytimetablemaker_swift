//
//  GetFirestoreButton.swift
//  mytimetablemaker_swiftui
//
//  Created by Nakajima Masao on 2023/10/09.
//

import SwiftUI

// MARK: - Get Firestore Button
// Button component for retrieving saved data from Firestore database
struct FirestoreButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var myFirestore: MyFirestore
    private let isSaveFirestore: Bool
    @State private var isShowAlert = false
    
    init(
        myFirestore: MyFirestore,
        isSaveFirestore: Bool
    ) {
        self.myFirestore = myFirestore
        self.isSaveFirestore = isSaveFirestore
    }
    
    var body: some View {
        Button(action: {
            isShowAlert = true
        }) {
            Text(isSaveFirestore ? "Save current data".localized: "Get saved data".localized)
                .font(.system(size: screen.settingsFontSize))
                .foregroundColor(.black)
        }
        // MARK: - Get Confirmation Alert
        .alert(isSaveFirestore ? "Save current data".localized: "Get saved data".localized, isPresented: $isShowAlert) {
            // OK button
            Button("OK".localized, role: .destructive) {
                isSaveFirestore ?  myFirestore.setFirestore(): myFirestore.getFirestore()
                isShowAlert = false
            }
            // Cancel button
            Button("Cancel".localized, role: .cancel) {
                isShowAlert = false
            }
        } message: {
            Text("⚠️ " + (isSaveFirestore ? "Overwritten saved data?".localized: "Overwritten current data?".localized))
        }
        .tint(.primary)
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct FirestoreButton_Previews: PreviewProvider {
    static var previews: some View {
        let myFirestore = MyFirestore()
        FirestoreButton(myFirestore: myFirestore, isSaveFirestore: false)
    }
}

