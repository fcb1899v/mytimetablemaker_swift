//
//  transitTimeAndName.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/22.
//

import SwiftUI

struct transitTimeAndName: View {
    
    private let goorback: String
    private let keytag: String

    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ keytag: String
    ){
        self.goorback = goorback
        self.keytag = keytag
    }

    var body: some View {
        HStack {
            transitTimeAlertView(goorback, keytag)
                .padding(.leading, 10.0)
            transportPickerLabel(goorback, keytag)
                .padding(.leading, 15.0)
            Spacer()
        }
    }
}

struct transitTimeAndName_Previews: PreviewProvider {
    static var previews: some View {
        transitTimeAndName("back1", "1")
    }
}
