//
//  TimetableAlertLabel.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/06.
//

import SwiftUI

struct TimetableAlertLabel: View {
    
    @State private var isShowingAlert = false
    @State private var isShowingPicker = false
    @State private var text = ""
    
    private let goorback: String
    private let weekflag: Bool
    private let num: Int
    private let hour: Int

    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ num: Int,
        _ hour: Int
    ) {
        self.goorback = goorback
        self.weekflag = weekflag
        self.num = num
        self.hour = hour
    }

    var body: some View {
        
        let timetable = Timetable(goorback, weekflag, num)
        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
        let primary = Color(DefaultColor.primary.rawValue.colorInt)
        
        let message = "\(goorback.lineNameArray[num]) (\(String(hour))\("Hour".localized))"
        let key = timetable.timetableKey(hour)

        Button (action: {
            self.isShowingAlert = true
        }) {
            ZStack(alignment: .leading) {
                primary.frame(width: UIScreen.screenWidth - 30)
                Button (action: {
                    self.isShowingAlert = true
                }) {
                    ZStack(alignment: .leading) {
                        Text(text)
                            .foregroundColor(.white)
                            .onReceive(timer) { (_) in
                                text = "\(key.userDefaultsValue(""))"
                            }
                        timeFieldAlertView(
                            text: $text,
                            isShowingAlert: $isShowingAlert,
                            isShowingPicker: $isShowingPicker,
                            title: DialogTitle.adddeletime.rawValue.localized,
                            message: message,
                            key: key,
                            maxnumber: 59
                        )
                        .actionSheet(isPresented: $isShowingPicker) {
                            timetable.copyTimetableSheet(hour, key)
                        }
                    }
                }
            }
        }
    }
}
