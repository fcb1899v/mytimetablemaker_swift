//
//  SwiftUIView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/18.
//

import SwiftUI
import FirebaseAuth


struct ContentView: View {
    
    @ObservedObject private var loginviewmodel: LoginViewModel
    @ObservedObject private var mainviewmodel: MainViewModel
    @ObservedObject private var firestoreviewmodel: FirestoreViewModel

    init(
        _ loginviewmodel: LoginViewModel,
        _ mainviewmodel: MainViewModel,
        _ firestoreviewmodel: FirestoreViewModel
    ) {
        self.loginviewmodel = loginviewmodel
        self.mainviewmodel = mainviewmodel
        self.firestoreviewmodel = firestoreviewmodel
    }

    var body: some View {
        if "Login".userDefaultsBool(false) {
            MainContentView(loginviewmodel, mainviewmodel, firestoreviewmodel)
            
        } else {
            LoginContentView(loginviewmodel, mainviewmodel, firestoreviewmodel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let loginviewmodel = LoginViewModel()
        let mainviewmodel = MainViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        ContentView(loginviewmodel, mainviewmodel, firestoreviewmodel)
    }
}
