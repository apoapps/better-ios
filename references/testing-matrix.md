# Testing Matrix

## Layer → test type

| Layer | Unit test | UI smoke | Visual proof | Device runtime |
|---|---|---|---|---|
| View (< 300 lines) | Optional | Yes | Yes | No |
| Coordinator / view-model | Required | Yes | Yes | No |
| Service / actor | Required | No | No | No (use fakes) |
| Network client | Required | No | No | No (use injected URLSession) |
| SwiftData / persistence | Required | No | No | No (use in-memory container) |
| Metal / on-device ML | No | No | No | Required |

## Rules

1. **TDD only.** Write the test first, watch it fail, implement, watch it pass.
2. **One behavior per test.** If the name has "and", split it.
3. **Use real code, not mocks** when possible. Prefer fakes over mocks.
4. **Never claim runtime proof from a simulator build.**

## Minimum coverage for a new feature

- One unit test for each new public method on a coordinator/service.
- One UI smoke test for the happy path.
- One screenshot for any changed visual surface.
- For on-device features (MLX, Apple Intelligence, LiDAR, etc.): device or Apple Silicon macOS proof.
