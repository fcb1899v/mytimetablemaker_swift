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
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore

    init(
        _ myTransit: MyTransit,
        _ myLogin: MyLogin,
        _ myFirestore: MyFirestore
    ) {
        self.myTransit = myTransit
        self.myLogin = myLogin
        self.myFirestore = myFirestore
        self.toTracking()
    }

    var body: some View {
        SplashContentView(myTransit, myLogin, myFirestore)
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
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        ContentView(myTransit, myLogin, myFirestore)
    }
}
