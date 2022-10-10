//
//  SwiftUIView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/18.
//

import SwiftUI
import FirebaseAuth
import AppTrackingTransparency
import AdSupport
import GoogleMobileAds

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
        self.toTracking()
    }

    var body: some View {
        if "Login".userDefaultsBool(false) {
            MainContentView(loginviewmodel, mainviewmodel, firestoreviewmodel)
                .preferredColorScheme(.light)
        } else {
            LoginContentView(loginviewmodel, mainviewmodel, firestoreviewmodel)
                .preferredColorScheme(.light)
        }
    }
    
    private func toTracking(){
        
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                })
            }
        } else {
            // Fallback on earlier versions
            GADMobileAds.sharedInstance().start(completionHandler: nil)
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
