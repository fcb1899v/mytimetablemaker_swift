# My Transfer Maker

<div align="center">
  <img src="mytimetablemaker_swiftui/Common/Assets.xcassets/icon.imageset/icon.png" alt="My Time Table Maker Icon" width="120" height="120">
  <br>
  <strong>Create and manage your personal timetable with ease</strong>
  <br>
  <strong>Smart timetable management for iOS with Firebase integration</strong>
</div>

## 📱 Application Overview

My Time Table Maker is a SwiftUI-based iOS application that helps users create and manage personal timetables for daily commutes and schedules. It provides a comprehensive solution with Firebase integration, user authentication, and modern SwiftUI interface.

### 🎯 Key Features

- **Modern SwiftUI Interface**: Declarative UI with smooth animations
- **Firebase Integration**: Authentication, Firestore database, Analytics
- **User Authentication**: Sign up, login, password reset functionality
- **Timetable Management**: Create, edit, and manage personal timetables
- **Multi-language Support**: Japanese and English localization
- **Google Mobile Ads**: Banner ads integration
- **Data Synchronization**: Cloud-based data storage and sync
- **Customizable Settings**: Various configuration options
- **Image Management**: Photo picker and image handling

## 🚀 Technology Stack

### Frameworks & Libraries
- **SwiftUI**: Modern declarative UI framework
- **Firebase**: Authentication, Firestore, Analytics, Core
- **Google Mobile Ads**: Advertisement display
- **Swift Package Manager**: Dependency management

### Core Features
- **Authentication**: Firebase Auth for user management
- **Database**: Cloud Firestore for data storage
- **Analytics**: Firebase Analytics for usage tracking
- **Ads**: Google Mobile Ads SDK
- **Localization**: Multi-language support
- **Image Handling**: Photo picker and image processing
- **Data Management**: UserDefaults for local storage
- **Navigation**: SwiftUI NavigationView

## 📋 Prerequisites

- Xcode 14.0+
- iOS 15.6+
- Swift Package Manager
- Firebase project setup
- Google Mobile Ads account

## 🛠️ Setup

### 1. Clone the Repository
```bash
git clone https://github.com/fcb1899v/mytimetablemaker_swift.git
cd mytimetablemaker_swiftui
```

### 2. Configuration Files Setup

#### Release.xcconfig Configuration
The release configuration file contains sensitive information and is not included in Git.

1. Copy `mytimetablemaker_swiftui/Release.xcconfig.template`
2. Save as `mytimetablemaker_swiftui/Release.xcconfig`
3. Update the following values with your actual values:
   - `ADMOB_BANNER_UNIT_ID`: Your actual AdMob Banner Unit ID

```bash
cp mytimetablemaker_swiftui/Release.xcconfig.template mytimetablemaker_swiftui/Release.xcconfig
```

### 3. Install Dependencies
```bash
# Resolve Swift Package Manager dependencies
xcodebuild -resolvePackageDependencies
```
### 4. Firebase Configuration
1. Create a Firebase project
2. Place `GoogleService-Info.plist` in `mytimetablemaker_swiftui/` directory
3. This file is automatically excluded by .gitignore

### 5. Run the Application
```bash
# Open in Xcode
open mytimetablemaker_swiftui.xcodeproj

# Or build from command line
xcodebuild build -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftui -destination 'platform=iOS Simulator,name=iPhone 16'
```

## 🎮 Application Structure

```
mytimetablemaker_swiftui/
├── mytimetablemaker_swiftuiApp.swift    # Application entry point
├── ContentView/                          # Main content views
│   ├── ContentView.swift
│   ├── AdMobView.swift
│   ├── AdMobBannerView.swift
│   └── NavigationBarModifier.swift
├── LoginContentView/                     # Authentication views
│   ├── LoginContentView.swift
│   ├── SignUpContentView.swift
│   ├── MyLogin.swift
│   └── SwiftUIView.swift
├── MainContentView/                      # Main app views
│   ├── MainContentView.swift
│   ├── SplashContentView.swift
│   ├── MyTransfer.swift
│   ├── stationAndTime.swift
│   ├── transferInfomation.swift
│   ├── lineInfomation.swift
│   ├── lineTimeImage.swift
│   └── operationButton.swift
├── SettingsContentView/                  # Settings views
│   ├── SettingsContentView.swift
│   ├── MyFirestore.swift
│   ├── SaveFirestoreButton.swift
│   ├── GetFirestoreButton.swift
│   ├── LogOutButton.swift
│   ├── DeleteAccountButton.swift
│   └── settingsChangeLine.swift
├── TimetableContentView/                 # Timetable views
│   ├── TimetableContentView.swift
│   ├── TimetableGridView.swift
│   ├── ImagePicker.swift
│   └── TimetableBackButton.swift
├── VariousSettingsContentView/           # Various settings
│   ├── VariousSettingsContentView.swift
│   ├── settingsStations.swift
│   ├── settingsLineName.swift
│   ├── settingsRideTime.swift
│   ├── settingsTransportation.swift
│   └── settingsTransitTime.swift
├── Common/                               # Shared components
│   ├── Assets.xcassets/
│   ├── Constant.swift
│   ├── EnumSetting.swift
│   ├── SizeConstant.swift
│   ├── DataExtension.swift
│   ├── TimeExtension.swift
│   ├── ColorExtension.swift
│   ├── Config.swift                      # AdMob configuration management
│   ├── en.lproj/                         # English localization
│   └── ja.lproj/                         # Japanese localization
├── Font/                                 # Custom fonts
│   ├── GenEiGothicN-*.otf
│   └── LICENSE.txt
├── Info.plist                           # App configuration
├── GoogleService-Info.plist             # Firebase configuration
└── mytimetablemaker_swiftuiRelease.entitlements
```

## 🎨 Customization

### Timetable Features
- **Week Management**: Monday to Sunday schedule management
- **Time Entry**: Add, edit, and delete time entries
- **Station Management**: Configure departure and arrival stations
- **Line Configuration**: Set up train lines and routes
- **Transport Options**: Various transportation modes
- **Image Support**: Add custom images to timetables

### User Interface
- **Modern SwiftUI Interface**: Declarative UI with smooth animations
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Dark/Light Mode**: System appearance support
- **Localization**: Japanese and English support
- **Custom Fonts**: GenEiGothicN font family

### Data Management
- **Cloud Sync**: Firebase Firestore integration
- **Local Storage**: UserDefaults for settings
- **Image Storage**: Local image management
- **Cloud Sync**: Firebase Firestore for data synchronization

## 📱 Supported Platforms

- **iOS**: iOS 15.6+
- **iPad**: iPadOS 15.6+

## 🔧 Development

### Code Analysis
```bash
# SwiftLint (if configured)
swiftlint

# Xcode build analysis
xcodebuild analyze -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftui
```

### Run Tests
```bash
# Unit Tests
xcodebuild test -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftui -destination 'platform=iOS Simulator,name=iPhone 16'

# UI Tests
xcodebuild test -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftuiUITests -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Build
```bash
# Debug Build
xcodebuild build -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftui -configuration Debug

# Release Build
xcodebuild build -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftui -configuration Release

# Archive for App Store
xcodebuild archive -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftui -archivePath build/mytimetablemaker_swiftui.xcarchive
```

## 🔒 Security

This project includes comprehensive security measures to protect sensitive information:
- **Environment Variables**: API keys and sensitive data stored in configuration files
- **Git Exclusions**: Firebase configuration files excluded from version control
- **Secure Storage**: UserDefaults for local data storage
- **Firebase Security**: App Check and Authentication integration
- **Code Obfuscation**: Production builds with optimized code

### Security Features
- Firebase App Check for API protection
- User authentication with email/password
- Secure data transmission with HTTPS
- Local data encryption
- AdMob integration with secure ad serving

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

We welcome contributions! Please feel free to submit pull requests or create issues for bugs and feature requests.

### Contribution Guidelines
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

If you have any problems or questions, please create an issue on GitHub or contact the development team.
<<<<<<< HEAD
=======

>>>>>>> 62ded4e0371b7659ed61348b05e40bcbe2a94148
## 🚀 Getting Started

For new developers:
1. Follow the setup instructions above
2. Review the application structure
3. Check the customization options
4. Start with `mytimetablemaker_swiftuiApp.swift` to understand the app flow
5. Explore the SwiftUI implementation

## 📊 Project Statistics

- **Lines of Code**: 15,000+
- **Swift Files**: 50+
- **Supported Languages**: 2 (Japanese, English)
- **Target Platforms**: iOS 15.6+, iPadOS 15.6+ (iPhone & iPad)
- **Dependencies**: 10+ external libraries

---

<div align="center">
  <strong>My Time Table Maker</strong> - Organize your time, organize your life!
</div>

## Licenses & Credits

This app uses the following open-source libraries and frameworks:

- **SwiftUI** (Apple License)
- **Firebase** (Apache License 2.0)
  - firebase_core
  - firebase_auth
  - firebase_firestore
  - firebase_analytics
- **Google Mobile Ads** (Apache License 2.0)
- **Swift Package Manager** (Apple License)

### Font Licenses
- **GenEiGothicN Font Family** (SIL Open Font License 1.1)

For details of each license, please refer to the respective documentation or LICENSE files in each repository.

## Acknowledgments

- Firebase team for excellent documentation and support
- Google Mobile Ads team for ad integration
- Apple for SwiftUI framework
- Open source community for various tools and libraries

---
