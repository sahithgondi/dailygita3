# Daily Gita

A clean, offline-first iOS app that presents the Bhagavad Gita in English — each shloka shown as
transliteration with its meaning underneath — surfaces one deterministic "shloka of the day," and
lets the reader bookmark shlokas and attach personal notes. The experience is anchored by
home-screen and lock-screen widgets.

- **Offline-first.** All 18 chapters / 700 shlokas are bundled; reading needs no network.
- **Daily shloka.** One shloka per day, chosen deterministically by date — the app, widgets, and
  the daily notification always agree.
- **Yours, synced.** Bookmarks and notes sync across your devices via your private iCloud. No
  account, no backend.

## Tech

Swift + SwiftUI (iOS 17+). SwiftData + CloudKit for user data. WidgetKit for the widgets. Shared
logic lives in the local `GitaKit` Swift package, used by both the app and the widget. No
third-party dependencies.

## Structure

```
App/            # SwiftUI app target
Widget/         # WidgetKit extension target
Packages/GitaKit/   # shared models, persistence, daily-shloka logic, tests
.github/workflows/  # CI: build + unit tests
```

## Develop

```sh
# Run the shared-package tests (iOS Simulator):
cd Packages/GitaKit
xcodebuild test -scheme GitaKit -destination 'platform=iOS Simulator,name=iPhone 16'
```

Open `dailygita3/dailygita3.xcodeproj` in Xcode to build and run the app + widget.
