## Context

The Flutter app already centralizes startup, routes, and provider wiring in `lib/main.dart`, service registration in `lib/core/service_locator.dart`, state orchestration in `lib/providers/`, UI screens in `lib/screens/`, models in `lib/models/`, and HTTP adapters in `lib/services/http/`. The profile tab already exposes placeholder rows for family sharing, theme selection, and lesson reminders, but those rows do not yet lead to production behavior.

The sibling backend contract requires `camelCase` fields, string enum values, ISO-8601 date strings, `{ "data": ... }` success responses, and structured `{ "error": { "code", "message", "fields" } }` failures. Existing runtime services default to HTTP-backed implementations, while mock services remain useful for tests and local fallback behavior.

## Goals / Non-Goals

**Goals:**
- Add provider-backed profile entry flows for lesson reminders, theme selection, and family sharing.
- Keep service contracts typed and model-based so screens do not depend on HTTP payload details.
- Persist reminder and theme preferences locally so startup/offline behavior remains stable.
- Keep family sharing behavior consistent with existing `AuthService` family APIs unless implementation evidence requires a dedicated `FamilyService`.
- Define focused implementation and verification steps that can be applied incrementally.

**Non-Goals:**
- Do not redesign the profile tab, navigation shell, or app-wide visual language beyond the theme skin variants.
- Do not implement server-side notification delivery; lesson reminders are local notifications driven by synced lesson data.
- Do not require an invitation workflow for MVP family sharing unless backend endpoints already expose it.
- Do not change unrelated child, class, lesson, attendance, or statistics behavior.

## Decisions

### Use dedicated providers for new state domains

Add `ReminderProvider`, `ThemeProvider`, and `FamilyProvider` instead of expanding screen-local state. This matches the existing provider boundary, keeps async loading/error state testable, and prevents profile screens from coordinating service calls directly.

Alternative considered: fold reminder and family state into `AuthProvider`. That would reduce provider count but would mix session state with notification scheduling, UI preferences, and member CRUD, making initialization and refresh side effects harder to reason about.

### Keep services explicit and backend-compatible

Introduce `ReminderService` and a theme preference service (`PreferenceService` or `ThemePreferenceService`) with HTTP implementations under `lib/services/http/` and test/mock implementations under `lib/services/mock/`. For family sharing, first reuse the existing `AuthService` family methods through `FamilyProvider`; split to `FamilyService` only if the implementation needs invite-specific endpoints or richer family lifecycle APIs.

Alternative considered: have providers call `ApiClient` directly for the new endpoints. That would be faster initially but would violate the repository's service boundary and make mock/test coverage weaker.

### Persist local preferences through `StorageService`

Store reminder settings and selected theme skin in `StorageService`. Reminder settings use defaults when neither local cache nor backend state exists. Theme cache is not cleared on logout so the app avoids visual flashback; a subsequent login may override it with the server preference.

Alternative considered: rely only on backend preferences. That would make cold start and offline states worse and would contradict the requirement for cached theme/reminder behavior.

### Schedule only eligible local lesson notifications

`ReminderService.scheduleLessonReminders` schedules notifications only for `scheduled` lessons that match the active reminder settings. Completed, leave, cancelled, or otherwise inactive lessons are skipped or cancelled. Permission denial does not block saving settings; it is exposed as provider/UI state with a direct action for the user to open system settings.

Alternative considered: schedule all lessons and filter inside notification callbacks. That increases stale notification risk and makes lesson mutation cleanup less reliable.

### Drive theme through `MaterialApp.theme`

`ThemeProvider` exposes the active `ThemeSkin` and a `ThemeData` generated from `AppTheme`. `ShikeGuanjiaApp` watches the provider so theme changes take effect immediately without replacing the navigation stack.

Alternative considered: pass theme colors through individual screens. That would be error-prone, would miss nested widgets, and would make state preservation harder.

## Risks / Trade-offs

- Notification permission APIs differ by platform and plugin version -> isolate permission reads/requests behind the reminder service and verify Android/iOS behavior manually after implementation.
- Local notification scheduling can become stale after lesson mutations -> have lesson/class mutations trigger reminder rescheduling through provider/service coordination.
- Backend preference save can fail after local theme switch -> keep the optimistic local theme, show a sync error, and retry on next explicit change or login sync.
- Family sharing endpoints may return error codes not yet documented -> map known codes explicitly and fall back to backend message for unknown codes without crashing the flow.
- Adding three flows in one change increases implementation size -> keep tasks separated by capability and verify each provider/service/screen path independently.
