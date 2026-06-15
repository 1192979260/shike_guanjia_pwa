# 课时管家 Flutter

Flutter client for 课时管家, a child training-class management app. The app tracks children, classes, generated lessons, check-in/leave state, and training expenses.

## Quick Start

Requirements:

- Flutter SDK matching `pubspec.yaml`
- A running backend at the API base URL expected by `lib/services/http/api_client.dart`

Install and run:

```bash
flutter pub get
flutter run
```

Useful checks:

```bash
flutter analyze
flutter test test/services test/date_utils_test.dart
```

Full `flutter test` currently also runs `test/widget_test.dart`, which requires test-side `GetIt` service registration before pumping the app.

## App Structure

- `lib/main.dart`: app startup, service locator setup, providers, and route wiring.
- `lib/core/service_locator.dart`: service registration; HTTP-backed services are the default data source.
- `lib/models/`: Flutter JSON models. Keep fields compatible with backend `camelCase` payloads.
- `lib/providers/`: `ChangeNotifier` state orchestration for auth, children, classes, and lessons.
- `lib/screens/home/home_screen.dart`: main five-tab app surface.
- `lib/screens/class_detail/`: class detail, check-in, leave, and edit entry points.
- `lib/screens/class_form/`: class create/edit/renew form.
- `lib/services/http/`: backend API client and HTTP service adapters.
- `lib/services/mock/`: local mock service implementations retained for tests and fallback development.

## Current UX Contracts

- Class detail keeps a local class snapshot; after returning from edit/renew it must refresh classes and lessons before updating the displayed class.
- The classes tab filters in two layers: child first, then subject/course. Changing the selected child clears the course filter.
- Class cards show remaining hours, progress, per-lesson price, and total fee.
- The statistics tab is an expense view: cumulative paid amount, consumed value, remaining lesson value, per-class fee breakdown, and calculation notes.

## Related Backend

The sibling backend project lives at `../shike_guanjia_backend`. It exposes REST JSON APIs with `{ "data": ... }` envelopes, bearer auth, `camelCase` fields, enum names, and ISO-8601 dates.
