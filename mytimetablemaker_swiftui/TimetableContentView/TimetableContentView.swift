//
//  TimetableContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/02.
//

import SwiftUI
import GoogleMobileAds

struct TimetableContentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var weekflag = true
    @State private var image = UIImage()
    @State private var isShowImagePicker = false

    private let goorback: String
    private let num: Int

    init(
        _ goorback: String,
        _ num: Int
    ) {
        self.goorback = goorback
        self.num = num
    }
    
    var body: some View {

        
        let timetable = Timetable(goorback, weekflag, num)
        
        NavigationView {
            ZStack {
                Color.primaryColor
                VStack {
                    VStack {
                        HStack {
                            Spacer()
                            Text(DialogTitle.timetable.rawValue.localized)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top, 20)
                            Spacer()
                        }
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(goorback.stationArray[2 * num + 2]).font(.title3)
                                Text(timetable.timetableTitle).font(.callout)
                            }
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            Spacer()
                            Button(action: {
                                weekflag = !weekflag
                            }){
                                Text(timetable.revWeekLabelText)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .frame(width: timetableWeekButtonWidth, height: timetableWeekButtonHeight)
                                    .foregroundColor(timetable.weekButtonLabelColor)
                                    .background(timetable.weekButtonBackColor)
                                    .cornerRadius(timetableWeekButtonCornerRadius)
                                    .padding(.top, 10)
                                    .padding(.trailing, 10)
                            }
                        }.frame(width: customWidth)
                    }
                    ScrollView {
                        VStack(spacing: 30) {
                            VStack(spacing: 0) {
                                Color.white.frame(width: customWidth, height: 1)
                                HStack {
                                    Color.white.frame(width: 1)
                                    ZStack(alignment: .center) {
                                        Color.primaryColor
                                        Text(timetable.weekLabelText)
                                            .foregroundColor(timetable.weekLabelColor)
                                            .fontWeight(.bold)
                                    }.frame(height: 25)
                                    Color.white.frame(width: 1)
                                }.frame(width: customWidth)
                                Color.white.frame(width: customWidth, height: 1)
                                ForEach(4...25, id: \.self) { hour in
                                    TimetableGridView(goorback, weekflag, num, hour)
                                }
                                Color.white.frame(width: customWidth, height: 0.5)
                            }
                            Button(action: {
                                self.isShowImagePicker = true
                            }, label: {
                                Text(DialogTitle.selectpicture.rawValue.localized)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .frame(width: ImagePickerButtonWidth, height: ImagePickerButtonHeight)
                                    .background(Color.accentColor)
                                    .cornerRadius(ImagePickerCornerRadius)
                            }).sheet(isPresented: $isShowImagePicker, content: {
                                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                            })
                            Image(uiImage: self.image)
                                .resizable()
                                .scaledToFit()
                                .padding(20)
                                .frame(width: customWidth)
                        }
                    }
                    Spacer()
                    AdMobView()
                }
                .navigationBarHidden(true)
                .navigationBarColor(backgroundColor: UIColor(Color.primaryColor), titleColor: .white)
            }.edgesIgnoringSafeArea(.bottom)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TimetableContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableContentView("back1", 0)
    }
}
