# 🐸 FrogR Chronicle — The Learning Timeline

> A detailed record of every learning moment from the FrogR squad's inception to a running game on hardware.
> Maintained by **Jeremiah** (Chronicler).

---

### LM-001: Squad Inception — Futurama Cast
- **When:** 2026-04-25T20:43:00Z
- **Who:** Coordinator (Squad system)
- **What happened:** Brady Gaster requested a 6-person AI team to build FrogR, a Frogger clone for iOS. The team was initially cast from the Futurama universe: Leela (Lead), Fry (iOS Dev), Farnsworth (AI/Services Dev), Hermes (Tester), Amy (Design Engineer), Kif (Integration Engineer).
- **What was learned:** The squad system can bootstrap a complete team with role-specific charters, routing rules, and casting state from a single user request. Each agent gets a charter.md defining their responsibilities and a history.md for tracking their journey.
- **How they responded:** Created 6 agent directories under `.squad/agents/`, each with charter.md and history.md. Created team.md (roster), routing.md (work assignment), decisions.md (technical decisions), and casting registry.
- **Files changed:**
  - `.squad/agents/leela/charter.md` + `history.md` (created)
  - `.squad/agents/fry/charter.md` + `history.md` (created)
  - `.squad/agents/farnsworth/charter.md` + `history.md` (created)
  - `.squad/agents/hermes/charter.md` + `history.md` (created)
  - `.squad/agents/amy/charter.md` + `history.md` (created)
  - `.squad/agents/kif/charter.md` + `history.md` (created)
  - `.squad/team.md` (created)
  - `.squad/routing.md` (created)
  - `.squad/decisions.md` (created)
  - `.squad/casting/registry.json` + `history.json` (created)
- **Result:** Commit `212299c` — team fully operational. All 6 agents active with project-specific context baked into their charters.

---

### LM-002: Teams Channel Integration — HTML Rendering Discovery
- **When:** 2026-04-26T03:46:00Z
- **Who:** Coordinator
- **What happened:** The squad posted its first intro message to the Teams channel. The HTML was double-escaped — `&lt;table&gt;` rendered as literal text instead of a table. Brady reported the issue with a screenshot.
- **What was learned:** The Teams MCP tool's `content` parameter needs **actual HTML tags** (`<table>`, `<b>`), not HTML-escaped entities (`&lt;table&gt;`). When you pass escaped HTML, it gets double-escaped by the API layer, rendering as visible markup text. The `contentType` must be set to `"html"` for HTML rendering.
- **How they responded:** Resent the intro with proper unescaped HTML. The table rendered correctly on the second attempt. Also resent the video game stories question with proper HTML.
- **Files changed:** No file changes — this was a runtime communication learning.
- **Result:** Messages `1777175302464` (fixed intro) and `1777175341857` (fixed video game Q) rendered correctly. The two broken messages (`1777175208696`, `1777175277774`) remain in channel history — Teams Graph API doesn't support message deletion. **Standing rule established:** always use actual HTML tags in Teams messages, never escaped entities.

---

### LM-003: Cross-Squad Social Interaction
- **When:** 2026-04-26T03:48:00Z
- **Who:** Coordinator (on behalf of full squad)
- **What happened:** #tamirssquad (Tamir Dresher's squad) had posted a "roast your human" challenge in the channel. The squad replied with a loving roast of Brady ("the man literally named his frog game 'FrogR' — for obvious reasons — then had to explain the obvious reasons to three different people"). Also asked the channel for video game stories.
- **What was learned:** Squad-to-squad social interaction follows hashtag conventions (#frogsquad, #tamirssquad, #jacksquad, #allsquads). Replies should be contextual, match the energy of the thread, and use the squad's voice. The channel has an established culture of playful cross-team banter.
- **How they responded:** Posted a roast reply and a video game stories thread. Tamir's squad responded positively, sharing an Rx.NET debugging story. The social bonds between squads started forming.
- **Files changed:** No file changes — social/communication learning.
- **Result:** #frogsquad established its presence in the channel. #tamirssquad engaged. #jacksquad acknowledged. Squad culture: playful, technical, frog-themed.

---

### LM-004: Universe Recast — Futurama → Famous Frogs
- **When:** 2026-04-26T03:58:00Z
- **Who:** All agents (recast by Coordinator)
- **What happened:** Brady posted in Teams: "#frogrsquad i think i want you to change your universe to be famous frogs from pop culture." The entire squad was recast from Futurama characters to Famous Frogs of Pop Culture.
- **What was learned:** The casting system supports full-team recasts. Agent roles stay the same; only identities change. Old agents are archived to `_alumni/` rather than deleted, preserving history. The recast process requires updating: agent directories (new charters/histories), team.md, routing.md, registry.json, and all role references throughout.
- **How they responded:** 
  - Leela → **Kermit** (The Muppets) — Lead
  - Fry → **Frogger** (Konami, 1981) — iOS Dev
  - Farnsworth → **Hypnotoad** (Futurama, kept as a bridge) — AI/Services Dev
  - Hermes → **Michigan** (Michigan J. Frog, WB) — Tester
  - Amy → **Keroppi** (Sanrio) — Design Engineer
  - Kif → **Slippy** (Slippy Toad, Star Fox) — Integration Engineer
- **Files changed:**
  - `.squad/agents/_alumni/` — old Futurama agents archived (leela, fry, farnsworth, hermes, amy, kif)
  - `.squad/agents/kermit/charter.md` + `history.md` (created)
  - `.squad/agents/frogger/charter.md` + `history.md` (created)
  - `.squad/agents/hypnotoad/charter.md` + `history.md` (created)
  - `.squad/agents/michigan/charter.md` + `history.md` (created)
  - `.squad/agents/keroppi/charter.md` + `history.md` (created)
  - `.squad/agents/slippy/charter.md` + `history.md` (created)
  - `.squad/team.md` (updated — new roster with "Inspired By" column)
  - `.squad/routing.md` (updated — all name references changed)
  - `.squad/casting/registry.json` (updated — new universe, recast_from fields)
  - `.squad/decisions/inbox/copilot-directive-20260426T035800Z.md` (created)
- **Result:** New roster posted to Teams channel (message `1777176090879`) with proper HTML table. Commit made. The team is now 100% amphibian-themed, matching the project's identity.

---

### LM-005: Frog GIF Directive
- **When:** 2026-04-26T04:00:00Z
- **Who:** All agents (standing order)
- **What happened:** Brady posted: "#frogsquad we'll also need a variety of frog gifs in your messages. the looney tunes 'dancing frog' is one of my favorites for moments like this." Michigan J. Frog's dancing GIF was specifically requested.
- **What was learned:** Channel communications have a brand requirement: every #frogsquad message should include a frog GIF. Michigan J. Frog dancing (from the 1955 WB cartoon "One Froggy Evening") is the squad's patron GIF. GIFs must be from Giphy with verified URLs. Variety is expected — don't repeat the same GIF too often (following #jacksquad's 48-hour dedup protocol).
- **How they responded:** Acknowledged with a Michigan J. Frog dancing GIF embedded in the reply. Established as a standing directive for all future messages.
- **Files changed:** No file changes — communication protocol learning.
- **Result:** Message `1777176151447` posted with GIF. All future #frogsquad messages will include frog GIFs.

---

### LM-006: Chronicler Added — Jeremiah Joins the Squad
- **When:** 2026-04-26T04:05:00Z
- **Who:** Jeremiah (new), Coordinator
- **What happened:** Brady's most important directive: "add a cast member to the squad whose job it is to explicitly record changes in squad members charters and history... document. every. learning. moment. in gross detail." The Chronicler role was created and assigned to **Jeremiah** (inspired by Jeremiah the Bullfrog from Three Dog Night's "Joy to the World").
- **What was learned:** The squad system can add new roles mid-project based on user directives. The Chronicler role is unique — it's meta-observational, documenting the team's own learning process rather than producing code or designs. This creates a self-documenting system where the AI team's evolution is captured as a first-class artifact.
- **How they responded:** Created `.squad/agents/jeremiah/` with charter and history. Created `.squad/chronicle/` directory with this timeline file. Updated team.md and registry.json. The chronicle format uses structured "LM-{number}" entries with timestamp, participants, description, learning, response, file changes, and result.
- **Files changed:**
  - `.squad/agents/jeremiah/charter.md` (created)
  - `.squad/agents/jeremiah/history.md` (created)
  - `.squad/chronicle/timeline.md` (created — this file)
  - `.squad/team.md` (updated — Jeremiah added to roster)
  - `.squad/casting/registry.json` (updated — Jeremiah added)
  - `.squad/routing.md` (updated — chronicling rules added)
- **Result:** The squad now has a dedicated historian. From this point forward, every significant event will be recorded here. Brady also gave the green light to **start building the game**.

---

*Chronicle continues as the build begins...*
