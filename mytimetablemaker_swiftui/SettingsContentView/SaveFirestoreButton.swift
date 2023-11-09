//
//  SetFirestoreButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2023/10/09.
//

import SwiftUI

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
        .alert("Save current data".localized, isPresented: $isShowAlert) {
            //Ok button
            Button(textOk, role: .destructive) {
                myFirestore.setFirestore()
                isShowAlert = false
            }
            //Cancel button
            Button(textCancel, role: .cancel){
                isShowAlert = false
            }
        } message: {
            Text("Overwritten saved data?".localized)
        }
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

struct SetFirestoreButton_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = MyTransit()
        let myFirestore = MyFirestore()
        SetFirestoreButton(myTransit: myTransit, myFirestore: myFirestore)
    }
}


