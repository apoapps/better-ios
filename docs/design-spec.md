# better-ios — Skill Design Spec

**Date:** 2026-06-20  
**Status:** Draft pending approval  
**Location:** `/Volumes/SandiskSSD/Documents/Development/dev/apoapps/better-ios/`

---

## 1. Goal

Create a reusable agent skill called `better-ios` that prevents common mistakes observed in real-world SwiftUI projects and complements the existing `build-ios-apps` plugin.

`build-ios-apps` teaches **how** to use XcodeBuildMCP, Liquid Glass, App Intents, profiling, and leak detection. `better-ios` teaches **what to build, what not to build, and how to prove it** — with hard-won rules from repeated handoffs, commits, and failed iterations.

---

## 2. Scope

### In scope
- Swift / SwiftUI native iOS and macOS apps.
- Architecture: state ownership, view splitting, MV vs MVVM, actor boundaries, backend/frontend decoupling.
- Design anti-slop: duplicate controls, excessive border radius, custom glass surfaces, hardcoded colors, fake/disabled buttons.
- Testing discipline: unit tests, UI smoke tests, visual proof, runtime proof boundaries.
- Verification workflow: build → run → screenshot/inspect → compare against reference.
- Real-world SwiftUI lessons: god view-models, sidebar gesture/z-order issues, duplicate model/settings entries, false "simulator proves Metal runtime" claims.

### Out of scope
- Deep reference docs for XcodeBuildMCP, ETTrace, memgraph, or App Intents (handled by `build-ios-apps`).
- Platform-specific macOS distribution/notarization (handled by `build-macos-apps` skill).
- Expo / React Native / Flutter / web implementation guides (may be referenced as counter-examples only).

---

## 3. Target audience

Future agent instances working on any SwiftUI project. The skill must be discoverable when an agent is about to:
- Add a new SwiftUI screen or feature.
- Refactor a large view or view-model.
- Polish UI / fix layout / add a button.
- Write or review tests.
- Claim that a feature "works" based on a build or simulator run.

---

## 4. Skill structure

```
better-ios/
  SKILL.md                              # main skill (required)
  README.md                             # human/GitHub summary
  references/
    architecture-patterns.md            # MV, @Observable, actors, streams
    visual-proof-checklist.md           # screenshot/XCUITest/MCP workflow
    testing-matrix.md                   # what tests for which layer
    anti-slop-gallery.md                # good vs bad examples
  examples/
    GoodComposer.swift
    GoodMessageBubble.swift
    GoodRuntimeCoordinator.swift
    BadGodViewModel.swift               # for agent baseline tests
    BadDuplicateButtons.swift
    BadBooleanSheets.swift
  .git/                                 # own repo, push to GitHub
```

---

## 5. Core content of `SKILL.md`

### 5.1 Frontmatter
```yaml
---
name: better-ios
description: Use when building or refactoring Swift/SwiftUI iOS or macOS apps and you need to avoid common AI-generated slop — duplicate controls, oversized rounded cards, god view-models, missing tests, backend logic in views, and false simulator/runtime claims.
---
```

### 5.2 Overview
One-sentence principle:
> Build native-first, small, tested, decoupled views — and prove them with real evidence, not compiler output.

### 5.3 When to use
- Starting a new SwiftUI feature or screen.
- Refactoring a view or view-model over ~400 lines.
- Adding a button, sheet, menu, or navigation path.
- Polishing UI / fixing layout / adopting Liquid Glass.
- Writing or reviewing tests.
- About to claim "it works" after a build or simulator run.

### 5.4 When NOT to use
- The task is purely MCP/debug/profiling/App Intents (use `build-ios-apps`).
- The task is macOS packaging/notarization (use `build-macos-apps`).
- The codebase is React Native / Flutter / web.

### 5.5 Core rules (Do / Don't)

| ✅ Do | ❌ Don't |
|---|---|
| Prefer native SwiftUI components (`List`, `Form`, `ContentUnavailableView`, `.toolbar`, `.confirmationDialog`) | Hand-roll custom glass/blur cards as the default container |
| One control per action; one source of truth per sheet/panel | Duplicate the same button in two places (e.g. "Download more models" in header and composer) |
| Use enum-driven `.sheet(item:)` | Stack multiple `isXPresented` booleans for mutually exclusive sheets |
| Keep view-models as stream/route coordinators; put I/O in actors/services | Create 1000+ line god view-models mixing persistence, network, runtime, and UI state |
| Write unit tests for view-models and services | Ship UI-only smoke tests for a large coordinator |
| Use semantic colors / Asset Catalog | Hardcode `Color(hex:)` across views |
| Apply radii from the design system, not ad-hoc | Sprinkle `cornerRadius` and `clipShape` everywhere |
| Use `NavigationStack` + `Hashable` route enum | Swap root branches with `if/else` or use `AnyView` |
| Prove runtime on real hardware for MLX / Foundation Models / Metal-dependent code | Claim "it works" because the simulator build succeeded |
| Capture screenshots / UI snapshots before declaring UI done | Say "it looks right in code" |

### 5.6 Architecture guidance
- **State ownership narrowest-first:** `@State` for view-owned value, `@Binding` for child→parent, `@Observable` reference models for shared state (iOS 17+), `@Environment` for shared services, explicit init injection for feature-local dependencies.
- **Prefer MV over MVVM** unless the view-model is actively coordinating a stream or run (e.g. a coordinator consuming `AsyncStream<GenerationEvent>`). Document the exception.
- **Actors for mutable runtime/download state.** Move URLSession, model loading, generation, persistence writes off the main actor.
- **Views never call network/persistence directly.** They send intent-style actions to a view-model or service.
- **Keep files under ~400 lines.** Anything larger is a signal of mixed responsibilities.

### 5.7 Anti-AI-slop design checklist
1. Are there two buttons/rows that do the same thing? Remove one.
2. Are surfaces wrapped in a custom glass/card wrapper by default? Replace with `List`, `Form`, or plain layout.
3. Are corner radii > 22 pt on primary content? Reduce or remove.
4. Are colors `Color(hex:)` or raw `rgba()`? Move to Asset Catalog / semantic tokens.
5. Are there disabled/fake feature rows (mic, camera, deep research, web search) that are not wired? Delete them.
6. Is the composer/input bar a custom frosted pill? Consider native `TextField(axis: .vertical)` + standard toolbar.
7. Are touch targets < 44 pt? Increase.

### 5.8 Testing requirements
- **Every new function/method has a test.** Follow TDD: test first, watch it fail, implement, watch it pass.
- **View-models > 400 lines** must have unit tests covering state transitions and error paths.
- **UI smoke tests** for critical path: launch → new chat → focus composer → type → send.
- **Visual proof tests** (`VisualProofUITests` or XcodeBuildMCP `screenshot`) for any UI change that affects layout, colors, or chrome.
- **Runtime proof boundaries:**
  - Simulator build = compile/layout proof only.
  - Unit tests with fake runtimes = behavior proof.
  - Real Metal / Apple Intelligence / on-device ML generation = requires arm64 physical device or macOS Apple Silicon run.
  - Never conflate the three.

### 5.9 Visual proof workflow
1. Build and run on target simulator/device.
2. Capture screenshot or semantic UI snapshot.
3. Inspect for: duplicate labels, hidden targets, contrast issues, clipped text, wrong z-order, gesture conflicts.
4. Save proof image with descriptive name.
5. Compare against the intended reference (e.g. a native iOS appbar).
6. Fix and re-capture before declaring done.

### 5.10 Common rationalizations and red flags

| Excuse | Reality |
|---|---|
| "The simulator build passed, so it works." | Simulator cannot exercise Metal / Apple Intelligence / device memory. Build ≠ runtime. |
| "I'll add tests after." | Tests added after pass immediately and prove nothing. TDD only. |
| "This custom glass looks better." | Custom blur is harder to maintain, less accessible, and reads as AI slop. |
| "The view-model needs everything in one place." | That's how multi-thousand-line coordinators happen. Split by responsibility. |
| "It's just a small UI tweak, no test needed." | Small UI tweaks are where regressions hide. Add a screenshot test. |
| "Two buttons for the same action is fine." | Duplicate controls confuse users and create maintenance drift. |

**Red flags — STOP and restart:**
- Adding a second button/menu/row for an existing action.
- Hardcoding a new color instead of using the token system.
- Writing a view-model that imports SwiftData, Network, and SwiftUI.
- Claiming runtime proof from a simulator build.
- Skipping a test because "it's obvious."

### 5.11 Examples
Each example is a short, complete Swift snippet.

- **Good composer:** small view, `TextField(axis: .vertical)`, actions delegate to view-model, native send button.
- **Good message list:** enum routes, stable `ForEach` identities, `.task(id:)` for streaming.
- **Good runtime boundary:** actor runtime supervisor, `AsyncStream<GenerationEvent>`, views observe via `@Observable` coordinator.
- **Bad god view-model:** a coordinator anti-pattern mixing persistence, runtime, haptics, widget sync, and UI state.
- **Bad duplicate buttons:** two "Download more models" entries.
- **Bad boolean sheets:** three `isXPresented` booleans for settings/model/downloads.

### 5.12 Cross-references
- For MCP/debug/profiling/App Intents: use `build-ios-apps`.
- For macOS packaging/notarization: use `build-macos-apps`.
- For TDD discipline: use `superpowers:test-driven-development`.

---

## 6. Baseline / TDD plan for the skill

Per `writing-skills`, the skill itself must be tested with subagents before it is considered valid.

### 6.1 Baseline test (without skill)
Create a small fake SwiftUI feature prompt and dispatch a subagent with no `better-ios` skill loaded. The agent will likely:
- Create a 600-line view-model mixing network and UI state.
- Add a custom glass card wrapper.
- Duplicate an existing action with a new button.
- Skip unit tests or write them after.
- Claim "feature works" after a build.

Document the exact violations and rationalizations.

### 6.2 Green test (with skill)
Dispatch the same prompt with `better-ios` loaded. The agent should:
- Split responsibilities into small views + coordinator + service.
- Use native components and design tokens.
- Have one action per control.
- Write a failing unit test first, then implement.
- Capture a screenshot or describe visual proof before finishing.

### 6.3 Refactor loop
If the agent finds new rationalizations (e.g. "this view-model is a coordinator exception"), add explicit counters and re-test.

---

## 7. Success criteria

1. `better-ios/SKILL.md` exists with YAML frontmatter and all sections above.
2. The skill is loadable via the native `Skill` tool.
3. A baseline subagent without the skill violates ≥ 4 core rules.
4. A green subagent with the skill violates 0 core rules and produces evidence.
5. The repo is initialized and ready to push to GitHub.

---

## 8. Scope decisions

- English only.
- Swift/SwiftUI native focus.
- Separate repo at `/apoapps/better-ios/`.
- Hybrid hard-rules + concrete examples approach.
- Generalized project references; no personal/company-specific names or paths in the published skill.
