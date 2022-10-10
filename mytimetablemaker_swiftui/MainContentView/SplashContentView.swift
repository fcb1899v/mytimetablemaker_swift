//
//  MainContentView.swift
//  mytimetablemaker_swiftui
//  Created by Nakajima Masao on 2020/12/25.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

struct MainContentView: View {

    @ObservedObject private var myTransit: MyTransit
    @ObservedObject private var settings1: Settings
    @ObservedObject private var settings2: Settings
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore

    @State private var isShowSplash = true
    @State private var isMoveSettings = false
    @State private var timer = Timer.publish(every: 1.0, on: .current, in: .common).autoconnect()

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
        self.timer = Timer.publish(every: 1.0, on: .current, in: .common).autoconnect()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        requestAppTrackingTransparencyAuthorization()
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
        requestAppTrackingTransparencyAuthorization()
    }
    
    var body: some View {
        
        NavigationView {
            ZStack {
                //MainView
                VStack {
                    //Header
                    ZStack {
                        //BackgroundColor of header
                        Color.primaryColor
                        //Header Menu
                        VStack(spacing: headerSpace) {
                            HStack{
                                Spacer()
                                HStack {
                                    Spacer()
                                    //Date
                                    if (myTransit.isTimeStop) {
                                        ZStack {
                                            Text(myTransit.dateLabel)
                                                .font(.custom("GenEiGothicN-Regular", size: headerDateFontSize))
                                                .onChange(of: myTransit.selectDate) {
                                                    newValue in myTransit.dateLabel = "\(newValue.setDate)"
                                                }
                                            DatePicker("datepicker", selection: $myTransit.selectDate,
                                                displayedComponents: .date
                                            )
                                            .labelsHidden()
                                            .opacity(0.1)
                                            .frame(width: headerDateHeight, height: headerDateHeight)
                                        }
                                    } else {
                                        Text(myTransit.dateLabel)
                                            .font(.custom("GenEiGothicN-Regular", size: headerDateFontSize))
                                            .onReceive(timer) { _ in myTransit.updateDateLabels() }
                                            .onDisappear { timer.upstream.connect().cancel() }
                                    }
                                    Spacer()
                                    //Time
                                    if (myTransit.isTimeStop) {
                                        ZStack {
                                            Text(myTransit.timeLabel)
                                                .font(.custom("GenEiGothicN-Regular", size: headerDateFontSize))
                                                .onChange(of: myTransit.selectDate) {
                                                    newValue in myTransit.timeLabel = "\(newValue.setTime)"
                                                }
                                            DatePicker("datepicker", selection: $myTransit.selectDate,
                                                displayedComponents: .hourAndMinute
                                            )
                                            .labelsHidden()
                                            .opacity(0.1)
                                            .frame(width: headerDateHeight, height: headerDateHeight)
                                        }
                                    } else {
                                        Text(myTransit.timeLabel)
                                            .font(.custom("GenEiGothicN-Regular", size: headerDateFontSize))
                                            .onReceive(timer) { _ in myTransit.updateDateLabels() }
                                            .onDisappear { timer.upstream.connect().cancel() }
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                            .font(.system(size: headerDateFontSize))
                            .foregroundColor(Color.white)
                            .padding(.top, headerTopMargin)
                            
                            HStack {
                                Spacer().frame(width: operationButtonSidePadding)
                                HStack {
                                    //Display going home route button
                                    operationButton(isOn: myTransit.isBack, label: "Back".localized,
                                        action: myTransit.backButtonChangeData
                                    )
                                    Spacer().frame(width: operationButtonMargin)
                                    //Display outgoing route button
                                    operationButton(isOn: !myTransit.isBack, label: "Go".localized,
                                        action: myTransit.goButtonChangeData
                                    )
                                    Spacer().frame(width: operationButtonMargin)
                                    //Time Start Button
                                    operationButton(isOn: !myTransit.isTimeStop, label: "Start".localized,
                                        action: myTransit.startButtonChangeData
                                    )
                                    Spacer().frame(width: operationButtonMargin)
                                    //Time Stop Button
                                    operationButton(isOn: myTransit.isTimeStop, label: "Stop".localized,
                                        action: myTransit.stopButtonChangeData
                                    )
                                    Spacer().frame(width: operationButtonMargin)
                                    //To Settings Button
                                    Button(action: {
                                        isMoveSettings = true
                                    }) {
                                        ZStack {
                                            Image("ic_settings1")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: operationSettingsBottonSize)
                                            NavigationLink(
                                                destination: SettingsContentView(myTransit, myLogin, myFirestore),
                                                isActive: $isMoveSettings,
                                                label: {}
                                            )
                                        }.frame(width: operationSettingsBottonSize, height: operationSettingsBottonSize)
                                    }
                                }
                                Spacer().frame(width: operationButtonSidePadding)
                            }
                            .padding(.bottom, headerSpace)
                        }
                    }.frame(height: headerHeight)

                    //My Transit
                    ZStack {
                        //Background of my transit
                        Color.white
                        //My transit view
                        VStack(alignment: .center) {
                            
                            HStack(alignment: .top) {
                                
                                if(screenWidth > 600) { Spacer() }

                                VStack(alignment: .center, spacing: routeBottomSpace) {
                                    Spacer().frame(height: routeCountdownTopSpace)
                                    Text(myTransit.currentTime.countdownTime(
                                        CalcTime(myTransit.goOrBack1, myTransit.isWeekday).departureTime(myTransit.currentTime)
                                    ))
                                    .font(.custom("GenEiGothicN-Regular", size: routeCountdownFontSize))
                                    .foregroundColor(myTransit.currentTime.countdownColor(
                                        CalcTime(myTransit.goOrBack1, myTransit.isWeekday)
                                            .departureTime(myTransit.currentTime)
                                    ))
                                    .padding(routeCountdownPadding)
                                    stationAndTime(myTransit.goOrBack1, myTransit.isWeekday, myTransit.currentTime, 1)
                                    ForEach(1...settings1.settingChangeLine + 1, id: \.self) { num in
                                        transitInfomation(myTransit.goOrBack1, num)
                                        stationAndTime(myTransit.goOrBack1, myTransit.isWeekday, myTransit.currentTime, 2 * num)
                                        lineInfomation(myTransit.goOrBack1, myTransit.isWeekday, num - 1)
                                        stationAndTime(myTransit.goOrBack1, myTransit.isWeekday, myTransit.currentTime, 2 * num + 1)
                                    }
                                    transitInfomation(myTransit.goOrBack1, 0)
                                    stationAndTime(myTransit.goOrBack1, myTransit.isWeekday, myTransit.currentTime, 0)
                                    Spacer()
                                }.onAppear() {
                                    settings1.getChangeLine()
                                }
                                .frame(width: myTransit.routeWidth, alignment: .top)
                                .padding(.horizontal, routeSidePadding)

                                if (myTransit.isShowRoute2) {
                                    
                                    if(screenWidth > 600) { Spacer() }
                                    
                                    Divider()
                                        .frame(width: 1.5, height: routeHeight - 10)
                                        .background(Color.primaryColor)
                                    
                                    if(screenWidth > 600) { Spacer() }
                                    
                                    VStack(alignment: .center, spacing: routeBottomSpace) {
                                        Spacer().frame(height: routeCountdownTopSpace)
                                        Text(myTransit.currentTime.countdownTime(
                                            CalcTime(myTransit.goOrBack2, myTransit.isWeekday).departureTime(myTransit.currentTime)
                                        ))
                                        .font(.system(size: routeCountdownFontSize))
                                        .foregroundColor(myTransit.currentTime.countdownColor(
                                            CalcTime(myTransit.goOrBack2,myTransit.isWeekday)
                                                .departureTime(myTransit.currentTime)
                                            ))
                                        .padding(routeCountdownPadding)
                                        stationAndTime(myTransit.goOrBack2, myTransit.isWeekday, myTransit.currentTime, 1)
                                        ForEach(1...settings2.settingChangeLine + 1, id: \.self) { num in
                                            transitInfomation(myTransit.goOrBack2, num)
                                            stationAndTime(myTransit.goOrBack2, myTransit.isWeekday, myTransit.currentTime, 2 * num)
                                            lineInfomation(myTransit.goOrBack2, myTransit.isWeekday, num - 1)
                                            stationAndTime(myTransit.goOrBack2, myTransit.isWeekday, myTransit.currentTime, 2 * num + 1)
                                        }
                                        transitInfomation(myTransit.goOrBack2, 0)
                                        stationAndTime(myTransit.goOrBack2, myTransit.isWeekday, myTransit.currentTime, 0)
                                        Spacer()
                                    }.onAppear() {
                                        settings2.getChangeLine()
                                    }
                                    .frame(width: myTransit.routeWidth)
                                    .padding(.horizontal, routeSidePadding)
                                }

                                if(screenWidth > 600) { Spacer() }
                            }
                            
                            Rectangle()
                                .foregroundColor(Color.primary)
                                .frame(width: screenWidth, height: 1.5)
                                .offset(y: -5)
                            //Admob
                            AdMobBannerView()
                                .frame(minWidth: admobBannerMinWidth)
                                .frame(width: admobBannerWidth, height: admobBannerHeight)
                        }
                    }
                }
                
                //Splash
                ZStack {
                    Color.accentColor
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding(.bottom, 100)
                    VStack {
                        Spacer()
                        Image("splash")
                            .resizable()
                            .scaledToFit()
                            .padding(0)
                            .frame(width: screenWidth)
                    }.frame(width: screenWidth)
                }
                .opacity(isShowSplash ? 1: 0)
                .frame(width: screenWidth, height: screenHeight)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation() {
                            self.isShowSplash = false
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = MyTransit()
        let settings1 = Settings(myTransit.goOrBack1)
        let settings2 = Settings(myTransit.goOrBack2)
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        MainContentView(myTransit, settings1, settings2, myLogin, myFirestore)
    }
}

private func requestAppTrackingTransparencyAuthorization() {
    guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            // リクエスト後の状態に応じた処理を行う
        })
    }
}
