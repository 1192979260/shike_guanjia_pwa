## 1. Project Setup & Foundation

- [x] 1.1 Create domain models directory structure (`lib/domain/models/`)
- [x] 1.2 Create data layer directory structure (`lib/data/models/`, `lib/data/repositories/`, `lib/data/services/`)
- [x] 1.3 Add required dependencies (provider, sqflite, path_provider, intl, time)
- [x] 1.4 Set up service locator/dependency injection (GetIt)
- [x] 1.5 Configure app entry point with Provider setup

## 2. Data Model Implementation

- [x] 2.1 Create User and Family domain models
- [x] 2.2 Create Child domain model with validation
- [x] 2.3 Create TrainingClass domain model with scheduling rules
- [x] 2.4 Create Lesson domain model with status tracking
- [x] 2.5 Create Attendance and LeaveRecord domain models
- [x] 2.6 Create CostStatistics domain model
- [x] 2.7 Create persistence models for SQLite schema
- [x] 2.8 Add model serialization (fromJson/toJson) for all domain models

## 3. Service Layer - Mock Implementation

- [x] 3.1 Create abstract service interfaces (AuthService, ChildService, ClassService, etc.)
- [x] 3.2 Implement AuthService mock with phone verification simulation
- [x] 3.3 Implement ChildService mock with in-memory storage
- [x] 3.4 Implement ClassService mock with in-memory storage
- [x] 3.5 Implement LessonService mock with in-memory storage
- [x] 3.6 Implement AttendanceService mock with in-memory storage
- [x] 3.7 Implement CostService mock with calculation logic
- [x] 3.8 Implement SyncService mock with offline simulation

## 4. Repository Layer

- [x] 4.1 Create base repository class with common CRUD operations
- [x] 4.2 Implement ChildRepository with mock service integration
- [x] 4.3 Implement ClassRepository with mock service integration
- [x] 4.4 Implement LessonRepository with mock service integration
- [x] 4.5 Implement AttendanceRepository with mock service integration
- [x] 4.6 Implement UserRepository with mock service integration

## 5. Scheduling Engine

- [x] 5.1 Create SchedulingRule abstract base class
- [x] 5.2 Implement WeeklyScheduleRule strategy
- [x] 5.3 Implement MonthlyScheduleRule strategy
- [x] 5.4 Implement CustomIntervalScheduleRule strategy
- [x] 5.5 Create LessonGenerator service
- [x] 5.6 Implement lesson generation logic for all rule types
- [x] 5.7 Create ConflictDetector service
- [x] 5.8 Implement time overlap detection algorithm
- [x] 5.9 Add unit tests for scheduling edge cases

## 6. Cost Calculation Engine

- [x] 6.1 Create CostCalculator service
- [x] 6.2 Implement per-session cost calculation
- [x] 6.3 Implement monthly cost aggregation
- [x] 6.4 Implement remaining cost calculation
- [x] 6.5 Implement cost breakdown by class and child
- [x] 6.6 Add memoization for performance optimization
- [x] 6.7 Add unit tests for cost calculation edge cases

## 7. Offline Sync Infrastructure

- [x] 7.1 Create SQLite database helper
- [x] 7.2 Define database schema and migration scripts
- [ ] 7.3 Implement local data caching layer
- [ ] 7.4 Create sync queue manager
- [ ] 7.5 Implement pending change tracking
- [ ] 7.6 Create background sync scheduler
- [ ] 7.7 Implement conflict resolution (last-write-wins)
- [ ] 7.8 Add sync status tracking and reporting
- [ ] 7.9 Implement retry logic with exponential backoff

## 8. State Management (Providers)

- [ ] 8.1 Create AuthProvider for user session management
- [ ] 8.2 Create ChildProvider for child profile state
- [ ] 8.3 Create ClassProvider for training class state
- [ ] 8.4 Create LessonProvider for lesson schedule state
- [ ] 8.5 Create AttendanceProvider for check-in and leave state
- [ ] 8.6 Create SyncProvider for offline sync status
- [ ] 8.7 Create CostProvider for cost statistics state

## 9. User Authentication UI

- [ ] 9.1 Create login page with phone input
- [ ] 9.2 Implement verification code input and validation
- [ ] 9.3 Create authentication service integration
- [ ] 9.4 Add session persistence logic
- [ ] 9.5 Implement logout functionality
- [ ] 9.6 Create family member management UI
- [ ] 9.7 Add family member invitation flow

## 10. Child Profile Management UI

- [ ] 10.1 Create child list page
- [ ] 10.2 Implement add child form with validation
- [ ] 10.3 Create edit child page
- [ ] 10.4 Implement delete child with confirmation dialog
- [ ] 10.5 Add default avatar generation
- [ ] ] 10.6 Implement avatar upload functionality

## 11. Training Class Management UI

- [ ] 11.1 Create class list page (active/completed tabs)
- [ ] 11.2 Implement add class form with all fields
- [ ] 11.3 Create scheduling rule selector UI
- [ ] 11.4 Implement weekly schedule rule configuration
- [ ] 11.5 Implement monthly schedule rule configuration
- [ ] 11.6 Implement custom interval schedule configuration
- [ ] 11.7 Create edit class page
- [ ] 11.8 Implement pause/resume class functionality
- [ ] 11.9 Implement class renewal flow
- [ ] 11.10 Add conflict detection warnings

## 12. Lesson Schedule UI

- [ ] 12.1 Create calendar view component
- [ ] 12.2 Implement 3-week view navigation
- [ ] 12.3 Add lesson filtering by child and class
- [ ] 12.4 Create lesson list view
- [ ] 12.5 Implement lesson detail page
- [ ] 12.6 Add manual lesson creation/modification
- [ ] 12.7 Implement temporary suspension UI
- [ ] 12.8 Add conflict visualization

## 13. Attendance Tracking UI

- [ ] 13.1 Create check-in confirmation dialog
- [ ] 13.2 Implement check-in with notes functionality
- [ ] 13.3 Add backdated check-in flow
- [ ] 13.4 Create leave request form
- [ ] 13.5 Implement leave history page
- [ ] 13.6 Add make-up lesson management UI
- [ ] 13.7 Implement attendance reminders display
- [ ] 13.8 Create attendance statistics view

## 14. Cost Statistics UI

- [ ] 14.1 Create monthly cost report page
- [ ] 14.2 Implement cost breakdown by class
- [ ] 14.3 Add cost comparison by child
- [ ] 14.4 Create remaining cost display
- [ ] 14.5 Implement cost trend visualization
- [ ] 14.6 Add CSV export functionality
- [ ] 14.7 Implement PDF export (placeholder for future)

## 15. Dashboard & Navigation

- [ ] 15.1 Create main dashboard/home page
- [ ] 15.2 Implement today's lessons card
- [ ] 15.3 Add upcoming 3-day lessons list
- [ ] 15.4 Create monthly cost summary card
- [ ] 15.5 Implement remaining sessions overview
- [ ] 15.6 Set up bottom navigation bar
- [ ] 15.7 Create app routing structure

## 16. Offline Sync UI

- [ ] 16.1 Create offline status banner
- [ ] 16.2 Implement sync progress indicator
- [ ] 16.3 Add pending changes display
- [ ] 16.4 Create sync settings page
- [ ] 16.5 Implement manual sync trigger
- [ ] 16.6 Add sync error handling and retry UI

## 17. Settings & Profile

- [ ] 17.1 Create settings page
- [ ] 17.2 Implement data export functionality
- [ ] 17.3 Add about page
- [ ] 17.4 Create user profile page
- [ ] 17.5 Implement theme configuration (placeholder for paid version)

## 18. Onboarding Flow

- [ ] 18.1 Create first-time user onboarding screens
- [ ] 18.2 Implement add first child prompt
- [ ] 18.3 Add add first class prompt
- [ ] 18.4 Create onboarding completion flow

## 19. Testing & Quality Assurance

- [ ] 19.1 Write unit tests for all domain models
- [ ] 19.2 Write unit tests for scheduling engine
- [ ] 19.3 Write unit tests for cost calculator
- [ ] 19.4 Write unit tests for repositories
- [ ] 19.5 Write widget tests for key UI components
- [ ] 19.6 Implement integration tests for critical flows
- [ ] 19.7 Add manual testing checklist for PRD scenarios

## 20. Performance & Optimization

- [ ] 20.1 Implement lazy loading for lesson data
- [ ] 20.2 Add pagination for reports and lists
- [ ] 20.3 Optimize database queries with proper indexing
- [ ] 20.4 Implement image caching for avatars
- [ ] 20.5 Add performance monitoring and logging

## 21. Documentation & Handoff

- [ ] 21.1 Document API service interfaces
- [ ] 21.2 Document data model relationships
- [ ] 21.3 Create architecture decision record
- [ ] 21.4 Document offline sync behavior
- [ ] 21.5 Write deployment guide for MVP
- [ ] 21.6 Document LeanCloud migration path
