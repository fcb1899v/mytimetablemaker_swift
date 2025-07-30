//
//  MainContentView.swift
//  mytimetablemaker_swiftui
//  Created by Masao Nakajima on 2020/12/25.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

// MARK: - Main Content View
// Primary view displaying transit information, timetables, and navigation controls
struct MainContentView: View {

    @ObservedObject private var myTransit: MyTransit
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore

    @State private var isShowSplash = true
    @State private var isMoveSettings = false

    init(
        _ myTransit: MyTransit,
        _ myLogin: MyLogin,
        _ myFirestore: MyFirestore
    ) {
        self.myTransit = myTransit
        self.myLogin = myLogin
        self.myFirestore = myFirestore
    }

    // MARK: - App Tracking Transparency
    // Handles app tracking transparency authorization requests
    private func applicationDidBecomeActive(_ application: UIApplication) {
        requestAppTrackingTransparencyAuthorization()
    }
    
    private func sceneDidBecomeActive(_ scene: UIScene) {
        requestAppTrackingTransparencyAuthorization()
    }
    
    private func requestAppTrackingTransparencyAuthorization() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            })
        }
    }
    
    var body: some View {
        NavigationView {
            // MARK: - Main View Layout
            VStack {
                // MARK: - Header Section
                VStack(spacing: headerSpace) {
                    HStack{
                        Spacer()
                        HStack {
                            Spacer()
                            // MARK: - Date Display
                            ZStack {
                                Text(myTransit.dateLabel)
                                    .font(.custom("GenEiGothicN-Regular", size: headerDateFontSize))
                                    .onChange(of: myTransit.selectDate) {
                                        newValue in myTransit.dateLabel = "\(newValue.setDate)"
                                    }
                                if (myTransit.isTimeStop) {
                                    DatePicker("datepicker", selection: $myTransit.selectDate,
                                        displayedComponents: .date
                                    )
                                    .labelsHidden()
                                    .opacity(0.1)
                                    .frame(width: headerDateHeight, height: headerDateHeight)
                                }
                            }
                            Spacer()
                            // MARK: - Time Display
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
                                    .onAppear { myTransit.startButton() }
                                    .onDisappear { myTransit.stopButton() }
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .font(.system(size: headerDateFontSize))
                    .foregroundColor(Color.white)
                    .padding(.top, headerTopMargin)
                    
                    // MARK: - Operation Buttons
                    HStack {
                        HStack(spacing: operationButtonMargin) {
                            // Display going home route button
                            operationButton(isOn: myTransit.isBack, label: textBack, action: myTransit.backButton)
                            // Display outgoing route button
                            operationButton(isOn: !myTransit.isBack, label: textGo, action: myTransit.goButton)
                            // Time Start Button
                            operationButton(isOn: !myTransit.isTimeStop, label: textStart, action: myTransit.startButton)
                            // Time Stop Button
                            operationButton(isOn: myTransit.isTimeStop, label: textStop, action: myTransit.stopButton)
                            // To Settings Button
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
                    }
                    .padding(.bottom, headerSpace)
                }
                .background(Color.primaryColor)
                .frame(height: headerHeight)
                
                // MARK: - Transit Information Display
                VStack(alignment: .center) {
                    HStack(alignment: .top) {
                        if(screenWidth > 600) { Spacer() }
                        VStack(alignment: .center, spacing: routeBottomSpace) {
                            Spacer().frame(height: routeCountdownTopSpace)
                            Text(myTransit.countdownTime1)
                                .font(.custom("GenEiGothicN-Regular", size: routeCountdownFontSize))
                                .foregroundColor(myTransit.countdownColor1)
                                .padding(.vertical, routeCountdownPadding)
                            stationAndTime(myTransit.goOrBack1, 1, myTransit.timeArrayString1[1])
                            ForEach(0...myTransit.changeLine1, id: \.self) { num in
                                transitInfomation(myTransit.goOrBack1, num + 1)
                                stationAndTime(myTransit.goOrBack1, 2 * num + 2, myTransit.timeArrayString1[2 * num + 2])
                                lineInfomation(myTransit.goOrBack1, myTransit.isWeekday, num)
                                stationAndTime(myTransit.goOrBack1, 2 * num + 3, myTransit.timeArrayString1[2 * num + 3])
                            }
                            transitInfomation(myTransit.goOrBack1, 0)
                            stationAndTime(myTransit.goOrBack1, 0, myTransit.timeArrayString1[0])
                            Spacer()
                        }
                        .frame(width: myTransit.routeWidth, alignment: .top)
                        .padding(.horizontal, routeSidePadding)
                        
                        // MARK: - Second Route Display (if enabled)
                        if (myTransit.isShowRoute2) {
                            if(screenWidth > 600) { Spacer() }
                            Divider()
                                .frame(width: 1.5, height: routeHeight)
                                .background(Color.primaryColor)
                            if(screenWidth > 600) { Spacer() }
                            VStack(alignment: .center, spacing: routeBottomSpace) {
                                Spacer().frame(height: routeCountdownTopSpace)
                                Text(myTransit.countdownTime2)
                                    .font(.system(size: routeCountdownFontSize))
                                    .foregroundColor(myTransit.countdownColor2)
                                    .padding(.vertical, routeCountdownPadding)
                                stationAndTime(myTransit.goOrBack2, 1, myTransit.timeArrayString2[1])
                                ForEach(0...myTransit.changeLine2, id: \.self) { num in
                                    transitInfomation(myTransit.goOrBack2, num + 1)
                                    stationAndTime(myTransit.goOrBack2, 2 * num + 2, myTransit.timeArrayString2[2 * num + 2])
                                    lineInfomation(myTransit.goOrBack2, myTransit.isWeekday, num)
                                    stationAndTime(myTransit.goOrBack2, 2 * num + 3, myTransit.timeArrayString2[2 * num + 3])
                                }
                                transitInfomation(myTransit.goOrBack2, 0)
                                stationAndTime(myTransit.goOrBack2, 0, myTransit.timeArrayString2[0])
                                Spacer()
                            }
                            .frame(width: myTransit.routeWidth)
                            .padding(.horizontal, routeSidePadding)
                        }
                        if(screenWidth > 600) { Spacer() }
                    }
                    Rectangle()
                        .foregroundColor(Color.primary)
                        .frame(width: screenWidth, height: 1.5)
                    
                    // MARK: - Ad Banner
                    AdMobBannerView()
                        .frame(minWidth: admobBannerMinWidth)
                        .frame(width: admobBannerWidth, height: admobBannerHeight)
                        .background(.white)
                }
            }
            .background(.white)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = MyTransit()
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        MainContentView(myTransit, myLogin, myFirestore)
    }
}

