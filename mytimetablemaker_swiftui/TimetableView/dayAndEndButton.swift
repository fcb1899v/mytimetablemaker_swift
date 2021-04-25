//
//  dayAndEndButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/04.
//

import SwiftUI

struct dayAndEndButton: View {
    
    private let weekflag: Bool
    private let action: () -> Void

    init(
        _ weekflag: Bool,
        action: @escaping () -> Void
    ) {
        self.weekflag = weekflag
        self.action = action
    }

    var body: some View {
        
        let primary = Color(DefaultColor.primary.rawValue.colorInt)

        Button(action: action) {
            Text((!weekflag).weekLabelText)
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(width: UIScreen.screenWidth/5,
                       height: 35,
                       alignment: .center)
                .foregroundColor((!weekflag) ? primary: Color.white)
                .background((!weekflag) ? Color.white: Color.red)
                .cornerRadius(15)
        }
    }
}

struct dayAndEndButton_Previews: PreviewProvider {
    static var previews: some View {
        let weekflag = !Date().weekFlag
        dayAndEndButton(weekflag, action: {})
            .background(Color.black)
    }
}
