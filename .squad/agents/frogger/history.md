# Frogger — History

## Recast
- **2026-04-26:** Recast from Fry (Futurama) → Frogger (Konami). Role unchanged: iOS Dev.

## Learnings

### SwiftUI & Animation
1. **TimelineView(.animation) is the game loop primitive** — calls back every frame, can be paused/resumed. 60fps via TimelineView in production.
2. **@Bindable property wrapper** is required when passing @Observable objects to child views that need to call mutating methods.
3. **Delta time clamping to 0.1s** prevents physics explosions when the app returns from background.
4. **Car mirroring via scaleEffect(x: -1)** based on direction — simple and effective for emoji vehicles.

### Game Physics & Architecture
5. **Platform riding requires fractional ridingOffset on the frog** that accumulates each frame, separate from the integer grid position.
6. **@Observable + TimelineView re-render loop gotcha** — When `tick()` mutates `engine.lanes` inside TimelineView body, even no-op mutations (`x += 0.0` when dt=0) trigger observation setters due to struct value semantics (read-modify-write). Fix: `guard dt > 0 else { return }` in both `tick()` and `engine.update()` (commit 6a5570f, LM-013).
7. **Grid layout:** 12×13 grid (GridConstants), @Observable for all VMs, Identifiable wrappers for ForEach.

### Key Files & Metrics
8. **Core modules:** GameModels.swift (121 lines), GameEngine.swift (306 lines), GameViewModel.swift (102 lines), GameView.swift (242 lines), MenuView.swift (87 lines), GameOverView.swift (84 lines), ContentView.swift (21 lines).
