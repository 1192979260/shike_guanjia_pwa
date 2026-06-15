## 1. Shared Model and Storage Foundations

- [x] 1.1 Add `ReminderSettings` model with defaults, `copyWith`, `toJson`, `fromJson`, `camelCase` fields, and ISO-8601 `updatedAt` serialization.
- [x] 1.2 Add `ThemeSkin` enum with `warm`, `fresh`, and `classic` string serialization plus safe fallback for unsupported values.
- [x] 1.3 Extend `StorageService` with local cache APIs for reminder settings and theme skin without clearing theme cache during logout.
- [x] 1.4 Export the new model and enum through `package:shike_guanjia/models/models.dart`.

## 2. Reminder Service and Provider

- [x] 2.1 Add `ReminderService` interface with get/update settings, schedule lesson reminders, cancel reminders, and notification permission status operations.
- [x] 2.2 Implement HTTP reminder settings calls for `GET /api/reminder-settings` and `PATCH /api/reminder-settings`.
- [x] 2.3 Implement mock/test reminder service behavior, including default settings and local scheduling call tracking where useful for tests.
- [x] 2.4 Implement local notification scheduling that only targets eligible scheduled lessons and cancels disabled, completed, leave, cancelled, or excluded makeup lesson reminders.
- [x] 2.5 Add `ReminderProvider` initialization, cached-first loading, backend refresh, settings update, permission refresh, error state, and reschedule methods.
- [x] 2.6 Register reminder services and provider wiring in `lib/core/service_locator.dart` and `lib/providers/providers.dart`.

## 3. Theme Service and Provider

- [x] 3.1 Add a typed theme preference service interface for get/update theme preference.
- [x] 3.2 Implement HTTP calls for `GET /api/preferences/theme` and `PATCH /api/preferences/theme`.
- [x] 3.3 Implement mock/test theme preference behavior with valid enum serialization and fallback handling.
- [x] 3.4 Add `ThemeProvider` with cached startup theme, login/server sync, optimistic local switching, backend save error state, and active `ThemeData` exposure.
- [x] 3.5 Extend `AppTheme` to provide `warm`, `fresh`, and `classic` theme data while preserving the current warm theme as default.
- [x] 3.6 Update `ShikeGuanjiaApp` so `MaterialApp.theme` watches `ThemeProvider` without resetting navigation state.

## 4. Family Sharing State

- [x] 4.1 Add `FamilyProvider` that loads current family and members through existing `AuthService` family APIs unless implementation reveals a dedicated service is required.
- [x] 4.2 Add member add flow state, phone validation, relation selection, duplicate-submit prevention, and list refresh after success.
- [x] 4.3 Add member removal flow state, confirmation handling, duplicate-submit prevention, and list refresh after success.
- [x] 4.4 Map known backend family error codes to directed UI messages and provide a safe fallback for unknown backend errors.
- [x] 4.5 Ensure family refresh or auth restoration invalidates stale family access when the backend no longer permits the current family.
- [x] 4.6 Register family provider wiring without clearing theme or reminder local cache during family mutations.

## 5. Screens and Navigation

- [x] 5.1 Add routes or `onGenerateRoute` handling for reminder settings, theme selection, and family sharing screens.
- [x] 5.2 Wire the profile tab menu rows to the new screens and show live summaries for selected theme and reminder timing.
- [x] 5.3 Build the reminder settings screen with enable switch, fixed advance time choices, today/makeup toggles, permission status, settings action, save feedback, and loading/error states.
- [x] 5.4 Build the theme selection screen with three theme cards, color previews, selected state, immediate apply behavior, and backend sync error feedback.
- [x] 5.5 Build the family sharing screen with family name, member list, relation labels, two-member limit display, add member form, remove confirmation, and directed error messages.
- [x] 5.6 Verify each screen handles empty, loading, success, permission-denied, and backend-error states without crashing.

## 6. Integration Side Effects

- [x] 6.1 Trigger reminder rescheduling after lesson create/edit, check-in, leave, cancellation, class edit, class renewal, and class lifecycle changes that affect upcoming lessons.
- [x] 6.2 Ensure login success syncs reminder settings, theme preference, and family state in a stable order without blocking app startup indefinitely.
- [x] 6.3 Ensure logout clears session/family state while preserving cached theme preference and reminder settings.
- [x] 6.4 Confirm backend response handling continues to unwrap `{ "data": ... }` and surface structured `{ "error": ... }` failures consistently.

## 7. Tests and Verification

- [x] 7.1 Add model/storage tests for `ReminderSettings`, `ThemeSkin`, local cache persistence, invalid enum fallback, and logout cache preservation.
- [x] 7.2 Add reminder service/provider tests for default settings, cached-first load, backend update failure, permission-denied state, scheduling eligibility, cancellation, and reschedule triggers.
- [x] 7.3 Add theme provider tests for cached startup theme, server override on login, immediate theme switch, backend failure keeping local selection, and invalid value fallback.
- [x] 7.4 Add family provider tests for loading, member add success, invalid phone rejection, two-member limit, removal confirmation path, known error code mapping, and stale family invalidation.
- [x] 7.5 Add focused widget tests for the three new screens where existing test setup can register service locator dependencies reliably.
- [x] 7.6 Run `flutter analyze` after provider/UI changes.
- [x] 7.7 Run `flutter test test/services test/date_utils_test.dart` plus the new focused tests; run full `flutter test` only after `test/widget_test.dart` has reliable service locator setup or is updated in this change.

## 8. Documentation and Release Notes

- [x] 8.1 Update `docs/iteration-requirements.md` or follow-up documentation if implementation choices differ from the current service or endpoint assumptions.
- [x] 8.2 Document any manual platform verification required for Android/iOS notification permission behavior.
- [x] 8.3 Review the final diff for unrelated refactors and keep the implementation scoped to the three specified capabilities.
