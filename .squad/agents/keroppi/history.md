# Keroppi — History

## Recast
- **2026-04-26:** Recast from Amy (Futurama) → Keroppi (Sanrio). Role unchanged: Design Engineer.

## Learnings

- **Modern iOS app icon format:** Only needs a single 1024×1024 slot with `"platform": "ios"` — Xcode handles all resizing. The old multi-size format with explicit filenames per scale is legacy.
- **Color system:** 6 named color sets with dark mode variants (FrogGreen, WaterBlue, RoadGray, SafeZoneGreen, DangerRed, LilyPadGreen).
- **LaunchScreen.storyboard** still required for iOS apps (not SwiftUI-based).
- **Info.plist updates:** Portrait lock via `UISupportedInterfaceOrientations`, light status bar via `UIStatusBarStyle`.
- **Key files:** FrogR/Assets.xcassets/ (all color sets + AppIcon), LaunchScreen.storyboard, Info.plist.
- **App icon slot** is ready but needs actual 1024×1024 artwork to be dropped in.
