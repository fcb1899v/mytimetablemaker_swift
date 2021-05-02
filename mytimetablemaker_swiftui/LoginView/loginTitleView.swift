//
//  loginTitleView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/04/06.
//

import SwiftUI

struct loginTitleView: View {
    
    private let title: String

    init(
        _ title: String
    ) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.title)
            .foregroundColor(.myprimary)
            .frame(height: 180)
            .offset(y: 50)
    }
}

struct loginTitleView_Previews: PreviewProvider {
    static var previews: some View {
        loginTitleView("My Transit Makers")
    }
}
