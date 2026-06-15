## 1. Service Contract Alignment

- [ ] 1.1 Compare `lib/services/*_service.dart` against `docs/api-design.md` and list signature gaps for auth, child, class, lesson, attendance, cost, and sync operations.
- [ ] 1.2 Normalize service interfaces so Provider-facing methods cover documented PRD/API operations without exposing mock storage internals.
- [ ] 1.3 Add or adjust model fields, enums, or helper methods needed by service contracts while preserving existing serialization compatibility.
- [ ] 1.4 Ensure service locator registration resolves all required service interfaces in mock mode.

## 2. Shared Mock Data Store

- [ ] 2.1 Review `MockDataStore` and centralize storage for users, families, children, classes, lessons, attendance records, leave records, and sync queue state.
- [ ] 2.2 Add reset or seed helpers needed for deterministic tests without leaking state across test cases.
- [ ] 2.3 Implement lookup utilities for family, child, class, and lesson relationships used by cascade and query operations.

## 3. Mock API Implementations

- [ ] 3.1 Implement mock auth verification, login, logout, current user, family creation, and MVP family member behavior.
- [ ] 3.2 Implement mock child create, update, delete, get, list, validation, and child deletion cascade to classes and lessons.
- [ ] 3.3 Implement mock class create, update, delete, get, filtered list, active/completed list, pause, resume, end, renew, and conflict detection.
- [ ] 3.4 Implement lesson generation on class creation using existing scheduling utilities and prevent duplicate generated lessons for the same class/date.
- [ ] 3.5 Implement mock lesson get, class lesson list, date range list, today's lessons, upcoming lessons, manual add, update, delete, conflict detection, and suspension operations.
- [ ] 3.6 Implement mock attendance check-in, leave request, leave cancellation/history, makeup lookup, and attendance statistics.
- [ ] 3.7 Ensure check-in marks lessons completed, records attendance metadata, and decrements remaining class hours exactly once.
- [ ] 3.8 Ensure leave marks lessons as leave, records the leave reason, and does not deduct class hours.
- [ ] 3.9 Implement mock cost statistics from current class and completed lesson state, including monthly cost, breakdown, trend, remaining value, and CSV export.
- [ ] 3.10 Implement mock sync initialize, queue, status, online/offline behavior, retry, callbacks, and deterministic sync results.

## 4. Provider Integration

- [ ] 4.1 Update AuthProvider to use AuthService session and family APIs consistently.
- [ ] 4.2 Update ChildProvider to call ChildService for CRUD and refresh dependent class/lesson state after child deletion.
- [ ] 4.3 Update ClassProvider to call ClassService for lifecycle operations and refresh or invalidate lesson/cost state after class mutations.
- [ ] 4.4 Update LessonProvider to call LessonService and AttendanceService for lesson mutations, check-in, and leave flows.
- [ ] 4.5 Ensure Providers expose loading and error states for failed asynchronous service operations without publishing local-only success state.
- [ ] 4.6 Verify UI screens still compile against updated Provider/service contracts.

## 5. Tests and Verification

- [ ] 5.1 Add service tests for auth validation, login session creation, logout, and family setup.
- [ ] 5.2 Add service tests for child CRUD, family filtering, validation failures, and cascade deletion.
- [ ] 5.3 Add service tests for class CRUD, status transitions, filtering, renewal, conflict detection, and generated lessons.
- [ ] 5.4 Add service tests for lesson date filtering, manual lesson mutation, suspension behavior, check-in idempotency, and leave behavior.
- [ ] 5.5 Add service tests for monthly cost, remaining value, class breakdown, child/class filters, and CSV export.
- [ ] 5.6 Add sync service tests for online success, offline pending behavior, retry, queue count, and callback updates.
- [ ] 5.7 Run `flutter test` or the narrowest available Dart/Flutter test command covering the changed services and Providers.
- [ ] 5.8 Run static analysis and fix new errors introduced by this change.

## 6. Documentation and Cleanup

- [ ] 6.1 Update `docs/api-design.md` if implementation chooses a service signature or side-effect behavior that differs from the current document.
- [ ] 6.2 Remove obsolete duplicate mock logic or direct Provider mutations made redundant by the finalized service layer.
- [ ] 6.3 Confirm the change remains ready for future LeanCloud adapter implementation without mock-only details leaking into UI code.
