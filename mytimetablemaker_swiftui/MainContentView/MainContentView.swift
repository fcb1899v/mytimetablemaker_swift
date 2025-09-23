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
                VStack(alignment: .center, spacing: screen.headerSpace) {

                    HStack(alignment: .center, spacing: screen.headerDateMargin) {

                        // MARK: - Date Display
                        ZStack {
                            Text(myTransfer.dateLabel)
                                .onChange(of: myTransfer.selectDate) {
                                    newValue in myTransfer.dateLabel = "\(newValue.setDate)"
                                }
                            if (myTransfer.isTimeStop) {
                                DatePicker("datepicker", selection: $myTransfer.selectDate,
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                                .opacity(0.1)
                                .frame(width: screen.headerDateHeight, height: screen.headerDateHeight)
                            }
                        }

                        // MARK: - Time Display
                        if (myTransfer.isTimeStop) {
                            ZStack {
                                Text(myTransfer.timeLabel)
                                    .onChange(of: myTransfer.selectDate) {
                                        newValue in myTransfer.timeLabel = "\(newValue.setTime)"
                                    }
                                DatePicker("datepicker", selection: $myTransfer.selectDate,
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .opacity(0.1)
                                .frame(width: screen.headerDateHeight, height: screen.headerDateHeight)
                            }
                        } else {
                            Text(myTransfer.timeLabel)
                                .onAppear {
                                    myTransfer.ensureTimerRunning()
                                }
                                .onDisappear {
                                    myTransfer.stopTimerOnDisappear()
                                }
                        }
                    }
                    .font(.custom("GenEiGothicN-Regular", size: screen.headerDateFontSize))
                    .foregroundColor(.white)
                    .padding(.top, screen.headerTopMargin)
                    
                    // MARK: - Operation Buttons
                    HStack(alignment: .center, spacing: screen.operationButtonMargin) {
                        // Display return route button
                        CustomButton(
                            title: "Back".localized,
                            backgroundColor: myTransfer.isBack ? Color.accent : Color.gray,
                            isEnabled: true,
                            action: myTransfer.backButton
                        )
                        .frame(width: screen.operationButtonWidth, height: screen.operationButtonHeight)
                        
                        // Display outbound route button
                        CustomButton(
                            title: "Go".localized,
                            backgroundColor: !myTransfer.isBack ? Color.accent : Color.gray,
                            isEnabled: true,
                            action: myTransfer.goButton
                        )
                        .frame(width: screen.operationButtonWidth, height: screen.operationButtonHeight)
                        
                        // Time Start Button
                        CustomButton(
                            title: "Start".localized,
                            backgroundColor: !myTransfer.isTimeStop ? Color.accent : Color.gray,
                            isEnabled: true,
                            action: myTransfer.startButton
                        )
                        .frame(width: screen.operationButtonWidth, height: screen.operationButtonHeight)
                        
                        // Time Stop Button
                        CustomButton(
                            title: "Stop".localized,
                            backgroundColor: myTransfer.isTimeStop ? Color.accent : Color.gray,
                            isEnabled: true,
                            action: myTransfer.stopButton
                        )
                        .frame(width: screen.operationButtonWidth, height: screen.operationButtonHeight)
                        // To Settings Button
                        Button(action: {
                            isMoveSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: screen.headerSettingsButtonSize))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, screen.headerSpace)
                }
                .frame(width: screen.bounds.size.width)
                .background(Color.primary)
                .frame(height: screen.headerHeight)
                
                // MARK: - Transfer Information Display
                VStack(alignment: .center) {
                    HStack(alignment: .top) {
                        if(screen.bounds.size.width > 600) { Spacer() }
                        VStack(alignment: .center, spacing: screen.routeBottomSpace) {
                            Spacer().frame(height: screen.routeCountdownTopSpace)
                            Text(myTransfer.countdownTime1)
                                .font(.custom("GenEiGothicN-Regular", size: screen.routeCountdownFontSize))
                                .foregroundColor(myTransfer.countdownColor1)
                                .padding(.vertical, screen.routeCountdownPadding)
                            HomeOfficeView(myTransfer.goOrBack1, 1, myTransfer.timeArrayString1[1])
                            ForEach(0...myTransfer.changeLine1, id: \.self) { num in
                                TransferView(myTransfer.goOrBack1, num + 1)
                                StationLineView(myTransfer.goOrBack1, myTransfer.isWeekday, num, myTransfer.timeArrayString1[2 * num + 2], myTransfer.timeArrayString1[2 * num + 3])
                            }
                            TransferView(myTransfer.goOrBack1, 0)
                            HomeOfficeView(myTransfer.goOrBack1, 0, myTransfer.timeArrayString1[0])
                            Spacer()
                        }
                        .frame(width: myTransfer.routeWidth, alignment: .top)
                        .padding(.horizontal, screen.routeSidePadding)
                        
                        // MARK: - Second Direction Display (if enabled)
                        if (myTransfer.isShowRoute2) {
                            if(screen.bounds.size.width > 600) { Spacer() }
                            Divider()
                                .frame(width: 1.5, height: screen.bounds.size.height - screen.admobBannerHeight - screen.headerHeight)
                                .background(Color.primary)
                            if(screen.bounds.size.width > 600) { Spacer() }
                            VStack(alignment: .center, spacing: screen.routeBottomSpace) {
                                Spacer().frame(height: screen.routeCountdownTopSpace)
                                Text(myTransfer.countdownTime2)
                                    .font(.system(size: screen.routeCountdownFontSize))
                                    .foregroundColor(myTransfer.countdownColor2)
                                    .padding(.vertical, screen.routeCountdownPadding)
                                HomeOfficeView(myTransfer.goOrBack2, 1, myTransfer.timeArrayString2[1])
                                ForEach(0...myTransfer.changeLine2, id: \.self) { num in
                                    TransferView(myTransfer.goOrBack2, num + 1)
                                    StationLineView(myTransfer.goOrBack2, myTransfer.isWeekday, num, myTransfer.timeArrayString2[2 * num + 2], myTransfer.timeArrayString2[2 * num + 3])
                                }
                                TransferView(myTransfer.goOrBack2, 0)
                                HomeOfficeView(myTransfer.goOrBack2, 0, myTransfer.timeArrayString2[0])
                                Spacer()
                            }
                            .frame(width: myTransfer.routeWidth)
                            .padding(.horizontal, screen.routeSidePadding)
                        }
                        if(screen.bounds.size.width > 600) { Spacer() }
                    }
                    
                    // MARK: - Ad Banner
                    AdMobBannerView()
                        .frame(minWidth: screen.admobBannerMinWidth)
                        .frame(width: screen.admobBannerWidth, height: screen.admobBannerHeight)
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
        // SettingsTransferSheetの保存完了を監視してMyTransferのデータを更新
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SettingsTransferUpdated"))) { _ in
            myTransfer.updateAllDataFromUserDefaults()
        }
        // 帰宅/外出の切り替えを監視して全ての表示を更新
        .onChange(of: myTransfer.isBack) { _ in
            myTransfer.updateAllDataFromUserDefaults()
        }
        .onAppear {
            // Ensure timer is running when MainContentView appears
            if myTransfer.isTimeStop {
                myTransfer.startButton()
            }
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

