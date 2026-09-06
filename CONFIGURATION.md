# Configuration files

Every file this app needs that is not in the repository, and what goes in it.
A clone builds once these exist.

## Untracked, you create them

| File | Template | What it holds |
|---|---|---|
| `mytimetablemaker_swiftui/Debug.xcconfig` | `Debug.xcconfig.example` | AdMob unit id, ODPT tokens, App Check debug secret |
| `mytimetablemaker_swiftui/Release.xcconfig` | `Release.xcconfig.example` | The same four keys with release values |

Copy each template next to itself, drop the `.example`, and fill it in. The
Xcode project names both files as its build configuration files, so a missing
one is not an error: the keys resolve to empty and the guards in
`AdMobBannerView` and `mytimetablemaker_swiftuiApp` fall back instead.

`Info.plist` copies all four keys into the bundle through `$(KEY)`, so
**everything in these files ships inside the app.** Nothing that grants server
access belongs in them.

## Tracked, already here

| File | Why it is tracked |
|---|---|
| `GoogleService-Info.plist` | Holds the same identifiers as the Android `google-services.json` and ships inside every copy of the app. Excluding it protected nothing and cost two sibling apps their copy in September 2026. A Firebase API key names the project; it does not authorize access. Firestore rules and App Check do that |

## The Android app shares two of these values

`ODPT_ACCESS_TOKEN` and `ODPT_CHALLENGE_TOKEN` are not platform specific. The
Compose repository holds the same two in its `local.properties`, described by
its `local.properties.example`. **Change them in one place and the other keeps
the old value.**

`ADMOB_BANNER_UNIT_ID` and `APP_CHECK_DEBUG_TOKEN` are per platform and differ.
Android and iOS are separate App Check apps and separate AdMob apps.

## App Check debug tokens

A registered debug token defeats App Check from anywhere, without the app.
Register one only while developing on a device, and delete it from the Firebase
Console when that device is done. Release builds attest with DeviceCheck and
never read the debug value.
