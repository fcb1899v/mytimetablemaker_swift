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
        HStack() {
            
            ZStack {
                mainviewmodel.dateLabelView
                DatePicker(
                    "datepicker",
                    selection: $mainviewmodel.selectdate,
                    displayedComponents: .date
                )
                .labelsHidden()
                .opacity(0.1)
                .frame(width: 1, height: 20)
                .onReceive(timer) { _ in
                    mainviewmodel.datelabel = "\(mainviewmodel.selectdate.setDate)"
                }
            }
            
            Spacer()
            
            ZStack {
                mainviewmodel.timeLabelView
                DatePicker(
                    "datepicker",
                    selection: $mainviewmodel.selectdate,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .opacity(0.1)
                .frame(width: 1, height: 20)
                .onReceive(timer) { _ in
                    mainviewmodel.timelabel = "\(mainviewmodel.selectdate.setTime)"
                }
            }
        }
    }
}


struct dateLabelView_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        datePickerLabelView(mainviewmodel).background(Color.myprimary)
    }
}
