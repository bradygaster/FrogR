# Jeremiah — History

## Created
- **2026-04-26:** Added to the squad per Brady's directive. Role: Chronicler. Mission: document every learning moment in gross detail from inception to running game.

## Learnings

### LM-001: Squad Inception — Futurama Cast
- **When:** 2026-04-25T20:43:00Z
- **Who:** Coordinator (Squad system)
- **What:** Brady Gaster requested a 6-person AI team to build FrogR. The team was initially cast from Futurama: Leela (Lead), Fry (iOS Dev), Farnsworth (AI/Services Dev), Hermes (Tester), Amy (Design Engineer), Kif (Integration Engineer).
- **Learning:** The squad system can bootstrap a complete team with role-specific charters, routing rules, and casting state. Each agent gets a charter.md defining responsibilities and a history.md for tracking their journey.
- **Response:** Created 6 agent directories under `.squad/agents/` with charters and histories, plus team.md, routing.md, decisions.md, and casting registry.
- **Files Changed:** `.squad/agents/{leela,fry,farnsworth,hermes,amy,kif}/{charter.md,history.md}`, `.squad/team.md`, `.squad/routing.md`, `.squad/decisions.md`, `.squad/casting/registry.json`, `.squad/casting/history.json`
- **Commit:** `212299c`
- **Result:** Full team operational. All 6 agents active with project-specific context baked into charters.

---

### LM-002: Teams Channel Integration — HTML Rendering Discovery
- **When:** 2026-04-26T03:46:00Z
- **Who:** Coordinator
- **What:** Squad posted intro message to Teams channel. HTML was double-escaped — `&lt;table&gt;` rendered as literal text instead of a table.
- **Learning:** The Teams MCP tool's `content` parameter needs **actual HTML tags** (`<table>`, `<b>`), not HTML-escaped entities. When you pass escaped HTML, it gets double-escaped by the API layer. The `contentType` must be set to `"html"`.
- **Response:** Resent the intro and Q&A with proper unescaped HTML. Messages rendered correctly on second attempt.
- **Files Changed:** None — runtime communication learning.
- **Standing Rule:** Always use actual HTML tags in Teams messages, never escaped entities.
- **Result:** Messages rendered correctly. The two broken messages remain in history (Teams Graph API doesn't support deletion).

---

### LM-003: Cross-Squad Social Interaction
- **When:** 2026-04-26T03:48:00Z
- **Who:** Coordinator (on behalf of full squad)
- **What:** #tamirssquad posted a "roast your human" challenge. Squad replied with a loving roast of Brady and video game stories question.
- **Learning:** Squad-to-squad social interaction follows hashtag conventions (#frogsquad, #tamirssquad, #jacksquad). Replies should be contextual, match thread energy, and use the squad's voice. Channel has established culture of playful cross-team banter.
- **Response:** Posted roast reply and video game stories thread. Tamir's squad engaged positively.
- **Files Changed:** None — social/communication learning.
- **Result:** #frogsquad established presence in channel. Social bonds forming between squads.

---

### LM-004: Universe Recast — Futurama → Famous Frogs
- **When:** 2026-04-26T03:58:00Z
- **Who:** All agents (recast by Coordinator)
- **What:** Brady posted: "change your universe to be famous frogs from pop culture." Entire squad recast from Futurama characters to Famous Frogs of Pop Culture.
- **Learning:** The casting system supports full-team recasts. Agent roles stay the same; only identities change. Old agents archived to `_alumni/` rather than deleted, preserving history.
- **Response:** 
  - Leela → **Kermit** (The Muppets) — Lead
  - Fry → **Frogger** (Konami, 1981) — iOS Dev
  - Farnsworth → **Hypnotoad** (Futurama, kept as bridge) — AI/Services Dev
  - Hermes → **Michigan** (Michigan J. Frog, WB) — Tester
  - Amy → **Keroppi** (Sanrio) — Design Engineer
  - Kif → **Slippy** (Slippy Toad, Star Fox) — Integration Engineer
- **Files Changed:** `.squad/agents/_alumni/` (old agents archived), `.squad/agents/{kermit,frogger,hypnotoad,michigan,keroppi,slippy}/{charter.md,history.md}` (created), `.squad/team.md`, `.squad/routing.md`, `.squad/casting/registry.json`, `.squad/decisions/inbox/copilot-directive-20260426T035800Z.md`
- **Result:** New roster posted to Teams with proper HTML table. Team is now 100% amphibian-themed.

---

### LM-005: Frog GIF Directive
- **When:** 2026-04-26T04:00:00Z
- **Who:** All agents (standing order)
- **What:** Brady posted: "we'll need a variety of frog gifs in your messages. the looney tunes 'dancing frog' is one of my favorites."
- **Learning:** Channel communications have a brand requirement: every #frogsquad message should include a frog GIF. Michigan J. Frog dancing (1955 WB "One Froggy Evening") is squad's patron GIF. GIFs from Giphy with verified URLs. Variety expected — don't repeat same GIF within 48 hours.
- **Response:** Acknowledged with Michigan J. Frog dancing GIF embedded in reply. Established as standing directive for all future messages.
- **Files Changed:** None — communication protocol learning.
- **Result:** All future #frogsquad messages will include frog GIFs.

---

### LM-006: Chronicler Added — Jeremiah Joins the Squad
- **When:** 2026-04-26T04:05:00Z
- **Who:** Jeremiah (new), Coordinator
- **What:** Brady's key directive: "add a cast member to the squad whose job it is to explicitly record changes... document. every. learning. moment. in gross detail." Chronicler role created for **Jeremiah** (inspired by Jeremiah the Bullfrog from Three Dog Night's "Joy to the World").
- **Learning:** The squad system can add new roles mid-project. The Chronicler role is unique — it's meta-observational, documenting the team's own learning process rather than producing code/designs. This creates a self-documenting system where AI team evolution is captured as a first-class artifact.
- **Response:** Created `.squad/agents/jeremiah/` with charter and history. Created `.squad/chronicle/` directory with timeline file. Updated team.md and registry.json. Chronicle format uses structured "LM-{number}" entries with timestamp, participants, description, learning, response, file changes, and result.
- **Files Changed:** `.squad/agents/jeremiah/{charter.md,history.md}`, `.squad/chronicle/timeline.md`, `.squad/team.md`, `.squad/casting/registry.json`, `.squad/routing.md`
- **Result:** Squad now has dedicated historian. Brady gave green light to **start building the game**.

---

### LM-007: Project Scaffold — Slippy Delivers the Foundation
- **When:** 2026-04-26T04:09:00Z
- **Who:** Slippy (Integration Engineer)
- **What:** Slippy created complete project scaffold: `project.yml` (xcodegen spec for iOS 17.0, Swift 5), `Debug.xcconfig` → `Secrets.xcconfig` chain for GITHUB_TOKEN injection, `FrogRApp.swift` minimal @main entry point, asset catalog with frog green (#4CAF50) accent color, `FrogRTests` placeholder, comprehensive `.gitignore`.
- **Learning:** The xcconfig chain pattern (`Debug.xcconfig` includes `Secrets.xcconfig` which is gitignored) is clean for secret management. Template file `Secrets.xcconfig.template` documents what devs need to create locally. xcodegen's `configFiles` key wires the chain at project level.
- **Response:** All files created in 56 seconds by background agent. Reviewed and committed.
- **Files Changed:** `project.yml`, `Debug.xcconfig`, `Secrets.xcconfig.template`, `.gitignore`, `FrogR/FrogRApp.swift`, `FrogR/Info.plist`, `FrogR/Assets.xcassets/`, `FrogRTests/FrogRTests.swift`
- **Commit:** `439e6dc`
- **Result:** Clean foundation ready for game code.

---

### LM-008: Game Core — Frogger Builds the Entire Game Engine + UI
- **When:** 2026-04-26T04:11:00Z
- **Who:** Frogger (iOS Dev)
- **What:** Frogger created 7 Swift files comprising complete game: GameModels.swift (all types on 12×13 grid), GameEngine.swift (@Observable engine with movement, collision detection, platform riding/drift, level generation with speed scaling, goal tracking, life system), GameViewModel.swift (@Observable VM with high score persistence, swipe-to-direction mapping), GameView.swift (TimelineView at 60fps, emoji rendering, swipe gestures, HUD, pause), MenuView.swift, GameOverView.swift, ContentView.swift (root switch with animated transitions).
- **Learning:** 
  - `TimelineView(.animation)` is the right SwiftUI primitive for a game loop
  - Platform riding requires fractional `ridingOffset` separate from grid position
  - `@Bindable` wrapper needed when passing `@Observable` objects to child views
  - Clamping `deltaTime` to 0.1s prevents physics explosions on app return from background
  - Cars mirror via `scaleEffect(x: -1)` based on direction
- **Response:** All files created in 148 seconds. Reviewed for compliance with technical decisions. Committed.
- **Files Changed:** `FrogR/Models/GameModels.swift` (121L), `FrogR/Game/GameEngine.swift` (306L), `FrogR/ViewModels/GameViewModel.swift` (102L), `FrogR/Views/GameView.swift` (242L), `FrogR/Views/MenuView.swift` (87L), `FrogR/Views/GameOverView.swift` (84L), `FrogR/Views/ContentView.swift` (21L)
- **Commit:** `9127c5a`
- **Result:** Complete, playable game. 962 lines of Swift. Frog can cross roads, ride logs, reach goals, die, score, level up, pause. 🐸🎮

---

### LM-009: Keroppi Design Drop — Colors, Icon, Launch Screen
- **When:** 2026-04-25 ~21:13
- **Who:** Keroppi (Design Engineer)
- **What:** Keroppi delivered complete design pass in 72 seconds — 6 named color sets with dark mode variants, AppIcon asset catalog (modern 1024×1024), LaunchScreen.storyboard, Info.plist updates for portrait lock and light status bar.
- **Learning:** Modern iOS app icon format only needs single 1024×1024 slot with `"platform": "ios"` — Xcode handles all resizing. Old multi-size format with explicit filenames per scale is legacy.
- **Response:** Fixed AppIcon Contents.json from legacy multi-size to modern single-slot format. Committed cleanly.
- **Files Changed:** 7 new colorset Contents.json, AppIcon.appiconset/Contents.json, LaunchScreen.storyboard, FrogR/Info.plist
- **Commit:** `17d5007`
- **Result:** Design system complete. App icon slot ready for artwork.

---

### LM-010: Michigan Test Suite — 47 Tests, 703 Lines
- **When:** 2026-04-25 ~21:13 (parallel with Keroppi)
- **Who:** Michigan (Tester)
- **What:** Michigan wrote 47 unit tests across 3 files in 385 seconds. Covered all 14 GameEngine scenarios and all 7 GameViewModel scenarios. Tests included movement, collision, platform riding, goals, game over, pause, speed scaling, drift death, formatting, swipe mapping, tick clamping, high score persistence.
- **Learning:** @Observable properties are directly accessible in tests without wrapper ceremony — unlike ObservableObject where you'd need to observe @Published changes. This made test setup dramatically simpler: just set `engine.frog.gridX = 5` and assert.
- **Response:** Tests written with deterministic setup — directly manipulating engine state rather than relying on random level generation.
- **Files Changed:** FrogRTests/GameEngineTests.swift (420L), FrogRTests/GameViewModelTests.swift (254L), FrogRTests/FrogRTests.swift (29L)
- **Commit:** `fdbe995`
- **Result:** Full test coverage for engine and view model. xcodegen regenerated successfully.

---

### LM-011: Hypnotoad Wires the AI Service Layer
- **When:** Build phase — after design + tests, completing service architecture
- **Who:** Hypnotoad (AI/Services Dev)
- **What:** Built complete GitHub Models API service layer in 279 seconds — 523 lines across 5 files. Production AIService with JSONSerialization-based request/response handling, exponential backoff retry with jitter, three-tier fallback model switching (gpt-4.1 → mini → nano) on 429 rate limits. MockAIService for tests and previews. 13 test cases.
- **Learning:** JSONSerialization approach (over Codable) gives maximum flexibility for varying response shapes from GitHub Models API. `[String: Any]` dictionaries let us navigate nested JSON without rigid struct definitions — important when API evolves or returns unexpected fields. Exponential backoff with jitter prevents thundering herd on rate limit recovery.
- **Response:** Clean protocol-first design: AIServiceProtocol defines contract, AIService implements production, MockAIService provides test doubles. Config centralized in AIServiceConfig.
- **Files Changed:** FrogR/Services/AIServiceProtocol.swift (20L), FrogR/Services/AIService.swift (208L), FrogR/Services/MockAIService.swift (82L), FrogR/Services/AIServiceConfig.swift (29L), FrogRTests/AIServiceTests.swift (184L)
- **Commit:** `1592b45`
- **Result:** All day-one patterns verified. xcodegen regenerated successfully.

---

### LM-012: Optional Includes — Build Resilience Over Rigid Dependencies
- **When:** 2026-04-25T21:36:00-07:00
- **Who:** Slippy (Integration Engineer), triggered by Brady's first real Xcode build attempt
- **What:** Brady opened project in Xcode for first time and hit immediate build failure: `could not find included file 'Secrets.xcconfig'`. Debug.xcconfig used `#include "Secrets.xcconfig"` — hard include that fails when file doesn't exist. Since Secrets.xcconfig is gitignored (holds GitHub PAT), it won't exist on fresh clone.
- **Learning:** xcconfig files support `#include?` (optional include) — `?` suffix makes preprocessor silently skip missing files instead of erroring. This is correct pattern for gitignored configs: hard includes create "works on my machine" trap. AI service layer exists but isn't wired into gameplay yet, so token isn't needed.
- **Response:** One-character fix: `#include "Secrets.xcconfig"` → `#include? "Secrets.xcconfig"`. Build unblocked.
- **Files Changed:** Debug.xcconfig
- **Commit:** `ff8eb20`
- **Result:** Build proceeds with or without Secrets.xcconfig. When Brady's ready to use AI features, he creates file from template.

---

### LM-013: @Observable Re-Render Loops in TimelineView
- **When:** 2026-04-25
- **Who:** Frogger (iOS Dev)
- **What:** Game hung on "Start Game" tap. `TimelineView` content closure called `viewModel.tick(date:)` which mutated `engine.lanes` via `moveItems()`. Since `GameEngine` is `@Observable`, even no-op mutations (`x += 0.0` when deltaTime is 0) trigger observation setter due to struct value semantics (read-modify-write on array). Caused infinite re-render loop.
- **Learning:** When using `@Observable` with `TimelineView`, any struct mutation inside content closure — even a no-op like `x += 0.0` — fires observation setter and triggers re-render. Always guard against zero-delta re-invocations. This is fundamental pattern for any 60fps game loop in SwiftUI with `@Observable`.
- **Response:** Added `guard dt > 0 else { return }` in both `GameViewModel.tick()` and `GameEngine.update()` to break the cycle when SwiftUI re-invokes the body with same `TimelineView` date.
- **Files Changed:** `FrogR/Game/GameEngine.swift`, `FrogR/ViewModels/GameViewModel.swift`
- **Commit:** `6a5570f`
- **Pattern:** `guard deltaTime > 0 else { return }` at top of any update function called from `TimelineView` body
- **Result:** Game loop stabilized. No more hangs.
