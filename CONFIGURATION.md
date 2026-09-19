# Configuration files

Every file this app needs that is not in the repository, and what goes in it.
A clone builds once these exist.

## Untracked, you create them

| File | Template | What it holds |
|---|---|---|
| `mytimetablemaker_swiftui/Debug.xcconfig` | `Debug.xcconfig.example` | AdMob unit id, ODPT tokens, App Check debug secret |
| `mytimetablemaker_swiftui/Release.xcconfig` | `Release.xcconfig.example` | The same four keys with release values |
| `mytimetablemaker_swiftui/GoogleService-Info.plist` | Firebase console | The Firebase project and app identifiers |

Copy each template next to itself, drop the `.example`, and fill it in. The
Xcode project names both files as its build configuration files, so a missing
one is not an error: the keys resolve to empty and the guards in
`AdMobBannerView` and `mytimetablemaker_swiftuiApp` fall back instead.

`Info.plist` copies all four keys into the bundle through `$(KEY)`, so
**everything in these files ships inside the app.** Nothing that grants server
access belongs in them.

Download `GoogleService-Info.plist` from the Firebase console
(Project settings > Your apps) and add it to the Xcode target. It is not in the
repository: anything the console hands back on request stays out, so a project's
identifiers are never published for nothing. That is not a claim that the file is
secret. Its API key names the project and ships inside every copy of the app;
Firestore rules and App Check are what deny access.

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
