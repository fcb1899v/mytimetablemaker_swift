//
//  MainContentView.swift
//  mytimetablemaker_swiftui
//  Created by Nakajima Masao on 2020/12/25.
//

import SwiftUI
import GoogleMobileAds


struct MainContentView: View {

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

    @State private var showSplash = true
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    MainHeaderView(loginviewmodel, mainviewmodel, firestoreviewmodel)
                    ZStack {
                        Color.white
                        VStack {
                            routeInfoView(mainviewmodel)
                            Rectangle()
                                .foregroundColor(Color.primary)
                                .frame(width: .screenwidth, height: 1.5)
                                .offset(y: -10)
                            AdMobView()
                        }
                    }
                }
                LoginBackgroundView()
                    .opacity(showSplash ? 1 : 0)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation() {
                                self.showSplash = false
                            }
                        }
                    }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        let mainviewmodel = MainViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        MainContentView(loginviewmodel, mainviewmodel, firestoreviewmodel)
    }
}


