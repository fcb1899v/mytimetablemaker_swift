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
            departPointAndTime(goorback, weekflag, currenttime)
            Spacer(minLength: 1)
            ForEach(0...goorback.changeLineInt, id: \.self) { num in
                HStack {
                    transitTimeAlertView(goorback, num + 1)
                    transportPickerLabel(goorback, num + 1)
                    Spacer()
                }
                Spacer(minLength: 1)
                departStationAndTime(goorback, weekflag, currenttime, num)
                Spacer(minLength: 1)
                HStack {
                    lineColorAlertView(goorback, weekflag, num)
                    lineNameAlertLabel(goorback, num)
                }
                Spacer(minLength: 1)
                arriveStationAndTime(goorback, weekflag, currenttime, num)
                Spacer(minLength: 1)
            }
            HStack {
                transitTimeAlertView(goorback, 0)
                transportPickerLabel(goorback, 0)
                Spacer()
            }
            Spacer(minLength: 1)
            destinationAndTime(goorback, weekflag, currenttime)
            Spacer(minLength: 1)
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
            departPointAndTime(goorback, weekflag, currenttime)
            Spacer(minLength: 1)
            ForEach(0...goorback.changeLineInt, id: \.self) { num in
                HStack {
                    transitTimeAlertView(goorback, num + 1)
                    transportPickerLabel(goorback, num + 1)
                    Spacer()
                }
                Spacer(minLength: 1)
                departStationAndTime(goorback, weekflag, currenttime, num)
                Spacer(minLength: 1)
                HStack {
                    lineColorAlertView(goorback, weekflag, num)
                    lineNameAlertLabel(goorback, num)
                }
                Spacer(minLength: 1)
                arriveStationAndTime(goorback, weekflag, currenttime, num)
                Spacer(minLength: 1)
            }
            HStack {
                transitTimeAlertView(goorback, 0)
                transportPickerLabel(goorback, 0)
                Spacer()
            }
            Spacer(minLength: 1)
            destinationAndTime(goorback, weekflag, currenttime)
            Spacer(minLength: 1)
        }.frame(width: width, alignment: .top)
    }
}


struct routeInfo_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        routeInfo1(mainviewmodel)
    }
}

