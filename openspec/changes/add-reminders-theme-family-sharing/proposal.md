## Why

The iteration requirements document captures three user-facing improvements that should be specified before implementation: lesson reminders, theme selection, and enhanced family sharing. Defining them as OpenSpec capabilities now keeps Flutter UI, provider state, service contracts, local cache behavior, and backend-facing API expectations aligned before code changes begin.

## What Changes

- Add configurable lesson reminders from the profile area, including enablement, advance time, today/makeup lesson inclusion, notification permission guidance, local cache fallback, and local notification scheduling.
- Add theme and skin selection from the profile area, including three preset skins, immediate app-wide theme switching, local persistence, and backend preference synchronization.
- Enhance family sharing from the profile area, including family/member display, relation labels, member add/remove flows, MVP two-member limit handling, confirmation prompts, and mapped backend error messages.
- Preserve existing architecture boundaries: screens delegate mutations to providers, providers use services, HTTP adapters stay under `lib/services/http/`, and app-wide services are registered through `lib/core/service_locator.dart`.
- Keep client models compatible with the sibling backend by using `camelCase` fields, string enum values, and ISO-8601 date strings.

## Capabilities

### New Capabilities
- `lesson-reminders`: Defines reminder settings, notification permission handling, lesson reminder scheduling, local cache fallback, and backend settings synchronization.
- `theme-selection`: Defines theme skin choices, immediate app-wide theme application, local persistence, and backend preference synchronization.
- `family-sharing`: Defines the family sharing page behavior, family member list, member relation handling, add/remove flows, two-member limit, and backend error mapping.

### Modified Capabilities

## Impact

- Affected code: `lib/main.dart`, `lib/core/service_locator.dart`, `lib/models/**`, `lib/providers/**`, `lib/screens/**`, `lib/services/**`, `lib/services/http/**`, `lib/services/mock/**`, and focused tests under `test/**`.
- Affected APIs: `GET /api/reminder-settings`, `PATCH /api/reminder-settings`, `GET /api/preferences/theme`, `PATCH /api/preferences/theme`, and existing or extended family member APIs exposed through `AuthService` or a dedicated family service.
- Affected systems: profile navigation, provider initialization, local storage, local notification scheduling, backend preference sync, family access state, and error presentation.
- Dependencies: implementation is expected to use the existing Flutter stack and current `flutter_local_notifications` integration; no new runtime dependency is required unless the current notification setup is insufficient for permission/status checks.
