# Michigan — History

## Recast
- **2026-04-26:** Recast from Hermes (Futurama) → Michigan J. Frog (Warner Bros.). Role unchanged: Tester.

## Learnings

### Testing Patterns
- **@Observable in tests:** Properties are directly accessible without wrapper ceremony. Unlike ObservableObject/@Published, just set `engine.frog.gridX = 5` and assert—dramatically simpler test setup.
- **Deterministic test setup:** Directly manipulate engine state rather than relying on random level generation. Build lanes/obstacles explicitly for each test scenario.

### Test Coverage & Structure
- **Total:** 60 tests across 4 files
  - **GameEngine scenarios (14):** movement, collision, platform riding, goals, game over, pause, speed scaling, drift death
  - **GameViewModel scenarios (7):** formatting, swipe mapping, tick clamping, high score persistence
  - **AI service tests (13):** mock behavior, backoff math, config validation, error handling
  - **Base tests (1):** FrogRTests.swift

### Key Test Files
- FrogRTests/GameEngineTests.swift (420 lines)
- FrogRTests/GameViewModelTests.swift (254 lines)
- FrogRTests/AIServiceTests.swift (184 lines)
- FrogRTests/FrogRTests.swift (29 lines)
