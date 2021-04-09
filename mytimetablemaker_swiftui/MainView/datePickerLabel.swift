//
//  dateLabelView.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/03/07.
//

import SwiftUI

struct datePickerLabelView: View {
    
    @ObservedObject private var mainviewmodel: MainViewModel
    
    init(
        _ mainviewmodel: MainViewModel
    ) {
        self.mainviewmodel = mainviewmodel
    }

    let timer = Timer.publish(every: 0.4, on: .current, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            mainviewmodel.dateLabelView
            DatePicker(
                "datepicker",
                selection: $mainviewmodel.selectdate,
                displayedComponents: .date
            )
            .labelsHidden()
            .accentColor(.clear)
            .frame(height: 20)
            .onReceive(timer) { (_) in
                mainviewmodel.datelabel = "\(mainviewmodel.selectdate.setDate)"
            }
        }
    }
}

struct dateLabelView_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        let primary = Color(DefaultColor.primary.rawValue.colorInt)
        datePickerLabelView(mainviewmodel).background(primary)
    }
}
