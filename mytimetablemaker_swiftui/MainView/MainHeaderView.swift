//
//  MainHeaderView.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/20.
//

import SwiftUI

struct MainHeaderView: View {
    
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

    let primary = Color(DefaultColor.primary.rawValue.colorInt)
    
    var body: some View {
        ZStack{
            primary
            VStack(spacing: 10) {
                HStack{
                    Spacer(minLength: 15)
                    if (mainviewmodel.timeflag) {
                        mainviewmodel.dateTextView
                    } else {
                        datePickerLabelView(mainviewmodel)
                    }
                    Spacer()
                    if (mainviewmodel.timeflag) {
                        mainviewmodel.timeTextView
                    } else {
                        timePickerLabelView(mainviewmodel)
                    }
                    Spacer()
                    Spacer()
                    moveSettingsButton(loginviewmodel, mainviewmodel, firestoreviewmodel)
                    Spacer(minLength: 15)
                }
                stateButtonArray(mainviewmodel)
            }.offset(y: 20)
        }.frame(width: UIScreen.screenWidth, height: 130)
    }
}

struct MainHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let loginviewmodel = LoginViewModel()
        let mainviewmodel = MainViewModel()
        let firestoreviewmodel = FirestoreViewModel()
        MainHeaderView(loginviewmodel, mainviewmodel, firestoreviewmodel)
    }
}
