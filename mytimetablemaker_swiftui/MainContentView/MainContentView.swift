//
//  MainContentView.swift
//  mytimetablemaker_swiftui
//  Created by Masao Nakajima on 2020/12/25.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

// MARK: - Main Content View
// Primary view displaying transfer information, timetables, and navigation controls
struct MainContentView: View {

    @ObservedObject private var myTransfer: MyTransfer
    @ObservedObject private var myLogin: MyLogin
    @ObservedObject private var myFirestore: MyFirestore

    @State private var isShowSplash = true
    @State private var isMoveSettings = false

    init(
        _ myTransfer: MyTransfer,
        _ myLogin: MyLogin,
        _ myFirestore: MyFirestore
    ) {
        self.myTransfer = myTransfer
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
        NavigationStack {
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
                                Text(myTransfer.dateLabel)
                                    .font(.custom("GenEiGothicN-Regular", size: headerDateFontSize))
                                    .onChange(of: myTransfer.selectDate) {
                                        newValue in myTransfer.dateLabel = "\(newValue.setDate)"
                                    }
                                if (myTransfer.isTimeStop) {
                                    DatePicker("datepicker", selection: $myTransfer.selectDate,
                                        displayedComponents: .date
                                    )
                                    .labelsHidden()
                                    .opacity(0.1)
                                    .frame(width: headerDateHeight, height: headerDateHeight)
                                }
                            }
                            Spacer()
                            // MARK: - Time Display
                            if (myTransfer.isTimeStop) {
                                ZStack {
                                    Text(myTransfer.timeLabel)
                                        .font(.custom("GenEiGothicN-Regular", size: headerDateFontSize))
                                        .onChange(of: myTransfer.selectDate) {
                                            newValue in myTransfer.timeLabel = "\(newValue.setTime)"
                                        }
                                    DatePicker("datepicker", selection: $myTransfer.selectDate,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .labelsHidden()
                                    .opacity(0.1)
                                    .frame(width: headerDateHeight, height: headerDateHeight)
                                }
                            } else {
                                Text(myTransfer.timeLabel)
                                    .font(.custom("GenEiGothicN-Regular", size: headerDateFontSize))
                                    .onAppear { myTransfer.startButton() }
                                    .onDisappear { myTransfer.stopButton() }
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
                            operationButton(isOn: myTransfer.isBack, label: textBack, action: myTransfer.backButton)
                            // Display outgoing route button
                            operationButton(isOn: !myTransfer.isBack, label: textGo, action: myTransfer.goButton)
                            // Time Start Button
                            operationButton(isOn: !myTransfer.isTimeStop, label: textStart, action: myTransfer.startButton)
                            // Time Stop Button
                            operationButton(isOn: myTransfer.isTimeStop, label: textStop, action: myTransfer.stopButton)
                            // To Settings Button
                            Button(action: {
                                isMoveSettings = true
                            }) {
                                ZStack {
                                    Image("ic_settings1")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: operationSettingsBottonSize)
                                }.frame(width: operationSettingsBottonSize, height: operationSettingsBottonSize)
                            }
                        }
                    }
                    .padding(.bottom, headerSpace)
                }
                .background(Color.primaryColor)
                .frame(height: headerHeight)
                
                // MARK: - Transfer Information Display
                VStack(alignment: .center) {
                    HStack(alignment: .top) {
                        if(screenWidth > 600) { Spacer() }
                        VStack(alignment: .center, spacing: routeBottomSpace) {
                            Spacer().frame(height: routeCountdownTopSpace)
                            Text(myTransfer.countdownTime1)
                                .font(.custom("GenEiGothicN-Regular", size: routeCountdownFontSize))
                                .foregroundColor(myTransfer.countdownColor1)
                                .padding(.vertical, routeCountdownPadding)
                            stationAndTime(myTransfer.goOrBack1, 1, myTransfer.timeArrayString1[1])
                            ForEach(0...myTransfer.changeLine1, id: \.self) { num in
                                TransferInfomation(myTransfer.goOrBack1, num + 1)
                                LineAndStation(myTransfer.goOrBack1, myTransfer.isWeekday, num, myTransfer.timeArrayString1[2 * num + 2], myTransfer.timeArrayString1[2 * num + 3])
                            }
                            TransferInfomation(myTransfer.goOrBack1, 0)
                            stationAndTime(myTransfer.goOrBack1, 0, myTransfer.timeArrayString1[0])
                            Spacer()
                        }
                        .frame(width: myTransfer.routeWidth, alignment: .top)
                        .padding(.horizontal, routeSidePadding)
                        
                        // MARK: - Second Route Display (if enabled)
                        if (myTransfer.isShowRoute2) {
                            if(screenWidth > 600) { Spacer() }
                            Divider()
                                .frame(width: 1.5, height: routeHeight)
                                .background(Color.primaryColor)
                            if(screenWidth > 600) { Spacer() }
                            VStack(alignment: .center, spacing: routeBottomSpace) {
                                Spacer().frame(height: routeCountdownTopSpace)
                                Text(myTransfer.countdownTime2)
                                    .font(.system(size: routeCountdownFontSize))
                                    .foregroundColor(myTransfer.countdownColor2)
                                    .padding(.vertical, routeCountdownPadding)
                                stationAndTime(myTransfer.goOrBack2, 1, myTransfer.timeArrayString2[1])
                                ForEach(0...myTransfer.changeLine2, id: \.self) { num in
                                    TransferInfomation(myTransfer.goOrBack2, num + 1)
                                    LineAndStation(myTransfer.goOrBack2, myTransfer.isWeekday, num, myTransfer.timeArrayString2[2 * num + 2], myTransfer.timeArrayString2[2 * num + 3])
                                }
                                TransferInfomation(myTransfer.goOrBack2, 0)
                                stationAndTime(myTransfer.goOrBack2, 0, myTransfer.timeArrayString2[0])
                                Spacer()
                            }
                            .frame(width: myTransfer.routeWidth)
                            .padding(.horizontal, routeSidePadding)
                        }
                        if(screenWidth > 600) { Spacer() }
                    }
                    Rectangle()
                        .foregroundColor(Color.primaryColor)
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
        .navigationDestination(isPresented: $isMoveSettings) {
            SettingsContentView(myTransfer, myLogin, myFirestore)
        }
        .navigationBarBackButtonHidden(true)
        // SettingsLineSheetの保存完了を監視してMyTransferのデータを更新
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SettingsLineUpdated"))) { _ in
            myTransfer.updateAllDataFromUserDefaults()
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransfer = MyTransfer()
        let myLogin = MyLogin()
        let myFirestore = MyFirestore()
        MainContentView(myTransfer, myLogin, myFirestore)
    }
}

