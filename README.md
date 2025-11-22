# My Transit Makers

<div align="center">
  <img src="mytimetablemaker_swiftui/Assets.xcassets/icon.imageset/icon.png" alt="My Transit Maker Icon" width="120" height="120">
  <br>
  <strong>Create and manage your personal timetable with ease</strong>
  <br>
  <strong>Smart timetable management for iOS with Firebase integration</strong>
</div>

## 📱 Application Overview

My Transit Makers is a SwiftUI-based iOS application that helps users create and manage personal timetables for daily commutes and schedules. It provides a comprehensive solution with Firebase integration, user authentication, real-time railway data, and modern SwiftUI interface.

### 🎯 Key Features

- **Personal Timetable Creation**: Create custom transit guides for daily commutes and schedules
- **Countdown Display**: Real-time countdown to departure time
- **Route Comparison**: Display and compare two routes simultaneously
- **Home/Office Routes**: Register separate routes for commuting and return trips with easy switching
- **Automatic Timetable Generation**: Auto-generate timetables for supported railway lines and bus routes
- **Modern SwiftUI Interface**: Declarative UI with smooth animations
- **Firebase Integration**: Authentication, Firestore database, Analytics
- **User Authentication**: Sign up, login, password reset functionality
- **Railway Data Integration**: Real-time data from ODPT API and local railway databases
- **Timetable Management**: Create, edit, and manage personal timetables
- **Multi-language Support**: Japanese and English localization
- **Google Mobile Ads**: Banner ads integration
- **Data Synchronization**: Cloud-based data storage and sync
- **Customizable Settings**: Various configuration options
- **Image Management**: Photo picker and image handling
- **Offline Support**: Local railway data files for offline functionality

## 🚀 Technology Stack

### Frameworks & Libraries
- **SwiftUI**: Modern declarative UI framework
- **Firebase**: Authentication, Firestore, Core (via Firebase SDK)
- **Google Mobile Ads**: Advertisement display
- **Swift Package Manager**: Dependency management
- **ODPT API**: Real-time railway data from Open Data Platform for Transportation

### Core Features
- **Authentication**: Firebase Auth for user management
- **Database**: Cloud Firestore for data storage
- **Railway Data**: ODPT API integration with local fallback data
- **Ads**: Google Mobile Ads SDK
- **Localization**: Multi-language support
- **Image Handling**: Photo picker and image processing
- **Data Management**: UserDefaults for local storage
- **Navigation**: SwiftUI NavigationView
- **Caching**: Intelligent data caching for offline access

## 📋 Prerequisites

- Xcode 14.0+
- iOS 16.6+
- Swift Package Manager
- Firebase project setup
- Google Mobile Ads account
- ODPT API access token (optional, for real-time railway data)
- ODPT API challenge token (optional, for ODPT API authentication)

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
   - `ODPT_ACCESS_TOKEN`: Your ODPT API access token (optional, for real-time railway data)
   - `ODPT_CHALLENGE_TOKEN`: Your ODPT API challenge token (optional, for API authentication)

```bash
cp mytimetablemaker_swiftui/Release.xcconfig.template mytimetablemaker_swiftui/Release.xcconfig
```

### 3. Install Dependencies

This project uses Swift Package Manager for dependency management. The following packages are included:
- Firebase iOS SDK (Authentication, Firestore)
- Google Mobile Ads SDK
- Swift Algorithms

```bash
# Resolve Swift Package Manager dependencies
xcodebuild -resolvePackageDependencies
```

**Note**: A `Podfile` exists in the project root, but it is for the legacy UIKit project (`mytimetablemaker_uikit`). The current SwiftUI project (`mytimetablemaker_swiftui`) uses Swift Package Manager only.

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
├── mytimetablemaker_swiftuiApp.swift  # Application entry point
├── CommonContentView/                 # Common content views and sheets
│   ├── AdMobBannerView.swift          # AdMob banner advertisement view
│   ├── CustomComponents.swift         # Custom reusable UI components
│   ├── NavigationBarModifier.swift    # Navigation bar customization
│   ├── SettingsLineSheet.swift        # Line configuration sheet
│   ├── SettingsLineViewModel.swift    # Line settings view model
│   └── SettingsTransferSheet.swift    # Transfer configuration sheet
├── LoginContentView/                  # Authentication views
│   ├── LoginContentView.swift         # Login screen view
│   ├── LoginViewModel.swift           # Login view model
│   └── SignUpContentView.swift        # Sign up screen view
├── MainContentView/                   # Main app views
│   ├── MainContentView.swift          # Main content view
│   ├── MainViewModel.swift            # Main view model
│   ├── MyTransit.swift                # Transit data model
│   └── SplashContentView.swift        # Splash screen view
├── SettingsContentView/               # Settings views
│   ├── SettingsContentView.swift      # Settings screen view
│   └── FirestoreViewModel.swift       # Firebase Firestore view model
├── TimetableContentView/              # Timetable views
│   ├── TimetableContentView.swift     # Timetable content view
│   ├── SettingsTimetableSheet.swift   # Timetable settings sheet
│   └── ImagePicker.swift              # Image picker component
├── Extensions/                        # Swift extensions
│   ├── AccountExtensions.swift        # Account-related extensions
│   ├── ColorExtensions.swift          # Color utility extensions
│   ├── LineExtensions.swift           # Line-related extensions
│   ├── SizeExtensions.swift           # Size calculation extensions
│   └── TimeExtensions.swift           # Time formatting and calculations
├── Models/                            # Data models
│   ├── Enums.swift                    # App enumerations
│   └── TransportationModels.swift     # Transportation types and models
├── Services/                          # Service layer
│   ├── CacheService.swift             # Data caching management
│   └── ODPTDataService.swift          # ODPT API integration
├── Assets.xcassets/                   # App assets
│   ├── AppIcon.appiconset/            # App icon assets
│   ├── icon.imageset/                 # App icon image set
│   └── splash.imageset/               # Splash screen images
├── Font/                              # Custom fonts
│   ├── GenEiGothicN-Bold.otf          # Bold font weight
│   ├── GenEiGothicN-ExtraLigh.otf     # Extra light font weight
│   ├── GenEiGothicN-Heavy.otf         # Heavy font weight
│   ├── GenEiGothicN-Ligh.otf          # Light font weight
│   ├── GenEiGothicN-Regular.otf       # Regular font weight
│   ├── GenEiGothicN-SemiBold.otf      # Semi-bold font weight
│   ├── GenEiGothicN-SemiLight.otf     # Semi-light font weight
│   └── LICENSE.txt                    # Font license
├── Preview Content/                   # Preview assets for SwiftUI
│   └── Preview Assets.xcassets/
├── en.lproj/                          # English localization
│   ├── InfoPlist.strings              # Info.plist localization
│   └── Localizable.strings            # App strings localization
├── ja.lproj/                          # Japanese localization
│   ├── InfoPlist.strings              # Info.plist localization
│   └── Localizable.strings            # App strings localization
├── Info.plist                         # App configuration
├── GoogleService-Info.plist           # Firebase configuration
├── Debug.xcconfig                     # Debug build configuration
├── Release.xcconfig                   # Release build configuration
├── Release.xcconfig.template          # Release config template
├── mytimetablemaker_swiftuiRelease.entitlements
└── mytimetablemaker_swiftui.xcdatamodeld/ # Core Data model
    └── mytimetablemaker_swiftui.xcdatamodel/
```

## 🚂 Railway Data Integration

### ODPT API Integration
The app integrates with the Open Data Platform for Transportation (ODPT) API to provide real-time railway information:

- **Real-time Data**: Station information, line details, and operator data
- **Automatic Caching**: Intelligent caching system for offline access
- **Data Validation**: ETag and Last-Modified header support for efficient updates
- **Fallback Support**: Local JSON files provide data when API is unavailable

### Local Railway Database
Comprehensive offline railway data covering major operators in Japan:

**Railway Operators:**
- **JR East**: Complete station and line data
- **Tokyo Metro**: Full subway network coverage
- **Toei Subway**: Full subway network coverage
- **Yokohama Municipal Subway**: Complete subway line data
- **Private Railways**: Tokyu Railway, Keikyu Railway, Odakyu Railway, Seibu Railway, Tobu Railway, Sotetsu Railway
- **Monorails**: Tama Monorail, Yurikamome
- **Regional Lines**: Tsukuba Express (首都圏新都市鉄道), Rinkai Line (東京臨海高速鉄道)

**Bus Operators:**
- **Toei Bus**: Comprehensive bus route coverage
- **Yokohama Municipal Bus**: Complete bus route data
- **Tokyu Bus**: Major bus routes
- **Seibu Bus**: Complete bus network
- **Sotetsu Bus**: Sotetsu Railway bus routes
- **Kanachu Bus**: Kanagawa Chuo Bus routes
- **Kokusai Kogyo**: International Kogyo Bus routes
- **Odakyu Bus**: Odakyu Railway bus routes
- **Keio Bus**: Keio Railway bus routes
- **Nishitokyo Bus**: Nishitokyo Bus routes

### Automatic Timetable Generation
The app features automatic timetable generation for supported operators using the Open Data Platform for Transportation (ODPT) API.

**Note**: Some operators (Tokyu Railway, Keikyu Railway, Odakyu Railway, Seibu Railway, Yurikamome) use proprietary algorithms for automatic generation, which may result in incorrect timetables. Manual correction is available when needed.

### Data Processing
- **Multi-format Support**: Handles various JSON data formats
- **Localization**: Japanese and English station/line names
- **Color Coding**: Line color information for visual identification
- **Station Ordering**: Maintains correct station sequence on each line

## 🎨 Customization

### Timetable Features
- **Week Management**: Monday to Sunday schedule management
- **Time Entry**: Add, edit, and delete time entries
- **Station Management**: Configure departure and arrival stations
- **Line Configuration**: Set up train lines and routes with real data
- **Transport Options**: Various transportation modes (walking, bicycle, car)
- **Image Support**: Add custom images to timetables
- **Color Customization**: 20+ color options for line identification

### User Interface
- **Modern SwiftUI Interface**: Declarative UI with smooth animations
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Dark/Light Mode**: System appearance support
- **Localization**: Japanese and English support
- **Custom Fonts**: GenEiGothicN font family (SIL Open Font License)
- **Accessibility**: VoiceOver and accessibility features support

### Data Management
- **Cloud Sync**: Firebase Firestore integration
- **Local Storage**: UserDefaults for settings and preferences
- **Image Storage**: Local image management
- **Cache Management**: Intelligent data caching for performance
- **Offline Mode**: Full functionality without internet connection

## 📱 Supported Platforms

- **iOS**: iOS 16.6+
- **iPad**: iPadOS 16.6+
- **Device Support**: iPhone and iPad optimized layouts

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
- User authentication with email/password
- Secure data transmission with HTTPS
- Local data encryption
- AdMob integration with secure ad serving
- ODPT API token management

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

## 🚀 Getting Started

For new developers:
1. Follow the setup instructions above
2. Review the application structure
3. Check the customization options
4. Start with `mytimetablemaker_swiftuiApp.swift` to understand the app flow
5. Explore the SwiftUI implementation
6. Understand the Services layer for data management

## 📊 Project Statistics

- **Lines of Code**: 12,000+
- **Swift Files**: 60+
- **Railway Data Files**: 16 JSON files covering major Japanese railways
- **Supported Languages**: 2 (Japanese, English)
- **Target Platforms**: iOS 16.6+, iPadOS 16.6+
- **External Dependencies**: Firebase, Google Mobile Ads, ODPT API
- **Data Coverage**: 1000+ railway stations across Japan
- **Supported Railway Operators**: 14 operators
- **Supported Bus Operators**: 10 operators

---

<div align="center">
  <strong>My Transit Makers</strong> - Organize your commute, organize your day!
</div>

## Licenses & Credits

This app uses the following open-source libraries and frameworks:

- **SwiftUI** (Apple License)
- **Firebase** (Apache License 2.0)
  - firebase_core
  - firebase_auth
  - firebase_firestore
- **Google Mobile Ads** (Apache License 2.0)
- **Swift Package Manager** (Apple License)
- **ODPT API** (Open Data Platform for Transportation)

### Font Licenses
- **GenEiGothicN Font Family** (SIL Open Font License 1.1)

### Data Sources
- **ODPT (Open Data Platform for Transportation)**: Real-time railway data
- **Local Railway Data**: Compiled from various public transportation sources

For details of each license, please refer to the respective documentation or LICENSE files in each repository.

## Acknowledgments

- Firebase team for excellent documentation and support
- Google Mobile Ads team for ad integration
- Apple for SwiftUI framework
- ODPT team for providing comprehensive transportation data
- Open source community for various tools and libraries
- Railway operators in Japan for providing public transportation data

---
