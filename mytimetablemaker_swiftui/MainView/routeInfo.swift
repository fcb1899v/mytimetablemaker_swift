//
//  routeInfo.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/06.
//

import SwiftUI

struct routeInfo1: View {
    
    @ObservedObject private var mainviewmodel: MainViewModel

    init(
        _ mainviewmodel: MainViewModel
    ) {
        self.mainviewmodel = mainviewmodel
    }
    
    private let gray = Color(DefaultColor.gray.rawValue.colorInt)

    var body: some View {
        
        let goorback = mainviewmodel.goorback1
        let weekflag = mainviewmodel.weekFlag
        let currenttime = mainviewmodel.currentHHmmssFromTime
        let width = (mainviewmodel.goorback2.route2Flag) ? UIScreen.screenWidth/2 - 40: UIScreen.screenWidth - 80
        
        ScrollView {
            Spacer(minLength: 15)
            countdownLabel(goorback, weekflag, currenttime)
            Spacer(minLength: 15)
            VStack(spacing: 1) {
                departPointAndTime(goorback, weekflag, currenttime)
                ForEach(0...goorback.changeLineInt, id: \.self) { num in
                    transitInfoAlertView(goorback, num + 1)
                    departStationAndTime(goorback, weekflag, currenttime, num)
                    lineInfoAlertLabel(goorback, weekflag, num)
                    arriveStationAndTime(goorback, weekflag, currenttime, num)
                }
                transitInfoAlertView(goorback, 0)
                destinationAndTime(goorback, weekflag, currenttime)
            }
        }.frame(width: width, alignment: .top)
    }
}

struct routeInfo2: View {
    
    @ObservedObject private var mainviewmodel: MainViewModel

    init(
        _ mainviewmodel: MainViewModel
    ) {
        self.mainviewmodel = mainviewmodel
    }
    
    private let gray = Color(DefaultColor.gray.rawValue.colorInt)

    var body: some View {
        
        let goorback = mainviewmodel.goorback2
        let weekflag = mainviewmodel.weekFlag
        let currenttime = mainviewmodel.currentHHmmssFromTime
        let width = (goorback.route2Flag) ? UIScreen.screenWidth/2 - 40: UIScreen.screenWidth - 80
        
        ScrollView {
            Spacer(minLength: 15)
            countdownLabel(goorback, weekflag, currenttime)
            Spacer(minLength: 15)
            VStack(spacing: 1) {
                departPointAndTime(goorback, weekflag, currenttime)
                ForEach(0...goorback.changeLineInt, id: \.self) { num in
                    transitInfoAlertView(goorback, num + 1)
                    departStationAndTime(goorback, weekflag, currenttime, num)
                    lineInfoAlertLabel(goorback, weekflag, num)
                    arriveStationAndTime(goorback, weekflag, currenttime, num)
                }
                transitInfoAlertView(goorback, 0)
                destinationAndTime(goorback, weekflag, currenttime)
            }
        }.frame(width: width, alignment: .top)
    }
}


struct routeInfo_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        routeInfo1(mainviewmodel)
    }
}

