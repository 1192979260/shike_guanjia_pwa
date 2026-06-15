## Why

The PRD and API design document define the core data operations for authentication, child profiles, classes, lessons, attendance, cost statistics, and sync, but the implementation still needs a coherent service contract that Provider/UI code can rely on. This change turns those documented API expectations into production-shaped Flutter service interfaces with mock implementations that can support MVP development and later LeanCloud migration.

## What Changes

- Implement the PRD-backed API surface across app service layers for auth, children, training classes, lessons, attendance, cost statistics, and sync.
- Align mock service behavior with `docs/api-design.md`, including validation, filtering, sorting, cascade deletion, class state transitions, lesson check-in/leave flows, and sync timestamp semantics.
- Keep Provider-facing APIs stable while moving business operations that affect multiple entities into services where needed.
- Preserve an easy migration path from mock data to LeanCloud by keeping service contracts explicit and model-based.
- Add focused tests for service behavior, edge cases, and cross-entity side effects.

## Capabilities

### New Capabilities
- `api-service-contracts`: Defines the app-wide service API contracts and expected behavior for PRD-backed domain operations.
- `mock-api-implementation`: Defines the MVP mock implementation requirements for auth, child, class, lesson, attendance, cost, and sync services.
- `provider-api-integration`: Defines how Providers consume the service APIs and refresh state after cross-entity mutations.

### Modified Capabilities

## Impact

- Affected code: `lib/services/**`, `lib/providers/**`, `lib/domain/models/**`, `lib/models/**`, `lib/core/service_locator.dart`, and focused tests under `test/**`.
- Affected APIs: Flutter in-process service APIs corresponding to documented endpoints in `docs/api-design.md`.
- Affected systems: mock data store, local session/cache storage, scheduling integration, cost calculation, and later LeanCloud adapter boundaries.
- Dependencies: no new runtime dependency is expected unless tests require existing Flutter/Dart test tooling configuration updates.
