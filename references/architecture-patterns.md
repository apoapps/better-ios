# Architecture Patterns

## State ownership decision table

| State belongs to | Tool |
|---|---|
| View only | `@State` |
| Child view mutates parent value | `@Binding` |
| Shared reference model (iOS 17+) | `@Observable` injected via `@State` or environment |
| Shared service / dependency | `@Environment(Type.self)` or init injection |
| Persisted preference | `@AppStorage` |
| Window/scene ephemeral | `@SceneStorage` |

## MV vs MVVM

### Default: MV

Most SwiftUI views need no view-model. State lives in `@State`, `@Binding`, or `@Observable` models. Use `.task` / `.task(id:)` for async work.

### Exception: thin stream/route coordinator

When a feature coordinates a stream (e.g. `AsyncStream<GenerationEvent>`), a `@MainActor @Observable` coordinator is acceptable. It must not own persistence, network, or file I/O.

## Actor boundaries

- **Views:** main actor, read-only.
- **View-model / coordinator:** main actor, owns presentation state.
- **Service / runtime / download:** actor or dedicated queue, owns I/O and mutable state.
- **Cross-actor communication:** `AsyncStream`, `CheckedContinuation`, or async methods.

## Navigation

Use `NavigationStack` with a `Hashable` route enum. One stack per tab or scene. Avoid `AnyView` and boolean sheet flags.

```swift
enum ChatRoute: Hashable {
    case settings
    case modelPicker
    case downloads
}

NavigationStack(path: $router.path) {
    ChatScreen()
        .navigationDestination(for: ChatRoute.self) { route in
            switch route {
            case .settings: SettingsScreen()
            case .modelPicker: ModelPickerScreen()
            case .downloads: DownloadsScreen()
            }
        }
}
```

## Sheet state

Use a single optional enum:

```swift
enum ChatSheet: Identifiable {
    case settings
    case modelPicker

    var id: Self { self }
}

.sheet(item: $presentedSheet) { sheet in
    switch sheet { ... }
}
```

## File size

- Views: < 300 lines.
- Coordinators: < 400 lines.
- Services/actors: can be larger, but split by responsibility.
