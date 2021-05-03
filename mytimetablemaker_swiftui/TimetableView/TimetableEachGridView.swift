//
//  TimetableEachGridView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI

struct TimetableEachGridView: View {

    @State private var isShowingAlert = false
    @State private var isShowingPicker = false
    @State private var text = ""
    @State private var label = ""

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
        
        let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
        let timetable = Timetable(goorback, weekflag, num)
        
        ZStack {
            Color.white
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 1) {
                HStack(spacing: 1) {
                    Color.white
                        .frame(width: 1)
                    ZStack {
                        Color.myprimary
                            .frame(width: 27)
                        Text(hour.addZeroTime)
                            .foregroundColor(.myaccent)
                    }
                    Button (action: {
                        self.isShowingAlert = true
                    }) {
                        ZStack(alignment: .leading) {
                            Color.myprimary
                                .frame(width: UIScreen.screenWidth - 30)
                            Button (action: {
                                self.isShowingAlert = true
                            }) {
                                ZStack(alignment: .leading) {
                                    Text(label)
                                        .foregroundColor(.white)
                                        .onReceive(timer) { (_) in
                                            label = timetable.timetableTime(hour)
                                        }
                                    timeFieldAlertView(
                                        text: $text,
                                        isShowingAlert: $isShowingAlert,
                                        isShowingPicker: $isShowingPicker,
                                        title: DialogTitle.adddeletime.rawValue.localized,
                                        message: timetable.timetableAlertMessage(hour),
                                        key: timetable.timetableKey(hour),
                                        maxnumber: 59
                                    )
                                    .actionSheet(isPresented: $isShowingPicker) {
                                        timetable.copyTimetableSheet(hour)
                                    }
                                }
                            }
                        }
                    }
                    Color.white.frame(width: 1)
                }
            }
        }
    }
}

struct TimetableEachGridView_Previews: PreviewProvider {
    static var previews: some View {
        let weekflag = !Date().weekFlag
        TimetableEachGridView("back1", weekflag, 0, 4)
    }
}
