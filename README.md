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
│   ├── ODPTDataService.swift          # ODPT API integration
│   └── GTFSDataService.swift          # GTFS data processing
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

### Open Data Platform for Transportation (ODPT) API Usage

The application uses the ODPT API (公共交通オープンデータセンター API) to fetch real-time transportation data. This section explains how the API is integrated and used in the application.

#### API Endpoints

The application uses the following ODPT API endpoints. All endpoints use query parameters for authentication (`&acl:consumerKey={token}`), except for Public API endpoints.

**Standard API Endpoints** (`api.odpt.org` - require `ODPT_ACCESS_TOKEN`):
- **Railway Data**: `https://api.odpt.org/api/v4/odpt:Railway?odpt:operator={operatorCode}&acl:consumerKey={accessToken}`
- **Bus Route Pattern**: `https://api.odpt.org/api/v4/odpt:BusroutePattern?odpt:operator={operatorCode}&acl:consumerKey={accessToken}`
- **Train Timetable**: `https://api.odpt.org/api/v4/odpt:TrainTimetable?odpt:operator={operatorCode}&acl:consumerKey={accessToken}`
- **Bus Timetable**: `https://api.odpt.org/api/v4/odpt:BusTimetable?odpt:operator={operatorCode}&acl:consumerKey={accessToken}`
- **Bus Stop Pole**: `https://api.odpt.org/api/v4/odpt:BusstopPole?odpt:operator={operatorCode}&acl:consumerKey={accessToken}`
- **Bus GTFS Files**: `https://api.odpt.org/api/v4/files/odpt/{operatorCode}?date={YYYYMMDD}&acl:consumerKey={accessToken}`
  - Date parameter format: `YYYYMMDD` (e.g., `20251117`)
  - Required for most GTFS operators (Yokohama Bus, Keio Bus, Nishitokyo Bus, Kawasaki Bus, etc.)

**Challenge API Endpoints** (`api-challenge.odpt.org` - require `ODPT_CHALLENGE_TOKEN`):
- Same endpoints as Standard API, but replace `api.odpt.org` with `api-challenge.odpt.org` and use `{challengeToken}` instead of `{accessToken}`
- Used for testing and development

**Public API Endpoints** (`api-public.odpt.org` - no authentication required):
- **Toei Bus GTFS**: `https://api-public.odpt.org/api/v4/files/{operatorCode}`
  - No token required
  - No date parameter needed

**Token Configuration:**

Tokens are configured in `Release.xcconfig` (not included in Git):

- **ODPT_ACCESS_TOKEN**: Used for Standard API endpoints (`api.odpt.org`)
  - Required for most operators and GTFS ZIP downloads
  - Provides full data access
  - Passed as query parameter: `&acl:consumerKey={accessToken}`

- **ODPT_CHALLENGE_TOKEN**: Used for Challenge API endpoints (`api-challenge.odpt.org`)
  - Used for testing and development
  - Passed as query parameter: `&acl:consumerKey={challengeToken}`

- **No Token**: Used for Public API endpoints (`api-public.odpt.org`)
  - Limited data access
  - Currently only used for Toei Bus GTFS files

**Note**: The application also supports Authorization header authentication as an alternative to query parameters, but query parameters are the primary method used in the codebase.

#### API Authentication

The ODPT API supports multiple authentication methods:

1. **Standard API** (`api.odpt.org`)
   - Requires `ODPT_ACCESS_TOKEN` (configured in `Release.xcconfig`)
   - Full data access
   - Used for most operators and GTFS ZIP downloads

2. **Challenge API** (`api-challenge.odpt.org`)
   - Requires `ODPT_CHALLENGE_TOKEN` (configured in `Release.xcconfig`)
   - Used for testing and development

3. **Public API** (`api-public.odpt.org`)
   - No authentication required
   - Limited data access
   - Currently only used for Toei Bus GTFS files

#### Request Configuration

The `ODPTDataService` class handles all API communication:

```swift
// Authentication header
request.setValue(consumerKey, forHTTPHeaderField: "Authorization")
request.setValue("application/json", forHTTPHeaderField: "Accept")

// Conditional GET headers for efficient caching
request.setValue(etag, forHTTPHeaderField: "If-None-Match")
request.setValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
```

#### Data Fetching Flow

1. **Initial Request**: Fetch operator data using `fetchIndividualOperatorData()`
2. **Cache Check**: Check if cached data exists
3. **Update Check**: Use conditional GET with ETag/Last-Modified headers
4. **Data Processing**: Parse JSON response using `ODPTParser`
5. **Cache Update**: Save updated data and headers for future requests

#### Efficient Update Checking

The application implements efficient update checking using HTTP conditional requests:

- **ETag Support**: Server provides ETag header, client sends `If-None-Match` header
- **Last-Modified Support**: Server provides `Last-Modified` header, client sends `If-Modified-Since` header
- **304 Not Modified**: Server returns 304 status when data hasn't changed
- **Automatic Caching**: ETag and Last-Modified values are stored in UserDefaults per operator

#### ODPT API Timetable Generation

The application generates timetables using ODPT API endpoints for both railway and bus operators (excluding GTFS operators). This section explains the detailed process of creating timetables from ODPT API data.

**Timetable Generation Overview:**

The application uses three main ODPT API endpoints for timetable data:
- **Train Timetable** (`odpt:TrainTimetable`): Railway timetable data
- **Bus Timetable** (`odpt:BusTimetable`): Bus timetable data
- **Station Timetable** (`odpt:StationTimetable`): Station-specific timetable data

**Railway Timetable Generation Flow:**

1. **API Request**: Fetch train timetable data from ODPT API
   - Endpoint: `https://api.odpt.org/api/v4/odpt:TrainTimetable?odpt:operator={operatorCode}&odpt:railway={railwayCode}&odpt:calendar={calendarType}&odpt:railDirection={direction}&acl:consumerKey={accessToken}`
   - Parameters:
     - `odpt:operator`: Operator code (e.g., `odpt.Operator:JR-East`)
     - `odpt:railway`: Railway line code (e.g., `odpt.Railway:JR-East.Yamanote`)
     - `odpt:calendar`: Calendar type (weekday, saturday, sunday, holiday, etc.)
     - `odpt:railDirection`: Rail direction (ascending or descending) - optional
     - `acl:consumerKey`: Access token

2. **Direction Detection**:
   - If `odpt:railDirection` is not specified, fetch data for both directions
   - Use `odpt:ascendingRailDirection` and `odpt:descendingRailDirection` from railway data
   - Determine correct direction based on departure and arrival stations

3. **Data Parsing**:
   - Parse JSON response containing timetable objects
   - Extract train information:
     - `odpt:trainNumber`: Train number/identifier
     - `odpt:departureTime`: Departure time from origin station
     - `odpt:arrivalTime`: Arrival time at destination station
     - `odpt:trainType`: Train type (Local, Rapid, Express, etc.)
     - `odpt:destinationStation`: Destination station name

4. **Time Processing**:
   - Apply time adjustments for next-day times (0-3 AM times are adjusted by adding 24 hours)
   - Convert time strings to internal time format
   - Calculate ride time between departure and arrival stations

5. **Route Validation**:
   - For loop lines (e.g., Yamanote Line), both directions may have data
   - Select direction with shorter average ride time
   - Validate that selected stations exist in the timetable data

6. **Data Conversion**: Convert parsed data to internal `TransportationTime` models:
   - `TrainTime`: Railway timetable entries with departure/arrival times
   - Includes train number, train type, and ride time information

**Bus Timetable Generation Flow:**

1. **API Request**: Fetch bus timetable data from ODPT API
   - Endpoint: `https://api.odpt.org/api/v4/odpt:BusTimetable?odpt:operator={operatorCode}&dc:title={routeTitle}&odpt:calendar={calendarType}&acl:consumerKey={accessToken}`
   - Parameters:
     - `odpt:operator`: Operator code
     - `dc:title`: Bus route title/name
     - `odpt:calendar`: Calendar type (weekday, saturday, sunday, holiday, etc.)
     - `acl:consumerKey`: Access token
   - **Note**: GTFS operators do not use this API endpoint (they use GTFS files instead)

2. **Data Parsing**:
   - Parse JSON response containing bus timetable objects
   - Extract bus information:
     - `odpt:busNumber`: Bus number/identifier
     - `odpt:departureTime`: Departure time from origin stop
     - `odpt:arrivalTime`: Arrival time at destination stop
     - `odpt:routePattern`: Route pattern identifier

3. **Time Processing**:
   - Apply time adjustments for next-day times (0-3 AM times are adjusted by adding 24 hours)
   - Calculate ride time between departure and arrival stops

4. **Data Conversion**: Convert parsed data to internal `BusTime` models:
   - Includes bus number, route pattern, and ride time information

**Station Timetable Generation Flow:**

1. **API Request**: Fetch station timetable data from ODPT API
   - Endpoint: `https://api.odpt.org/api/v4/odpt:StationTimetable?odpt:operator={operatorCode}&odpt:railway={railwayCode}&odpt:station={stationCode}&odpt:calendar={calendarType}&acl:consumerKey={accessToken}`
   - Parameters:
     - `odpt:operator`: Operator code
     - `odpt:railway`: Railway line code
     - `odpt:station`: Station code
     - `odpt:calendar`: Calendar type
     - `acl:consumerKey`: Access token

2. **Data Parsing**:
   - Parse JSON response containing `odpt:stationTimetableObject` array
   - Extract train information for the specific station:
     - `odpt:trainNumber`: Train number
     - `odpt:departureTime`: Departure time from the station
     - `odpt:destinationStation`: Destination station
     - `odpt:trainType`: Train type

3. **Time Processing**:
   - Apply time adjustments for next-day times
   - Sort by departure time in ascending order

4. **Data Conversion**: Convert to internal timetable models for station-specific display

**Calendar Type Handling:**

The application supports multiple calendar types for timetable generation:

- **weekday**: Monday to Friday (excluding holidays)
- **saturday**: Saturday (excluding holidays)
- **sunday**: Sunday (excluding holidays)
- **holiday**: Japanese national holidays
- **saturdayHoliday**: Saturday or holiday
- **monday, tuesday, wednesday, thursday, friday**: Individual weekday types

Calendar type is passed as `odpt:calendar` parameter in API requests.

**Time Adjustment Logic:**

- Times from 00:00 to 03:00 are treated as next-day times
- These times are adjusted by adding 24 hours (e.g., 01:30 becomes 25:30)
- This ensures correct sorting and display of early morning services

**Error Handling:**

- Network errors: Timeout after 30 seconds for requests
- Invalid data: JSON parsing errors are caught and logged
- HTTP errors: Non-200 status codes are handled with appropriate error messages
- Missing data: Empty responses are handled gracefully

**Caching:**

- Timetable data is not cached separately (fetched on-demand)
- Line and station data are cached for faster route selection
- Update checking uses ETag/Last-Modified headers when available

#### GTFS Data Processing

The application uses GTFS (General Transit Feed Specification) format for bus operators that provide their data in this standardized format. GTFS is a common format for public transportation schedules and geographic data.

**GTFS Format Overview:**

GTFS data is provided as a ZIP file containing multiple CSV files. The application processes these files to extract route information, stop data, and timetable schedules.

**Supported GTFS Operators:**

- **Toei Bus**: Uses public API (no authentication token required)
- **Yokohama Municipal Bus**: Uses standard API with date parameter and `ODPT_ACCESS_TOKEN`
- **Keio Bus**: Uses standard API with date parameter (20251117) and `ODPT_ACCESS_TOKEN`
- **Nishitokyo Bus**: Uses standard API with date parameter (20251101) and `ODPT_ACCESS_TOKEN`
- **Kawasaki Bus**: Uses standard API with date parameter (20251201) and `ODPT_ACCESS_TOKEN`
- **Kawasaki Tsurumi Rinko Bus**: Uses standard API with date parameter (20251117) and `ODPT_ACCESS_TOKEN`
- **Kanto Bus**: Uses standard API with date parameter (20251110) and `ODPT_ACCESS_TOKEN`
- **Izuhakone Bus**: Uses standard API with date parameter (20251101) and `ODPT_ACCESS_TOKEN`
- **Keisei Transit Bus**: Uses standard API with date parameter (20250401) and `ODPT_ACCESS_TOKEN`

**Note**: Most GTFS operators require `ODPT_ACCESS_TOKEN` for downloading ZIP files. Only Toei Bus uses the public API without authentication.

**GTFS Data Processing Flow:**

1. **ZIP Download**: Download GTFS ZIP file from ODPT API
   - Uses the same endpoint format as described in the API Endpoints section above
   - Standard API: Requires `ODPT_ACCESS_TOKEN` and date parameter (format: YYYYMMDD)
   - Public API (Toei Bus only): No authentication required, no date parameter
   - The application uses conditional GET with ETag/Last-Modified headers for efficient update checking

2. **ZIP Extraction**: Extract ZIP file to temporary directory
   - Uses ZipArchive library (SSZipArchive) for extraction
   - Extracted files are cached for faster subsequent access

3. **CSV File Parsing**: Parse required GTFS CSV files:
   - **routes.txt**: Route information (route_id, route_short_name, route_long_name, route_color)
   - **trips.txt**: Trip information (trip_id, route_id, service_id, trip_headsign, direction_id)
   - **stop_times.txt**: Stop times for each trip (trip_id, stop_id, arrival_time, departure_time, stop_sequence)
   - **stops.txt**: Stop information (stop_id, stop_name, stop_lat, stop_lon)
   - **calendar.txt**: Service calendar (service_id, monday-sunday flags, start_date, end_date)
   - **calendar_dates.txt**: Service exceptions (service_id, date, exception_type)
   - **translations.txt**: Multi-language translations (table_name, field_name, language, translation)

4. **Route Processing**:
   - Extract route information from routes.txt
   - Group trips by route_id and direction (trip_headsign, direction_id)
   - Create separate `TransportationLine` models for each route direction
   - Handle routes without direction information using stop sequences

5. **Stop Processing**:
   - Load stop information from stops.txt
   - Apply translations from translations.txt for multi-language support
   - Convert fullwidth numbers and alphabets to halfwidth
   - Create `TransportationStop` models for route selection

6. **Timetable Processing**:
   - Filter trips by route_id and direction
   - Match trips to calendar types (weekday, saturday, sunday, holiday)
   - Extract departure and arrival times from stop_times.txt
   - Handle time adjustments for next-day times (0-3 AM)
   - Calculate ride times between stops

7. **Calendar Type Detection**:
   - Parse calendar.txt to determine service days
   - Handle calendar_dates.txt for service exceptions
   - Support multiple calendar types: weekday, saturday, sunday, holiday, saturdayHoliday, and individual weekdays

8. **Data Conversion**: Convert GTFS data to internal models:
   - `TransportationLine`: Route information with direction
   - `TransportationStop`: Stop information with localization
   - `BusTime`: Timetable entries with departure/arrival times

9. **Caching**: Cache extracted directory for faster subsequent access
   - Cache key includes operator name and date
   - Extracted directory is cached to avoid re-extraction
   - In-memory cache for frequently accessed CSV files

**GTFS Data Structure:**

The application processes GTFS data with the following key relationships:

```
routes.txt (route_id)
  └── trips.txt (route_id → trip_id, service_id, direction_id, trip_headsign)
      └── stop_times.txt (trip_id → stop_id, arrival_time, departure_time)
          └── stops.txt (stop_id → stop_name)
      └── calendar.txt (service_id → service days)
          └── calendar_dates.txt (service_id → exceptions)
```

**Multi-language Support:**

- Load translations from translations.txt
- Support Japanese (default) and English translations
- Convert fullwidth characters to halfwidth for consistency
- Fallback to original text if translation not available

**Direction Handling:**

Routes with multiple directions are handled as follows:

1. **With direction_id**: Use direction_id (0 or 1) to distinguish directions
2. **With trip_headsign**: Use trip_headsign to distinguish directions
3. **Without direction info**: Use first and last stop_id to create unique direction code

**GTFS Update Checking:**

- **Toei Bus**: Uses conditional GET with ETag/Last-Modified headers
- **Other operators**: Cache key includes date, so cached file is already for the correct date
- Extracted directory is cached separately for faster access

#### Error Handling

The application handles various error scenarios:

- **Network Errors**: Timeout after 30 seconds for requests, 60 seconds for resources
- **Invalid Data**: JSON parsing errors are caught and logged
- **HTTP Errors**: Non-200 status codes are handled with appropriate error messages
- **Redirect Handling**: HTTP redirects preserve authentication parameters

#### Configuration

API configuration is managed through:

- **Release.xcconfig**: Contains ODPT access tokens (not in Git)
- **Enums.swift**: Defines operator codes and API endpoint mappings
- **LocalDataSource enum**: Maps operators to their ODPT operator codes

#### Example Usage

**ODPT API (Railway/Bus):**

```swift
let odptService = ODPTDataService()
let consumerKey = "your-consumer-key"

// Fetch railway data for JR East
let data = try await odptService.fetchIndividualOperatorData(.jrEast, consumerKey: consumerKey)

// Check for updates using conditional GET
let needsUpdate = try await odptService.checkIndividualOperatorForUpdates(.jrEast, consumerKey: consumerKey)

if needsUpdate {
    // Fetch updated data
    let updatedData = try await odptService.fetchIndividualOperatorData(.jrEast, consumerKey: consumerKey)
}
```

**Bus GTFS Format:**

```swift
let gtfsService = GTFSDataService()
let consumerKey = "your-consumer-key"

// Fetch GTFS routes for Toei Bus
let routes = try await gtfsService.fetchGTFSData(.toeiBus, consumerKey: consumerKey)

// Fetch stops for a specific route
let stops = try await gtfsService.fetchGTFSStopsForRoute(
    "route_id_0",  // route_id with direction_id
    transportOperator: .toeiBus,
    consumerKey: consumerKey
)

// Fetch timetable for a route and stops
let timetable = try await gtfsService.fetchGTFSBusTimetable(
    routeId: "route_id_0",
    departureStop: departureStop,
    arrivalStop: arrivalStop,
    calendarType: .weekday,
    transportOperator: .toeiBus,
    consumerKey: consumerKey
)
```

#### API Rate Limits

- The application implements intelligent caching to minimize API calls
- Conditional GET requests reduce bandwidth usage
- Data is cached locally for offline access
- Update checks only occur when cached data exists

#### Data Format

ODPT API returns JSON data in the following format:

```json
[
  {
    "@type": "odpt:Railway",
    "dc:title": "山手線",
    "owl:sameAs": "odpt.Railway:JR-East.Yamanote",
    "odpt:operator": "odpt.Operator:JR-East",
    "odpt:lineColor": "#E60012",
    "odpt:railwayTitle": {
      "ja": "山手線",
      "en": "Yamanote Line"
    }
  }
]
```

The application parses this data into internal `TransportationLine` models for use throughout the app.

### Local Railway Database
Comprehensive offline railway data covering major operators in Japan:

**Railway Operators:**
- **JR East**: Complete station and line data
- **Tokyo Metro**: Full subway network coverage
- **Toei Subway**: Full subway network coverage
- **Yokohama Municipal Subway**: Complete subway line data
- **Private Railways**: Tokyu Railway, Keikyu Railway, Odakyu Railway, Seibu Railway, Tobu Railway, Sotetsu Railway
- **Monorails**: Tama Monorail, Yurikamome
- **Regional Lines**: Tsukuba Express (TWR), Rinkai Line (MIR)

**Bus Operators:**
- **Tokyu Bus**: Major bus routes
- **Seibu Bus**: Complete bus network
- **Sotetsu Bus**: Sotetsu Railway bus routes
- **Kanachu Bus**: Kanagawa Chuo Bus routes
- **Kokusai Kogyo**: International Kogyo Bus routes
- **Odakyu Bus**: Odakyu Railway bus routes
- **Toei Bus**: Comprehensive bus route coverage (GTFS format)
- **Yokohama Municipal Bus**: Complete bus route data (GTFS format)
- **Keio Bus**: Keio Railway bus routes (GTFS format)
- **Nishitokyo Bus**: Nishitokyo Bus routes (GTFS format)
- **Kawasaki Bus**: Kawasaki City Bus (GTFS format)
- **Kawasaki Tsurumi Rinko Bus**: Kawasaki Tsurumi Rinko Bus (GTFS format)
- **Kanto Bus**: Kanto Bus (GTFS format)
- **Izuhakone Bus**: Izuhakone Bus (GTFS format)
- **Keisei Transit Bus**: Keisei Transit Bus (GTFS format)

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
- **Supported Bus Operators**: 15 operators (10 ODPT API, 5 GTFS format)

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
