//
//  GetFirestoreButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2023/10/09.
//

import SwiftUI

struct GetFirestoreButton: View {
    
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
            Text("Get saved data".localized).foregroundColor(.black)
        }
        .alert("Get saved data".localized, isPresented: $isShowAlert) {
            //Ok button
            Button(textOk, role: .destructive) {
                myFirestore.getFirestore()
            }
            //Cancel button
            Button(textCancel, role: .cancel){
                isShowAlert = false
            }
        } message: {
            Text("Overwritten current data?".localized)
        }
        .alert(myFirestore.title, isPresented: $myFirestore.isShowMessage) {
            Button(textOk, role: .none) {
                myFirestore.isShowMessage = false
                if (myFirestore.isFirestoreSuccess) {
                    myTransit.setRoute2()
                    myTransit.setChangeLine()
                }
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(myFirestore.message)
        }
    }
}

struct GetFirestoreButton_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = MyTransit()
        let myFirestore = MyFirestore()
        GetFirestoreButton(myTransit: myTransit, myFirestore: myFirestore)
    }
}

