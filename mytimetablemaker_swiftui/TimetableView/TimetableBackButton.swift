//
//  TimetableBackButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/27.
//

import SwiftUI

struct TimetableBackButton: View {
        
    @State var isBackMainView = false
    
    private let loginviewmodel = LoginViewModel()
    private let mainviewmodel = MainViewModel()
    private let firestoreviewmodel = FirestoreViewModel()

    var body: some View {
        Button(action: {
            isBackMainView = true
        }) {
            ZStack {
                NavigationLink(
                    destination: MainContentView(loginviewmodel, mainviewmodel, firestoreviewmodel),
                    isActive: $isBackMainView,
                    label: {}
                )
            }
        }
    }
}

struct TimetableBackButton_Previews: PreviewProvider {
    static var previews: some View {
        TimetableBackButton()
            .background(Color.black)
    }
}
