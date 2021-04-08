//
//  timeLabel.swift
//  mytimetablemakers_swiftui
//
//  Created by 中島正雄 on 2021/02/07.
//

import SwiftUI

struct timeLabel: View {
    
    private let time: String
    
    /// 値を指定して生成する
    init(
        _ time: String
    ){
        self.time = time
    }
    
    private let primary = Color(DefaultColor.primary.rawValue.colorInt)
    
    var body: some View {
        Text(time)
            .font(Font.title.monospacedDigit())
            .foregroundColor(primary)
    }
}

struct timeLabel_Previews: PreviewProvider {
    static var previews: some View {
        timeLabel("00:00")
    }
}

