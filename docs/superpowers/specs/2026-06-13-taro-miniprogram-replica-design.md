# Taro Mini Program Replica Design

Date: 2026-06-13
Status: Approved design, pending implementation plan

## Goal

Create a sibling Taro project for the 课时管家 WeChat Mini Program that replicates the current Flutter app's functionality and UI as closely as practical. The mini program connects to the Tencent CloudBase cloud hosting backend:

`https://shike-backend-269793-9-1252534988.sh.run.tcloudbase.com`

The primary runtime target is WeChat Mini Program. Taro H5 should remain usable for development preview, but visual and behavioral parity is judged against the mini program target.

## Source Of Truth

The Flutter client in `/Users/zhengping/Documents/demos/shike_guanjia` is the source for:

- Page flow and navigation hierarchy
- Models, enum string values, `camelCase` fields, and ISO-8601 date strings
- HTTP API paths and `{ data, error }` response envelope handling
- Provider responsibilities and user-facing business workflows
- Organic warm sticker visual language from `lib/themes/app_theme.dart` and `lib/widgets/design/sticker_widgets.dart`

The sibling backend at `../shike_guanjia_backend` remains the API contract owner.

## Project Location

Create the new project as a sibling directory of the Flutter app, for example:

`/Users/zhengping/Documents/demos/shike_guanjia_taro`

Do not place the Taro project inside the Flutter repository.

## Technical Architecture

Use Taro with React, TypeScript, SCSS, and Zustand.

Recommended structure:

```text
src/
  app.config.ts
  app.scss
  app.ts
  components/
    child-avatar/
    class-card/
    organic-progress-bar/
    soft-chip/
    sticker-card/
  models/
    attendance.ts
    child.ts
    class.ts
    cost-statistics.ts
    lesson.ts
    preferences.ts
    user.ts
  pages/
    login/
    onboarding/
    home/
    class-detail/
    class-form/
    family-sharing/
    reminder-settings/
    theme-selection/
  services/
    api-client.ts
    auth-service.ts
    child-service.ts
    class-service.ts
    lesson-service.ts
    cost-service.ts
    preference-service.ts
  store/
    auth-store.ts
    child-store.ts
    class-store.ts
    lesson-store.ts
    preference-store.ts
  theme/
    tokens.scss
  utils/
    date.ts
    format.ts
```

Keep state orchestration in stores, backend calls in services, and screen components focused on UI and user interactions.

## API Client

Implement a shared request client using `Taro.request`.

Requirements:

- Base URL is the CloudBase URL above.
- Send JSON with `content-type: application/json`.
- Persist auth data with Taro storage keys equivalent to Flutter:
  - `auth_token`
  - `auth_phone`
  - `family_id`
  - `onboarding_done`
  - `theme_skin`
- Attach `authorization: Bearer <token>` when token exists.
- Unwrap successful responses from `body.data`.
- If `body.error` exists, throw a typed API error with `code`, `message`, and optional `fields`.
- Treat HTTP 5xx and request failures as user-visible network errors.
- Clean `null` and `undefined` request values before sending.

## Model Compatibility

Port the Flutter models to TypeScript interfaces and string union types.

Core enum values:

- `ClassStatus`: `active`, `paused`, `ended`
- `RecurringRuleType`: `weekly`, `monthly`, `custom`
- `LessonStatus`: `scheduled`, `completed`, `leave`, `cancelled`
- `AttendanceType`: `checkin`, `early_attempt`, `backdated`
- `LeaveStatus`: `approved`, `cancelled`
- `FamilyRelation`: `mother`, `father`
- `ThemeSkin`: `warm`, `fresh`, `classic`

Dates should stay as ISO strings at the API boundary. UI helpers can format them, but should not mutate stored API objects into incompatible shapes.

## Page Flow

Match the Flutter startup gate:

1. If no restored token/session exists, show login.
2. After login, if onboarding is not done, show onboarding.
3. Otherwise show the home tabs.

Main pages:

- Login: phone, verification code, send code, login, loading/error states.
- Onboarding: minimal first-use flow that marks `onboarding_done`.
- Home: five tabs matching Flutter's information architecture:
  - Overview/dashboard
  - Lessons/schedule
  - Classes
  - Statistics
  - Settings
- Class detail: class summary, lesson list, check-in, cancel check-in, leave, manual lesson, edit, renew, pause, resume, end, delete.
- Class form: create, edit, and renew mode.
- Family sharing: member list, add member, remove member, backend error mapping.
- Theme selection: warm/fresh/classic choices.
- Reminder settings: enabled flag, advance minutes, today/makeup toggles.

## UX Contracts To Preserve

- Class detail refreshes class and lesson data after returning from edit or renew before displaying the cached class snapshot.
- Classes tab filters by child first, then subject/course; changing child clears selected course.
- Class cards show progress, remaining hours, per-lesson price, and total fee.
- Statistics tab is an expense view: cumulative paid amount, consumed value, remaining lesson value, class fee breakdown, and calculation notes.
- Error handling should use inline errors for page-level failures and toast/modal feedback for operation results.

## Visual Design

Replicate the Flutter organic sticker visual direction:

- Warm default palette:
  - Primary `#C66B3D`
  - Accent `#C08E3A`
  - Sage `#8B9D83`
  - Moss `#606C38`
  - Clay `#B08B6E`
  - Sand/background `#E8DCC7`
  - Oat `#D4B895`
  - Surface `#F9F1E3`
  - Primary text `#3F3428`
  - Secondary text `#7D6B58`
- Components:
  - Sticker cards with large rounded corners, soft border, and warm shadow.
  - Circular child avatars with generated colors and initial letters.
  - Rounded action buttons and chips.
  - Organic progress bars for class usage.
  - Warm/fresh/classic theme cards with swatches.
- Do not introduce a new visual brand. Mini program UI should feel like the Flutter app adapted to WeChat constraints.

## Error Handling

Map known backend error codes where Flutter already does so, especially family sharing:

- `FAMILY_MEMBER_LIMIT_REACHED`: 当前家庭最多支持 2 位成员
- `USER_ALREADY_IN_FAMILY`: 该手机号已在当前家庭中
- `CANNOT_REMOVE_LAST_MEMBER`: 至少需要保留一位家庭成员
- `FAMILY_INVITE_EXPIRED`: 邀请已过期，请重新发送
- `FAMILY_INVITE_NOT_FOUND`: 邀请不存在或已失效
- `FAMILY_NOT_FOUND`: 家庭不存在或已失效，请重新登录

Fallback copy: 操作失败，请稍后重试

## Testing And Verification

Minimum verification after implementation:

- Install dependencies.
- Run TypeScript check or Taro build checks.
- Build WeChat Mini Program target.
- Run H5 preview if the project setup supports it without extra platform credentials.
- Verify app startup, login request wiring, token persistence, home tab rendering, and at least one authenticated API call against the CloudBase URL.

## Scope Notes

Pixel-level parity is the target, but implementation should still land in reviewable layers. Build the reusable theme/components first, then pages and workflows. Avoid broad reinvention of backend behavior on the client.
