//
//  stateButtonArray.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/07.
//

import SwiftUI

struct stateButtonArray: View {

    @ObservedObject private var mainviewmodel: MainViewModel

    init(
        _ mainviewmodel: MainViewModel
    ) {
        self.mainviewmodel = mainviewmodel
    }
    
    var body: some View {
        
        HStack{
            Spacer()
            stateButton(
                flag: mainviewmodel.goorbackflag,
                label: "Back".localized,
                action: mainviewmodel.backButtonChangeData
            )
            Spacer()
            stateButton(
                flag: !mainviewmodel.goorbackflag,
                label: "Go".localized,
                action: mainviewmodel.goButtonChangeData
            )
            Spacer()
            stateButton(
                flag: mainviewmodel.timeflag,
                label: "Start".localized,
                action: mainviewmodel.startButtonChangeData
            )
            Spacer()
            stateButton(
                flag: !mainviewmodel.timeflag,
                label: "Stop".localized,
                action: mainviewmodel.stopButtonChangeData
            )
            Spacer()
        }
    }
}

struct stateButtonArray_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        stateButtonArray(mainviewmodel)
    }
}
