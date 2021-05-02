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
        
        VStack(spacing: 10) {
            Color.primary.frame(height: 10)
            Button(action: {
                self.isShowPhotoLibrary = true
            }, label: {
                Text(DialogTitle.selectpicture.rawValue.localized)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(width: 300, height: 35)
                    .foregroundColor(Color.white)
                    .background(Color.accent)
                    .cornerRadius(15)
            }).sheet(isPresented: $isShowPhotoLibrary, content: {
                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
            })
            Image(uiImage: self.image)
                .resizable()
                .scaledToFit()
                .padding(50)
        }.frame(alignment: .top)
    }
}

struct imagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        imagePickerView()
            .background(Color.primary)
    }
}
