//
//  settingsChangeLine.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/16.
//

import SwiftUI

struct settingsChangeLine: View {
    
    @State private var isShowingPicker = false
    @State private var changeline = "Zero".localized
    private let goorback: String

    /// 値を指定して生成する
    init(
        _ goorback: String
    ){
        self.goorback = goorback
    }
    
    var body: some View {
    
        let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
        let title = DialogTitle.numtransit.rawValue.localized
        let message = goorback.routeTitle
        let key = "\(goorback)changeline"
        let list = TransitTime.allCases.map{$0.rawValue.localized}
        let value = TransitTime.allCases.map{$0.Number}

        if goorback.route2Flag {
            
            HStack {
                Button(
                    goorback.routeTitle
                ) {
                    self.isShowingPicker = true
                }
                .frame(alignment: .leading)
                .font(.subheadline)
                .foregroundColor(Color.black)
                .padding(5)
                .actionSheet(isPresented: $isShowingPicker) {
                    ActionSheet(
                        title: Text(title),
                        message:  Text(message),
                        buttons: ActionSheetButtons(
                            list: list,
                            value: value,
                            key: key
                        )
                    )
                }
                Spacer()
                Text(changeline)
                    .foregroundColor(Color.black)
                    .font(.subheadline)
                    .padding(5)
                    .onReceive(timer) { (_) in
                        changeline = key.userDefaultsInt(0).stringChangeLine
                    }
            }
        }
    }
}

struct settingsChangeLine_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        settingsChangeLine(mainviewmodel.goorback1)
    }
}
