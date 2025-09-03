//
//  SetFirestoreButton.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2023/10/09.
//

import SwiftUI

// MARK: - Save Firestore Button
// Button component for saving current data to Firestore database
struct SetFirestoreButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var myTransfer: MyTransfer
    @ObservedObject private var myFirestore: MyFirestore
    @State private var isShowAlert = false
    
    init(
        myTransfer: MyTransfer,
        myFirestore: MyFirestore
    ) {
        self.myTransfer = myTransfer
        self.myFirestore = myFirestore
    }
    
    var body: some View {
        Button(action: {
            isShowAlert = true
        }) {
            Text("Save current data".localized)
                .font(.system(size: screen.settingsFontSize))
                .foregroundColor(.black)
        }
        // MARK: - Save Confirmation Alert
        .alert("Save current data".localized, isPresented: $isShowAlert) {
            // OK button
                            Button("OK".localized, role: .destructive) {
                myFirestore.setFirestore()
                isShowAlert = false
            }
            // Cancel button
                            Button("Cancel".localized, role: .cancel){
                isShowAlert = false
            }
        } message: {
            Text("Overwritten saved data?".localized)
        }
        // MARK: - Save Result Alert
        .alert(myFirestore.title, isPresented: $myFirestore.isShowMessage) {
                            Button("OK".localized, role: .none) {
                myFirestore.isShowMessage = false
                if (myFirestore.isFirestoreSuccess) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(myFirestore.message)
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct SetFirestoreButton_Previews: PreviewProvider {
    static var previews: some View {
        let myTransfer = MyTransfer()
        let myFirestore = MyFirestore()
        SetFirestoreButton(myTransfer: myTransfer, myFirestore: myFirestore)
    }
}


