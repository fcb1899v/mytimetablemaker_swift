//
//  stateButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/06.
//

import SwiftUI

struct stateButton: View {
    
    private let flag: Bool
    private let label: String
    private let action: () -> Void

    /// 値を指定して生成する
    init(
        flag: Bool,
        label: String,
        action: @escaping () -> Void
    ){
        self.flag = flag
        self.label = label
        self.action = action
    }

    var body: some View {
        
        Button(action: action) {
            if (flag) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(width: .statebuttonwidth, height: 35)
                    .foregroundColor(.white)
                    .background(Color.myaccent)
                    .cornerRadius(15)
            } else {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(width: .statebuttonwidth, height: 35)
                    .foregroundColor(.white)
                    .background(Color.mygray)
                    .cornerRadius(15)
            }
        }
    }
}

struct stateButton_Previews: PreviewProvider {
    static var previews: some View {
        stateButton(
            flag: true,
            label: "Back",
            action: {}
        )
    }
}

