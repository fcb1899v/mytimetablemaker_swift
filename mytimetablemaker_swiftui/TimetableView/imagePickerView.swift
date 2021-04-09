//
//  imagePickerView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/08.
//

import SwiftUI

struct imagePickerView: View {

    @State private var image = UIImage()
    @State private var isShowPhotoLibrary = false
    
    var body: some View {
        
        let primary = Color(DefaultColor.primary.rawValue.colorInt)
        let accent = Color(DefaultColor.accent.rawValue.colorInt)
        let title = "Select your timetable picture".localized

        VStack(spacing: 10) {
            primary.frame(height: 10)
            Button(action: {
                self.isShowPhotoLibrary = true
            }, label: {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(width: UIScreen.screenWidth * 0.7,
                           height: 35,
                           alignment: .center)
                    .foregroundColor(Color.white)
                    .background(accent)
                    .cornerRadius(15)
            }).sheet(isPresented: $isShowPhotoLibrary, content: {
                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
            })
            primary.frame(height: 0)
            Image(uiImage: self.image)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.screenWidth * 0.9)
        }
    }
}

struct imagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        imagePickerView()
    }
}
