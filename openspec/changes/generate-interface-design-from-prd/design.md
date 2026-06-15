## Context

The PRD defines a comprehensive training class management system with complex scheduling rules, cost calculations, and offline-first requirements. Currently, the codebase has minimal structure with basic Flutter scaffolding. We need to establish a clear architecture for data models, API services, and business logic that can scale from MVP mock data to production LeanCloud integration.

Key constraints:
- Flutter cross-platform (iOS/Android)
- MVP uses mock data, production uses LeanCloud BaaS
- Offline-first with local caching
- Family account sharing (2 users max)
- Complex scheduling rules (weekly, monthly, custom intervals)

## Goals / Non-Goals

**Goals:**
- Define clear data model architecture that supports all PRD entities
- Establish service layer abstraction for mock-to-production migration
- Design offline sync strategy with conflict resolution
- Create reusable scheduling engine for lesson generation
- Define cost calculation engine with clear business rules
- Establish type-safe API contracts

**Non-Goals:**
- Implement actual LeanCloud SDK integration (MVP uses mocks)
- Build real-time push notification system
- Implement GPS-based check-in
- Create visualization charts (deferred to future iterations)

## Decisions

### 1. Data Model Architecture

**Decision:** Use repository pattern with domain models separate from persistence models.

**Rationale:**
- Domain models (`lib/domain/models/`) represent business entities with validation and business logic
- Persistence models (`lib/data/models/`) map to storage (LeanCloud objects or local SQLite)
- Repository layer (`lib/data/repositories/`) handles data transformation and sync
- Enables clean migration from mock to real backend without changing domain layer

**Alternatives considered:**
- Direct LeanCloud objects in UI: Too tight coupling, hard to test
- Single model everywhere: Mixes concerns, makes offline sync complex

### 2. Scheduling Engine Design

**Decision:** Implement rule-based scheduling engine with pluggable strategies.

**Rationale:**
- PRD defines three scheduling patterns: weekly, monthly, custom interval
- Strategy pattern allows easy extension for future rules
- Separates lesson generation logic from data models
- Testable in isolation without full data layer

**Components:**
- `SchedulingRule` abstract base class
- `WeeklyScheduleRule`, `MonthlyScheduleRule`, `CustomIntervalRule` implementations
- `LessonGenerator` service that applies rules to date ranges
- `ConflictDetector` for identifying overlapping lessons

### 3. Cost Calculation Engine

**Decision:** Centralized cost calculator with clear business rule separation.

**Rationale:**
- PRD defines specific formula: `单次成本 = 总费用 ÷ 总课时`
- Monthly reports need aggregation across multiple classes
- Cost logic should be consistent across all views
- Easy to adjust pricing models in future

**Design:**
- `CostCalculator` service with methods:
  - `calculatePerClassCost(class)`: Returns single session cost
  - `calculateMonthlyCost(month, classes)`: Returns monthly spending
  - `calculateRemainingCost(class)`: Returns remaining value
- Memoization for performance on large datasets

### 4. Offline Sync Strategy

**Decision:** Optimistic replication with last-write-wins conflict resolution.

**Rationale:**
- Simple to implement and understand
- Works well for single-family use case (2 users max)
- MVP doesn't need complex merge strategies
- Local-first UX feels faster

**Architecture:**
- Local SQLite as primary data store
- Background sync queue for pending operations
- Timestamp-based conflict resolution
- Sync status tracked per entity (synced, pending, conflict)

**Trade-off:** Last-write-wins can lose data if both parents edit simultaneously. Acceptable for MVP given low conflict probability.

### 5. API Service Layer

**Decision:** Abstract service interfaces with mock and production implementations.

**Rationale:**
- Enables parallel development without backend
- Clear contracts defined in interfaces
- Easy to switch implementations via dependency injection
- Testable with mock implementations

**Structure:**
- `lib/data/services/` contains abstract service interfaces
- `lib/data/services/mock/` implements with in-memory data
- `lib/data/services/leancloud/` implements with real SDK (future)
- `ServiceLocator` or `GetIt` for dependency injection

### 6. State Management

**Decision:** Use Provider for state management with clear separation of concerns.

**Rationale:**
- Flutter-recommended, lightweight
- Good for our use case (family data, not complex global state)
- Easier to learn than Bloc/Riverpod for the team
- Sufficient for MVP scale

**Architecture:**
- `ChildProvider`, `ClassProvider`, `LessonProvider` for domain entities
- `SyncProvider` for offline sync status
- `AuthProvider` for user session

## Risks / Trade-offs

### Risk 1: Scheduling Edge Cases
**Risk:** Complex date math around month boundaries, leap years, holidays.

**Mitigation:**
- Use `intl` and `time` packages for date operations
- Comprehensive unit tests for scheduling edge cases
- Manual adjustment UI for edge cases automation can't handle

### Risk 2: Offline Sync Conflicts
**Risk:** Both parents edit same class simultaneously, data loss with last-write-wins.

**Mitigation:**
- Add conflict detection UI when sync fails
- Consider field-level merging for MVP+1
- Document limitation clearly

### Risk 3: LeanCloud Migration Complexity
**Risk:** Mock data structure doesn't map well to LeanCloud schema.

**Mitigation:**
- Design persistence models with LeanCloud constraints in mind
- Keep mock and production implementations in sync during development
- Early integration testing before production launch

### Risk 4: Performance with Large Datasets
**Risk:** Query performance degrades with many classes/lessons over time.

**Mitigation:**
- Index SQLite tables properly
- Lazy load lesson data (only visible range)
- Pagination for reports
- Consider data archiving for completed classes

### Trade-off: Simplicity vs. Flexibility
**Trade-off:** MVP uses simple last-write-wins sync, not operational transformation.

**Justification:** Complexity not justified for 2-user family use case. Can upgrade if needed.

## Open Questions

1. **Holiday Handling:** Should we support custom holiday calendars for scheduling? (Deferred to MVP+1)
2. **Reminder Timing:** What are optimal reminder times before class? (User-configurable or fixed?)
3. **Data Retention:** How long to keep completed class data? (Archive policy?)
4. **Export Format:** CSV vs. JSON for data export? (PRD mentions CSV, verify with users)
5. **Theme System:** Should we implement theming now or defer to paid version? (PRD mentions paid feature)

## Migration Plan

### Phase 1: Foundation (Current)
- Implement data models and repositories with mock services
- Build scheduling and cost calculation engines
- Set up offline sync infrastructure
- Implement core CRUD operations

### Phase 2: UI Integration
- Connect UI to service layer
- Implement all PRD features with mock data
- Test offline behavior thoroughly

### Phase 3: Production Migration
- Implement LeanCloud service layer
- Data migration script for mock to production
- Gradual rollout with feature flags
- Monitor sync reliability

### Rollback Strategy
- Feature flag to switch back to mock services
- Local data persists regardless of backend
- No data loss during backend transitions
