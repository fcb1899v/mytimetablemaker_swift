//
//  settingsChangeLine.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/16.
//

import SwiftUI

struct settingsChangeLine: View {
    
    @State private var isShowingPicker = false
    private let goorback: String
    @ObservedObject var settingviewmodel:  SettingsViewModel

    /// 値を指定して生成する
    init(
        _ goorback: String
    ){
        self.goorback = goorback
        self.settingviewmodel = SettingsViewModel(goorback)
    }
    
    var body: some View {
        if goorback.route2Flag {
            HStack {
                Button(
                    goorback.routeTitle
                ) {
                    self.isShowingPicker = true
                }
                .frame(alignment: .leading)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(5)
                .actionSheet(isPresented: $isShowingPicker) {
                    ActionSheet(
                        title: Text(DialogTitle.numtransit.rawValue.localized),
                        message:  Text(goorback.routeTitle),
                        buttons: "\(goorback)changeline".ActionSheetButtons(
                            list: TransitTime.allCases.map{$0.rawValue.localized},
                            value: TransitTime.allCases.map{$0.Number}
                        )
                    )
                }
                Spacer()
                Text(settingviewmodel.changeline)
                    .font(.subheadline)
                    .padding(5)
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
