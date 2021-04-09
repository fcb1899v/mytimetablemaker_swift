//
//  TimetableContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI

struct TimetableContentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let goorback: String
    @State var weekflag: Bool
    let keytag: String
    
    var body: some View {

        let primary = Color(DefaultColor.primary.rawValue.colorInt)
        
        NavigationView {
            ZStack {
                primary
                ScrollView {
                    TimetableTitleView(
                        goorback, weekflag, keytag, {weekflag = (weekflag) ? false: true}
                    )
                    TimetableGridView(
                        goorback, weekflag, keytag
                    )
                    imagePickerView()
                    Spacer(minLength: 30)
                }
                .navigationTitle(DialogTitle.timetable.rawValue.localized)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarColor(backgroundColor: UIColor(primary), titleColor: .white)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading){
                        settingsBackButton(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }, Color.white)
                    }
                }
            }
        }
    }
}

struct TimetableContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableContentView(goorback: "back1", weekflag: true, keytag: "1")
    }
}
