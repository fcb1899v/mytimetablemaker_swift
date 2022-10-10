//
//  TimetableContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI
import GoogleMobileAds

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

        NavigationView {
            ZStack {
                Color.myprimary
                VStack {
                    TimetableTitleView(goorback, weekflag, num, {
                        weekflag = (weekflag) ? false: true
                    })
                    ScrollView {
                        TimetableGridView(goorback, weekflag, num)
                        imagePickerView()
                    }
                    Spacer()
                    AdMobView()
                }
                .navigationBarHidden(true)
                .navigationBarColor(backgroundColor: UIColor(Color.myprimary), titleColor: .white)
            }.edgesIgnoringSafeArea(.bottom)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TimetableContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableContentView("back1", 0)
    }
}
