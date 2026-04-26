# Squad Decisions

## Active Decisions

### 2026-04-25T20:43:21Z: Day-one technical decisions
**By:** brady gaster (project owner)
**What:** Established core technical patterns for FrogR:
1. GitHub Models endpoint: `https://models.github.ai/inference/chat/completions`
2. Use `JSONSerialization` for API request/response bodies (not Codable structs)
3. Service classes (not structs) with protocol abstractions and mock implementations
4. Retry with exponential backoff + fallback model switching on rate limits
5. `@Observable` (not `ObservableObject`) for all view models
6. `Identifiable` wrapper structs for any array powering `ForEach` (never `ForEach(array.indices, id: \.self)`)
**Why:** Owner preferences — baked in from day one, all agents must follow these patterns.

### 2026-04-25T20:43:21Z: Teams channel for updates
**By:** brady gaster (via Copilot)
**What:** Post updates and screenshots to the #frogsquad Teams channel as work progresses.
**Channel:** Team `1de78cdf-3f73-4447-9601-a940bd98b80d`, Channel `19:490cc99c6d83437188970caec86f6843@thread.tacv2`
**Why:** User request — team visibility into progress.

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
