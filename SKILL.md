---
name: better-ios
description: Use when building or refactoring Swift/SwiftUI iOS or macOS apps and you need to avoid common AI-generated slop — duplicate controls, oversized rounded cards, god view-models, missing tests, backend logic in views, and false simulator/runtime claims.
---

# better-ios

## Overview

Build native-first, small, tested, decoupled views — and prove them with real evidence, not compiler output.

This skill is the **quality foundation** for SwiftUI work. It tells you what is worth building, what to delete, and how to verify it. For the deep tooling recipes — XcodeBuildMCP, ETTrace, memgraph analysis, App Intents, Liquid Glass API details, macOS packaging — load `build-ios-apps` or `build-macos-apps` **after** this one. This skill sets the bar those tools help you reach.

## When to Use

- Starting a new SwiftUI feature or screen.
- Refactoring a view or view-model over ~400 lines.
- Adding a button, sheet, menu, or navigation path.
- Polishing UI / fixing layout / adopting Liquid Glass.
- Writing or reviewing tests.
- About to claim "it works" after a build or simulator run.

## When NOT to Use

- The task is purely MCP/debug/profiling/App Intents — use `build-ios-apps`. That skill owns the step-by-step recipes; this skill tells you when and why to run them.
- The task is macOS packaging/notarization — use `build-macos-apps`.
- The codebase is React Native / Flutter / web.

## Core Rules

| ✅ Do | ❌ Don't |
|---|---|
| Prefer native SwiftUI components (`List`, `Form`, `ContentUnavailableView`, `.toolbar`, `.confirmationDialog`) | Hand-roll custom glass/blur cards as the default container |
| One control per action; one source of truth per sheet/panel | Duplicate the same button in two places |
| Use enum-driven `.sheet(item:)` | Stack multiple `isXPresented` booleans for mutually exclusive sheets |
| Keep view-models as stream/route coordinators; put I/O in actors/services | Create 1000+ line god view-models mixing persistence, network, runtime, and UI state |
| Write unit tests for view-models and services | Ship UI-only smoke tests for a large coordinator |
| Use semantic colors / Asset Catalog | Hardcode `Color(hex:)` across views |
| Apply radii from the design system, not ad-hoc | Sprinkle `cornerRadius` and `clipShape` everywhere |
| Use `NavigationStack` + `Hashable` route enum | Swap root branches with `if/else` or use `AnyView` |
| Prove runtime on real hardware for Metal / Apple Intelligence / on-device ML | Claim "it works" because the simulator build succeeded |
| Capture screenshots / UI snapshots before declaring UI done | Say "it looks right in code" |

**Violating the letter of these rules is violating the spirit.**

## Architecture

### State ownership (narrowest tool first)

```swift
@State           // view-owned value state
@Binding         // child → parent mutation
@Observable      // shared reference models on iOS 17+
@Environment      // shared services
init injection   // feature-local dependencies
```

### MV over MVVM

Prefer MV unless the view-model is actively coordinating a stream or run (e.g. consuming `AsyncStream<GenerationEvent>`). In that case, document the exception and keep the coordinator thin.

### Actors for mutable I/O

Move URLSession, model loading, generation, and persistence writes off the main actor. Views send intent-style actions; actors and services do the work.

### File-size signal

Keep files under ~400 lines. A file that grows larger is usually doing too much. Split it into real subviews or services, not computed `var x: some View` fragments.

### Views never own the backend

Views do not call `URLSession`, `SwiftData`, or file I/O directly. They call a view-model or service method.

## Anti-AI-Slop Design Checklist

Before declaring a screen done, verify:

1. **No duplicate controls** — two buttons/rows for the same action means one must go.
2. **No default glass cards** — surfaces wrapped in custom blur/card should become `List`, `Form`, or plain layout.
3. **No oversized radii on content** — primary surfaces should not look like dashboards. Radii > 22 pt are a warning.
4. **No hardcoded colors** — use Asset Catalog / semantic tokens.
5. **No fake feature rows** — delete disabled rows for mic, camera, web search, deep research, etc. unless wired.
6. **No frosted custom composer** — prefer `TextField(axis: .vertical)` + standard toolbar.
7. **No < 44 pt touch targets** — increase targets and keep Dynamic Type intact.

## Testing Requirements

- **Every new function/method has a test.** Follow TDD: test first, watch it fail, implement, watch it pass.
- **View-models > 400 lines** must have unit tests covering state transitions and error paths.
- **UI smoke tests** for critical path: launch → load → interact → submit.
- **Visual proof tests** (`VisualProofUITests` or XcodeBuildMCP `screenshot`) for any UI change that affects layout, colors, or chrome.
- **Runtime proof boundaries:**
  - Simulator build = compile/layout proof only.
  - Unit tests with fakes = behavior proof.
  - Real Metal / Apple Intelligence / on-device ML = requires arm64 physical device or macOS Apple Silicon run.
  - Never conflate the three.

## Visual Proof Workflow

1. Build and run on target simulator/device.
2. Capture screenshot or semantic UI snapshot.
3. Inspect for: duplicate labels, hidden targets, contrast issues, clipped text, wrong z-order, gesture conflicts.
4. Save proof image with descriptive name.
5. Compare against the intended native reference.
6. Fix and re-capture before declaring done.

For the exact MCP commands, see `build-ios-apps`. This skill tells you to capture the proof; that skill tells you how to drive the simulator.

## Common Rationalizations

| Excuse | Reality |
|---|---|
| "The simulator build passed, so it works." | Simulator cannot exercise Metal / Apple Intelligence / device memory. Build ≠ runtime. |
| "I'll add tests after." | Tests added after pass immediately and prove nothing. TDD only. |
| "This custom glass looks better." | Custom blur is harder to maintain, less accessible, and reads as AI slop. |
| "The view-model needs everything in one place." | That's how multi-thousand-line coordinators happen. Split by responsibility. |
| "It's just a small UI tweak, no test needed." | Small UI tweaks are where regressions hide. Add a screenshot test. |
| "Two buttons for the same action is fine." | Duplicate controls confuse users and create maintenance drift. |
| "I'll use a boolean flag for now and refactor later." | Boolean sheet flags multiply and create duplicate state. Use an enum now. |

## Red Flags — STOP and Restart

- Adding a second button/menu/row for an existing action.
- Hardcoding a new color instead of using the token system.
- Writing a view-model that imports SwiftData, Network, and SwiftUI together.
- Claiming runtime proof from a simulator build.
- Skipping a test because "it's obvious."
- Adding a `.sheet(isPresented:)` when a `.sheet(item:)` enum already exists.

## Examples

See the `examples/` directory:

- `GoodComposer.swift` — small view, native text field, delegated actions.
- `GoodRuntimeCoordinator.swift` — thin coordinator + actor service + `AsyncStream`.
- `BadGodViewModel.swift` — what a 1000+ line coordinator anti-pattern looks like.
- `BadBooleanSheets.swift` — why boolean flags for sheets fail.
- `BadDuplicateButtons.swift` — two controls doing the same action.

## Getting the build-ios-apps and build-macos-apps Skills

`better-ios` sets the quality bar, but it does **not** include step-by-step XcodeBuildMCP, ETTrace, memgraph, App Intents, or macOS packaging recipes. You need `build-ios-apps` and `build-macos-apps` for that. If they are not already installed in your agent environment, fetch and adapt them yourself.

### Where to find them

- OpenAI Codex plugins repo: `https://github.com/openai/plugins`
  - iOS: `plugins/build-ios-apps/`
  - macOS: `plugins/build-macos-apps/`
- Each plugin is a directory containing `SKILL.md` files under `skills/`, plus `references/` and `scripts/`.

### How to install for any agent

1. **Clone or copy** the plugin directory into your agent's skill search path:
   - Claude Code / Codex / Kimi user scope: `~/.agents/skills/build-ios-apps/`
   - Kimi managed plugins: `~/.kimi-code/plugins/managed/openai-build-ios-apps/`
   - Other agents: wherever the tool description says skills are discovered (often `~/.claude/skills/`, `~/.agents/skills/`, or a configured plugin directory).
2. **Preserve the structure.** Each subskill must keep its own `SKILL.md`, `references/`, and `scripts/`.
3. **Wire the MCP server.** `build-ios-apps` expects `xcodebuildmcp`. If your agent supports MCP, install it:
   ```bash
   npx -y xcodebuildmcp@latest mcp
   ```
   Then register it in the agent's MCP config (e.g. `.mcp.json`, `mcpServers` config, or equivalent).
4. **Adapt path references.** If the plugin mentions Codex-specific paths (e.g. `.codex/`, `environment.toml`), translate them to your agent's equivalent. The skill content itself is tool-agnostic.
5. **Load order.** Load `better-ios` first to decide what to build, then load `build-ios-apps`/`build-macos-apps` for the tooling recipes.

### If the plugin is unavailable

If you cannot fetch the plugin, still follow the verification workflow in this skill using whatever build tools you have (`xcodebuild`, `xcrun simctl`, `xcodebuildmcp` if installable). Do not skip visual proof or runtime proof boundaries just because the deep-reference skill is missing.

## Cross-References

- `build-ios-apps` — XcodeBuildMCP, Liquid Glass details, App Intents, ETTrace, memgraph.
- `build-macos-apps` — macOS packaging, notarization, shell-first scripts.
- `superpowers:test-driven-development` — TDD discipline.
