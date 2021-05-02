//
//  settingsRideTime.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/01.
//

import SwiftUI

struct settingsRideTime: View {
    
    @State private var isShowingAlert = false
    @State private var isShowingNextAlert = false
    @State private var text = ""
    @State private var title = "Line 1"
    @State private var label = "Not set".localized
    @State private var color = Color(DefaultColor.gray.rawValue.colorInt)

    private let goorback: String
    private let num: Int
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ num: Int
    ){
        self.goorback = goorback
        self.num = num
    }
    
    var body: some View {

        let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
        
        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                ZStack (alignment: .leading) {
                    Text(title)
                        .frame(alignment: .leading)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(5)
                        .onReceive(timer) { _ in
                            title = goorback.lineNameArray[num]
                        }
                    numberFieldPlusAlertView(
                        text: $text,
                        isShowingAlert: $isShowingAlert,
                        isShowingNextAlert: $isShowingNextAlert,
                        title: DialogTitle.ridetime.rawValue.localized,
                        message: goorback.rideTimeAlertMessage(num),
                        key: goorback.rideTimeKey(num),
                        addtitle: DialogTitle.timetable.rawValue.localized,
                        maxnumber: 99
                    )
                }
                .sheet(isPresented: $isShowingNextAlert) {
                    TimetableContentView(goorback, num)
                }
                Spacer()
                Text(label)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(color)
                    .padding(5)
                    .onReceive(timer) { _ in
                        label = goorback.rideTimeStringArray[num]
                        color = goorback.rideTimeSettingsColor(num)
                    }
            }
        }
    }
}

struct settingsRideTime_Previews: PreviewProvider {
    static var previews: some View {
        settingsRideTime("back1", 0)
    }
}
