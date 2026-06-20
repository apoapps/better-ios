# better-ios

A quality-first skill for building Swift/SwiftUI iOS and macOS apps without the usual AI-generated slop.

## What it is

`better-ios` is the first skill you load when thinking about what to build. It covers:

- Architecture: small views, thin coordinators, actors for I/O, `@Observable` state ownership.
- Design: no duplicate controls, no default glass cards, no hardcoded colors, no fake feature rows.
- Testing: TDD, unit tests for coordinators, UI smoke tests, visual proof.
- Proof boundaries: why a simulator build does not prove on-device ML/Metal runtime.

## What it is not

This skill does **not** replace `build-ios-apps`. Use `build-ios-apps` for the deep tooling recipes:

- XcodeBuildMCP workflows
- ETTrace profiling
- memgraph leak analysis
- App Intents
- Liquid Glass API details

Use `better-ios` first to decide what is worth building, then load `build-ios-apps` to execute the tooling.

## Structure

```
better-ios/
  SKILL.md                      # skill reference
  README.md                     # this file
  references/
    architecture-patterns.md
    visual-proof-checklist.md
    testing-matrix.md
    anti-slop-gallery.md
  examples/
    GoodInputBar.swift
    GoodRuntimeCoordinator.swift
    BadGodViewModel.swift
    BadBooleanSheets.swift
    BadDuplicateButtons.swift
```

## Install

Clone into your agent skills directory or load the `SKILL.md` directly.

## License

MIT
