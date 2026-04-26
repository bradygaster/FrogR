# Hypnotoad — History

## Recast
- **2026-04-26:** Recast from Farnsworth (Futurama) → Hypnotoad (Futurama). Role unchanged: AI/Services Dev. Kept from Futurama as a bridge between universes — ALL GLORY TO THE HYPNOTOAD.

## Learnings

### Architecture & Design Patterns
- **JSONSerialization over Codable:** `[String: Any]` dictionaries maximize flexibility for varying GitHub Models API response shapes — no rigid struct definitions needed. Critical when APIs evolve or return unexpected fields.
- **Protocol-first design:** AIServiceProtocol defines the contract, AIService implements production behavior, MockAIService provides deterministic test doubles.
- **Three-tier fallback model switching:** gpt-4.1 → gpt-4.1-mini → gpt-4.1-nano on 429 rate limits. Each tier tried before giving up.

### Resilience & Performance
- **Exponential backoff with jitter:** Prevents thundering herd on rate limit recovery. Random jitter spreads retry timing across clients.

### Integration Details
- **GitHub Models endpoint:** `https://models.github.ai/inference/chat/completions` — PAT injected via Info.plist as `GITHUB_TOKEN` from Secrets.xcconfig
- **Key files:** AIServiceProtocol.swift (20 lines), AIService.swift (208 lines), MockAIService.swift (82 lines), AIServiceConfig.swift (29 lines)
- **Not yet wired into gameplay:** Infrastructure ready for tips, dynamic difficulty, hints features
