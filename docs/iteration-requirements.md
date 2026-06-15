# 课时管家三项迭代需求文档（Flutter）

> 版本：v0.1  
> 日期：2026-06-12  
> 状态：需求沉淀，待拆分 OpenSpec  
> 适用工程：`shike_guanjia`

## 1. 概述

本轮迭代沉淀三个后续待开发能力：上课提醒、主题与皮肤选择、家庭共享增强。Flutter 侧重点是用户入口、状态管理、服务接口、本地缓存、本地通知调度和错误态交互。

本文件只定义需求和客户端落地方向，不直接修改运行时代码。后续进入规格阶段时，需要同步更新 Provider、Service、Model、Screen 和测试。

## 2. 通用约定

- 与后端保持 `camelCase` 字段、字符串枚举和 ISO-8601 时间格式。
- HTTP 成功响应继续从 `{ "data": ... }` 中解包。
- HTTP 错误继续从 `{ "error": { "code", "message", "fields" } }` 中解包。
- 默认运行链路仍通过 `lib/core/service_locator.dart` 注册 HTTP service。
- UI 状态编排放在 `lib/providers/`，HTTP 细节放在 `lib/services/http/`。

## 3. 上课提醒功能

### 3.1 用户入口

在“我的”页新增“上课提醒”入口，进入提醒设置页。首页和课表页可以在后续实现中展示提醒状态，但不作为 MVP 必须入口。

设置页需要支持：

- 开启或关闭上课提醒。
- 选择提前提醒时间。
- 是否提醒今日课次。
- 是否提醒补课课次。
- 展示系统通知权限状态和引导操作。

### 3.2 状态管理

建议新增 `ReminderProvider`，负责：

- 初始化时读取本地缓存并请求后端设置。
- 更新设置后立即刷新本地状态。
- 登录成功后同步服务端设置。
- 课次数据变化后重新调度本地通知。

建议新增模型：

```dart
class ReminderSettings {
  final bool enabled;
  final int advanceMinutes;
  final bool includeTodayLessons;
  final bool includeMakeupLessons;
  final DateTime updatedAt;
}
```

默认值：

- `enabled`: `true`
- `advanceMinutes`: `60`
- `includeTodayLessons`: `true`
- `includeMakeupLessons`: `true`

### 3.3 服务接口

建议新增 `ReminderService`，HTTP 实现放在 `lib/services/http/`。

服务能力：

- `Future<ReminderSettings> getReminderSettings()`
- `Future<ReminderSettings> updateReminderSettings(ReminderSettings settings)`
- `Future<void> scheduleLessonReminders(List<Lesson> lessons, ReminderSettings settings)`
- `Future<void> cancelLessonReminders()`

HTTP 方向：

- `GET /api/reminder-settings`
- `PATCH /api/reminder-settings`

### 3.4 本地存储与通知

- 使用现有 `flutter_local_notifications` 做本地通知。
- `StorageService` 增加提醒设置缓存，保障无网络时仍按最后一次设置工作。
- 本地通知只为 `scheduled` 状态课次调度。
- 已打卡、已请假、已取消课次需要取消或跳过提醒。
- 通知权限未授权时，不阻断保存设置，但需要在 UI 中提示权限状态。

### 3.5 UI 交互

- 设置保存成功后给轻量反馈。
- 权限未授权时展示“去开启通知”的操作。
- 提前提醒时间使用固定选项，例如 15 分钟、30 分钟、1 小时、2 小时、1 天。
- 无课次时设置页仍可正常保存设置。

### 3.6 验收标准

- 新登录用户能看到默认提醒设置。
- 切换提醒开关后，本地状态和后端设置一致。
- 修改提前提醒时间后，后续课次按新时间重新调度。
- 通知权限未授权时有明确降级提示，不影响其他功能。
- 已打卡、请假、取消的课次不会继续提醒。

## 4. 主题与皮肤选择

### 4.1 用户入口

在“我的”页新增“主题与皮肤”入口，进入主题选择页。主题切换需要即时生效，不要求重启 App。

MVP 预设三套主题：

- `warm`：当前暖色主题，作为默认主题。
- `fresh`：清新浅色主题。
- `classic`：稳重经典主题。

### 4.2 状态管理

建议新增 `ThemeProvider`，负责：

- App 启动时从 `StorageService` 读取本地主题。
- 登录后从后端读取用户主题偏好并同步。
- 用户切换主题时立即更新 `MaterialApp.theme`。
- 后端更新失败时保留本地切换，并提示稍后同步。

建议新增枚举：

```dart
enum ThemeSkin {
  warm,
  fresh,
  classic,
}
```

### 4.3 服务接口

建议新增 `PreferenceService` 或 `ThemePreferenceService`。

服务能力：

- `Future<ThemeSkin> getThemePreference()`
- `Future<ThemeSkin> updateThemePreference(ThemeSkin skin)`

HTTP 方向：

- `GET /api/preferences/theme`
- `PATCH /api/preferences/theme`

### 4.4 本地存储

- `StorageService` 增加主题皮肤缓存。
- 退出登录不清除本地主题缓存，避免 App 视觉闪回默认值。
- 换账号登录后，以服务端返回偏好为准，并更新本地缓存。

### 4.5 UI 交互

- 主题选择页展示三套主题名称、色彩预览和当前选中状态。
- 点击主题卡片立即生效。
- 当前主题需要在“我的”页展示摘要。
- 主题切换不应重置当前导航页和已有表单输入。

### 4.6 验收标准

- App 启动时使用本地缓存主题。
- 登录后能同步服务端主题偏好。
- 点击主题后 UI 即时切换。
- 重启 App 后仍保持上次主题。
- 服务端保存失败时，用户能看到错误提示，本地主题不闪退回旧值。

## 5. 家庭共享增强

### 5.1 用户入口

在“我的”页新增“家庭共享”入口，进入家庭共享页。

页面需要展示：

- 当前家庭名称。
- 当前家庭成员列表。
- 成员关系，例如宝妈、爸爸。
- 添加成员入口。
- 移除成员操作。
- MVP 最多 2 人的限制说明。

### 5.2 状态管理

现有 `AuthService` 已包含家庭成员相关能力，后续可以在 `AuthProvider` 中补充家庭状态，或新增 `FamilyProvider` 专门管理家庭共享页。

推荐新增 `FamilyProvider`，负责：

- 加载家庭信息。
- 加载家庭成员。
- 添加或邀请成员。
- 移除成员。
- 根据后端错误码生成 UI 可理解的错误状态。

### 5.3 服务接口

当前已有服务方向：

- `Future<Family?> getFamily()`
- `Future<List<FamilyMember>> getFamilyMembers()`
- `Future<FamilyMember?> addFamilyMember(String phone, FamilyRelation relation)`
- `Future<bool> removeFamilyMember(String memberId)`

后续规格阶段需要决定是否从“直接添加手机号”升级为邀请流。

如果使用邀请流，客户端需要补充：

- 创建邀请。
- 查看待处理邀请。
- 接受邀请。
- 取消邀请。
- 处理邀请过期。

### 5.4 UI 交互

- 添加成员时输入手机号并选择关系。
- 已满 2 人时隐藏或禁用添加入口，并展示明确说明。
- 移除成员需要二次确认。
- 不允许移除最后一个成员时，需要展示明确错误提示。
- 添加重复成员、手机号格式错误、邀请过期等场景需要有定向文案。

建议错误码映射：

| 错误码 | UI 文案方向 |
|--------|-------------|
| `FAMILY_MEMBER_LIMIT_REACHED` | 当前家庭最多支持 2 位成员 |
| `USER_ALREADY_IN_FAMILY` | 该手机号已在当前家庭中 |
| `CANNOT_REMOVE_LAST_MEMBER` | 至少需要保留一位家庭成员 |
| `FAMILY_INVITE_EXPIRED` | 邀请已过期，请重新发送 |
| `FAMILY_INVITE_NOT_FOUND` | 邀请不存在或已失效 |

### 5.5 数据刷新

- 添加或移除成员成功后刷新家庭成员列表。
- 被移除成员重新进入 App 时，需要在鉴权恢复阶段失效原家庭访问，回到登录或重新初始化状态。
- 家庭共享变化不应清空本地主题和提醒设置。

### 5.6 验收标准

- 家庭共享页能展示当前家庭和成员列表。
- 最多 2 人限制在 UI 上可见，并与后端错误一致。
- 添加成员成功后列表立即刷新。
- 移除成员前有二次确认，成功后列表立即刷新。
- 后端返回明确错误码时，UI 展示定向文案。
- 被移除成员不能继续访问原家庭数据。

## 6. 后续规格拆分建议

建议后续拆成三个独立 OpenSpec change：

1. `add-lesson-reminders`
2. `add-theme-selection`
3. `enhance-family-sharing`

每个 change 至少包含：

- `lib/models/` 模型或枚举变更。
- `lib/services/` 抽象接口。
- `lib/services/http/` HTTP 适配器。

## 7. 实现验证备注

- 本轮 Flutter 实现已按 `add-reminders-theme-family-sharing` OpenSpec change 落地三项能力。
- 上课提醒使用 `flutter_local_notifications` 做本地通知调度；Android/iOS 真机发布前需要分别手工验证通知权限申请、权限关闭提示、精确定时权限和系统重启后的通知表现。
- 当前“去开启通知”操作优先触发系统通知权限申请；若后续产品要求直接跳转系统设置页，需要补充对应平台设置页能力或引入专用插件。
- 主题切换已通过 `MaterialApp.theme` 即时生效，现有部分老组件仍使用 `AppTheme` 静态色值；如需全量视觉随主题变化，后续应继续把静态色迁移到 `ThemeData` 或 ThemeExtension。
- 家庭共享 MVP 复用现有 `AuthService` 家庭成员接口；若后端升级为邀请流，再新增邀请创建、待处理邀请、接受、取消和过期处理规格。
- `lib/services/mock/` mock 实现。
- `lib/providers/` 状态管理。
- `lib/screens/` 页面入口和交互。
- `lib/core/service_locator.dart` 注册。
- 必要的 `StorageService` 缓存字段。

## 7. 最小验证要求

后续进入代码实现时，Flutter 最小验证为：

```bash
flutter analyze
```

涉及服务逻辑、日期或提醒候选筛选时，补充运行：

```bash
flutter test test/services test/date_utils_test.dart
```

如果只修改文档，至少检查两端需求文档中的字段、枚举和业务边界一致。
