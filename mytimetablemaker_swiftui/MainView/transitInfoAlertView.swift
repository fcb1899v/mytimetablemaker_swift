//
//  transitTimeAlertView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/25.
//

import SwiftUI

struct transitInfoAlertView: View {
    
    @State private var isShowingAlert = false
    @State private var isShowingPicker = false
    @State private var text = ""

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

        let keytag = (num == 0) ? "e": "\(num)"
        let gray = Color(DefaultColor.gray.rawValue.colorInt)
        
        let transitdepartstation = goorback.transitDepartStation(num).localized
        let transitarrivestation = goorback.transitArriveStation(num).localized
    
        let transittimetitle = DialogTitle.transittime.rawValue.localized
        let transittimemessage = "\("from ".localized)\(transitdepartstation)\(" to ".localized)\(transitarrivestation)"
        let transittimekey = "\(goorback)transittime\(keytag)"

        let transportlist = Transportation.allCases.map{$0.rawValue.localized}
        let transporttitle = DialogTitle.transport.rawValue.localized
        let transportmessage = "\("from ".localized)\(transitdepartstation)\(" to ".localized)\(transitarrivestation)"
        let transportkey = "\(goorback)transport\(keytag)"
        let defaultvalue = "Walking".localized
        let transportation = goorback.transportation(keytag, defaultvalue)
        
        HStack {
            
            Button (action: {
                self.isShowingAlert = true
            }) {
                ZStack(alignment: .leading) {
                    gray.frame(width: 22, height: 30)
                    Image(uiImage: UIImage(named: "ic_clock2.png")!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(.white)
                        .padding(.leading, 1)
                    numberFieldAlertView(
                        text: $text,
                        isShowingAlert: $isShowingAlert,
                        title: transittimetitle,
                        message: transittimemessage,
                        key: transittimekey,
                        maxnumber: 99
                    )
                }
                .frame(width: 30, height: 35.0, alignment: .center)
                .padding(.leading, 10.0)
            }
            Button(
                (transportation == "") ? transportlist[0]: transportation
            ) {
                self.isShowingPicker = true
            }
            .frame(alignment: .leading)
            .font(.footnote)
            .lineLimit(1)
            .foregroundColor(gray)
            .padding(.leading, 15.0)
            .actionSheet(isPresented: $isShowingPicker) {
                ActionSheet(
                    title: Text(transporttitle),
                    message:  Text(transportmessage),
                    buttons: ActionSheetButtons(
                        list: transportlist,
                        value: transportlist,
                        key: transportkey
                    )
                )
            }
            Spacer()
        }
    }
}

struct transitInfoAlertView_Previews: PreviewProvider {
    static var previews: some View {
        transitInfoAlertView("back1", 0)
    }
}

