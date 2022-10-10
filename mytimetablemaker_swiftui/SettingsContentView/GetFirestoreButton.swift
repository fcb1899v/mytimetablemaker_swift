//
//  GetDataButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2023/10/09.
//

import SwiftUI

struct GetFirestoreDaButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    private let isGetFirestore: Bool
    @ObservedObject private var myTransit: MyTransit
    @ObservedObject private var myFirestore: MyFirestore
    
    init(
        myTransit: MyTransit,
        myFirestore: MyFirestore,
        isGetFirestore: Bool
    ) {
        self.myTransit = myTransit
        self.myFirestore = myFirestore
        self.isGetFirestore = isGetFirestore
    }
    
    var body: some View {

        let label = isGetFirestore ? "Get saved data".localized: "Save current data".localized
        let message = isGetFirestore ? "Overwritten current data?".localized: "Overwritten saved data?".localized
        
        Button(action: {
            myFirestore.isShowAlert = true
        }) {
            Text(label).foregroundColor(.black)
        }
        .alert(label, isPresented: $myFirestore.isShowAlert) {
            //Ok button
            Button("OK".localized, role: .none) {
                isGetFirestore ? myFirestore.getFirestore(): myFirestore.setFirestore()
            }
            //Cancel button
            Button("Cancel".localized, role: .cancel){
                myFirestore.isShowAlert = false
            }
        } message: {
            Text(message)
        }
        .alert(myFirestore.title, isPresented: $myFirestore.isShowMessage) {
            Button("OK".localized, role: .none) {
                myFirestore.isShowMessage = false
                if (myFirestore.isFirestoreSuccess) {
                    if (isGetFirestore) {
                        myTransit.setRoute2()
                        myTransit.setChangeLine()
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(myFirestore.message)
        }
    }
}

struct firestoreButton_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = MyTransit()
        let myFirestore = MyFirestore()
        firestoreButton(myTransit: myTransit, myFirestore: myFirestore, isGetFirestore: true)
    }
}

