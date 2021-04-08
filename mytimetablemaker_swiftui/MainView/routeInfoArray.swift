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
                routeInfo(mainviewmodel, mainviewmodel.goorback1)
                    .padding(.trailing, 5.0)
                if (mainviewmodel.goorback2.route2Flag) {
                    Divider()
                        .frame(width: 1.5, height: UIScreen.screenHeight)
                        .background(primary)
                    routeInfo(mainviewmodel, mainviewmodel.goorback2)
                        .padding(.leading, 5.0)
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
