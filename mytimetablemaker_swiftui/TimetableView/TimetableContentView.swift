//
//  TimetableContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI

struct TimetableContentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var weekflag = Date().weekFlag
    
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

        let primary = Color(DefaultColor.primary.rawValue.colorInt)
        let keytag = "\(num + 1)"
        
        NavigationView {
            ZStack {
                primary
                ScrollView {
                    TimetableTitleView(
                        goorback, weekflag, keytag, {
                            weekflag = (weekflag) ? false: true
                        }
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
                        settingsBackButton()
                    }
                }
            }
        }
    }
}

struct TimetableContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableContentView("back1", 0)
    }
}
