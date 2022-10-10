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
    
    @ObservedObject private var myTransit: MyTransit
    @ObservedObject private var settings1: Settings
    @ObservedObject private var settings2: Settings
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore

    init(
        _ myTransit: MyTransit,
        _ settings1: Settings,
        _ settings2: Settings,
        _ myLogin: MyLogin,
        _ myFirestore: MyFirestore
    ) {
        self.myTransit = myTransit
        self.settings1 = Settings(myTransit.goOrBack1)
        self.settings2 = Settings(myTransit.goOrBack2)
        self.myLogin = myLogin
        self.myFirestore = myFirestore
        self.toTracking()
    }

    var body: some View {
        MainContentView(myTransit, settings1, settings2, myLogin, myFirestore)
            .preferredColorScheme(.light)
    }
    
    private func toTracking(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = MyTransit()
        let settings1 = Settings(myTransit.goOrBack1)
        let settings2 = Settings(myTransit.goOrBack2)
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        ContentView(myTransit, settings1, settings2, myLogin, myFirestore)
    }
}
