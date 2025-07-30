//
//  settingsChangeLine.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/02/16.
//

import SwiftUI

// MARK: - Settings Change Line View
// Component for configuring the number of line changes for each route
struct settingsChangeLine: View {
    
    @ObservedObject private var myTransit: MyTransit
    @State private var label: String
    @State private var isShowingAlert = false

    private let goorback: String

    init(
        _ myTransit: MyTransit,
        goorback: String
    ){
        self.myTransit = myTransit
        self.goorback = goorback
        self.label = goorback.changeLineString
    }

    var body: some View {
        Button (action: {
            self.isShowingAlert = true
        }) {
            HStack {
                Text(goorback.routeTitle).padding(5)
                Spacer()
                Text(label).padding(5)
                    .onChange(of: goorback.changeLineString) {
                        newValue in label = newValue
                    }
            }
            .foregroundColor(.black)
            // MARK: - Change Line Action Sheet
            .actionSheet(isPresented: $isShowingAlert) {
                ActionSheet(
                    title: Text(changeLineAlertTitle),
                    message: Text(goorback.routeTitle),
                    buttons: TransitTime.allCases.map{$0.rawValue.localized}.indices.map { i in
                        .default(Text(TransitTime.allCases.map{$0.rawValue.localized}[i])) {
                            UserDefaults.standard.set(
                                TransitTime.allCases.map{$0.Number}[i],
                                forKey: goorback.changeLineKey
                            )
                            myTransit.setChangeLine()
                        }
                    } + [.cancel()]
                )
            }
        }
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct settingsChangeLine_Previews: PreviewProvider {
    static var previews: some View {
        let myTransit = MyTransit()
        settingsChangeLine(myTransit, goorback: "back1")
    }
}
