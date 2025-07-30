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
    @ObservedObject private var myTransit: MyTransit
    @ObservedObject private var myFirestore: MyFirestore
    @State private var isShowAlert = false
    
    init(
        myTransit: MyTransit,
        myFirestore: MyFirestore
    ) {
        self.myTransit = myTransit
        self.myFirestore = myFirestore
    }
    
    var body: some View {
        Button(action: {
            isShowAlert = true
        }) {
            Text("Save current data".localized).foregroundColor(.black)
        }
        // MARK: - Save Confirmation Alert
        .alert("Save current data".localized, isPresented: $isShowAlert) {
            // OK button
            Button(textOk, role: .destructive) {
                myFirestore.setFirestore()
                isShowAlert = false
            }
            // Cancel button
            Button(textCancel, role: .cancel){
                isShowAlert = false
            }
        } message: {
            Text("Overwritten saved data?".localized)
        }
        // MARK: - Save Result Alert
        .alert(myFirestore.title, isPresented: $myFirestore.isShowMessage) {
            Button(textOk, role: .none) {
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
        let myTransit = MyTransit()
        let myFirestore = MyFirestore()
        SetFirestoreButton(myTransit: myTransit, myFirestore: myFirestore)
    }
}


