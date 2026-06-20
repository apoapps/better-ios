# Anti-Slop Gallery

## 1. Duplicate controls

### Bad
A "New item" button in the toolbar and another "Create" button in the floating action area.

### Why
Users discover one path, then later find another. Maintenance drift makes them behave differently.

### Good
One entry point per action. If the action must appear in two contexts, reuse the exact same closure/view and document it.

## 2. Default glass cards

### Bad
Every screen wraps content in a custom `GlassSurface` with a configurable corner radius.

### Why
It makes every screen look like a dashboard and fights accessibility/Dynamic Type.

### Good
Use `List`, `Form`, `ContentUnavailableView`, or plain `VStack`/`HStack` with semantic backgrounds. Reserve glass/material for floating chrome (toolbars, nav bars, input bars).

## 3. Hardcoded colors

### Bad
```swift
.background(Color(hex: 0x0C0C0E))
.foregroundStyle(Color(hex: 0xF1F1F2))
```

### Why
Dark mode, accessibility, and future re-theming become fragile.

### Good
Asset Catalog color sets or a centralized semantic token struct:
```swift
.background(Color(.systemBackground))
// or
.background(theme.background)
```

## 4. Oversized border radius

### Bad
Primary content surfaces with 28 pt+ corner radius everywhere.

### Why
Reads as AI-generated dashboard UI. Primary content should feel like paper, not cards.

### Good
Use the design system radius scale. Keep primary surfaces mostly flat or with small radii (8–16 pt). Larger radii only on floating chrome.

## 5. Fake feature rows

### Bad
A settings menu with rows for "Cloud backup", "Siri shortcuts", "Watch app" that are not wired.

### Why
Disabled/fake controls erode trust and clutter the UI.

### Good
Only show actions the app actually performs. Delete the rest.

## 6. Boolean sheet flags

### Bad
```swift
@State private var isSettingsPresented = false
@State private var isPickerPresented = false
@State private var isEditorPresented = false
```

### Why
Boolean flags cannot carry data, encourage duplicate state, and make sheet stacking impossible to reason about.

### Good
```swift
enum Sheet: Identifiable {
    case settings
    case picker
    case editor(itemID: String)
}
@State private var presentedSheet: Sheet?
```

## 7. God view-model

### Bad
A single coordinator that imports SwiftData, Network, and SwiftUI, and handles persistence, sensor polling, widget sync, haptics, and UI state.

### Why
Impossible to test, reason about, or refactor.

### Good
Split into:
- `PlantCoordinator` — UI state + stream consumption
- `PlantService` / actor — sensor/network calls
- `WidgetSync` — widget updates
- `Haptics` — small feedback helper
