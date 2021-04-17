//
//  routeInfoArray.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/23.
//

import SwiftUI

struct routeInfoArray: View {
   
    @ObservedObject private var mainviewmodel: MainViewModel

    init(
        _ mainviewmodel: MainViewModel
    ) {
        self.mainviewmodel = mainviewmodel
    }

    private let primary = Color(DefaultColor.primary.rawValue.colorInt)

    var body: some View {
        ScrollView {
            HStack(alignment: .top) {
                routeInfo1(mainviewmodel)
                if (mainviewmodel.goorback2.route2Flag) {
                    Divider()
                        .frame(width: 1.5, height: UIScreen.screenHeight)
                        .background(primary)
                        .padding(.leading, 10.0)
                        .padding(.trailing, 10.0)
                    routeInfo2(mainviewmodel)
                }
            }
        }
    }
}

struct routeInfoArray_Previews: PreviewProvider {
    static var previews: some View {
        let mainviewmodel = MainViewModel()
        routeInfoArray(mainviewmodel)
    }
}
