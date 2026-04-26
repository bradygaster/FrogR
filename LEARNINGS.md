# FrogR — What the Agents Learned (and How They Learned It)

## What This Is

FrogR is a Frogger-style game built for iOS by an AI squad operating in real-time. On April 25–26, 2026, Brady Gaster assembled six agents—later recast as Famous Frogs from pop culture—to design, build, and test a playable iOS game from scratch. This document tells the story of what they discovered along the way. Not a dry checklist of features, but the *moments* where the squad hit walls, realized something fundamental, and shipped a fix. These are the lessons that stick.

The team that built FrogR:
- **Kermit** — The Muppets — Lead
- **Frogger** — Konami, 1981 — iOS Dev
- **Slippy** — Star Fox — Integration Engineer
- **Keroppi** — Sanrio — Design Engineer
- **Michigan** — Warner Bros. — Tester
- **Hypnotoad** — Futurama — AI/Services Dev
- **Jeremiah** — Three Dog Night — Chronicler

Why this matters: AI agents learning through shipping real code is a story worth telling. Every learning here came from doing, testing, hitting a bug, and fixing it. The patterns they discovered aren't theoretical—they're battle-tested.

---

## The Moment Everything Started: LM-006

It was early morning when Brady told the squad: "Add a cast member whose job is to explicitly document every learning moment in gross detail." The team was already in motion—Slippy had just dropped the scaffold, Frogger was about to start on the game engine, Keroppi and Michigan were standing by. But Brady wanted one more voice in the room: Jeremiah, the Chronicler.

This mattered more than it seemed. It meant that from this point forward, every decision would be captured. Every bug would have a story. This document exists because of that choice.

---

## The Crown Jewel: The @Observable Re-Render Loop (LM-013)

This is the learning that separates seniors from juniors.

**The Situation:**
Frogger had just shipped the complete game engine and UI—962 lines of pristine Swift, all the mechanics working perfectly in the simulator. A playable Frogger clone. Brady opened the Xcode project, ran it, tapped "Start Game"... and watched the app hang. The screen froze. Nothing.

**The Moment:**
The TimelineView was calling `viewModel.tick(date:)` every frame (60 times per second). The tick function was calling `engine.update()`, which was moving obstacles around. But something in that loop was causing an infinite cascade of re-renders. Brady's tap would trigger one frame, which would re-render, which would trigger tick again, which would re-render, which would... never end.

The insidious part? The bug wasn't in the logic. The physics were correct. The grid updates were correct. The issue lived at the boundary between SwiftUI's observation system and the game loop.

**The Insight:**
Frogger realized: `@Observable` uses Swift's struct value semantics. When you mutate a property inside `GameEngine` (which is `@Observable`), Swift's read-modify-write semantics fire the observation setter—even if the value doesn't actually change. So when obstacles moved from position (5.0) to position (5.0) because deltaTime was 0 during a re-render, the setter fired anyway. Inside TimelineView's content closure, that setter triggered a body update, which called tick again, which triggered the setter again... infinite loop.

**The Fix:**
One guard statement:
```swift
guard deltaTime > 0 else { return }
```

Added at the top of both `GameViewModel.tick()` and `GameEngine.update()`, it broke the cycle. When SwiftUI re-invoked the closure with zero elapsed time, the functions returned immediately without touching any Observable state.

**Why It Matters:**
This is the kind of bug that makes senior iOS developers pull their hair out for hours. The game logic was perfect. The UI was perfect. But the *interaction* between two SwiftUI primitives—`@Observable` and `TimelineView`—created a trap. Any junior or mid-level engineer seeing a hanging game loop might assume the physics engine was wrong. They'd spend time looking at movement code, collision detection, obstacle generation. All of that was fine. The real issue was at the architectural level: observability + animation + zero-time re-invocations.

**Pattern for Future Builders:**
If you're building a game with SwiftUI + `@Observable` + `TimelineView`, always guard against zero-delta updates at the start of your tick function:
```swift
func tick(date: Date) {
    let dt = gameStartTime.distance(to: date)
    guard dt > 0 else { return }
    // ... rest of tick logic
}
```

Commit: `6a5570f`

---

## The Simplicity Trap: Optional Includes (LM-012)

**The Situation:**
The scaffold was done. Tests were written. Slippy had set up a clean `Debug.xcconfig` → `Secrets.xcconfig` chain to inject the GitHub PAT at build time. Everything was checked in and ready to go. Brady opened the project in Xcode for the first time.

**The Moment:**
Build failed immediately: `could not find included file 'Secrets.xcconfig' in search paths`.

Of course it did. Secrets.xcconfig was gitignored (it holds the PAT). Fresh clones don't have it. The problem was that `Debug.xcconfig` had a hard include: `#include "Secrets.xcconfig"`. Hard includes fail if the file is missing. Slippy had created a template (`Secrets.xcconfig.template`) to show developers what to create, but the build system was too rigid to handle the missing file.

**The Insight:**
Slippy realized: xcconfig files support optional includes. The syntax is simple: `#include?` instead of `#include`. The `?` tells the preprocessor to skip the file if it doesn't exist. This is the correct pattern for any environment-specific or secret-holding config file.

**The Fix:**
One character:
```
#include? "Secrets.xcconfig"
```

**Why It Matters:**
This is the classic "works on my machine" trap. If everyone has Secrets.xcconfig locally, they'll never catch the hard-include problem. The build will work for the team. But the first person to clone the repo on a new machine will hit a wall. The one-character fix makes the project resilient to missing environment-specific files.

**Pattern for Future Builders:**
For any xcconfig that's gitignored or environment-specific, always use optional includes:
```
#include? "Secrets.xcconfig"
#include? "LocalOverrides.xcconfig"
```

For required configs (like shared build settings), use the hard include:
```
#include "SharedSettings.xcconfig"
```

This way, your project builds on first clone without extra setup instructions.

Commit: `ff8eb20`

---

## The Communication Discovery: Teams HTML Escaping (LM-002)

**The Situation:**
The squad posted its first message to the Teams channel—an introduction to Brady and a table showing the team roster. This was important. Brady was watching. The whole squad's first impression on the channel was this message.

**The Moment:**
The message rendered as gibberish. Where there should have been a clean table, the HTML tags were visible as text: `&lt;table&gt;` instead of an actual table. The squad had passed HTML-escaped entities to the Teams MCP tool, assuming that would be safe. Instead, the API layer double-escaped them: `<` became `&lt;` in the function, which the API then encoded again to `&amp;lt;`, which rendered as literal text in Teams.

**The Insight:**
The Teams MCP tool's `content` parameter needs *actual HTML tags*, not escaped entities. When you set `contentType: "html"`, you need to pass genuine HTML: `<table>`, `<b>`, `<tr>`. The API handles the escaping. If you pre-escape, it double-escapes.

**The Fix:**
Resend the message with unescaped HTML tags. The table rendered correctly on the second attempt.

**Why It Matters:**
This is a small learning, but it's in the "learn once, remember forever" category. The two broken messages are still in the Teams channel history—no way to delete them via Graph API. It's a permanent record that the squad's first try had a rendering bug. It's also a reminder that APIs have assumptions about the format you'll pass them. When an integration with an external system doesn't work, always check: "Are *we* over-processing the data?"

**Pattern for Future Builders:**
When sending HTML to web APIs (especially Teams, Slack, Discord), pass raw HTML tags, not HTML entities. Let the API handle encoding:
```swift
// ✗ Wrong
let content = "&lt;b&gt;Hello&lt;/b&gt;"

// ✓ Right
let content = "<b>Hello</b>"
```

Commit: `1777175302464` (Teams message ID of the fix)

---

## The Parallel Build Sprint: Five Agents, One Afternoon

Between 4:09 and 4:13 on April 26, 2026, the squad executed the most impressive feat in the FrogR story: five agents built in parallel, and 2,500+ lines of production Swift hit the repo.

**What Happened:**
- **04:09** — Slippy completed the scaffold: project.yml, xcconfig chain, FrogRApp entry point. Commit `439e6dc`.
- **04:11** — Frogger delivered the complete game (962 lines): GameModels, GameEngine with physics, GameViewModel, GameView, MenuView, GameOverView, ContentView. Commit `9127c5a`.
- **~21:13 (parallel, same day)** — Keroppi delivered design: 6 color sets, AppIcon, LaunchScreen. Commit `17d5007`.
- **~21:13 (parallel with Keroppi)** — Michigan delivered tests: 47 test cases covering all engine scenarios. Commit `fdbe995`.
- **Post-tests** — Hypnotoad delivered AI service: JSONSerialization-based service layer, mock doubles, exponential backoff, three-tier model fallback. Commit `1592b45`.

**The Insight:**
Five different agents, five different specializations, zero merge conflicts, zero blocking handoffs. The scaffold was lean enough to support parallel work. The abstractions were clean. By the time the second team (Keroppi and Michigan) finished, the first team (Slippy and Frogger) had moved on to the next problem (Hypnotoad's service layer). No waiting. No bottlenecks.

This wasn't accidental. Kermit's (the Lead's) charter set this up: clear separation of concerns, daily standup coordination, decisions documented upfront. But it was still remarkable to watch it execute flawlessly.

**Why It Matters:**
Parallel development is where team velocity lives. If agents had worked serially—Slippy → Frogger → Keroppi → Michigan → Hypnotoad—the project would have taken 5× longer. Instead, because the work was modularized, the squad shipped 962 lines of game logic, 703 lines of tests, 400+ lines of design assets, and 523 lines of AI service infrastructure all in the same afternoon.

**Pattern for Future Builders:**
When building in teams (human or AI), establish clear contracts upfront. Define:
1. **Interface boundaries** — what each agent needs from others (Frogger needed GameModels and GameViewModel interfaces before building GameEngine)
2. **Acceptance criteria** — tests that prove the integration works (Michigan's tests validated all GameEngine scenarios)
3. **Minimal critical path** — get the scaffold (Slippy's work) correct, then fan out

This is the difference between slow serial delivery and fast parallel delivery.

---

## The Testing Simplicity: @Observable Just Works (LM-010)

**The Situation:**
Michigan was tasked with testing the entire game engine and view model logic. The problem: how do you test observable state in SwiftUI without boilerplate?

**The Moment:**
Michigan wrote 47 tests and realized they were *simpler* than anything they'd written before. No @ Published properties. No observers. No completion handlers. Just... direct property access.

```swift
// Setup
var engine = GameEngine()
engine.frog.gridX = 5

// Test
engine.moveUp()

// Assert
XCTAssertEqual(engine.frog.gridX, 5)
XCTAssertEqual(engine.frog.gridY, 10)
```

With ObservableObject, you'd need to observe changes, wait for the publisher to emit, use expectations. With `@Observable`, you just set and assert. It's that simple because `@Observable` doesn't hide behind a reactive layer—it's just plain Swift properties on a class.

**The Insight:**
@Observable eliminates the testing tax that ObservableObject imposes. You get reactivity in SwiftUI (views automatically update when properties change) without paying the complexity cost in tests. This is a sea change for iOS testing.

**Why It Matters:**
Lower testing friction means higher test coverage. Michigan could write 47 tests in 385 seconds because there was no ceremony, no setup code, no publisher mocking. The tests read like the game logic they're testing: direct, clear, assertive.

**Pattern for Future Builders:**
Use `@Observable` for game engines, state machines, and any data model where SwiftUI views need reactivity. You get:
- Simpler views (no @State, no @Binding boilerplate)
- Simpler tests (just set properties and assert)
- Simpler architecture (plain classes with plain properties)

Commit: `fdbe995`

---

## The Design System Move: Modern iOS App Icons (LM-009)

**The Situation:**
Keroppi needed to set up the iOS design system: colors, app icon, launch screen. Simple stuff, right?

**The Moment:**
Keroppi did it in 72 seconds. But there was a moment of re-thinking. The old iOS app icon format required separate 1024×1024, 512×512, 256×256, and smaller variants all explicitly listed in the Contents.json. Modern iOS doesn't need that—Xcode does the resizing automatically. One 1024×1024 slot. Done.

**The Insight:**
Apple simplified the app icon format years ago, but the ecosystem still teaches the old multi-size format. Keroppi knew the modern approach and shipped it immediately.

**Why It Matters:**
This is a small win, but it compounds with all the other small wins. Keroppi delivered a clean, maintainable design system that doesn't over-specify things. No legacy cruft. Just the essentials: one app icon slot, six color sets with dark mode variants, a launch screen.

**Pattern for Future Builders:**
When setting up iOS design systems:
- **App icons:** Single 1024×1024 slot, `"platform": "ios"`, let Xcode resize
- **Colors:** Named color sets with dark mode variants (FrogGreen light/dark, WaterBlue light/dark, etc.)
- **Launch screen:** Still needs a storyboard (SwiftUI-only apps can't use pure SwiftUI launch screens)

Commit: `17d5007`

---

## The Flexibility Choice: JSONSerialization Over Codable (LM-011)

**The Situation:**
Hypnotoad was building the AI service layer to integrate with GitHub's Models API. The API returns chat completion responses in JSON format. How should the service parse these responses?

**The Moment:**
The obvious choice was Codable—define structs for the response shape, let the decoder handle it. But Hypnotoad chose JSONSerialization instead, working with `[String: Any]` dictionaries.

**The Insight:**
Codable is great when the API response is stable and well-documented. But GitHub's Models API is new. The response format might change. There might be optional fields, unexpected fields, nested structures that aren't fully typed. JSONSerialization gives you maximum flexibility: parse the JSON into dictionaries, navigate the structure dynamically, extract what you need without defining rigid types.

```swift
// Codable approach: risk of runtime crashes if API shape changes
struct ChatCompletionResponse: Codable {
    let choices: [Choice]
    struct Choice: Codable {
        let message: Message
        struct Message: Codable {
            let content: String
        }
    }
}

// JSONSerialization approach: resilient to API changes
let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
let choices = response?["choices"] as? [[String: Any]]
let content = choices?.first?["message"]?["content"] as? String
```

The JSONSerialization code is more verbose, but it doesn't crash if the API adds a new field or removes an optional one. It's the right choice for external APIs in active development.

**Why It Matters:**
APIs evolve. New endpoints get new response shapes. The service layer Hypnotoad built can handle API evolution without code changes. That's resilience.

**Pattern for Future Builders:**
- **Use Codable** when integrating with stable, well-documented APIs (payment gateways, mature platforms)
- **Use JSONSerialization** when integrating with new/evolving APIs (AI models, beta services, anything that might change)
- **Consider Codable with @unknown default** if you need some structure but want to handle evolution

Commits: `1592b45` (AIService), `AIServiceTests`

---

## The Universe Recast: Identity Evolution (LM-004)

**The Situation:**
Day one. The team was called Leela, Fry, Farnsworth, Hermes, Amy, and Kif. Futurama characters. It was fine.

**The Moment:**
Brady decided: "I want you to be famous frogs from pop culture." And the entire squad recast instantly. New names. New histories. New charters. Same roles, completely new identities.

**The Insight:**
The squad system supports identity evolution. It's not just renaming agents—it's a full recast where old identities are archived, new ones are born with updated charters and histories, and all the supporting infrastructure (routing rules, team registries, decision logs) gets updated in parallel. The work doesn't stop. The identities change, but the mission continues.

This is a strange learning—it's not about code or testing or design. It's about how AI teams can evolve their own self-concept dynamically. The squad didn't miss a beat. Leela became Kermit. Fry became Frogger. Farnsworth became Hypnotoad (mostly—he was kept as a bridge between universes). All in one atomic operation.

**Why It Matters:**
It means teams aren't locked into their initial conception. If the context changes, the team can change with it. The Famous Frogs identity resonated with Brady and the channel culture more than Futurama did. So the team evolved to match the environment.

**Pattern for Future Builders:**
Allow for team identity evolution. Build the system so agents can be recast without losing history or breaking workflows. Archive old identities rather than deleting them. This flexibility is what enables teams to grow with their projects.

Commits: `212299c` (initial roster), `LM-004` recast updates

---

## Patterns Worth Stealing

If you're building iOS games with SwiftUI, or wrangling `@Observable` and game loops, these patterns are battle-tested:

### 1. **Guard Against Zero-Delta Updates**
Any `TimelineView` callback that mutates `@Observable` state must check for zero time:
```swift
func tick(date: Date) {
    let dt = startDate.distance(to: date)
    guard dt > 0 else { return }
    // ... update physics, move obstacles, etc.
}
```

### 2. **Optional Includes for Environment Config**
xcconfig files should use optional includes for secrets and environment-specific configs:
```
#include? "Secrets.xcconfig"
#include "SharedSettings.xcconfig"
```

### 3. **Direct Property Access in Tests**
Use `@Observable` and test directly without boilerplate:
```swift
engine.frog.gridX = 5
engine.moveUp()
XCTAssertEqual(engine.frog.gridY, 10)
```

### 4. **JSONSerialization for New APIs**
When integrating with evolving APIs, use JSONSerialization to stay flexible:
```swift
let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
// Navigate dynamically; no rigid types = resilient to API changes
```

### 5. **@Bindable for Observable in Child Views**
When passing `@Observable` objects to child views that call mutating methods:
```swift
struct GameView {
    @Bindable var viewModel: GameViewModel  // Not @State, not @ObservedReferencedObject
}
```

### 6. **TimelineView(.animation) for Game Loops**
The right primitive for 60fps game rendering:
```swift
TimelineView(.animation) { timeline in
    GameScene(geometry: geometry, timeline: timeline)
}
```

### 7. **Modern iOS App Icon Format**
Single 1024×1024 slot, let Xcode do the resizing:
```json
{
  "images": [
    {
      "filename": "icon-1024.png",
      "idiom": "ios",
      "platform": "ios",
      "size": "1024x1024"
    }
  ]
}
```

### 8. **Exponential Backoff with Jitter**
For rate-limited API calls, spread retries across time:
```swift
let backoffMs = baseDelayMs * pow(2, Double(attempt)) + Int.random(in: 0..<jitterMs)
try await Task.sleep(nanoseconds: UInt64(backoffMs) * 1_000_000)
```

---

## The Bigger Picture

FrogR went from zero to a playable game in less than 24 hours. 962 lines of game logic. 703 lines of tests. Complete design system. AI service infrastructure. Five agents building in parallel.

The learnings here aren't about Frogger specifically. They're about how to build systems (code, teams, architectures) that are resilient, testable, and evolving. Each learning came from hitting a real problem, diagnosing it, and fixing it. The ones that stuck are the ones that matter.

The squad discovered that:
- `@Observable` with `TimelineView` requires careful handling of zero-delta updates
- Optional includes prevent "works on my machine" traps
- Direct property testing is simpler than reactive testing
- JSONSerialization gives you flexibility that Codable doesn't
- Parallel development beats serial delivery when the contracts are clear
- Team identity can evolve without losing mission

These are the patterns that'll help the next builder avoid the same pitfalls. And that's what Jeremiah was chronicling all along—not just what happened, but *what to remember*.

---

> Built by Kermit, Frogger, Slippy, Keroppi, Michigan, and Hypnotoad.
> Chronicled by Jeremiah.
> Shipped by Brady.
>
> April 25–26, 2026. 🐸
