//
//  lineColorAndName.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/02/22.
//

import SwiftUI

struct lineColorAndName: View {
    
    @State private var isShowingAlert = false
    @State private var isShowingNextAlert = false
    @State private var text = ""
    
    private let goorback: String
    private let weekflag: Bool
    private let keytag: String
    
    /// 値を指定して生成する
    init(
        _ goorback: String,
        _ weekflag: Bool,
        _ keytag: String
    ){
        self.goorback = goorback
        self.weekflag = weekflag
        self.keytag = keytag
    }
    
    var body: some View {
        
        let title = DialogTitle.linename.rawValue.localized
        let message = "\("of ".localized)\("line ".localized)\(keytag)"
        let key = "\(goorback)linename\(keytag)"
        let addtitle = DialogTitle.linecolor.rawValue.localized
        let defaultvalue = "\("Line ".localized)\(keytag)"

        let colortitle = DialogTitle.linecolor.rawValue.localized
        let colormessage = goorback.lineName(keytag, "line ".localized + keytag)
        let colorlist = CustomColor.allCases.map{$0.rawValue.localized}
        let colorvalue = CustomColor.allCases.map{$0.RGB}
        let colorkey = "\(goorback)linecolor\(keytag)"
        
        HStack {
            lineColorAlertView(goorback, weekflag, keytag)
                .padding(.leading, 10.0)
            mainAlertPlusLabel(title, message, key, addtitle, defaultvalue, colortitle, colormessage, colorlist, colorvalue, colorkey)
                .padding(.leading, 15.0)
        }
    }
}

struct lineColorAndName_Previews: PreviewProvider {
    static var previews: some View {
        lineColorAndName("back1", false, "1")
    }
}

