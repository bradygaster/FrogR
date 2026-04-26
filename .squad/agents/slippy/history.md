# Slippy — History

## Recast
- **2026-04-26:** Recast from Kif (Futurama) → Slippy Toad (Star Fox). Role unchanged: Integration Engineer.

## Learnings

### xcconfig & Build Configuration
- **Include chain pattern:** `Debug.xcconfig` → `Secrets.xcconfig` (gitignored) provides clean secret management. Template file documents required secrets for developers.
- **Optional includes:** Use `#include?` (with `?` suffix) for gitignored/environment-specific configs—silently skips missing files. Use bare `#include` only for required files.
- **xcodegen integration:** `configFiles` key in `project.yml` wires the xcconfig chain at project level.

### Project Scaffold
- **iOS target:** iOS 17.0, Swift 5, Debug/Release configurations.
- **Bundle ID:** `com.bradygaster.frogr`
- **Key files:** `project.yml`, `Debug.xcconfig`, `Secrets.xcconfig.template`, `.gitignore`, `FrogR/FrogRApp.swift`, `FrogR/Info.plist`
- **.gitignore coverage:** `.xcodeproj/`, `Secrets.xcconfig`, `DerivedData/`
