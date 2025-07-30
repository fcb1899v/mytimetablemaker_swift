//
//  TimetableContentView.swift
//  mytimetablemaker_swiftui
//
//  Created by Masao Nakajima on 2021/03/02.
//

import SwiftUI
import GoogleMobileAds

// MARK: - Timetable Content View
// Main timetable editing screen with grid view and image picker
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
        NavigationView {
            ZStack {
                Color.primaryColor
                VStack {
                    // MARK: - Header Section
                    VStack {
                        HStack {
                            Spacer()
                            Text(timetableAlertTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top, 20)
                            Spacer()
                        }
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(goorback.stationArray[2 * num + 2]).font(.title3)
                                Text(goorback.timetableAlertTitle(num)).font(.callout)
                            }
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            Spacer()
                            // MARK: - Weekday/Weekend Toggle Button
                            Button(action: {
                                weekflag = !weekflag
                            }){
                                Text(weekflag.weekendLabel)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .frame(width: timetableButtonWidth, height: operationButtonHeight)
                                    .foregroundColor(weekflag.weekButtonLabelColor)
                                    .background(weekflag.weekButtonColor)
                                    .cornerRadius(operationButtonCornerRadius)
                                    .padding(.top, 10)
                                    .padding(.trailing, 10)
                            }
                        }.frame(width: customWidth)
                    }
                    
                    // MARK: - Timetable Grid
                    ScrollView {
                        VStack(spacing: 30) {
                            VStack(spacing: 0) {
                                Color.white.frame(width: customWidth, height: 1)
                                HStack {
                                    Color.white.frame(width: 1)
                                    ZStack(alignment: .center) {
                                        Color.primaryColor
                                        Text(weekflag.weekdayLabel)
                                            .foregroundColor(weekflag.weekLabelColor)
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
                            
                            // MARK: - Image Picker Button
                            Button(action: {
                                self.isShowImagePicker = true
                            }, label: {
                                Text(timetablePictureButtonText)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .frame(width: ImagePickerButtonWidth, height: operationButtonHeight)
                                    .background(Color.accentColor)
                                    .cornerRadius(operationButtonCornerRadius)
                            }).sheet(isPresented: $isShowImagePicker, content: {
                                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                            })
                            
                            // MARK: - Selected Image Display
                            Image(uiImage: self.image)
                                .resizable()
                                .scaledToFit()
                                .padding(20)
                                .frame(width: customWidth)
                        }
                    }
                }
                .navigationBarHidden(true)
                .navigationBarColor(backgroundColor: UIColor(Color.primaryColor), titleColor: .white)
            }.edgesIgnoringSafeArea(.bottom)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Preview Provider
// Provides preview data for SwiftUI previews in Xcode
struct TimetableContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableContentView("back1", 0)
    }
}
