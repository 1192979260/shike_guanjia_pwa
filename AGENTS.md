# Project Rules

This is the Flutter client for the 课时管家 app. Keep UI models compatible with the sibling backend at `../shike_guanjia_backend`: `camelCase` fields, enum string values, and ISO-8601 date strings.

## Commands

- Install: `flutter pub get`
- Run app: `flutter run`
- Analyze: `flutter analyze`
- Targeted tests: `flutter test test/services test/date_utils_test.dart`
- Full tests: `flutter test`

## Architecture Boundaries

- App startup, routes, and provider wiring live in `lib/main.dart`.
- Service registration lives in `lib/core/service_locator.dart`; HTTP-backed services are the default runtime data source.
- State orchestration lives in `lib/providers/`; avoid moving backend or persistence details into screens.
- UI screens live in `lib/screens/`; keep business mutations delegated to providers/services.
- Models live in `lib/models/`; use `package:shike_guanjia/models/models.dart` for app-wide model imports.
- HTTP adapters live in `lib/services/http/`; mock implementations live in `lib/services/mock/`.

## UX Invariants

- Class detail must refresh class and lesson data after returning from class edit/renew before displaying the cached class snapshot.
- Classes tab filters are child first, then subject/course; changing child clears the selected course.
- Class cards show progress, remaining hours, per-lesson price, and total fee.
- Statistics tab is an expense view: cumulative paid amount, consumed value, remaining lesson value, class fee breakdown, and calculation notes.

## Verification Notes

- `flutter analyze` is the fastest required check after UI/provider changes.
- `flutter test test/services test/date_utils_test.dart` covers current service/date logic without app-level `GetIt` setup.
- `test/widget_test.dart` pumps the full app and needs test-side service locator registration before it can be treated as a reliable regression check.
