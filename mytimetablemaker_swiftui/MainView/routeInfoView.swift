//
//  routeInfoArray.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/23.
//

import SwiftUI

struct routeInfoView: View {
   
    @ObservedObject private var mainviewmodel: MainViewModel

    init(
        _ mainviewmodel: MainViewModel
    ) {
        self.mainviewmodel = mainviewmodel
    }

    var body: some View {

        let goorback1 = mainviewmodel.goorback1
        let goorback2 = mainviewmodel.goorback2
        let weekflag = mainviewmodel.weekFlag
        let currenttime = mainviewmodel.currentHHmmssFromTime
        let departuretime1 = weekflag.departureTime(goorback1, currenttime)
        let departuretime2 = weekflag.departureTime(goorback2, currenttime)
        let width = (goorback2.route2Flag) ? UIScreen.screenWidth/2 - 40: UIScreen.screenWidth - 80

        ScrollView {
            HStack(alignment: .top) {
                
                ScrollView {
                    
                    Spacer(minLength: 15)
                    
                    Text(currenttime.countdownTime(departuretime1))
                        .font(Font.largeTitle.monospacedDigit())
                        .foregroundColor(currenttime.countdownColor(departuretime1))
                    
                    Spacer(minLength: 15)
                    
                    VStack(spacing: 1) {
                        
                        stationAndTime(goorback1, weekflag, currenttime, 1)
                        
                        ForEach(1...goorback1.changeLineInt + 1, id: \.self) { num in
                            transitInfoAlertView(goorback1, num)
                            stationAndTime(goorback1, weekflag, currenttime, 2 * num)
                            lineInfoAlertLabel(goorback1, weekflag, num - 1)
                            stationAndTime(goorback1, weekflag, currenttime, 2 * num + 1)
                        }
                        
                        transitInfoAlertView(goorback1, 0)
                        
                        stationAndTime(goorback1, weekflag, currenttime, 0)
                    }
                }.frame(width: width, alignment: .top)

                if (mainviewmodel.goorback2.route2Flag) {
                    
                    Divider()
                        .frame(width: 1.5, height: UIScreen.screenHeight)
                        .background(Color.myprimary)
                        .padding(.leading, 10.0)
                        .padding(.trailing, 10.0)
                    
                    ScrollView {
                        
                        Spacer(minLength: 15)
                        
                        Text(currenttime.countdownTime(departuretime2))
                            .font(Font.largeTitle.monospacedDigit())
                            .foregroundColor(currenttime.countdownColor(departuretime2))
                        
                        Spacer(minLength: 15)
                        
                        VStack(spacing: 1) {
                            
                            stationAndTime(goorback2, weekflag, currenttime, 1)
                            
                            ForEach(1...goorback2.changeLineInt + 1, id: \.self) { num in
                                transitInfoAlertView(goorback2, num)
                                stationAndTime(goorback2, weekflag, currenttime, 2 * num)
                                lineInfoAlertLabel(goorback2, weekflag, num - 1)
                                stationAndTime(goorback2, weekflag, currenttime, 2 * num + 1)
                            }
                            
                            transitInfoAlertView(goorback2, 0)
                            
                            stationAndTime(goorback2, weekflag, currenttime, 0)
                        }
                    }.frame(width: width, alignment: .top)
                }
            }
        }
    }
}

struct routeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        routeInfoView(mainviewmodel)
    }
}
