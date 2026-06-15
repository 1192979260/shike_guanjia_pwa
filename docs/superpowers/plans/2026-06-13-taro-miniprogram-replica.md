# Taro Mini Program Replica Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a sibling Taro React TypeScript WeChat Mini Program that closely replicates the Flutter 课时管家 app UI and workflows while connecting to the CloudBase backend.

**Architecture:** Create a new sibling project at `/Users/zhengping/Documents/demos/shike_guanjia_taro`. Keep API access in `src/services`, model contracts in `src/models`, global orchestration in Zustand stores under `src/store`, and page components under `src/pages`. Build reusable visual primitives first so all pages share the Flutter organic sticker style.

**Tech Stack:** Taro, React, TypeScript, SCSS, Zustand, Vitest for pure utility/service tests, Tencent CloudBase HTTP endpoint via `Taro.request`.

---

## File Structure

Create these files in `/Users/zhengping/Documents/demos/shike_guanjia_taro`:

- `package.json`: npm scripts and dependencies.
- `project.config.json`: WeChat Mini Program project metadata.
- `config/index.ts`, `config/dev.ts`, `config/prod.ts`: Taro build config.
- `tsconfig.json`: TypeScript config.
- `src/app.ts`, `src/app.config.ts`, `src/app.scss`: app root, page registry, global styles.
- `src/theme/tokens.scss`: Flutter theme tokens ported to SCSS variables.
- `src/models/*.ts`: TypeScript API contracts matching Flutter models.
- `src/utils/date.ts`, `src/utils/format.ts`, `src/utils/storage.ts`: date, currency, and Taro storage helpers.
- `src/services/api-client.ts`: shared request wrapper and API error handling.
- `src/services/*-service.ts`: endpoint adapters for auth, family, child, class, lesson, cost, and preferences.
- `src/store/*.ts`: Zustand stores mirroring Flutter providers.
- `src/components/*`: reusable UI components: sticker card, icon badge, child avatar, soft chip, class card, progress bar, empty state, page shell.
- `src/pages/login/*`: login page.
- `src/pages/onboarding/*`: onboarding flow.
- `src/pages/home/*`: five-tab home surface.
- `src/pages/class-detail/*`: class detail and lesson actions.
- `src/pages/class-form/*`: create/edit/renew class form.
- `src/pages/family-sharing/*`, `src/pages/theme-selection/*`, `src/pages/reminder-settings/*`: settings subpages.
- `src/__tests__/*.test.ts`: utility and API client tests.

Do not create files inside `/Users/zhengping/Documents/demos/shike_guanjia` except for this plan if it needs updates.

---

## Task 1: Scaffold The Taro Project

**Files:**
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/package.json`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/project.config.json`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/config/index.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/config/dev.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/config/prod.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/tsconfig.json`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/app.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/app.config.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/app.scss`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/login/index.tsx`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/login/index.config.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/login/index.scss`

- [ ] **Step 1: Create the sibling directory**

Run:

```bash
mkdir -p /Users/zhengping/Documents/demos/shike_guanjia_taro
```

Expected: directory exists and is outside the Flutter repo.

- [ ] **Step 2: Create package metadata**

Write `/Users/zhengping/Documents/demos/shike_guanjia_taro/package.json`:

```json
{
  "name": "shike-guanjia-taro",
  "version": "1.0.0",
  "private": true,
  "description": "课时管家 Taro 微信小程序",
  "scripts": {
    "dev:weapp": "taro build --type weapp --watch",
    "build:weapp": "taro build --type weapp",
    "dev:h5": "taro build --type h5 --watch",
    "build:h5": "taro build --type h5",
    "typecheck": "tsc --noEmit",
    "test": "vitest run"
  },
  "dependencies": {
    "@tarojs/components": "^4.0.0",
    "@tarojs/helper": "^4.0.0",
    "@tarojs/plugin-framework-react": "^4.0.0",
    "@tarojs/plugin-platform-h5": "^4.0.0",
    "@tarojs/plugin-platform-weapp": "^4.0.0",
    "@tarojs/react": "^4.0.0",
    "@tarojs/runtime": "^4.0.0",
    "@tarojs/taro": "^4.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "zustand": "^4.5.5"
  },
  "devDependencies": {
    "@tarojs/cli": "^4.0.0",
    "@tarojs/webpack5-runner": "^4.0.0",
    "@types/node": "^20.14.0",
    "@types/react": "^18.2.79",
    "@types/react-dom": "^18.2.25",
    "@vitejs/plugin-react": "^4.3.1",
    "typescript": "^5.4.5",
    "vitest": "^1.6.0"
  }
}
```

- [ ] **Step 3: Add Taro config**

Write `/Users/zhengping/Documents/demos/shike_guanjia_taro/config/index.ts`:

```ts
import { defineConfig, type UserConfigExport } from '@tarojs/cli'

export default defineConfig<'webpack5'>(async (merge) => {
  const baseConfig: UserConfigExport<'webpack5'> = {
    projectName: 'shike-guanjia-taro',
    date: '2026-06-13',
    designWidth: 375,
    deviceRatio: {
      640: 2.34 / 2,
      750: 1,
      828: 1.81 / 2
    },
    sourceRoot: 'src',
    outputRoot: 'dist',
    plugins: [
      '@tarojs/plugin-framework-react',
      '@tarojs/plugin-platform-weapp',
      '@tarojs/plugin-platform-h5'
    ],
    framework: 'react',
    compiler: 'webpack5',
    mini: {
      postcss: {
        pxtransform: {
          enable: true,
          config: {}
        },
        cssModules: {
          enable: false,
          config: {
            namingPattern: 'module',
            generateScopedName: '[name]__[local]___[hash:base64:5]'
          }
        }
      }
    },
    h5: {
      publicPath: '/',
      staticDirectory: 'static',
      postcss: {
        autoprefixer: {
          enable: true,
          config: {}
        }
      }
    }
  }

  if (process.env.NODE_ENV === 'production') {
    return merge({}, baseConfig, require('./prod').default)
  }
  return merge({}, baseConfig, require('./dev').default)
})
```

Write `/Users/zhengping/Documents/demos/shike_guanjia_taro/config/dev.ts`:

```ts
export default {
  logger: {
    quiet: false,
    stats: true
  },
  mini: {},
  h5: {}
}
```

Write `/Users/zhengping/Documents/demos/shike_guanjia_taro/config/prod.ts`:

```ts
export default {
  mini: {},
  h5: {
    esnextModules: ['taro-ui']
  }
}
```

- [ ] **Step 4: Add TypeScript and WeChat project config**

Write `/Users/zhengping/Documents/demos/shike_guanjia_taro/tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "es2018",
    "module": "commonjs",
    "jsx": "react-jsx",
    "strict": true,
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    },
    "types": ["node", "@tarojs/taro", "vitest/globals"]
  },
  "include": ["src", "config", "types"],
  "exclude": ["node_modules", "dist"]
}
```

Write `/Users/zhengping/Documents/demos/shike_guanjia_taro/project.config.json`:

```json
{
  "miniprogramRoot": "dist/",
  "projectname": "shike-guanjia-taro",
  "description": "课时管家 Taro 微信小程序",
  "appid": "touristappid",
  "setting": {
    "urlCheck": true,
    "es6": true,
    "enhance": true,
    "postcss": true,
    "minified": true
  },
  "compileType": "miniprogram"
}
```

- [ ] **Step 5: Add app entry and a temporary login page**

Write `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/app.ts`:

```ts
import { PropsWithChildren } from 'react'
import './app.scss'

function App({ children }: PropsWithChildren) {
  return children
}

export default App
```

Write `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/app.config.ts`:

```ts
export default defineAppConfig({
  pages: [
    'pages/login/index'
  ],
  window: {
    backgroundTextStyle: 'light',
    navigationBarBackgroundColor: '#E8DCC7',
    navigationBarTitleText: '课时管家',
    navigationBarTextStyle: 'black',
    backgroundColor: '#E8DCC7'
  }
})
```

Write `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/app.scss`:

```scss
page {
  min-height: 100%;
  background: #E8DCC7;
  color: #3F3428;
  font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", "Helvetica Neue", Arial, sans-serif;
}

view,
text,
input,
button,
textarea {
  box-sizing: border-box;
}
```

Write `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/login/index.config.ts`:

```ts
export default definePageConfig({
  navigationBarTitleText: '登录'
})
```

Write `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/login/index.tsx`:

```tsx
import { View, Text } from '@tarojs/components'
import './index.scss'

export default function LoginPage() {
  return (
    <View className='login-page'>
      <Text className='login-title'>Lesson Butler</Text>
      <Text className='login-subtitle'>课时管家小程序初始化完成</Text>
    </View>
  )
}
```

Write `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/login/index.scss`:

```scss
.login-page {
  min-height: 100vh;
  padding: 96px 24px 24px;
  background: #E8DCC7;
}

.login-title {
  display: block;
  font-size: 30px;
  font-weight: 900;
  color: #3F3428;
}

.login-subtitle {
  display: block;
  margin-top: 8px;
  font-size: 15px;
  color: #7D6B58;
}
```

- [ ] **Step 6: Install and verify scaffold**

Run:

```bash
cd /Users/zhengping/Documents/demos/shike_guanjia_taro
npm install
npm run typecheck
npm run build:weapp
```

Expected: dependencies install, TypeScript passes, and `dist/` is generated.

- [ ] **Step 7: Commit scaffold**

Run:

```bash
cd /Users/zhengping/Documents/demos/shike_guanjia_taro
git init
git add .
git commit -m "chore: scaffold Taro mini program"
```

Expected: first commit contains only the Taro project scaffold.

---

## Task 2: Port Models, Utilities, And API Client

**Files:**
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/models/*.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/utils/date.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/utils/format.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/utils/storage.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/services/api-client.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/__tests__/api-client.test.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/__tests__/format.test.ts`

- [ ] **Step 1: Write tests for pure formatting**

Create `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/__tests__/format.test.ts`:

```ts
import { describe, expect, it } from 'vitest'
import { classFeePerHour, formatCurrency, lessonStatusLabel } from '../utils/format'

describe('format helpers', () => {
  it('formats currency like the Flutter class cards', () => {
    expect(formatCurrency(1200)).toBe('¥1,200')
    expect(formatCurrency(1200.5)).toBe('¥1,200.5')
  })

  it('calculates per-lesson price without divide by zero', () => {
    expect(classFeePerHour({ totalFee: 2400, totalHours: 24 })).toBe(100)
    expect(classFeePerHour({ totalFee: 2400, totalHours: 0 })).toBe(0)
  })

  it('maps lesson statuses to Chinese labels', () => {
    expect(lessonStatusLabel('scheduled')).toBe('待上课')
    expect(lessonStatusLabel('completed')).toBe('已上课')
    expect(lessonStatusLabel('leave')).toBe('已请假')
    expect(lessonStatusLabel('cancelled')).toBe('已取消')
  })
})
```

- [ ] **Step 2: Write utility implementation**

Create `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/utils/format.ts`:

```ts
import type { LessonStatus } from '@/models/lesson'

export function formatCurrency(value: number): string {
  return `¥${new Intl.NumberFormat('zh-CN', {
    maximumFractionDigits: 1
  }).format(value)}`
}

export function classFeePerHour(input: { totalFee: number; totalHours: number }): number {
  return input.totalHours > 0 ? input.totalFee / input.totalHours : 0
}

export function lessonStatusLabel(status: LessonStatus): string {
  const labels: Record<LessonStatus, string> = {
    scheduled: '待上课',
    completed: '已上课',
    leave: '已请假',
    cancelled: '已取消'
  }
  return labels[status]
}
```

Create `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/utils/date.ts`:

```ts
export function toLocalIso(value: Date): string {
  const two = (input: number) => input.toString().padStart(2, '0')
  const three = (input: number) => input.toString().padStart(3, '0')
  return `${value.getFullYear().toString().padStart(4, '0')}-${two(value.getMonth() + 1)}-${two(value.getDate())}T${two(value.getHours())}:${two(value.getMinutes())}:${two(value.getSeconds())}.${three(value.getMilliseconds())}`
}

export function formatMonthDay(iso: string): string {
  const date = new Date(iso)
  return `${date.getMonth() + 1}月${date.getDate()}日`
}

export function formatTimeRange(startIso: string, endIso?: string): string {
  const start = new Date(startIso)
  const end = endIso ? new Date(endIso) : undefined
  const two = (input: number) => input.toString().padStart(2, '0')
  const startText = `${two(start.getHours())}:${two(start.getMinutes())}`
  if (!end) return startText
  return `${startText}-${two(end.getHours())}:${two(end.getMinutes())}`
}
```

Create `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/utils/storage.ts`:

```ts
import Taro from '@tarojs/taro'
import type { ThemeSkin } from '@/models/preferences'

export const storageKeys = {
  authPhone: 'auth_phone',
  authToken: 'auth_token',
  loggedIn: 'auth_logged_in',
  familyId: 'family_id',
  onboardingDone: 'onboarding_done',
  themeSkin: 'theme_skin'
} as const

export function getStorageString(key: string): string | undefined {
  const value = Taro.getStorageSync<string>(key)
  return value || undefined
}

export function setStorageString(key: string, value: string): void {
  Taro.setStorageSync(key, value)
}

export function getStorageBoolean(key: string): boolean {
  return Taro.getStorageSync<boolean>(key) === true
}

export function setStorageBoolean(key: string, value: boolean): void {
  Taro.setStorageSync(key, value)
}

export function getThemeSkin(): ThemeSkin {
  return (getStorageString(storageKeys.themeSkin) as ThemeSkin | undefined) ?? 'warm'
}
```

- [ ] **Step 3: Add model contracts**

Create the model files using these exact type names:

```ts
// src/models/lesson.ts
export type LessonStatus = 'scheduled' | 'completed' | 'leave' | 'cancelled'

export interface Lesson {
  id: string
  classId: string
  scheduledDate: string
  scheduledEndDate?: string | null
  status: LessonStatus
  actualDate?: string | null
  checkinTime?: string | null
  isMakeup?: boolean
  notes?: string | null
  leaveReason?: string | null
}
```

```ts
// src/models/class.ts
export type ClassStatus = 'active' | 'paused' | 'ended'
export type RecurringRuleType = 'weekly' | 'monthly' | 'custom'

export interface LessonTimeSlot {
  dayOfWeek: number
  startHour: number
  startMinute: number
  endHour: number
  endMinute: number
}

export interface RecurringRule {
  type: RecurringRuleType
  daysOfWeek: number[]
  timeSlots: LessonTimeSlot[]
  weekOfMonth?: number | null
  customIntervalDays?: number | null
}

export interface TrainingClass {
  id: string
  childId: string
  familyId: string
  institutionName: string
  className: string
  courseName: string
  teacherName?: string | null
  teacherPhone?: string | null
  totalHours: number
  usedHours: number
  remainingHours: number
  totalFee: number
  startTime: string
  endTime?: string | null
  recurringRule: RecurringRule
  status: ClassStatus
  createdAt: string
  updatedAt?: string | null
  notes?: string | null
}
```

Also create `child.ts`, `user.ts`, `attendance.ts`, `cost-statistics.ts`, `preferences.ts`, and `index.ts` with the fields from the approved spec and Flutter models.

- [ ] **Step 4: Write API client tests**

Create `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/__tests__/api-client.test.ts`:

```ts
import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@tarojs/taro', () => ({
  default: {
    request: vi.fn(),
    getStorageSync: vi.fn(),
    setStorageSync: vi.fn()
  }
}))

describe('api client', () => {
  beforeEach(() => {
    vi.resetModules()
    vi.clearAllMocks()
  })

  it('unwraps data responses', async () => {
    const Taro = (await import('@tarojs/taro')).default
    vi.mocked(Taro.request).mockResolvedValue({ statusCode: 200, data: { data: { ok: true } } } as never)
    const { request } = await import('../services/api-client')

    await expect(request<{ ok: boolean }>('/api/ping')).resolves.toEqual({ ok: true })
  })

  it('throws typed API errors', async () => {
    const Taro = (await import('@tarojs/taro')).default
    vi.mocked(Taro.request).mockResolvedValue({
      statusCode: 200,
      data: { error: { code: 'BAD_CODE', message: '验证码错误' } }
    } as never)
    const { request, ApiError } = await import('../services/api-client')

    await expect(request('/api/auth/login')).rejects.toBeInstanceOf(ApiError)
    await expect(request('/api/auth/login')).rejects.toMatchObject({
      code: 'BAD_CODE',
      message: '验证码错误'
    })
  })
})
```

- [ ] **Step 5: Implement the API client**

Create `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/services/api-client.ts`:

```ts
import Taro from '@tarojs/taro'
import { getStorageString, storageKeys } from '@/utils/storage'

export const API_BASE_URL = 'https://shike-backend-269793-9-1252534988.sh.run.tcloudbase.com'

export class ApiError extends Error {
  code: string
  fields?: unknown[]

  constructor(code: string, message: string, fields?: unknown[]) {
    super(message)
    this.name = 'ApiError'
    this.code = code
    this.fields = fields
  }
}

type Method = 'GET' | 'POST' | 'PATCH' | 'DELETE'

interface ErrorEnvelope {
  error?: {
    code?: string
    message?: string
    fields?: unknown[]
  }
}

interface DataEnvelope<T> extends ErrorEnvelope {
  data?: T
}

export function cleanParams<T extends Record<string, unknown>>(value?: T): Partial<T> | undefined {
  if (!value) return undefined
  return Object.fromEntries(
    Object.entries(value).filter(([, item]) => item !== null && item !== undefined)
  ) as Partial<T>
}

export async function request<T>(
  path: string,
  options: { method?: Method; data?: Record<string, unknown> } = {}
): Promise<T> {
  const token = getStorageString(storageKeys.authToken)
  const response = await Taro.request<DataEnvelope<T>>({
    url: `${API_BASE_URL}${path}`,
    method: options.method ?? 'GET',
    data: cleanParams(options.data),
    header: {
      'content-type': 'application/json',
      ...(token ? { authorization: `Bearer ${token}` } : {})
    }
  })

  const body = response.data
  if (response.statusCode >= 500) {
    throw new ApiError('NETWORK_ERROR', '服务暂时不可用，请稍后重试')
  }
  if (body?.error) {
    throw new ApiError(
      body.error.code ?? 'API_ERROR',
      body.error.message ?? '操作失败，请稍后重试',
      body.error.fields
    )
  }
  return body?.data as T
}
```

- [ ] **Step 6: Verify and commit**

Run:

```bash
cd /Users/zhengping/Documents/demos/shike_guanjia_taro
npm run test
npm run typecheck
git add src package.json tsconfig.json
git commit -m "feat: add API contracts and request client"
```

Expected: tests and typecheck pass before commit.

---

## Task 3: Implement Services And Stores

**Files:**
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/services/auth-service.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/services/child-service.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/services/class-service.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/services/lesson-service.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/services/cost-service.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/services/preference-service.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/store/auth-store.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/store/child-store.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/store/class-store.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/store/lesson-store.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/store/preference-store.ts`

- [ ] **Step 1: Implement endpoint adapters**

Services must wrap these paths from Flutter:

```ts
// auth-service.ts
request('/api/auth/me')
request('/api/auth/send-code', { method: 'POST', data: { phone } })
request('/api/auth/login', { method: 'POST', data: { phone, code } })
request('/api/auth/logout', { method: 'POST' })
request('/api/family')
request('/api/family/members')
request('/api/family/members', { method: 'POST', data: { phone, relation } })
request(`/api/family/members/${memberId}`, { method: 'DELETE' })

// child-service.ts
request('/api/children')
request('/api/children', { method: 'POST', data: { name, age, avatarUrl } })
request(`/api/children/${childId}`, { method: 'PATCH', data })
request(`/api/children/${childId}`, { method: 'DELETE' })

// class-service.ts
request('/api/classes', { data: { childId, status } })
request('/api/classes', { method: 'POST', data })
request(`/api/classes/${classId}`, { method: 'PATCH', data })
request(`/api/classes/${classId}`, { method: 'DELETE' })
request(`/api/classes/${classId}/pause`, { method: 'POST' })
request(`/api/classes/${classId}/resume`, { method: 'POST' })
request(`/api/classes/${classId}/end`, { method: 'POST' })
request(`/api/classes/${classId}/renew`, { method: 'POST', data: { newTotalHours, newTotalFee } })

// lesson-service.ts
request(`/api/classes/${classId}/lessons`)
request('/api/lessons/range', { data: { start, end, childId, classId } })
request('/api/lessons/today')
request('/api/lessons/upcoming', { data: { days } })
request('/api/lessons/manual', { method: 'POST', data: { classId, scheduledDate } })
request(`/api/lessons/${lessonId}`, { method: 'PATCH', data })
request(`/api/lessons/${lessonId}`, { method: 'DELETE' })
request('/api/attendance/check-in', { method: 'POST', data })
request(`/api/attendance/lessons/${lessonId}/cancel`, { method: 'POST' })
request('/api/leaves', { method: 'POST', data: { lessonId, reason } })
request(`/api/leaves/${leaveId}/cancel`, { method: 'POST' })
```

For GET query parameters, extend `request()` in Task 2 to support `query` and append a query string. Use the same `cleanParams()` helper.

- [ ] **Step 2: Implement auth store**

Create `auth-store.ts` with:

```ts
interface AuthState {
  isInitialized: boolean
  isLoggedIn: boolean
  phone?: string
  familyId?: string
  isLoading: boolean
  onboardingDone: boolean
  init: () => Promise<void>
  sendVerificationCode: (phone: string) => Promise<void>
  login: (phone: string, code: string) => Promise<boolean>
  logout: () => Promise<void>
  setOnboardingDone: () => Promise<void>
}
```

`init()` restores token, calls `/api/auth/me`, persists phone/family id if valid, and clears auth storage if invalid. `login()` stores token, phone, family id, and sets `isLoggedIn`.

- [ ] **Step 3: Implement data stores**

Create child, class, lesson, and preference stores using the same public actions as Flutter providers:

```ts
loadChildren()
addChild(name, age, avatarUrl)
updateChild(child)
removeChild(childId)
loadClasses(childId?)
addClass(input)
updateClass(cls)
deleteClass(classId)
pauseClass(classId)
resumeClass(classId)
endClass(classId)
renewClass(classId, newTotalHours, newTotalFee)
loadLessons({ classId, startFrom, endAt })
loadTodayLessons()
checkinLesson(lessonId)
cancelCheckin(lessonId)
requestLeave(lessonId, reason?)
createLesson({ classId, scheduledDate })
loadTheme()
setThemeSkin(skin)
loadReminderSettings()
updateReminderSettings(settings)
```

Each store should expose `isLoading` and `error`, and should update arrays immutably after mutations.

- [ ] **Step 4: Verify and commit**

Run:

```bash
cd /Users/zhengping/Documents/demos/shike_guanjia_taro
npm run typecheck
npm run test
git add src/services src/store src/utils src/models
git commit -m "feat: add service adapters and stores"
```

Expected: typecheck and tests pass.

---

## Task 4: Build Theme And Reusable Components

**Files:**
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/theme/tokens.scss`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/components/sticker-card/*`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/components/sticker-icon/*`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/components/child-avatar/*`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/components/soft-chip/*`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/components/organic-progress-bar/*`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/components/class-card/*`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/components/page-shell/*`

- [ ] **Step 1: Define theme tokens**

Create `tokens.scss`:

```scss
$primary: #C66B3D;
$primary-light: #D88A5F;
$primary-dark: #9A4F2D;
$accent: #C08E3A;
$sage: #8B9D83;
$moss: #606C38;
$clay: #B08B6E;
$sand: #E8DCC7;
$oat: #D4B895;
$surface: #F9F1E3;
$text-primary: #3F3428;
$text-secondary: #7D6B58;
$text-tertiary: #A38F78;
$text-inverse: #FFFBF3;
$success: #6F8F58;
$warning: #C08E3A;
$error: #B8563F;
$info: #7F9B9B;
```

- [ ] **Step 2: Implement visual primitives**

Create React components with these prop contracts:

```ts
// StickerCard
interface StickerCardProps {
  children: React.ReactNode
  className?: string
  color?: string
  rotated?: boolean
  onClick?: () => void
}

// ChildAvatar
interface ChildAvatarProps {
  name: string
  size?: number
}

// SoftChip
interface SoftChipProps {
  label: string
  selected?: boolean
  onClick?: () => void
}

// ClassCard
interface ClassCardProps {
  cls: TrainingClass
  childName?: string
  onClick: () => void
}
```

ClassCard must show `className`, `${institutionName} · ${courseName}`, progress, `剩余 X/Y 课时 · ¥Z/课时`, total fee, and status chip.

- [ ] **Step 3: Verify and commit**

Run:

```bash
cd /Users/zhengping/Documents/demos/shike_guanjia_taro
npm run typecheck
git add src/components src/theme src/app.scss
git commit -m "feat: add organic sticker component system"
```

Expected: typecheck passes.

---

## Task 5: Implement Startup, Login, And Onboarding

**Files:**
- Modify: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/app.config.ts`
- Modify: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/login/index.tsx`
- Modify: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/login/index.scss`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/onboarding/index.tsx`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/onboarding/index.config.ts`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/onboarding/index.scss`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/home/index.tsx`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/home/index.config.ts`

- [ ] **Step 1: Register pages**

`src/app.config.ts` pages must include:

```ts
pages: [
  'pages/login/index',
  'pages/onboarding/index',
  'pages/home/index'
]
```

- [ ] **Step 2: Implement login parity**

Login page must include:

- Center 92px rounded logo block with sage background and accent sticker.
- `Lesson Butler` title and `让课程管理变得如拆开贴纸书般轻松` subtitle.
- Sticker form with `欢迎回来`, phone input, code input, `获取验证码` countdown, agreement checkbox, and primary login button.
- Phone length validation: 11 digits.
- Code validation: 6 digits.
- On success, redirect to onboarding or home based on store `onboardingDone`.

- [ ] **Step 3: Implement onboarding parity**

Onboarding must include:

- Intro page with three sticker cards:
  - 多娃排课不再乱
  - 剩余课时一眼看
  - 把时间留给陪伴
- Second page to add child with name and age inputs.
- `保存`, `稍后添加`, and `跳过引导` flows.
- Saving a child calls `addChild()` then `setOnboardingDone()`.

- [ ] **Step 4: Verify and commit**

Run:

```bash
cd /Users/zhengping/Documents/demos/shike_guanjia_taro
npm run typecheck
npm run build:weapp
git add src/pages src/app.config.ts
git commit -m "feat: add auth and onboarding flows"
```

Expected: typecheck and WeChat build pass.

---

## Task 6: Implement Home Five Tabs

**Files:**
- Modify: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/home/index.tsx`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/home/index.scss`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/home/dashboard-tab.tsx`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/home/schedule-tab.tsx`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/home/classes-tab.tsx`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/home/stats-tab.tsx`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/home/me-tab.tsx`

- [ ] **Step 1: Implement custom bottom navigation**

Use a fixed bottom bar with five labels:

```ts
const tabs = [
  { key: 'dashboard', label: '首页' },
  { key: 'schedule', label: '课表' },
  { key: 'classes', label: '班级' },
  { key: 'stats', label: '统计' },
  { key: 'me', label: '我的' }
] as const
```

On first mount, load children, classes, lessons for the current month window, and today lessons.

- [ ] **Step 2: Implement dashboard tab**

Dashboard must show:

- Greeting: `早上好！` and `${firstChild.name}妈` or `课时管家`.
- Horizontal child chips: `全部宝贝`, each child, and `添加`.
- Today's first lesson hero named `今日旅程` when available.
- Metrics for `未来 3 天` and `本月消费`.
- Upcoming rows for future 3 days or empty state copy from Flutter.

- [ ] **Step 3: Implement schedule tab**

Schedule tab must show:

- Today lessons section.
- Upcoming lessons section.
- Lesson cards with course name, child, institution, time range, and status.
- Actions for scheduled lessons: check in and leave.

- [ ] **Step 4: Implement classes tab**

Classes tab must preserve the invariant:

- Child filter first.
- Course filter second.
- Changing child clears selected course.
- Class cards use the shared ClassCard component.
- Add class button navigates to class form.

- [ ] **Step 5: Implement stats and me tabs**

Stats must show:

- Cumulative paid amount from loaded classes.
- Consumed value from completed lessons and per-class fee.
- Remaining lesson value.
- Class fee breakdown and calculation notes.

Me tab must show:

- Phone/family summary.
- Navigation rows for family sharing, theme selection, reminder settings.
- Logout action.

- [ ] **Step 6: Verify and commit**

Run:

```bash
cd /Users/zhengping/Documents/demos/shike_guanjia_taro
npm run typecheck
npm run build:weapp
git add src/pages/home src/app.config.ts
git commit -m "feat: replicate home tabs"
```

Expected: typecheck and WeChat build pass.

---

## Task 7: Implement Class Detail And Class Form

**Files:**
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/class-detail/*`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/class-form/*`
- Modify: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/app.config.ts`
- Modify: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/home/classes-tab.tsx`

- [ ] **Step 1: Register pages**

Add:

```ts
'pages/class-detail/index',
'pages/class-form/index'
```

- [ ] **Step 2: Implement class detail**

Class detail must:

- Read `classId` from router params.
- Load latest class and class lessons on mount and on page show.
- Show class summary, remaining/total hours, fee per hour, total fee, institution, teacher fields, status.
- Show lesson list sorted by `scheduledDate`.
- Provide actions: check in, cancel check-in, leave, manual lesson, edit, renew, pause, resume, end, delete.
- After returning from edit or renew, refresh class and lessons before updating UI.

- [ ] **Step 3: Implement class form**

Class form must support modes:

- create: empty values, POST `/api/classes`.
- edit: prefill selected class, PATCH `/api/classes/:id`.
- renew: ask for `newTotalHours` and `newTotalFee`, POST `/api/classes/:id/renew`.

Use form fields for child, institution, class name, course name, teacher name, teacher phone, total hours, used hours, total fee, first lesson date/time, recurring weekly days/time slots, and notes.

- [ ] **Step 4: Verify and commit**

Run:

```bash
cd /Users/zhengping/Documents/demos/shike_guanjia_taro
npm run typecheck
npm run build:weapp
git add src/pages/class-detail src/pages/class-form src/app.config.ts src/pages/home/classes-tab.tsx
git commit -m "feat: add class detail and class form workflows"
```

Expected: typecheck and WeChat build pass.

---

## Task 8: Implement Settings Subpages

**Files:**
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/family-sharing/*`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/theme-selection/*`
- Create: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/reminder-settings/*`
- Modify: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/app.config.ts`
- Modify: `/Users/zhengping/Documents/demos/shike_guanjia_taro/src/pages/home/me-tab.tsx`

- [ ] **Step 1: Register pages**

Add:

```ts
'pages/family-sharing/index',
'pages/theme-selection/index',
'pages/reminder-settings/index'
```

- [ ] **Step 2: Implement family sharing**

Family page must show current family and members, max 2 members, add member by phone/relation, and remove member. Map backend error codes exactly:

```ts
const familyErrorMessages: Record<string, string> = {
  FAMILY_MEMBER_LIMIT_REACHED: '当前家庭最多支持 2 位成员',
  USER_ALREADY_IN_FAMILY: '该手机号已在当前家庭中',
  CANNOT_REMOVE_LAST_MEMBER: '至少需要保留一位家庭成员',
  FAMILY_INVITE_EXPIRED: '邀请已过期，请重新发送',
  FAMILY_INVITE_NOT_FOUND: '邀请不存在或已失效',
  FAMILY_NOT_FOUND: '家庭不存在或已失效，请重新登录'
}
```

- [ ] **Step 3: Implement theme selection**

Theme page must show warm/fresh/classic cards with swatches and selected indicator. Persist selection locally and call `/api/preferences/theme`.

- [ ] **Step 4: Implement reminder settings**

Reminder page must show:

- `开启上课提醒`
- `提醒今日课次`
- `提醒补课课次`
- advance options `[15, 30, 60, 120, 1440]` with labels `15 分钟`, `30 分钟`, `1 小时`, `2 小时`, `1 天`

Persist via `/api/reminder-settings`.

- [ ] **Step 5: Verify and commit**

Run:

```bash
cd /Users/zhengping/Documents/demos/shike_guanjia_taro
npm run typecheck
npm run build:weapp
git add src/pages/family-sharing src/pages/theme-selection src/pages/reminder-settings src/app.config.ts src/pages/home/me-tab.tsx
git commit -m "feat: add settings subpages"
```

Expected: typecheck and WeChat build pass.

---

## Task 9: Pixel QA, H5 Preview, And Final Hardening

**Files:**
- Modify as needed only inside `/Users/zhengping/Documents/demos/shike_guanjia_taro/src`
- Modify: `/Users/zhengping/Documents/demos/shike_guanjia_taro/README.md`

- [ ] **Step 1: Add README**

Create `/Users/zhengping/Documents/demos/shike_guanjia_taro/README.md`:

```md
# 课时管家 Taro 小程序

微信小程序版课时管家，使用 Taro + React + TypeScript + Zustand。

## Backend

默认连接：

https://shike-backend-269793-9-1252534988.sh.run.tcloudbase.com

## Commands

\`\`\`bash
npm install
npm run typecheck
npm run test
npm run build:weapp
npm run dev:h5
\`\`\`

## Notes

- 微信小程序是主目标，H5 仅作为开发预览。
- API 字段保持与 Flutter 和后端一致：camelCase、枚举字符串、ISO-8601 日期字符串。
```

- [ ] **Step 2: Run full verification**

Run:

```bash
cd /Users/zhengping/Documents/demos/shike_guanjia_taro
npm run test
npm run typecheck
npm run build:weapp
npm run build:h5
```

Expected: all commands pass. If `build:h5` fails because a WeChat-only API needs guards, add platform guards around that call and rerun.

- [ ] **Step 3: Start H5 preview when possible**

Run:

```bash
cd /Users/zhengping/Documents/demos/shike_guanjia_taro
npm run dev:h5
```

Expected: dev server prints a local URL. Open it with the in-app browser and verify:

- Login screen renders without overlap.
- Navigation after mocked or real login does not blank.
- Home tab layout is readable on mobile viewport.
- Cards and buttons stay within bounds.

- [ ] **Step 4: Commit final hardening**

Run:

```bash
cd /Users/zhengping/Documents/demos/shike_guanjia_taro
git add .
git commit -m "docs: add Taro mini program handoff"
```

Expected: final commit contains README and QA polish only.

---

## Self-Review

- Spec coverage: Tasks cover sibling project creation, CloudBase API client, model compatibility, startup flow, login, onboarding, home five tabs, class detail, class form, family sharing, theme, reminders, pixel styling, and verification.
- Placeholder scan: No unresolved TBD/TODO items are intentionally left. Steps specify paths, commands, and expected outcomes.
- Type consistency: `TrainingClass`, `Lesson`, `ThemeSkin`, and store action names match the approved design and Flutter model names.
- Risk note: Taro dependency versions should be resolved by `npm install`; if Taro 4 package constraints differ on the local machine, keep the same architecture and adjust package versions as a scaffold fix in Task 1 before implementing business code.
