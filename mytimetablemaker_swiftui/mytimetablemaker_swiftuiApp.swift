//
//  mytimetablemaker_swiftuiApp.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/06.
//

import SwiftUI

@main
struct mytimetablemaker_swiftuiApp: App {
    //let persistenceController = PersistenceController.shared

    var body: some Scene {
        let loginviewmodel = LoginViewModel()
        let mainviewmodel = MainViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        WindowGroup {
            MainContentView(loginviewmodel, mainviewmodel, firestoreviewmodel)
        }
    }
}
