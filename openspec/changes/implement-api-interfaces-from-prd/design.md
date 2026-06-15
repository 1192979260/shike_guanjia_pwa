## Context

The project is a Flutter app for managing children's training classes. `PRD.md` defines the user-facing product behavior, while `docs/api-design.md` translates that behavior into an MVP service API backed by mock data and later replaceable by LeanCloud.

The codebase already contains domain models, service interfaces, mock service files, Providers, scheduling utilities, cost calculation, and a service locator. The remaining work is to make the service layer contract explicit and ensure the mock implementation behaves like a real backend boundary, including validation, filtering, sorting, cascade deletion, cross-entity updates, and stable Provider refresh behavior.

The MVP constraint is important: the app should work without a real backend, but the interfaces should remain shaped for LeanCloud migration.

## Goals / Non-Goals

**Goals:**

- Align app services with the API behavior documented in `docs/api-design.md`.
- Provide complete mock implementations for authentication, child profiles, training classes, lessons, attendance, cost statistics, and sync.
- Ensure cross-entity mutations are consistent, especially child/class cascade deletion, class state transitions, lesson check-in, leave, and remaining-hours updates.
- Keep Provider code thin: Providers coordinate UI state, while services own data mutations and API-like behavior.
- Add focused tests for service contracts and important business side effects.

**Non-Goals:**

- Implement real LeanCloud SDK integration.
- Introduce a REST server or network API layer.
- Replace the app's current state management approach.
- Build full offline conflict resolution beyond the MVP mock sync semantics already planned.
- Implement deferred features such as push notifications, PDF export, production ACL, or real SMS delivery.

## Decisions

### 1. Treat Flutter Services as the API Boundary

Use `lib/services/*_service.dart` interfaces as the source-of-truth API boundary for implementation. The documented HTTP-style endpoints map to in-process service methods because the MVP backend is mock data inside the app.

Rationale: this preserves development speed and avoids adding a local REST layer that would not exist in production Flutter/LeanCloud usage.

Alternatives considered:

- Add a REST client abstraction now: rejected because there is no real HTTP backend for MVP.
- Let Providers mutate all models directly: rejected because cross-entity side effects become duplicated and harder to migrate.

### 2. Use a Shared Mock Data Store for Cross-Entity Consistency

Mock service implementations should coordinate through a shared `MockDataStore` rather than each service owning isolated collections.

Rationale: child deletion must remove related classes and lessons; class deletion must remove lessons; attendance/check-in must update lesson status and class remaining hours. These are backend-like operations and need one consistent data source.

Alternatives considered:

- Keep independent in-memory maps per service: rejected because it makes cascade behavior fragile.
- Persist every mock entity in `SharedPreferences`: rejected for MVP service tests because it increases setup cost and does not improve the contract.

### 3. Service Methods Return Domain Models and Stable Failure Values

Services should continue returning domain models and simple success/failure values (`T?`, `bool`, `List<T>`) where the current interface already does so. Invalid input should fail predictably without partially mutating state.

Rationale: this matches existing interfaces and keeps Provider usage simple. More structured failures can be introduced later if UI needs detailed error presentation.

Alternatives considered:

- Throw exceptions for every validation error: rejected for common user-input failures because Providers currently fit nullable/boolean outcomes better.
- Add an Either/Result type: rejected because it would create broad refactoring not required for this change.

### 4. Move Cross-Entity Business Mutations into Services

Operations that affect more than one entity should be owned by services, not left as ad hoc Provider mutations. This includes check-in, leave, cascade deletion, class pause/resume/end, and generated lessons after class creation.

Rationale: these behaviors are API semantics from the PRD and must remain identical when the mock layer is replaced by LeanCloud.

Alternatives considered:

- Keep check-in and leave entirely inside `LessonProvider`: acceptable for a prototype, but it hides important data invariants from the service layer.

### 5. Keep LeanCloud Migration as an Adapter Swap

The mock implementation should avoid assumptions that block LeanCloud migration. IDs can remain locally generated for MVP, but service contracts should not expose mock-only storage details.

Rationale: the production path will likely replace mock services with LeanCloud-backed implementations while keeping Providers and UI mostly unchanged.

Alternatives considered:

- Model all LeanCloud object shapes now: rejected because production integration is explicitly out of scope and would slow MVP delivery.

## Risks / Trade-offs

- Mock behavior diverges from future LeanCloud behavior -> Mitigation: keep tests written against service interfaces rather than mock internals.
- Nullable/boolean failures do not provide detailed UI errors -> Mitigation: preserve existing signatures now and add structured validation only where current UI requires it.
- Check-in can double-decrement remaining hours if not idempotent -> Mitigation: require check-in to mutate only scheduled/eligible lessons and test repeated calls.
- Generated lessons may duplicate on class creation or update -> Mitigation: define generation idempotency around class ID and scheduled dates.
- Last-write-wins sync may lose simultaneous edits -> Mitigation: keep this documented as MVP behavior and expose pending/sync status consistently.

## Migration Plan

1. Normalize service contracts against `docs/api-design.md` and current domain models.
2. Complete mock service implementations using `MockDataStore`.
3. Update Providers to call service methods for API-like operations and refresh dependent state after mutations.
4. Add focused tests for auth, child/class/lesson CRUD, cascade deletion, check-in/leave side effects, cost stats, and sync status.
5. Run static analysis and targeted tests.

Rollback strategy: because this change is confined to service/provider behavior, rollback is a code revert of the change. Existing UI can continue using the prior mock paths if needed.

## Open Questions

- Should service contracts eventually expose structured validation errors for all modules, or only for forms with user-visible inline validation?
- Should class update regenerate future lessons automatically, or should that remain an explicit operation in this MVP?
- Should leave automatically create a makeup/superseding lesson in MVP, or only mark leave and preserve the future extension point?
