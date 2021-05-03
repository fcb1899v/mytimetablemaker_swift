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
    @State private var label = "Walking".localized
    
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
        
        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
        
        HStack {
            
            Button (action: {
                self.isShowingAlert = true
            }) {
                ZStack(alignment: .leading) {
                    Color.mygray.frame(width: 22, height: 30)
                    Image(uiImage: UIImage(named: "ic_clock2.png")!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(.white)
                        .padding(.leading, 1)
                    numberFieldAlertView(
                        text: $text,
                        isShowingAlert: $isShowingAlert,
                        title: DialogTitle.transittime.rawValue.localized,
                        message: goorback.transportationMessage(num),
                        key: goorback.transitTimeKey(num),
                        maxnumber: 99
                    )
                }
                .frame(width: 30, height: 35.0)
                .padding(.leading, 10.0)
            }
            
            Button(action: {
                self.isShowingPicker = true
            }) {
                Text(label)
            }
            .frame(alignment: .leading)
            .font(.footnote)
            .lineLimit(1)
            .foregroundColor(.mygray)
            .padding(.leading, 15.0)
            .onReceive(timer) { _ in
                label = goorback.transportationArray[num]
            }
            .actionSheet(isPresented: $isShowingPicker) {
                ActionSheet(
                    title: Text(DialogTitle.transport.rawValue.localized),
                    message:  Text(goorback.transportationMessage(num)),
                    buttons: goorback.transportationKey(num).ActionSheetButtons(
                        list: Transportation.allCases.map{$0.rawValue.localized},
                        value: Transportation.allCases.map{$0.rawValue.localized}
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

