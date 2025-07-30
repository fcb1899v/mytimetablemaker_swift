//
//  TimetableBackButton.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/04/27.
//

import SwiftUI

// MARK: - Timetable Back Button
// Navigation button to return to main content view from timetable screen
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

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct TimetableBackButton_Previews: PreviewProvider {
    static var previews: some View {
        TimetableBackButton()
            .background(Color.black)
    }
}
