# 课时管家 — 接口设计文档

> **版本**: v1.0  
> **日期**: 2026-06-11  
> **状态**: 初稿  
> **依据**: [PRD.md](../PRD.md)

---

## 一、概述

本文档为「课时管家」Flutter App 定义接口与客户端服务契约。当前默认运行链路通过 `lib/core/service_locator.dart` 注册 HTTP service，连接 sibling backend；`lib/services/mock/` 保留本地 mock 实现用于测试和兜底开发。

**分层架构：**

```
┌─────────────┐     ┌─────────────────┐     ┌──────────────┐
│  UI / Provider │ ──► │  Service Interfaces │ ──► │ HTTP Backend / Mock |
│  (ChangeNotifier)│     │ Auth/Class/Lesson...│     │ ApiClient/MockStore |
└─────────────┘     └─────────────────┘     └──────────────┘
```

Provider 层依赖抽象 service 接口，不直接持有 HTTP 细节。运行时默认由 `HttpBackendService`、`HttpClassService`、`HttpLessonService` 等适配器承接；mock service 不应成为生产路径。

---

## 二、接口列表

### 2.1 认证模块 (`Auth`)

#### POST /auth/send-code

发送短信验证码

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `phone` | `String` | 是 | 11位中国大陆手机号 |

**响应（模拟成功）**

```dart
Future<void> sendVerificationCode(String phone)
// 打印日志：「验证码已发送到 {phone}（模拟：任意6位数即可登录）」
```

#### POST /auth/login

手机号 + 验证码登录

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `phone` | `String` | 是 | 11位手机号 |
| `code` | `String` | 是 | 6位验证码 |

**响应**

```dart
Future<bool> login(String phone, String code)
// 返回: true = 登录成功, false = 失败
```

**成功后副作用：**
- 持久化 `phone` 到 `SharedPreferences`
- 创建/获取 `Family` 记录，持久化 `familyId`
- 若首次登录，`Family` 成员自动创建为 `mother` 角色

#### POST /auth/logout

退出登录

```dart
// Provider 层调用 _storage.logout()，无服务端接口
```

---

### 2.2 娃档案管理 (`Child`)

#### GET /children

获取家庭下所有娃

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `familyId` | `String` | 是 | 家庭 ID |

**响应**

```dart
Future<List<Child>> getChildren(String familyId)
// 返回按 createdAt 升序排列的 Child 列表
```

**Child 模型字段：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | `String` | 是 | UUID v4 |
| `name` | `String` | 是 | 孩子昵称/真名 |
| `age` | `int?` | 否 | 年龄 |
| `avatarUrl` | `String?` | 否 | 头像 URL，默认自动生成 |
| `familyId` | `String` | 是 | 所属家庭 |
| `createdAt` | `DateTime` | 是 | 创建时间 |

#### POST /children

创建娃

```dart
Future<Child> createChild(Child child)
```

| 入参 | 类型 | 说明 |
|------|------|------|
| `child` | `Child` | 完整模型对象，`id` 由调用方通过 `Uuid.v4()` 生成 |

#### PATCH /children/:id

更新娃

```dart
Future<Child> updateChild(Child child)
```

#### DELETE /children/:id

删除娃（**级联删除**关联的 TrainingClass 和 Lesson）

```dart
Future<void> deleteChild(String id)
```

---

### 2.3 培训班管理 (`TrainingClass`)

#### GET /classes

获取班级列表

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `familyId` | `String` | 是 | 家庭 ID |
| `childId` | `String?` | 否 | 按娃筛选 |
| `status` | `ClassStatus?` | 否 | 按状态筛选 (`active` / `paused` / `ended`) |

**响应**

```dart
Future<List<TrainingClass>> getClasses({String? familyId, String? childId, ClassStatus? status})
// 按 startTime 升序排列
```

#### POST /classes

创建培训班

```dart
Future<TrainingClass> createClass(TrainingClass cls)
```

**TrainingClass 模型字段：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | `String` | 是 | UUID v4 |
| `childId` | `String` | 是 | 所属娃 ID |
| `familyId` | `String` | 是 | 所属家庭 |
| `institutionName` | `String` | 是 | 机构名称 |
| `className` | `String` | 是 | 班级名称（如"大班A班"） |
| `courseName` | `String` | 是 | 课程名称（如"美术启蒙"） |
| `teacherName` | `String?` | 否 | 老师姓名 |
| `teacherPhone` | `String?` | 否 | 老师电话 |
| `totalHours` | `int` | 是 | 总课时 |
| `totalFee` | `double` | 是 | 总费用 |
| `usedHours` | `int` | 是(默认0) | 已上课时 |
| `remainingHours` | `int` | 是 | 剩余课时 |
| `startTime` | `DateTime` | 是 | 第一节课日期 |
| `endTime` | `DateTime?` | 否 | 到期自动结束 |
| `recurringRule` | `RecurringRule` | 是 | 排课规则 |
| `status` | `ClassStatus` | 是 | 班级状态 |
| `createdAt` | `DateTime` | 是 | 创建时间 |
| `updatedAt` | `DateTime?` | 否 | 更新时间 |
| `notes` | `String?` | 否 | 备注 |

**派生属性：** `feePerHour = totalHours > 0 ? totalFee / totalHours : 0`

#### PATCH /classes/:id

更新班级

```dart
Future<TrainingClass> updateClass(TrainingClass cls)
```

#### DELETE /classes/:id

删除班级（级联删除关联 Lesson）

```dart
Future<void> deleteClass(String id)
```

#### PATCH /classes/:id/pause

暂停班级

```dart
Future<TrainingClass> pauseClass(String id)
// 状态变更为 ClassStatus.paused
```

#### PATCH /classes/:id/resume

恢复班级

```dart
Future<TrainingClass> resumeClass(String id)
// 状态变更为 ClassStatus.active
```

#### PATCH /classes/:id/end

结束班级（归档）

```dart
Future<TrainingClass> endClass(String id)
// 状态变更为 ClassStatus.ended
```

---

### 2.4 课次管理 (`Lesson`)

#### GET /lessons

获取课次列表

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `classId` | `String?` | 否 | 按班级筛选 |
| `startFrom` | `DateTime?` | 否 | 起始日期（含） |
| `endAt` | `DateTime?` | 否 | 结束日期（含） |

**响应**

```dart
Future<List<Lesson>> getLessons({String? classId, DateTime? startFrom, DateTime? endAt})
// 按 scheduledDate 升序排列
```

**Lesson 模型字段：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | `String` | 是 | UUID v4 |
| `classId` | `String` | 是 | 所属班级 |
| `scheduledDate` | `DateTime` | 是 | 计划上课日期 |
| `status` | `LessonStatus` | 是 | 课次状态 |
| `actualDate` | `DateTime?` | 否 | 实际上课日期 |
| `checkinTime` | `DateTime?` | 否 | 打卡时间 |
| `isMakeup` | `bool` | 是(默认false) | 是否补录 |
| `notes` | `String?` | 否 | 课后笔记 |
| `leaveReason` | `String?` | 否 | 请假原因 |

**LessonStatus 枚举：**

| 值 | 说明 |
|----|------|
| `scheduled` | 已排课，待上课 |
| `completed` | 已确认上课 |
| `leave` | 请假 |
| `cancelled` | 停课/取消 |

#### POST /lessons

创建课次（排课规则自动生成 + 手动微调）

```dart
Future<Lesson> createLesson({required String classId, required DateTime scheduledDate})
// 默认状态: scheduled
```

#### PATCH /lessons/:id

更新课次

```dart
Future<Lesson> updateLesson(Lesson lesson)
```

#### DELETE /lessons/:id

删除课次

```dart
Future<void> deleteLesson(String id)
```

#### PATCH /lessons/:id/checkin

确认上课打卡

```dart
// Provider 层操作，直接 updateLesson：
// status = completed, actualDate = now, checkinTime = now
// 同时扣减班级 remainingHours
```

#### PATCH /lessons/:id/leave

请假

```dart
// Provider 层操作，直接 updateLesson：
// status = leave, leaveReason = 用户输入
```

---

### 2.5 家庭共享 (`Family`)

#### GET /family/:id

获取家庭信息

```dart
// 当前 Provider 层通过 AuthProvider 获取 _storage.familyId
// 后续 LeanCloud 替换后，改为 _lc.getFamily(familyId)
```

**Family 模型字段：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | `String` | 是 | 家庭 ID |
| `name` | `String` | 是 | 家庭名称 |
| `members` | `List<FamilyMember>` | 是 | 成员列表 |

**FamilyMember 模型字段：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | `String` | 是 | 成员 ID |
| `userId` | `String` | 是 | 用户 ID |
| `relation` | `FamilyRelation` | 是 | 关系 (`mother` / `father`) |
| `displayName` | `String?` | 否 | 显示名称 |
| `createdAt` | `DateTime` | 是 | 加入时间 |

#### POST /family/:id/add-member

邀请家庭成员（MVP 仅支持 2 人）

```dart
// MVP 阶段不暴露接口，后续 LeanCloud ACL 实现
```

---

## 三、Service 接口总览

核心接口由 `lib/services/*_service.dart` 定义，并在 `service_locator.dart` 中注册：

```dart
abstract class AuthService {
  // === Auth ===
  Future<bool> login(String phone, String code);
  Future<void> sendVerificationCode(String phone);
}

abstract class ChildService {
  // === Children ===
  Future<List<Child>> getChildren(String familyId);
  Future<Child> createChild(Child child);
  Future<Child> updateChild(Child child);
  Future<void> deleteChild(String id);
}

abstract class ClassService {
  // === Classes ===
  Future<List<TrainingClass>> getClasses(String familyId, {String? childId, ClassStatus? status});
  Future<TrainingClass?> createClass(...);
  Future<TrainingClass?> updateClass(String classId, ...);
  Future<bool> deleteClass(String id);
  Future<TrainingClass?> pauseClass(String id);
  Future<TrainingClass?> resumeClass(String id);
  Future<TrainingClass?> endClass(String id);
}

abstract class LessonService {
  // === Lessons ===
  Future<List<Lesson>> getLessons({String? classId, DateTime? startFrom, DateTime? endAt});
  Future<Lesson?> createLesson(...);
  Future<Lesson?> updateLesson(String id, ...);
  Future<bool> deleteLesson(String id);
}
```

---

## 四、Provider 层操作映射

```
AuthProvider         → login(), logout(), init()
ChildProvider        → loadChildren(), addChild(), updateChild(), removeChild()
ClassProvider        → loadClasses(), addClass(), updateClass(), deleteClass()
                       → pauseClass(), resumeClass(), endClass()
LessonProvider       → loadLessons(), createLesson(), updateLesson(), deleteLesson()
                       → checkinLesson(), cancelCheckIn(), markLeave(), deleteLesson()
                       → getTodayLessons(), getUpcomingLessons(), getMonthlyStats()
```

> **注意**：打卡、取消打卡、请假会同时影响课次与班级课时，当前应通过 Provider 调用 service 后刷新对应 class/lesson 数据，避免详情页继续显示缓存快照。

### 4.1 UI 数据口径

- 班级列表：先按娃过滤，再按科目过滤；切换娃时清空科目筛选。
- 班级卡片：展示剩余课时、课时进度、客单价（`totalFee / totalHours`）和总费用。
- 统计页：按娃筛选后展示累计缴费、已消耗价值、剩余课时价值和班级费用明细。
- 本月消耗：本月已完成课次按对应班级 `feePerHour` 求和；历史补录只影响剩余课时和剩余价值。

---

## 五、数据同步

### 5.1 缓存策略

`StorageService` 通过 `SharedPreferences` 缓存：

| 键名 | 内容 | 类型 |
|------|------|------|
| `auth_phone` | 登录手机号 | `String` |
| `auth_logged_in` | 登录状态 | `bool` |
| `family_id` | 家庭 ID | `String` |
| `last_sync_time` | 上次同步时间 | `DateTime` |
| `local_classes` | 班级 JSON | `List<Map>` |
| `local_lessons` | 课次 JSON | `List<Map>` |
| `local_children` | 娃 JSON | `List<Map>` |
| `onboarding_done` | 引导完成标记 | `bool` |

### 5.2 同步机制

```dart
Future<void> sync() async {
  // MVP: 仅更新时间戳
  // 生产环境：增量拉取 + 本地变更推送到 LeanCloud
}
```

---

## 六、后续 LeanCloud 接入改造点

| 当前方式 | 改造目标 |
|---------|---------|
| `Map<String, dynamic>` 内存存储 | LeanCloud `AVObject` / REST API |
| `SharedPreferences` 做缓存 | LeanCloud 离线持久化 + 同步引擎 |
| Provider 直接管理业务状态 | Service 层统一数据源，Provider 仅做状态分发 |
| `Uuid.v4()` 本地生成 ID | 依赖 LeanCloud 自动生成的 objectId |
| 无权限控制 | LeanCloud ACL（家庭共享读写） |
| 无分页 | LeanCloud 查询分页（skip/limit） |
| 无 Webhook | LeanCloud Cloud Code 触发排课生成 |

---

## 七、接口扩展预留

以下接口 PRD 中提到但 MVP 不在范围内，接口设计需预留扩展点：

| 预留接口 | 说明 |
|---------|------|
| `POST /auth/wechat-login` | 微信登录 |
| `POST /auth/biometric` | FaceID/指纹 |
| `GET /families/:id/invite-link` | 家庭邀请链接 |
| `GET /classes/:id/conflicts?childId=X` | 冲突检测 |
| `POST /classes/:id/holiday?startDate=&endDate=` | 临时停课 |
| `GET /stats/monthly?year=&month=` | 月度报表聚合 |
| `GET /export/csv?entity=classes|lessons` | CSV 导出 |
| `GET /export/pdf?entity=monthly-report` | PDF 报表 |
| `POST /notifications/calendar` | 日历事件推送 |

---

## 八、接口调用时序（核心流程）

### 8.1 新手引导流程

```
LoginScreen → POST /auth/login → 首次登录? → Onboarding(添加娃) → 添加班级 → HomeScreen
```

### 8.2 排课生成流程

```
createClass() → 保存 TrainingClass → ScheduleGenerator.generate() → 批量 createLesson()
```

### 8.3 上课打卡流程

```
HomeScreen 查看今日课次 → 点击「确认上课」→ checkinLesson() → updateLesson(status=completed) → 扣减 remainingHours → 通知刷新
```

### 8.4 请假流程

```
ClassDetail 选择课次 → 填写请假原因 → markLeave() → updateLesson(status=leave) → 自动顺延(预留)
```
