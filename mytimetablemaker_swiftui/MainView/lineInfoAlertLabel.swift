//
//  mainAlertPlusLabel.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/04.
//

import SwiftUI

struct lineInfoAlertLabel: View {

    @State private var isShowingRideTimeAlert = false
    @State private var isShowingTimetableAlert = false
    @State private var isShowingLineNameAlert = false
    @State private var isShowingLineColorAlert = false
    @State private var text = ""
    @State private var label = ""

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
        
        let keytag = "\(num + 1)"
        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
        let accent = DefaultColor.accent.rawValue

        let ridetimetitle = DialogTitle.ridetime.rawValue.localized
        let ridetimemessage = "\("on ".localized)\(goorback.lineName(keytag, "\("Line ".localized)\(keytag)"))"
        let ridetimekey = "\(goorback)ridetime\(keytag)"
        let timetabletitle = DialogTitle.timetable.rawValue.localized
        
        let linenametitle = DialogTitle.linename.rawValue.localized
        let linenamemessage = "\("of ".localized)\("line ".localized)\(keytag)"
        let linenamekey = "\(goorback)linename\(keytag)"
        let addtitle = DialogTitle.linecolor.rawValue.localized
        let defaultlinename = "\("Line ".localized)\(keytag)"
        
        let colortitle = DialogTitle.linecolor.rawValue.localized
        let colormessage = goorback.lineName(keytag, "line ".localized + keytag)
        let colorlist = CustomColor.allCases.map{$0.rawValue.localized}
        let colorvalue = CustomColor.allCases.map{$0.RGB}
        let colorkey = "\(goorback)linecolor\(keytag)"
        var color = colorkey.userDefaultsColor(accent)

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
                        title: ridetimetitle,
                        message: ridetimemessage,
                        key: ridetimekey,
                        addtitle: timetabletitle,
                        maxnumber: 99
                    )
                    NavigationLink(
                        destination: TimetableContentView(goorback, num),
                        isActive: $isShowingTimetableAlert,
                        label: { }
                    )
                }
//                .sheet(isPresented: $isShowingTimetableAlert) {
//                    TimetableContentView(goorback, num)
//                }
            }
            .frame(width: 30, height: 35.0, alignment: .center)
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
                            label = linenamekey.userDefaultsValue(defaultlinename)
                            color = colorkey.userDefaultsColor(accent)
                        }
                    textFieldPlusAlertView(
                        text: $text,
                        isShowingAlert: $isShowingLineNameAlert,
                        isShowingNextAlert: $isShowingLineColorAlert,
                        title: linenametitle,
                        message: linenamemessage,
                        key: linenamekey,
                        addtitle: addtitle
                    )
                }.actionSheet(isPresented: $isShowingLineColorAlert) {
                    ActionSheet(
                        title: Text(colortitle),
                        message:  Text(colormessage),
                        buttons: ActionSheetButtons(
                            list: colorlist,
                            value: colorvalue,
                            key: colorkey
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
        lineInfoAlertLabel(mainviewmodel.goorback1, true, 0)
    }
}
