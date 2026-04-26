# Squad Team

> FrogR — A Frogger-style arcade game for iOS, built with Swift/SwiftUI

## Coordinator

| Name | Role | Notes |
|------|------|-------|
| Squad | Coordinator | Routes work, enforces handoffs and reviewer gates. |

## Members

| Name | Role | Charter | Status | Inspired By |
|------|------|---------|--------|-------------|
| Kermit | Lead | `.squad/agents/kermit/charter.md` | 🏗️ Active | Kermit the Frog (The Muppets) |
| Frogger | iOS Dev | `.squad/agents/frogger/charter.md` | 📱 Active | Frogger (Konami, 1981) |
| Hypnotoad | AI/Services Dev | `.squad/agents/hypnotoad/charter.md` | 🤖 Active | Hypnotoad (Futurama) |
| Michigan | Tester | `.squad/agents/michigan/charter.md` | 🧪 Active | Michigan J. Frog (Warner Bros.) |
| Keroppi | Design Engineer | `.squad/agents/keroppi/charter.md` | 🎨 Active | Keroppi (Sanrio) |
| Slippy | Integration Engineer | `.squad/agents/slippy/charter.md` | ⚙️ Active | Slippy Toad (Star Fox) |
| Scribe | Session Logger | `.squad/agents/scribe/charter.md` | 📋 Active | — |
| Ralph | Work Monitor | — | 🔄 Monitor | — |

## Project Context

- **User:** brady gaster
- **Project:** FrogR
- **Description:** A Frogger-style arcade game for iOS. Classic gameplay — guide a frog across roads and rivers. Built for Brady's wife as a fun phone game.
- **Stack:** Swift, SwiftUI, iOS 17+, xcodegen (project.yml)
- **AI Integration:** GitHub Models API (chat completions with vision) for AI features
- **Secrets:** PAT in Secrets.xcconfig, injected via Info.plist
- **Distribution:** Direct install via cable (no App Store)
- **Created:** 2026-04-26

## Key Technical Decisions (Day One)

- GitHub Models endpoint: `https://models.github.ai/inference/chat/completions`
- Use `JSONSerialization` for API request/response bodies (not Codable structs)
- Service classes (not structs) with protocol abstractions and mock implementations
- Retry with exponential backoff + fallback model switching on rate limits
- `@Observable` (not `ObservableObject`) for all view models
- `Identifiable` wrapper structs for any array powering `ForEach` (never `ForEach(array.indices, id: \.self)`)
