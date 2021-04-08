//
//  routeInfo.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/06.
//

import SwiftUI

struct routeInfo: View {
    
    @ObservedObject private var mainviewmodel: MainViewModel
    private let goorback: String

    init(
        _ mainviewmodel: MainViewModel,
        _ goorback: String
    ) {
        self.mainviewmodel = mainviewmodel
        self.goorback = goorback
    }
    
    private let gray = Color(DefaultColor.gray.rawValue.colorInt)

    var body: some View {
        
        let weekflag = mainviewmodel.weekFlag
        let currenttime = mainviewmodel.currentHHmmssFromTime
        let width = (mainviewmodel.goorback2.route2Flag) ? UIScreen.screenWidth/2 - 25: UIScreen.screenWidth - 125
        
        ScrollView {
            Spacer(minLength: 15)
            countdownLabel(mainviewmodel, goorback)
            Spacer(minLength: 15)
            departPointAndTime(goorback, weekflag.displayTimeArray(goorback, currenttime)[1])
            Spacer(minLength: 2)
            ForEach(0...goorback.changeLineInt, id: \.self) { num in
                departAndArriveTime(mainviewmodel, goorback, num)
            }
            transitTimeAndName(goorback, "e")
            Spacer(minLength: 2)
            destinationAndTime(goorback, weekflag.displayTimeArray(goorback, currenttime)[0])
            Spacer(minLength: 2)
        }.frame(width: width, alignment: .top)
    }
}

struct routeInfo_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        routeInfo(mainviewmodel, "back1")
    }
}

