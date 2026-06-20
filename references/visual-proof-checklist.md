# Visual Proof Checklist

Use this checklist before declaring any UI work done.

## Required proof

- [ ] Build succeeds on the target platform (iOS Simulator, macOS, or physical device).
- [ ] App launches without crashing.
- [ ] Screenshot or semantic snapshot captured for the changed screen.
- [ ] No duplicate labels or hidden controls in the snapshot.
- [ ] Contrast is readable in both light and dark mode (or the app's declared mode).
- [ ] Touch targets are ≥ 44 pt.
- [ ] Text is not clipped at the largest Dynamic Type size if the app supports it.

## What to inspect

| Area | Look for |
|---|---|
| Layout | Wrong z-order, shifted overlays blocking taps, clipped text, overflow bubbles |
| Navigation | Duplicate back buttons, missing close affordance, two routes for the same sheet |
| Controls | Two buttons doing the same thing, disabled/fake rows, tiny hit targets |
| Color | Hardcoded colors, white-on-white, poor contrast |
| Materials | Custom blur cards where `List`/`Form`/system material would suffice |
| Radii | Oversized rounded corners on primary content |

## Tools

- XcodeBuildMCP `snapshot_ui` / `screenshot` for simulator.
- `XCUIScreen.main.screenshot()` in a `VisualProofUITests` target.
- Manual Simulator screenshot with `xcrun simctl io <udid> screenshot`.
- cua-driver or accessibility inspector for macOS.

## Saving proof

Name screenshots descriptively:

```
ios-01-landing.png
ios-02-chat-empty.png
ios-03-composer-enabled.png
ios-07-settings.png
macos-01-main-window.png
```

Keep them in a `visual-proof/` directory or attach them as `XCTAttachment` with `.keepAlways`.
