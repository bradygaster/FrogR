# Work Routing

How to decide who handles what.

## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| SwiftUI views, navigation, view models, camera, @Observable | Fry | Build game screen, add photo picker, create settings view |
| GitHub Models API, prompts, service layer, retry logic, response parsing | Farnsworth | API integration, prompt engineering, fallback model switching |
| Architecture, scope, code review, design decisions | Leela | Review PRs, architecture proposals, scope trade-offs |
| Unit tests, edge cases, mocks, test coverage | Hermes | Write tests, mock services, verify correctness |
| App icon, colors, SF Symbols, asset catalogs, UI polish, accessibility | Amy | Design color scheme, create assets, generate icon prompts |
| xcodegen, project.yml, xcconfig, Info.plist, bundle IDs, build settings | Kif | Configure xcodegen, manage secrets injection, CI/CD setup |
| Code review | Leela | Review PRs, check quality, suggest improvements |
| Testing | Hermes | Write tests, find edge cases, verify fixes |
| Scope & priorities | Leela | What to build next, trade-offs, decisions |
| Session logging | Scribe | Automatic — never needs routing |

## Issue Routing

| Label | Action | Who |
|-------|--------|-----|
| `squad` | Triage: analyze issue, assign `squad:{member}` label | Leela |
| `squad:leela` | Architecture/scope work | Leela |
| `squad:fry` | iOS/SwiftUI implementation | Fry |
| `squad:farnsworth` | AI/services integration | Farnsworth |
| `squad:hermes` | Testing/quality | Hermes |
| `squad:amy` | Design/assets/polish | Amy |
| `squad:kif` | Build config/project plumbing | Kif |

### How Issue Assignment Works

1. When a GitHub issue gets the `squad` label, **Leela** triages it — analyzing content, assigning the right `squad:{member}` label, and commenting with triage notes.
2. When a `squad:{member}` label is applied, that member picks up the issue in their next session.
3. Members can reassign by removing their label and adding another member's label.
4. The `squad` label is the "inbox" — untriaged issues waiting for Leela's review.

## Rules

1. **Eager by default** — spawn all agents who could usefully start work, including anticipatory downstream work.
2. **Scribe always runs** after substantial work, always as `mode: "background"`. Never blocks.
3. **Quick facts → coordinator answers directly.** Don't spawn an agent for "what port does the server run on?"
4. **When two agents could handle it**, pick the one whose domain is the primary concern.
5. **"Team, ..." → fan-out.** Spawn all relevant agents in parallel as `mode: "background"`.
6. **Anticipate downstream work.** If a feature is being built, spawn Hermes to write test cases from requirements simultaneously.
7. **Issue-labeled work** — when a `squad:{member}` label is applied to an issue, route to that member. Leela handles all `squad` (base label) triage.
8. **Game logic + UI** — Fry owns game loop, controls, and rendering. Farnsworth owns AI features only.
9. **Build breaks** — route to Kif first (project config), escalate to the breaking agent if it's a code issue.
