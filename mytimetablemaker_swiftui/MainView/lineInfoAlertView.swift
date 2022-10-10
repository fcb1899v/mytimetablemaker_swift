//
//  mainAlertPlusLabel.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/04.
//

import SwiftUI

struct lineInfoAlertView: View {

    @State private var isShowingRideTimeAlert = false
    @State private var isShowingTimetableAlert = false
    @State private var isShowingLineNameAlert = false
    @State private var isShowingLineColorAlert = false
    @State private var text = ""
    @State private var label = "Line 1"
    @State private var color = Color.myaccent

    private let goorback: String
    private let weekflag: Bool
    private let num: Int
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ num: Int
    ){
        self.goorback = goorback
        self.weekflag = weekflag
        self.num = num
    }

    var body: some View {
        
        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()

        HStack {
            
            Button (action: {
                self.isShowingRideTimeAlert = true
            }) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: 22, height: 30)
                        .foregroundColor(color)
                    Image(uiImage: UIImage(named: "ic_clock2.png")!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(.white)
                        .padding(.leading, 1)
                    numberFieldPlusAlertView(
                        text: $text,
                        isShowingAlert: $isShowingRideTimeAlert,
                        isShowingNextAlert: $isShowingTimetableAlert,
                        title: DialogTitle.ridetime.rawValue.localized,
                        message: goorback.rideTimeAlertMessage(num),
                        key: goorback.rideTimeKey(num),
                        addtitle: DialogTitle.timetable.rawValue.localized,
                        maxnumber: 99
                    )
                }
                .sheet(isPresented: $isShowingTimetableAlert) {
                    TimetableContentView(goorback, num)
                }
            }
            .frame(width: 30, height: 35.0)
            .padding(.leading, 10.0)
            
            Button (action: {
                isShowingLineNameAlert = true
            }) {
                ZStack (alignment: .leading) {
                    Text(label)
                        .font(.footnote)
                        .lineLimit(1)
                        .foregroundColor(color)
                        .padding(.leading, 15.0)
                        .onReceive(timer) { _ in
                            label = goorback.lineNameArray[num]
                            color = goorback.lineColorArray[num]
                        }
                    textFieldPlusAlertView(
                        text: $text,
                        isShowingAlert: $isShowingLineNameAlert,
                        isShowingNextAlert: $isShowingLineColorAlert,
                        title: DialogTitle.linename.rawValue.localized,
                        message: goorback.lineNameAlertMessage(num),
                        key: goorback.lineNameKey(num),
                        addtitle: DialogTitle.linecolor.rawValue.localized
                    )
                }.actionSheet(isPresented: $isShowingLineColorAlert) {
                    ActionSheet(
                        title: Text(DialogTitle.linecolor.rawValue.localized),
                        message:  Text(goorback.lineNameArray[num]),
                        buttons: goorback.lineColorKey(num).ActionSheetButtons(
                            list: CustomColor.allCases.map{$0.rawValue.localized},
                            value: CustomColor.allCases.map{$0.RGB}
                        )
                    )
                }
            }
        }
    }
}

struct lineInfoAlertLabel_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        lineInfoAlertView(mainviewmodel.goorback1, true, 0)
    }
}
