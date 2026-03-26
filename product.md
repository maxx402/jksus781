# 水赫手记 · 产品技术说明文档

> **版本**: v1.0.0  
> **技术栈**: Flutter 3.x (Dart)  
> **UI 风格**: shadcn/ui 中性设计系统移植  
> **适用读者**: Flutter 开发工程师  
> **最后更新**: 2026-03-12

---

## 目录

1. [项目概述](#1-项目概述)
2. [技术架构](#2-技术架构)
3. [设计系统规范](#3-设计系统规范)
4. [模块功能说明](#4-模块功能说明)
   - 4.1 [Todo List 待办事项](#41-todo-list-待办事项)
   - 4.2 [备忘 Memo](#42-备忘-memo)
   - 4.3 [手记 Journal](#43-手记-journal)
   - 4.4 [个人设置 Settings](#44-个人设置-settings)
5. [交互反馈机制](#5-交互反馈机制)
6. [数据层设计](#6-数据层设计)
7. [路由与导航](#7-路由与导航)
8. [依赖包清单](#8-依赖包清单)
9. [目录结构](#9-目录结构)
10. [开发规范](#10-开发规范)

---

## 1. 项目概述

**水赫手记**是一款以个人效率与日常记录为核心的移动端应用，集 Todo List、备忘、手记和个人设置于一体。产品定位为极简、中性、克制的工具类 App，UI 风格参照 [shadcn/ui](https://ui.shadcn.com/) 设计系统，在 Flutter 中实现对应的组件体系与视觉语言。

### 核心功能一览

| 模块 | 功能描述 | 优先级 |
|------|----------|--------|
| Todo List | 任务创建、完成、删除，完成时触发音效 + 震动 | P0 |
| 备忘 Memo | 快速文本备忘，支持置顶与标签 | P0 |
| 手记 Journal | 富文本日记/手记，支持图片插入 | P1 |
| 个人设置 | 主题、通知、数据导出、账户信息 | P1 |

---

## 2. 技术架构

### 2.1 整体架构

采用 **Clean Architecture + 分层架构**，结合 Flutter 社区主流的状态管理方案：

```
Presentation Layer  (UI Widgets / Pages / ViewModels)
        ↕
Domain Layer        (UseCases / Entities / Repository Interfaces)
        ↕
Data Layer          (Repository Impl / LocalDataSource / RemoteDataSource)
```

### 2.2 状态管理

使用 **Riverpod 2.x**（`flutter_riverpod`）作为全局状态管理方案：

- `StateNotifierProvider` 管理复杂列表状态（Todo、Memo、Journal）
- `Provider` 管理只读依赖注入（Repository、Service）
- `FutureProvider` / `StreamProvider` 处理异步数据

### 2.3 本地持久化

- **Isar** 作为本地数据库（高性能、支持全文检索、无需 FFI 配置）
- 图片资源存储于设备文件系统，数据库仅保存路径引用
- 导出功能使用 JSON 序列化

### 2.4 平台支持

| 平台 | 支持 | 备注 |
|------|------|------|
| Android | ✅ | minSdkVersion 21 |
| iOS | ✅ | iOS 13+ |
| Web | ❌ | 不在本期范围 |

---

## 3. 设计系统规范

参照 shadcn/ui 的设计语言，在 Flutter 中建立对应的 Token 体系，**禁止**在业务组件中硬编码颜色和间距值。

### 3.1 颜色 Token

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // Background
  static const Color background     = Color(0xFFFFFFFF); // --background
  static const Color foreground     = Color(0xFF09090B); // --foreground

  // Card
  static const Color card           = Color(0xFFFFFFFF); // --card
  static const Color cardForeground = Color(0xFF09090B); // --card-foreground

  // Muted
  static const Color muted          = Color(0xFFF4F4F5); // --muted
  static const Color mutedForeground= Color(0xFF71717A); // --muted-foreground

  // Primary
  static const Color primary        = Color(0xFF18181B); // --primary
  static const Color primaryForeground = Color(0xFFFAFAFA); // --primary-foreground

  // Border / Input
  static const Color border         = Color(0xFFE4E4E7); // --border
  static const Color input          = Color(0xFFE4E4E7); // --input
  static const Color ring           = Color(0xFF18181B); // --ring

  // Destructive
  static const Color destructive    = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFAFAFA);

  // Dark mode variants（使用 ThemeData.brightness 判断）
  static const Color backgroundDark     = Color(0xFF09090B);
  static const Color foregroundDark     = Color(0xFFFAFAFA);
  static const Color mutedDark          = Color(0xFF27272A);
  static const Color mutedForegroundDark= Color(0xFFA1A1AA);
  static const Color borderDark         = Color(0xFF27272A);
}
```

### 3.2 Typography

```dart
// lib/core/theme/app_text_styles.dart

// 字体：使用系统默认 + Geist（如需自定义）
class AppTextStyles {
  static const TextStyle h1 = TextStyle(fontSize: 36, fontWeight: FontWeight.w700, height: 1.2);
  static const TextStyle h2 = TextStyle(fontSize: 30, fontWeight: FontWeight.w600, height: 1.3);
  static const TextStyle h3 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle h4 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.5);

  static const TextStyle bodyLg = TextStyle(fontSize: 18, fontWeight: FontWeight.w400, height: 1.6);
  static const TextStyle body   = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.6);
  static const TextStyle bodySm = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);

  static const TextStyle label  = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle muted  = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.mutedForeground);
  static const TextStyle code   = TextStyle(fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.w400);
}
```

### 3.3 间距与圆角

```dart
class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xxl = 24.0;
}

class AppRadius {
  static const double sm  = 4.0;   // --radius: 0.3rem
  static const double md  = 6.0;   // --radius: 0.5rem
  static const double lg  = 8.0;   // --radius: 0.75rem
  static const double full= 9999.0;
}
```

### 3.4 核心 UI 组件清单

以下组件需开发团队实现并纳入设计系统，**禁止**在业务页面中直接使用原生 Flutter Widget 替代：

| 组件名 | 路径 | 对应 shadcn 组件 |
|--------|------|------------------|
| `AppButton` | `lib/shared/widgets/app_button.dart` | Button (variant: default/ghost/outline/destructive) |
| `AppInput` | `lib/shared/widgets/app_input.dart` | Input |
| `AppCard` | `lib/shared/widgets/app_card.dart` | Card |
| `AppBadge` | `lib/shared/widgets/app_badge.dart` | Badge |
| `AppCheckbox` | `lib/shared/widgets/app_checkbox.dart` | Checkbox |
| `AppDialog` | `lib/shared/widgets/app_dialog.dart` | Dialog |
| `AppSheet` | `lib/shared/widgets/app_sheet.dart` | Sheet (底部抽屉) |
| `AppSeparator` | `lib/shared/widgets/app_separator.dart` | Separator |
| `AppSwitch` | `lib/shared/widgets/app_switch.dart` | Switch |
| `AppToast` | `lib/shared/widgets/app_toast.dart` | Toast / Sonner |
| `AppSkeleton` | `lib/shared/widgets/app_skeleton.dart` | Skeleton（加载占位） |

---

## 4. 模块功能说明

### 4.1 Todo List 待办事项

#### 功能描述

用户管理日常待办任务的核心模块，支持创建、完成（勾选）、删除和整理任务。**完成任务时必须触发音效 + 震动反馈**（详见[第 5 节](#5-交互反馈机制)）。

#### 数据模型

```dart
// lib/features/todo/domain/entities/todo_item.dart

@collection
class TodoItem {
  Id id = Isar.autoIncrement;

  late String title;          // 任务标题（必填，最大 200 字）
  String? note;               // 补充说明（可选）
  bool isDone = false;        // 完成状态
  bool isPinned = false;      // 是否置顶
  String? tag;                // 标签（单标签，可选）

  @Index()
  late DateTime createdAt;

  DateTime? completedAt;      // 完成时间（isDone=true 时记录）
  DateTime? dueDate;          // 截止日期（可选）
}
```

#### UI 结构

```
TodoPage
├── AppBar（标题："待办"，右上角添加按钮）
├── FilterBar（全部 / 进行中 / 已完成）
├── TodoListView
│   ├── TodoItemTile（未完成）
│   │   ├── AppCheckbox（点击触发完成动画 + 音效 + 震动）
│   │   ├── 标题文本
│   │   ├── 截止日期 Badge（可选）
│   │   └── 滑动删除（SwipeAction → destructive）
│   └── TodoItemTile（已完成，标题加删除线，色调 muted）
└── FAB / 底部输入框（快速添加）
```

#### 交互细节

- **快速添加**：底部固定输入框（类似 Things 3），按回车直接创建，输入框保持焦点
- **详情编辑**：点击 tile 文本区域展开 `AppSheet`，可编辑标题、备注、截止日期、标签
- **排序规则**：置顶 → 未完成（按创建时间降序）→ 已完成（折叠区域，可展开）
- **完成动画**：checkbox 勾选 → 0.2s 缩放弹跳动画 → 文字划线动画 → item 移动至"已完成"区

#### 状态管理

```dart
// lib/features/todo/presentation/providers/todo_provider.dart

final todoListProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier(ref.watch(todoRepositoryProvider));
});

class TodoState {
  final List<TodoItem> items;
  final TodoFilter filter;    // all / active / done
  final bool isLoading;
  final String? error;
}
```

---

### 4.2 备忘 Memo

#### 功能描述

轻量快速的文本记录模块，适合碎片化信息的记录。区别于手记，备忘为**纯文本、单列表**，无需富文本支持。

#### 数据模型

```dart
@collection
class MemoItem {
  Id id = Isar.autoIncrement;

  late String content;        // 正文内容（最大 2000 字）
  String? tag;                // 标签（可选）
  bool isPinned = false;

  @Index()
  late DateTime createdAt;
  late DateTime updatedAt;
}
```

#### UI 结构

```
MemoPage
├── AppBar（搜索按钮 + 添加按钮）
├── SearchBar（展开时覆盖 AppBar，实时过滤）
├── MemoGrid / MemoList（支持两列网格 / 单列切换）
│   └── MemoCard（AppCard）
│       ├── 内容预览（最多 3 行，超出省略）
│       ├── 标签 Badge（可选）
│       └── 更新时间（muted 样式）
└── FAB（新建备忘）
```

#### 交互细节

- **新建/编辑**：跳转 `MemoEditPage`（全屏），顶部 AppBar 含保存/返回，自动保存（防抖 1s）
- **删除**：长按进入多选模式，或在编辑页面菜单删除，删除前弹出 `AppDialog` 确认
- **置顶**：长按菜单提供置顶/取消置顶
- **搜索**：全文检索（Isar 支持），高亮匹配词

---

### 4.3 手记 Journal

#### 功能描述

日记/手记模块，支持富文本编辑和图片插入，以**时间线**形式展示历史记录，强调仪式感和书写体验。

#### 数据模型

```dart
@collection
class JournalEntry {
  Id id = Isar.autoIncrement;

  late String title;           // 标题（可选，默认显示日期）
  late String contentJson;     // 富文本内容（存储为 Delta JSON，使用 flutter_quill）
  List<String> imagePaths = [];// 本地图片路径列表
  String? mood;                // 心情标签（可选，枚举值）
  String? weather;             // 天气标签（可选，枚举值）

  @Index()
  late DateTime createdAt;
  late DateTime updatedAt;

  // 字数统计（写入时计算）
  int wordCount = 0;
}
```

#### 枚举定义

```dart
enum JournalMood { happy, calm, sad, anxious, excited, tired }
enum JournalWeather { sunny, cloudy, rainy, snowy, windy }
```

#### UI 结构

```
JournalPage
├── AppBar（月份/年份导航，日历视图切换按钮）
├── CalendarStrip（横向日期条，有记录的日期显示指示点）
├── JournalTimeline
│   └── JournalCard（AppCard，按日期分组）
│       ├── 日期标头（yyyy年M月d日 + 星期）
│       ├── 标题
│       ├── 正文预览（纯文本，最多 4 行）
│       ├── 图片缩略图（若有，最多展示 3 张）
│       └── 心情 / 天气 Badge
└── FAB（新建手记）

JournalEditPage（全屏）
├── 顶部：标题输入框（placeholder: 今天的标题...）
├── 工具栏：粗体 / 斜体 / 列表 / 引用 / 插入图片
├── QuillEditor（富文本区域）
└── 底部栏：心情选择 | 天气选择 | 字数统计
```

#### 技术要点

- 富文本使用 `flutter_quill` 3.x，Delta 格式存储
- 图片插入：从相册选取（`image_picker`），压缩后存入 App 沙盒目录，路径写入数据库
- 自动保存：编辑中每隔 2s 触发防抖保存，退出页面时强制保存

---

### 4.4 个人设置 Settings

#### 功能描述

应用全局配置项，包含主题、通知、数据管理和关于等。

#### UI 结构

```
SettingsPage
├── 账户区（可选，本期为本地模式，占位 UI）
│
├── 外观
│   ├── 主题模式（亮色 / 暗色 / 跟随系统）—— AppSwitch / SegmentedControl
│   └── 字体大小（正常 / 大 / 超大）
│
├── 待办提醒
│   ├── 启用截止提醒 —— AppSwitch
│   └── 提醒时间（截止前 N 小时）—— 选择器
│
├── 声音与反馈
│   ├── 完成音效 —— AppSwitch（默认开启）
│   └── 触觉反馈 —— AppSwitch（默认开启）
│
├── 数据管理
│   ├── 导出数据（JSON）
│   ├── 导入数据（JSON）
│   └── 清除所有数据（危险区，destructive 样式，二次确认）
│
└── 关于
    ├── 版本号
    ├── 隐私政策
    └── 用户协议
```

#### 设置持久化

使用 `shared_preferences` 存储用户偏好设置：

```dart
// lib/core/settings/app_settings.dart

class AppSettings {
  static const _keyThemeMode       = 'theme_mode';       // system/light/dark
  static const _keyFontScale       = 'font_scale';       // 1.0/1.2/1.4
  static const _keySoundEnabled    = 'sound_enabled';    // bool
  static const _keyHapticEnabled   = 'haptic_enabled';   // bool
  static const _keyReminderEnabled = 'reminder_enabled'; // bool
  static const _keyReminderOffset  = 'reminder_offset';  // int（小时数）
}
```

---

## 5. 交互反馈机制

### 5.1 完成 Todo 时的反馈（核心需求）

当用户勾选 Todo 任务时，**同时触发以下三种反馈**：

#### ① 音效

```dart
// lib/core/services/sound_service.dart

import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  /// 播放任务完成音效
  /// 音频文件：assets/sounds/todo_done.mp3（推荐使用短促清脆的 "叮" 音，约 200ms）
  Future<void> playTodoDone() async {
    if (!AppSettings.soundEnabled) return;
    await _player.play(AssetSource('sounds/todo_done.mp3'));
  }
}
```

**音效文件规范**：
- 格式：MP3 / AAC，建议 44100Hz 16bit
- 时长：150ms ~ 300ms（短促，不干扰）
- 音量：适中，不刺耳
- 推荐风格：清脆的木鱼声、钢琴单音或水滴音

#### ② 触觉反馈（震动）

```dart
// lib/core/services/haptic_service.dart

import 'package:flutter/services.dart';

class HapticService {
  /// 任务完成反馈 —— 使用 light impact（轻触感，不打扰）
  static Future<void> todoComplete() async {
    if (!AppSettings.hapticEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// 危险操作（删除）反馈
  static Future<void> danger() async {
    await HapticFeedback.heavyImpact();
  }

  /// 普通点击反馈
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }
}
```

> **注意**：iOS 使用 `UIImpactFeedbackGenerator`（通过 Flutter channel 调用），Android 使用 `Vibrator` API。`HapticFeedback.lightImpact()` 在两端均有效。

#### ③ 视觉动画

```dart
// lib/features/todo/presentation/widgets/todo_item_tile.dart

// 完成动画序列：
// Step 1: Checkbox 勾选 → 缩放弹跳（ScaleTransition，0.8 → 1.15 → 1.0，200ms）
// Step 2: 标题文字 → 添加删除线（AnimatedDefaultTextStyle，150ms）
// Step 3: Tile 透明度 → 淡化至 0.5（FadeTransition，300ms）
// Step 4: Item 移动至已完成区域（AnimatedList remove + insert，500ms）

// 在 _onCheckboxTap 中的调用顺序：
Future<void> _onTodoDone(TodoItem item) async {
  // 1. 立即触发音效和震动（无需等待）
  unawaited(SoundService().playTodoDone());
  unawaited(HapticService.todoComplete());

  // 2. 开始视觉动画
  _animationController.forward();

  // 3. 动画完成后更新数据
  await Future.delayed(const Duration(milliseconds: 500));
  ref.read(todoListProvider.notifier).markDone(item.id);
}
```

### 5.2 其他反馈规范

| 操作 | 音效 | 震动 | 视觉 |
|------|------|------|------|
| 完成 Todo | ✅ `todo_done.mp3` | ✅ lightImpact | ✅ 划线 + 淡出 |
| 删除 Todo | ❌ | ✅ heavyImpact | ✅ 滑出动画 |
| 新建成功 | ❌ | ✅ selectionClick | ✅ 插入动画 |
| 错误提示 | ❌ | ❌ | ✅ AppToast（red）|
| 保存成功 | ❌ | ❌ | ✅ AppToast（neutral）|

---

## 6. 数据层设计

### 6.1 Repository 接口

```dart
// lib/features/todo/domain/repositories/todo_repository.dart

abstract class TodoRepository {
  Future<List<TodoItem>> getAll();
  Future<TodoItem?> getById(int id);
  Future<void> save(TodoItem item);
  Future<void> delete(int id);
  Future<void> markDone(int id);
  Stream<List<TodoItem>> watchAll();   // 响应式流，UI 实时更新
}
```

### 6.2 Isar 实现示例

```dart
// lib/features/todo/data/repositories/todo_repository_impl.dart

class TodoRepositoryImpl implements TodoRepository {
  final Isar _isar;

  TodoRepositoryImpl(this._isar);

  @override
  Stream<List<TodoItem>> watchAll() {
    return _isar.todoItems
        .where()
        .sortByIsPinnedDesc()
        .thenByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<void> markDone(int id) async {
    await _isar.writeTxn(() async {
      final item = await _isar.todoItems.get(id);
      if (item != null) {
        item.isDone = true;
        item.completedAt = DateTime.now();
        await _isar.todoItems.put(item);
      }
    });
  }
}
```

### 6.3 数据导出格式

```json
{
  "exportVersion": "1.0",
  "exportAt": "2026-03-12T00:00:00Z",
  "todos": [...],
  "memos": [...],
  "journals": [
    {
      "id": 1,
      "title": "今天的手记",
      "contentJson": "{...delta...}",
      "imagePaths": [],
      "mood": "calm",
      "createdAt": "2026-03-12T08:00:00Z"
    }
  ]
}
```

---

## 7. 路由与导航

### 7.1 底部导航

使用 `NavigationBar`（Material 3）自定义为 shadcn 风格，共 4 个 Tab：

| Index | 路由名 | 图标 | 标签 |
|-------|--------|------|------|
| 0 | `/todo` | `CheckSquare` | 待办 |
| 1 | `/memo` | `FileText` | 备忘 |
| 2 | `/journal` | `BookOpen` | 手记 |
| 3 | `/settings` | `Settings` | 设置 |

### 7.2 路由表（使用 `go_router`）

```dart
final router = GoRouter(
  initialLocation: '/todo',
  routes: [
    ShellRoute(
      builder: (_, __, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/todo',     builder: (_, __) => const TodoPage()),
        GoRoute(path: '/memo',     builder: (_, __) => const MemoPage()),
        GoRoute(path: '/journal',  builder: (_, __) => const JournalPage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      ],
    ),
    GoRoute(
      path: '/memo/edit',
      builder: (_, state) => MemoEditPage(id: state.extra as int?),
    ),
    GoRoute(
      path: '/journal/edit',
      builder: (_, state) => JournalEditPage(id: state.extra as int?),
    ),
  ],
);
```

---

## 8. 依赖包清单

```yaml
# pubspec.yaml dependencies

dependencies:
  flutter:
    sdk: flutter

  # 状态管理
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # 路由
  go_router: ^13.2.0

  # 本地数据库
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  path_provider: ^2.1.3

  # 富文本编辑
  flutter_quill: ^9.4.4

  # 音效
  audioplayers: ^6.0.0

  # 图片选择
  image_picker: ^1.1.2
  flutter_image_compress: ^2.3.0

  # 本地通知（截止提醒）
  flutter_local_notifications: ^17.2.1

  # 用户偏好
  shared_preferences: ^2.2.3

  # 工具
  intl: ^0.19.0          # 日期格式化
  uuid: ^4.4.0           # ID 生成
  collection: ^1.18.0    # 集合工具

dev_dependencies:
  build_runner: ^2.4.9
  isar_generator: ^3.1.0
  riverpod_generator: ^2.4.0
  flutter_lints: ^4.0.0
```

---

## 9. 目录结构

```
lib/
├── main.dart
├── app.dart                    # MaterialApp + router + theme
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_theme.dart      # ThemeData 配置
│   │   └── app_spacing.dart
│   ├── services/
│   │   ├── sound_service.dart
│   │   ├── haptic_service.dart
│   │   └── notification_service.dart
│   ├── settings/
│   │   └── app_settings.dart
│   └── database/
│       └── isar_provider.dart
│
├── shared/
│   └── widgets/
│       ├── app_button.dart
│       ├── app_input.dart
│       ├── app_card.dart
│       ├── app_badge.dart
│       ├── app_checkbox.dart
│       ├── app_dialog.dart
│       ├── app_sheet.dart
│       ├── app_switch.dart
│       ├── app_toast.dart
│       └── app_skeleton.dart
│
├── features/
│   ├── todo/
│   │   ├── domain/
│   │   │   ├── entities/todo_item.dart
│   │   │   └── repositories/todo_repository.dart
│   │   ├── data/
│   │   │   └── repositories/todo_repository_impl.dart
│   │   └── presentation/
│   │       ├── pages/todo_page.dart
│   │       ├── providers/todo_provider.dart
│   │       └── widgets/
│   │           ├── todo_item_tile.dart
│   │           ├── todo_filter_bar.dart
│   │           └── todo_quick_add.dart
│   │
│   ├── memo/
│   │   ├── domain/ ...
│   │   ├── data/ ...
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── memo_page.dart
│   │       │   └── memo_edit_page.dart
│   │       └── widgets/ ...
│   │
│   ├── journal/
│   │   ├── domain/ ...
│   │   ├── data/ ...
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── journal_page.dart
│   │       │   └── journal_edit_page.dart
│   │       └── widgets/
│   │           ├── journal_card.dart
│   │           ├── calendar_strip.dart
│   │           └── mood_picker.dart
│   │
│   └── settings/
│       └── presentation/
│           └── pages/settings_page.dart
│
assets/
├── sounds/
│   └── todo_done.mp3
└── fonts/              # 如需自定义字体
```

---

## 10. 开发规范

### 10.1 代码规范

- 使用 `flutter_lints` 规则集，严格模式
- 所有公开类、方法必须写 Dart Doc 注释
- 禁止在 Widget build 方法中执行异步操作，使用 `ref.watch` + `AsyncValue`
- 文件命名：`snake_case.dart`；类命名：`PascalCase`

### 10.2 颜色与主题规范

- **禁止**在 Widget 中硬编码任何颜色值（`Color(0xFF...)` 直接出现在 UI 代码中）
- 所有颜色必须通过 `Theme.of(context)` 或 `AppColors` 常量引用
- Dark Mode 通过 `ThemeData` 双主题实现，不使用条件判断在组件中切换颜色

### 10.3 音效与震动规范

- 音效和震动服务必须在 `SoundService` / `HapticService` 中统一管理
- **所有音效/震动调用前必须检查用户设置开关**（见 `AppSettings`）
- 音效播放使用 `unawaited()`，不阻塞主逻辑

### 10.4 错误处理

- Repository 层错误统一封装为 `AppException`
- UI 层通过 `AsyncValue.when(error: ...)` 处理，展示 `AppToast` 或错误状态组件
- 不在 UI 层直接 `try/catch` 数据库操作

### 10.5 性能要求

- 列表滚动帧率 ≥ 60fps（Profile 模式测试）
- 首屏加载时间 < 500ms（冷启动，数据 < 1000 条）
- 图片插入前压缩至最大 1MB（`flutter_image_compress`）

---

*文档由产品团队维护，如有疑问请联系项目负责人。*
