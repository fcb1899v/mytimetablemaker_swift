//
//  settingsChangeLine.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/16.
//

import SwiftUI

struct settingsChangeLine: View {
    
    private let goorback: String
    @ObservedObject private var settings: Settings
    @State private var label: String
    @State private var isShowingAlert = false

    /// 値を指定して生成する
    init(
        _ goorback: String
    ){
        self.goorback = goorback
        self.settings = Settings(goorback)
        self.label = goorback.changeLineString
    }

    var body: some View {

        //Setting change line button
        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                Text(goorback.routeTitle).padding(5)
                Spacer()
                Text(label).padding(5)
                    .onChange(of: goorback.changeLineString) { newValue in label = newValue }
            }
            .font(.subheadline)
            .foregroundColor(.black)
            //Setting change line action sheet
            .actionSheet(isPresented: $isShowingAlert) {
                ActionSheet(
                    title: Text(DialogTitle.numtransit.rawValue.localized),
                    message: Text(goorback.routeTitle),
                    buttons: TransitTime.allCases.map{$0.rawValue.localized}.indices.map { i in
                        .default(Text(TransitTime.allCases.map{$0.rawValue.localized}[i])) {
                            UserDefaults.standard.set(TransitTime.allCases.map{$0.Number}[i], forKey: goorback.changeLineKey)
                            settings.getChangeLine()
                        }
                    } + [.cancel()]
                )
            }
        }
    }
}

struct settingsChangeLine_Previews: PreviewProvider {
    static var previews: some View {
        settingsChangeLine("back1")
    }
}
