//
//  timePickerLabelView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/07.
//

import SwiftUI

struct timePickerLabelView: View {
    
    @ObservedObject private var mainviewmodel: MainViewModel
    
    init(
        _ mainviewmodel: MainViewModel
    ) {
        self.mainviewmodel = mainviewmodel
    }

    let timer = Timer.publish(every: 0.4, on: .current, in: .common).autoconnect()

    var body: some View {
        ZStack {
            mainviewmodel.timeLabelView
            DatePicker(
                "datepicker",
                selection: $mainviewmodel.selectdate,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .accentColor(.clear)
            .onReceive(timer) { (_) in
                mainviewmodel.timelabel = "\(mainviewmodel.selectdate.setTime)"
            }
        }
    }
}

struct timeLabelView_Previews: PreviewProvider {
    static var previews: some View {
        let primary = Color(DefaultColor.primary.rawValue.colorInt)
        let mainviewmodel = MainViewModel()
        timePickerLabelView(mainviewmodel).background(primary)
    }
}
