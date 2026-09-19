# My Transit Makers

<div align="center">
  <img src="mytimetablemaker_swiftui/Assets.xcassets/icon.imageset/icon.png" alt="My Transit Maker Icon" width="120" height="120">
  <br>
  <strong>Create and manage your personal timetable with ease</strong>
  <br>
  <strong>Smart timetable management for iOS with Firebase integration</strong>
</div>

## 📱 Application Overview

My Transit Makers is a SwiftUI iOS application for building personal timetables for daily commutes.
It combines Firebase authentication and Firestore storage with railway and bus data from the ODPT API.

### 🎯 Key Features

- **Personal Timetable Creation**: Create custom transit guides for daily commutes and schedules
- **Countdown Display**: Real-time countdown to departure time
- **Route Comparison**: Display and compare two routes simultaneously
- **Home/Office Routes**: Register separate routes for commuting and return trips with easy switching
- **Automatic Timetable Generation**: Auto-generate timetables for supported railway lines and bus routes
- **SwiftUI Interface**: Declarative UI with smooth animations
- **Firebase Integration**: Authentication, Firestore, Analytics, App Check
- **User Authentication**: Sign up, login, password reset
- **Railway Data Integration**: ODPT API; the GTFS code path is present but currently disabled
- **Multi-language Support**: Japanese and English localization
- **Google Mobile Ads**: Banner ads
- **Data Synchronization**: Firestore save and get (`FirestoreViewModel.setFirestore()` / `getFirestore()`), keyed on the signed-in user's uid
- **Account Deletion**: `LoginViewModel.delete()` removes the Firebase Auth user and the Firestore document it owns
- **Image Management**: Photo picker for timetable images
- **Caching**: Fetched line and station data are cached on the device

## 🚀 Technology Stack

### Frameworks & Libraries

- **SwiftUI**: UI, with `@UIApplicationDelegateAdaptor` for launch-time setup
- **Firebase iOS SDK**: FirebaseAuth, FirebaseFirestore, FirebaseAnalytics, FirebaseAppCheck
- **Google Mobile Ads**: Banner ads
- **swift-algorithms**: linked by the project, but no source file imports it today
- **ZipArchive**: Used by the GTFS code path, which is currently disabled
- **Swift Package Manager**: The only dependency manager used here; there is no Podfile
- **ODPT API**: Railway and bus data from the Open Data Platform for Transportation

### Local Storage

- **UserDefaults**: Settings, route configuration, and the cached ETag and Last-Modified values per operator
- **On-disk cache**: Operator data fetched from the ODPT API

## 📋 Prerequisites

- An Xcode with a Swift 6.1 or later toolchain, because `firebase-ios-sdk` declares `swift-tools-version:6.1`
- iOS 16.6 or later (`IPHONEOS_DEPLOYMENT_TARGET` on the app target)
- iOS 17.0 or later to run the tests: the test targets are built against 17.0, so an older simulator will not run them
- A Firebase project with Authentication, Firestore and App Check enabled
- A Google Mobile Ads account, for the release banner unit id
- An ODPT access token and challenge token, for railway and bus data

## 🛠️ Setup

### 1. Clone the Repository

```bash
git clone https://github.com/fcb1899v/mytimetablemaker_swift.git
cd mytimetablemaker_swift
```

### 2. Configuration Files Setup

Two build configuration files are untracked and have to be created.
Copy each template next to itself and drop the `.example`:

```bash
cp mytimetablemaker_swiftui/Debug.xcconfig.example   mytimetablemaker_swiftui/Debug.xcconfig
cp mytimetablemaker_swiftui/Release.xcconfig.example mytimetablemaker_swiftui/Release.xcconfig
```

Each template lists all four keys with what belongs in them, and is the one place that list is maintained.
`CONFIGURATION.md` covers the same ground alongside the files that are tracked, and records which two values the Compose repository holds a second copy of.

`Info.plist` copies all four keys into the bundle through `$(KEY)`, so everything in these files ships inside the app.
Nothing that grants server access belongs in them.

The Xcode project names both files as its build configuration files, so a missing one is not a build error: the keys resolve to empty, and the guards in `AdMobBannerView` and `mytimetablemaker_swiftuiApp` fall back instead.
A release built that way shows no ads rather than failing.

### 3. Resolve Dependencies

The project resolves these Swift packages, all declared in `mytimetablemaker_swiftui.xcodeproj`:

- `firebase-ios-sdk`, up to the next major from 12.0.0, so 12.x (FirebaseAuth, FirebaseFirestore, FirebaseAnalytics, FirebaseAppCheck)
- `swift-package-manager-google-mobile-ads`, up to the next major from 12.0.0, so 12.x (GoogleMobileAds)
- `swift-algorithms`, up to the next major from 1.2.1, so 1.x (Algorithms)
- `ZipArchive`, up to the next major from 2.6.0, so 2.x (linked for the GTFS code path, which is currently disabled)

`Package.resolved` is tracked, so this resolves to the pinned versions rather than to whatever is current.
Updating a package changes that file.

```bash
xcodebuild -resolvePackageDependencies
```

### 4. Firebase Configuration

1. Create a Firebase project and enable Email/Password authentication.
2. Place `GoogleService-Info.plist` in the `mytimetablemaker_swiftui/` directory.
   It is not tracked here, so download it from the Firebase Console for your own project.
3. Register the App Check providers: a debug token for the simulator, DeviceCheck for release.
   `AppCheckState` installs the provider before `FirebaseApp.configure()`, and debug builds print a token to register in the Firebase Console.

### 5. Run the Application

```bash
# Open in Xcode
open mytimetablemaker_swiftui.xcodeproj

# Or build from the command line
xcodebuild build -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftui -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'
```

## 🎮 Application Structure

```
mytimetablemaker_swiftui/
├── mytimetablemaker_swiftuiApp.swift  # Entry point, Firebase and App Check setup, AppCheckState
├── CommonContentView/                 # Common content views and sheets
│   ├── AdMobBannerView.swift          # AdMob banner advertisement view
│   ├── CustomComponents.swift         # Custom reusable UI components
│   ├── NavigationBarModifier.swift    # Navigation bar customization
│   ├── SettingsLineSheet.swift        # Line configuration sheet
│   ├── SettingsLineViewModel.swift    # Line settings, operator and timetable fetching
│   └── SettingsTransferSheet.swift    # Transfer configuration sheet
├── LoginContentView/                  # Authentication views
│   ├── LoginContentView.swift         # Login screen view
│   ├── LoginViewModel.swift           # Login view model
│   └── SignUpContentView.swift        # Sign up screen view
├── MainContentView/                   # Main app views
│   ├── MainContentView.swift          # Main content view
│   ├── MainViewModel.swift            # Main view model
│   └── SplashContentView.swift        # Splash screen view
├── SettingsContentView/               # Settings views
│   ├── SettingsContentView.swift      # Settings screen view
│   └── FirestoreViewModel.swift       # Firestore save and get
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
│   ├── Enums.swift                    # Operators, API types, endpoints, GTFS feed dates
│   └── TransportationModels.swift     # Transportation types and models
├── Services/                          # Service layer
│   ├── CacheService.swift             # ODPT cache management; its GTFS branches are commented out
│   ├── ODPTDataService.swift          # ODPT API integration
│   └── GTFSDataService.swift          # GTFS download, extraction and parsing; nothing selectable in the app leads here
├── Assets.xcassets/                   # App assets
├── Font/                              # GenEiGothicN Regular, the only weight the app asks for, and its LICENSE.txt
├── Preview Content/                   # Preview assets for SwiftUI
├── en.lproj/                          # English localization
├── ja.lproj/                          # Japanese localization
├── Info.plist                         # App configuration, reads the four xcconfig keys
├── GoogleService-Info.plist           # Firebase configuration, not tracked; download it from the console
├── Debug.xcconfig.example             # Debug config template (copy, drop .example)
├── Release.xcconfig.example           # Release config template (copy, drop .example)
├── mytimetablemaker_swiftuiRelease.entitlements
└── mytimetablemaker_swiftui.xcdatamodeld/  # Core Data model
```

`mytimetablemaker_uikit/` is the legacy UIKit version, kept for reference and not part of the SwiftUI target.

## 🚂 Railway and Bus Data

### How an Operator Reaches Its Data

`LocalDataSource.apiType` in `Models/Enums.swift` decides which endpoint an operator uses, and `apiLink(for:transportationKind:)` builds the URL.
Tokens are passed as the `acl:consumerKey` query parameter.

| API type | Host | Token | Operators |
|---|---|---|---|
| `publicAPI` | `api-public.odpt.org` | none | Toei Subway, Toei Bus |
| `standard` | `api.odpt.org` | `ODPT_ACCESS_TOKEN` | Tokyo Metro, Yokohama Municipal Subway, Tsukuba Express, Tama Monorail, Yurikamome, TWR (Rinkai), Tokyu Bus, Seibu Bus, Sotetsu Bus, Yokohama Municipal Bus |
| `challenge` | `api-challenge.odpt.org` | `ODPT_CHALLENGE_TOKEN` | JR East, Tokyu, Odakyu, Keikyu, Tobu, Seibu, Sotetsu, Kanachu, Kokusai Kogyo, Tobu Bus |
| `gtfs` (disabled) | GTFS ZIP files | `ODPT_ACCESS_TOKEN` | Keio Bus, Nishitokyo Bus, Kawasaki City Bus, Kawasaki Tsurumi Rinko Bus, Kanto Bus, Izuhakone Bus, Keisei Transit Bus |

The challenge host is not a testing switch: the operators above publish their data there, so those routes stop working without `ODPT_CHALLENGE_TOKEN`.

**GTFS is currently paused, so the seven `gtfs` operators cannot be selected in the app.**
`SettingsLineViewModel` filters them out of the operator list with `dataSource.apiType != .gtfs`, and the GTFS branches in `CacheService` and `SettingsLineSheet` are commented out. Four of the calls into `GTFSDataService` sit behind `apiType == .gtfs`, and the fifth, `fetchGTFSLinesForOperator`, has its only caller commented out. None of it is maintained.

### Endpoints in Use

- **Railway lines**: `odpt:Railway`
- **Train timetable**: `odpt:TrainTimetable`
- **Station timetable**: `odpt:StationTimetable`
- **Bus route pattern**: `odpt:BusroutePattern`
- **Bus timetable**: `odpt:BusTimetable`
- **Bus stop pole**: `odpt:BusstopPole`
- **GTFS files**, while the path is disabled: `https://api.odpt.org/api/v4/files/odpt/KeioBus/AllLines.zip?date=20260126&acl:consumerKey={token}`

That GTFS URL looks irregular because `operatorCode` already carries the file path and the `?`, for example `KeioBus/AllLines.zip?` in `LocalDataSource`, and `apiLink` appends `date=...` straight onto it.
GTFS feed dates are hardcoded per operator in `GTFSDates` (`Models/Enums.swift`), because the standard API serves one feed per date.
They are not repeated here: a feed date that is right in two places and wrong in a third is worse than one place to look.

### Caching and Update Checks

- ETag and Last-Modified are stored in UserDefaults per operator, and sent back as `If-None-Match` and `If-Modified-Since`
- A 304 response means the cached data is reused
- Timetables themselves are fetched on demand rather than cached
- No GTFS caching happens today, because the GTFS branches in `CacheService.swift` are commented out

### Time Handling

Departure times between 00:00 and 03:00 belong to the previous service day, so 24 hours are added to them.
This keeps early morning services sorted and displayed after the late night ones rather than at the top.

Calendar types are passed as `odpt:calendar`: weekday, saturday, sunday, holiday, saturdayHoliday, and the individual weekdays.

### Automatic Timetable Generation

`hasTrainTimeTable` and `hasBusTimeTable` in `Models/Enums.swift` decide whether the auto-generate button is available.

**Railway, nine operators**: JR East, Tokyo Metro, Toei Subway, Yokohama Municipal Subway, Tobu Railway, Sotetsu (Sagami Railway), Tokyo Waterfront Area Rapid Transit, Tsukuba Express, Tama Monorail.

**Railway, line and station selection only**: Tokyu Railway, Keikyu Railway, Odakyu Railway, Seibu Railway, Yurikamome.
This app fetches no timetable for them, so their timetables have to be entered by hand.

**Bus**: `hasBusTimeTable` is true for every bus operator, but only the ODPT ones can be reached today: Tobu Bus, Toei Bus, Yokohama Municipal Bus, Tokyu Bus, Seibu Bus, Sotetsu Bus, Kanachu, Kokusai Kogyo.
The seven GTFS operators are filtered out of the operator list, so their timetables cannot be generated while GTFS is paused.

Two behaviours follow from generation:

- **Train type selection**: A route generated from ODPT offers only the train types returned at generation time, while a manually entered route offers the default five
- **Line and operator persistence**: Saving line settings stores the line-selected flag and the operator code, which is how the timetable sheet tells generated routes from manual ones

### Error Handling

- Requests time out after 30 seconds, resources after 60
- JSON parsing failures are caught and logged
- Non-200 responses are reported as errors
- A redirect drops the consumer key, so a redirected request is unauthenticated

## 📱 Supported Platforms

- **iOS**: 16.6 or later
- **iPadOS**: 16.6 or later
- **Devices**: iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`)

## 🔧 Development

### Build

```bash
# Debug build
xcodebuild build -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftui -configuration Debug

# Release build
xcodebuild build -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftui -configuration Release

# Archive for the App Store
xcodebuild archive -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftui -archivePath build/mytimetablemaker_swiftui.xcarchive
```

### Analyze

```bash
xcodebuild analyze -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftui
```

### Tests

The repository carries the Xcode test templates in `mytimetablemaker_swiftuiTests/` and `mytimetablemaker_swiftuiUITests/`, so these run but check nothing of the app yet.

```bash
xcodebuild test -project mytimetablemaker_swiftui.xcodeproj -scheme mytimetablemaker_swiftui -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'
```

## 📄 License

This project is not open source.
The source is published so that it can be read, and all rights are reserved.
See [LICENSE](LICENSE) for what that permits.
Third-party components keep their own licenses, listed below.

## 🤝 Contributing

Issue reports are welcome.
Pull requests are not accepted, because the code is not licensed for redistribution.

## 📞 Support

If you have any problems or questions, please create an issue on GitHub.

## Licenses & Credits

This app uses the following third-party components:

- **SwiftUI** (Apple)
- **Firebase iOS SDK** (Apache License 2.0): FirebaseAuth, FirebaseFirestore, FirebaseAnalytics, FirebaseAppCheck
- **Google Mobile Ads** (the Swift package is Apache License 2.0, but it ships no source of its own: its `Package.swift` declares a `binaryTarget` that downloads `googlemobileadsios-spm-*.zip` from `dl.google.com`, and depends on the User Messaging Platform package, which downloads `googleusermessagingplatformios-spm-*.zip` the same way)
- **User Messaging Platform**, the consent SDK reached through Google Mobile Ads (its Swift package is Apache License 2.0; the binary it downloads is a proprietary Google distribution)
- **swift-algorithms** (Apache License 2.0)
- **ZipArchive** (MIT License)

### Font Licenses

- **GenEiGothicN Regular** (SIL Open Font License 1.1), with the full text in `mytimetablemaker_swiftui/Font/LICENSE.txt`

### Data Sources

- **ODPT (Open Data Platform for Transportation)**: Railway and bus data, at [odpt.org](https://www.odpt.org/)

For details of each license, please refer to the respective repositories.
