//
//  MainContentView.swift
//  mytimetablemaker_swiftui
//  Created by Nakajima Masao on 2020/12/25.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

// MARK: - Main Content View
// Primary view displaying transfer information, timetables, and navigation controls
struct MainContentView: View {

    @ObservedObject private var myTransfer: TransferViewModel
    @ObservedObject private var myLogin: LoginViewModel
    @ObservedObject private var myFirestore: FirestoreViewModel

    @State private var isShowSplash = true
    @State private var isMoveSettings = false
    // Centralize sheet states to avoid per-row @State scatter.
    // Selected route/row are captured via active* before presenting sheets.
    @State private var activeTransferNum: Int? = nil
    @State private var activeGoorback: String? = nil
    @State private var isShowingLineSheet: Bool = false
    @State private var isShowingTransferSheet: Bool = false
    // Computed values for sheet initialization to ensure correct values are captured
    @State private var sheetGoorback: String = ""
    @State private var sheetLineIndex: Int = 0

    init(
        _ myTransfer: TransferViewModel,
        _ myLogin: LoginViewModel,
        _ myFirestore: FirestoreViewModel
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
            VStack(spacing: 0) {
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
                HStack(alignment: .top) {
                    if(screen.screenWidth > 600) { Spacer() }
                    VStack(alignment: .center, spacing: screen.routeBottomSpace) {
                        Spacer().frame(height: screen.routeCountdownTopSpace)
                        Text(myTransfer.countdownTime1)
                            .font(.custom("GenEiGothicN-Regular", size: screen.routeCountdownFontSize))
                            .foregroundColor(myTransfer.countdownColor1)
                            .padding(.vertical, screen.routeCountdownPadding)
                            .frame(height: screen.routeCountdownFontSize + screen.routeCountdownPadding * 2, alignment: .center)
                        HomeOfficeView(myTransfer.goOrBack1, 1)
                        ForEach(0...myTransfer.changeLine1, id: \.self) { num in
                            TransferView(myTransfer.goOrBack1, num + 1)
                            StationLineView(myTransfer.goOrBack1, num)
                        }
                        TransferView(myTransfer.goOrBack1, 0)
                        HomeOfficeView(myTransfer.goOrBack1, 0)
                        Spacer()
                    }
                    .frame(width: myTransfer.routeWidth, alignment: .top)
                    .padding(.horizontal, screen.routeSidePadding)
                    
                    // MARK: - Second Direction Display (if enabled)
                    if (myTransfer.isShowRoute2) {
                        Divider()
                            .frame(width: 1.5)
                            .frame(maxHeight: .infinity)
                            .background(Color.primary)
                        VStack(alignment: .center, spacing: screen.routeBottomSpace) {
                            Spacer().frame(height: screen.routeCountdownTopSpace)
                            Text(myTransfer.countdownTime2)
                                .font(.custom("GenEiGothicN-Regular", size: screen.routeCountdownFontSize))
                                .foregroundColor(myTransfer.countdownColor2)
                                .padding(.vertical, screen.routeCountdownPadding)
                                .frame(height: screen.routeCountdownFontSize + screen.routeCountdownPadding * 2, alignment: .center)
                            HomeOfficeView(myTransfer.goOrBack2, 1)
                            ForEach(0...myTransfer.changeLine2, id: \.self) { num in
                                TransferView(myTransfer.goOrBack2, num + 1)
                                StationLineView(myTransfer.goOrBack2, num)
                            }
                            TransferView(myTransfer.goOrBack2, 0)
                            HomeOfficeView(myTransfer.goOrBack2, 0)
                            Spacer()
                        }
                        .frame(width: myTransfer.routeWidth, alignment: .top)
                        .padding(.horizontal, screen.routeSidePadding)
                    }
                    if(screen.screenWidth > 600) { Spacer() }
                }
                    
                // MARK: - Ad Banner
                ZStack {
                    Color.primary
                        .frame(width: screen.screenWidth, height: screen.admobBannerHeight)

                    AdMobBannerView()
                        .frame(minWidth: screen.admobBannerMinWidth)
                        .frame(width: screen.admobBannerWidth, height: screen.admobBannerHeight)
                        .background(Color.primary)
                }
            }
            .background(.white)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationDestination(isPresented: $isMoveSettings) {
            SettingsContentView(myTransfer, myLogin, myFirestore)
        }
        .navigationBarBackButtonHidden(true)
        // Centralized sheets: content uses activeGoorback/activeTransferNum.
        // Avoid closing due to row identity changes by owning sheets here.
        .sheet(isPresented: $isShowingLineSheet) {
            NavigationStack {
                SettingsLineSheet(
                    goorback: sheetGoorback,
                    lineIndex: sheetLineIndex
                )
            }
        }
        .sheet(isPresented: $isShowingTransferSheet) {
            NavigationStack {
                SettingsTransferSheet()
            }
        }
        // Listen global UserDefaults changes and reflect immediately.
        // Reflect any UserDefaults changes into the view model safely on MainActor.
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            Task { @MainActor in
                myTransfer.updateAllDataFromUserDefaults()
            }
        }
        // Refresh when SettingsLineSheet finishes saving.
        // When SettingsLineSheet saves, refresh all derived values.
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SettingsLineUpdated"))) { _ in
            Task { @MainActor in
                myTransfer.updateAllDataFromUserDefaults()
            }
        }
        // Refresh when SettingsTransferSheet finishes saving.
        // When SettingsTransferSheet saves, refresh all derived values.
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SettingsTransferUpdated"))) { _ in
            Task { @MainActor in
                myTransfer.updateAllDataFromUserDefaults()
            }
        }
        // Refresh all views when Go/Back flag toggles.
        .onChange(of: myTransfer.isBack) { _ in
            myTransfer.updateAllDataFromUserDefaults()
        }
        // Ensure timer is running when MainContentView appears
        .onAppear {
            if myTransfer.isTimeStop {
                myTransfer.startButton()
            }
        }
    }
    
    // MARK: - Station and Time View
    // Displays station name and departure time with editing capability
    @ViewBuilder
    func HomeOfficeView(_ goorback: String, _ num: Int) -> some View {
        let timeArray = goorback == myTransfer.goOrBack1 ? myTransfer.timeArrayString1 : myTransfer.timeArrayString2
        let time = num == 0 ? timeArray[0] : timeArray[1]
        
        HStack {
            // MARK: - Station Name Button
            Text(num == 0 ? goorback.destination: goorback.departurePoint)
                .font(.system(size: screen.stationFontSize))
                .lineLimit(1)
            Spacer()
            // MARK: - Time Display
            Text(time)
                .font(.custom("GenEiGothicN-Regular", size: screen.timeFontSize))
        }
        .foregroundColor(.primary)
    }

    // MARK: - Line Time Image (func)
    // Build small icon view from goorback/num without holding state
    @ViewBuilder
    func LineTimeImage(_ goorback: String, _ num: Int, isTransfer: Bool) -> some View {
        let transportationArray = goorback.transportationArray
        let lineColorArray = goorback.lineColorArray
        let lineCodeArray = goorback.lineCodeArray
        let lineKindArray = goorback.lineKindArray

        let lineColor: Color = isTransfer ? .gray : lineColorArray[num]
        let lineCode: String = isTransfer ? "" : lineCodeArray[num]
        let transportation: String = isTransfer ? transportationArray[num] : ""
        let transportationKind: TransportationLine.Kind? = isTransfer ? nil : lineKindArray[num]

        let iconName: String = {
            if isTransfer {
                return transportation != "" ? transferType(from: transportation).iconName: "figure.walk"
            } else {
                switch transportationKind {
                case .railway: return "lightrail"
                case .bus: return "bus"
                case .none: return "lightrail"
                }
            }
        }()

        ZStack(alignment: .center) {
            Rectangle()
                .frame(width: screen.lineImageBackgroundSize, height: screen.lineImageBackgroundSize)
                .foregroundColor(lineColor)

            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(
                    width: screen.lineImageForegroundSize,
                    height: screen.lineImageForegroundSize
                )
                .foregroundColor(.white)

            Text(lineCode)
                .font(.system(size: 14, weight: .bold, design: .default))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundColor(.white)
                .shadow(color: .secondary, radius: 0, x: 0.5, y: 0)
                .shadow(color: .secondary, radius: 0, x: -0.5, y: 0)
                .shadow(color: .secondary, radius: 0, x: 0, y: 0.5)
                .shadow(color: .secondary, radius: 0, x: 0, y: -0.5)
                .shadow(color: .secondary, radius: 0, x: 0.5, y: 0.5)
                .shadow(color: .secondary, radius: 0, x: 0.5, y: -0.5)
                .shadow(color: .secondary, radius: 0, x: -0.5, y: 0.5)
                .shadow(color: .secondary, radius: 0, x: -0.5, y: -0.5)
        }
    }

    // MARK: - Transfer View (func)
    @ViewBuilder
    func TransferView(_ goorback: String, _ num: Int) -> some View {
        HStack {
            Button(action: {
                activeTransferNum = num
                activeGoorback = goorback
                // Calculate and store values for sheet initialization when showing line sheet
                if num >= 2 {
                    sheetGoorback = goorback
                    sheetLineIndex = max(num - 2, 0)
                }
                // Ensure state updates are applied before showing sheet
                // Use Task to ensure state is updated on MainActor before showing sheet
                Task { @MainActor in
                    if num < 2 {
                        isShowingTransferSheet = true
                    } else {
                        isShowingLineSheet = true
                    }
                }
            }) {
                LineTimeImage(goorback, num, isTransfer: true)
            }
            Spacer()
        }
        .frame(height: screen.transferHeight)
    }

    // MARK: - StationLine View (func)
    @ViewBuilder
    func StationLineView(_ goorback: String, _ num: Int) -> some View {
        let currentDate = myTransfer.selectDate
        let currentTime = myTransfer.currentTime
        // Use line-specific calendar type (num is 0-based line index)
        let timeArray = goorback.timeArray(currentDate, currentTime).map { $0.stringTime }
        let departureTime = timeArray[2 * num + 2]
        let arrivalTime = timeArray[2 * num + 3]
        let stationArray = goorback.stationArray
        let lineNameArray = goorback.lineNameArray
        let lineColorArray = goorback.lineColorArray

        VStack(alignment: .leading) {
            HStack {
                Text(stationArray[2 * num])
                    .font(.system(size: screen.stationFontSize))
                    .lineLimit(1)
                Spacer()
                Text(departureTime)
                    .font(.custom("GenEiGothicN-Regular", size: screen.timeFontSize))
            }
            .foregroundColor(.primary)

            Button(action: {
                activeTransferNum = num + 2 // Convert line num to Settings' lineIndex.
                activeGoorback = goorback
                // Calculate and store values for sheet initialization
                sheetGoorback = goorback
                sheetLineIndex = max((num + 2) - 2, 0)
                // Ensure state updates are applied before showing sheet
                // Use Task to ensure state is updated on MainActor before showing sheet
                Task { @MainActor in
                    isShowingLineSheet = true
                }
            }) {
                HStack {
                    LineTimeImage(goorback, num, isTransfer: false)
                    Text(lineNameArray[num])
                        .font(.system(size: screen.lineFontSize))
                        .foregroundColor(lineColorArray[num])
                        .lineLimit(2)
                }
            }
            .frame(height: screen.lineNameHeight)

            HStack {
                Text(stationArray[2 * num + 1])
                    .font(.system(size: screen.stationFontSize))
                    .lineLimit(1)
                Spacer()
                Text(arrivalTime)
                    .font(.custom("GenEiGothicN-Regular", size: screen.timeFontSize))
            }
            .foregroundColor(.primary)
        }
    }

}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        let myTransfer = TransferViewModel()
        let myLogin = LoginViewModel()
        let myFirestore = FirestoreViewModel()
        MainContentView(myTransfer, myLogin, myFirestore)
    }
}

