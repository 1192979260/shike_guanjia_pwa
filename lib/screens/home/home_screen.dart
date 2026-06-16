import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../themes/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../widgets/child_avatar.dart';
import '../../widgets/design/sticker_widgets.dart';
import 'home_lesson_summary.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _DashboardTab(),
      const _ScheduleTab(),
      const _ClassesTab(),
      const _StatsTab(),
      const _MeTab(),
    ];

    return Scaffold(
      body: OrganicBackground(child: tabs[_tabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: '课表',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_library_outlined),
            selectedIcon: Icon(Icons.local_library_rounded),
            label: '班级',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard_rounded),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

Future<void> _loadHomeData(BuildContext context) async {
  final childProvider = context.read<ChildProvider>();
  final classProvider = context.read<ClassProvider>();
  final lessonProvider = context.read<LessonProvider>();
  await Future.wait([
    childProvider.loadChildren(),
    classProvider.loadClasses(),
  ]);
  await lessonProvider.loadLessons();
  await lessonProvider.repairMissingInitialLessons(classProvider.activeClasses);
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  String? _selectedChildId;

  @override
  Widget build(BuildContext context) {
    final allClasses = context.watch<ClassProvider>().activeClasses;
    final lessons = context.watch<LessonProvider>().lessons;
    final children = context.watch<ChildProvider>().children;
    final now = DateTime.now();
    final effectiveChildId =
        children.any((child) => child.id == _selectedChildId)
        ? _selectedChildId
        : null;
    final classes = effectiveChildId == null
        ? allClasses
        : allClasses.where((cls) => cls.childId == effectiveChildId).toList();
    final selectedChild = effectiveChildId == null
        ? null
        : children.where((child) => child.id == effectiveChildId).firstOrNull;
    final todayLessons = buildTodayLessonSummaries(
      lessons: lessons,
      classes: classes,
      now: now,
    );
    final upcomingLessons = buildUpcomingLessonSummaries(
      lessons: lessons,
      classes: classes,
      now: now,
    );
    final nextTodayLesson = todayLessons.isNotEmpty ? todayLessons.first : null;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await _loadHomeData(context);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '早上好！',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        selectedChild != null
                            ? '${selectedChild.name}妈'
                            : children.isNotEmpty
                            ? '${children.first.name}妈'
                            : '课时管家',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_month_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ChipScroller(
              children: [
                SoftChip(
                  label: '全部宝贝',
                  selected: effectiveChildId == null,
                  onTap: () => setState(() => _selectedChildId = null),
                ),
                ...children.map(
                  (child) => SoftChip(
                    label: child.name,
                    selected: effectiveChildId == child.id,
                    onTap: () => setState(() => _selectedChildId = child.id),
                  ),
                ),
                SoftChip(
                  label: '添加',
                  icon: Icons.add_rounded,
                  onTap: () async {
                    final child = await Navigator.pushNamed(
                      context,
                      '/add_child',
                    );
                    if (!mounted || child is! Child) return;
                    setState(() => _selectedChildId = child.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            StickerCard(
              color: AppTheme.sage,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '今日旅程',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.textInverse.withValues(
                                  alpha: 0.82,
                                ),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextTodayLesson?.trainingClass.courseName ?? '今日无课',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppTheme.textInverse),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nextTodayLesson == null
                              ? '可以安排一次复盘或休息'
                              : '${lessonTimeRange(nextTodayLesson.lesson)} · ${nextTodayLesson.trainingClass.institutionName} · 剩余 ${nextTodayLesson.trainingClass.remainingHours} 课时',
                          style: const TextStyle(
                            color: AppTheme.textInverse,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const StickerIcon(
                    icon: Icons.star_rounded,
                    backgroundColor: AppTheme.accent,
                    size: 64,
                  ),
                ],
              ),
            ),
            const SectionTitle(title: '未来 3 天'),
            ..._upcomingRows(
              context,
              upcomingLessons,
              hasClasses: classes.isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _upcomingRows(
    BuildContext context,
    List<HomeLessonSummary> lessons, {
    required bool hasClasses,
  }) {
    if (!hasClasses) {
      return [const StickerCard(child: Text('还没有课程，先新建一个班级吧。'))];
    }
    if (lessons.isEmpty) {
      return [const StickerCard(child: Text('未来 3 天暂无课程安排'))];
    }
    return lessons.map((summary) {
      final lesson = summary.lesson;
      final cls = summary.trainingClass;
      return StickerCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        onTap: () =>
            Navigator.pushNamed(context, '/class_detail', arguments: cls),
        child: Row(
          children: [
            StickerIcon(
              icon: _courseIcon(cls.courseName),
              backgroundColor: AppTheme.primary,
              size: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cls.courseName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '${formatDateShort(lesson.scheduledDate)} ${weekdayChinese(lesson.scheduledDate)} ${lessonTimeRange(lesson)} • ${cls.institutionName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _ScheduleTab extends StatefulWidget {
  const _ScheduleTab();

  @override
  State<_ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<_ScheduleTab> {
  String? _selectedChildId;

  @override
  Widget build(BuildContext context) {
    final children = context.watch<ChildProvider>().children;
    final childProvider = context.watch<ChildProvider>();
    final classes = context.watch<ClassProvider>().activeClasses;
    final lessons = context.watch<LessonProvider>().lessons;
    final now = DateTime.now();
    final effectiveChildId =
        children.any((child) => child.id == _selectedChildId)
        ? _selectedChildId
        : null;
    final filteredClasses = effectiveChildId == null
        ? classes
        : classes.where((cls) => cls.childId == effectiveChildId).toList();
    final todayLessons = buildTodayLessonSummaries(
      lessons: lessons,
      classes: filteredClasses,
      now: now,
    );
    final selectedChild = effectiveChildId == null
        ? null
        : children.where((child) => child.id == effectiveChildId).firstOrNull;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await _loadHomeData(context);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _topTitle(
              context,
              '课时管家',
              '${now.year}年${now.month}月',
              Icons.calendar_month_rounded,
            ),
            const SizedBox(height: 12),
            _ChipScroller(
              children: [
                SoftChip(
                  label: '全部宝贝',
                  selected: effectiveChildId == null,
                  onTap: () => setState(() => _selectedChildId = null),
                ),
                ...children.map(
                  (child) => SoftChip(
                    label: child.name,
                    selected: effectiveChildId == child.id,
                    onTap: () => setState(() => _selectedChildId = child.id),
                  ),
                ),
              ],
            ),
            SectionTitle(
              title: selectedChild == null
                  ? '今日课程'
                  : '${selectedChild.name}的今日课程',
              trailing: '${todayLessons.length} 节课',
            ),
            if (children.isEmpty && childProvider.isLoading)
              const StickerCard(child: Text('正在加载宝贝列表...'))
            else if (todayLessons.isEmpty)
              StickerCard(
                child: Text(
                  selectedChild == null
                      ? '今日暂无课程'
                      : '${selectedChild.name}今日暂无课程',
                ),
              ),
            ...todayLessons.map(
              (summary) => _lessonCard(
                context,
                summary.lesson,
                summary.trainingClass,
                _childName(children, summary.trainingClass.childId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lessonCard(
    BuildContext context,
    Lesson lesson,
    TrainingClass cls,
    String childName,
  ) {
    return StickerCard(
      margin: const EdgeInsets.only(bottom: 14),
      onTap: () =>
          Navigator.pushNamed(context, '/class_detail', arguments: cls),
      child: Column(
        children: [
          Row(
            children: [
              StickerIcon(
                icon: _courseIcon(cls.courseName),
                backgroundColor: AppTheme.primary,
                size: 48,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cls.courseName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      childName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _statusPill(
                _lessonStatusLabel(lesson.status),
                _lessonStatusColor(lesson.status),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _meta(Icons.schedule_rounded, lessonTimeRange(lesson)),
          _meta(Icons.location_on_rounded, cls.institutionName),
        ],
      ),
    );
  }

  String _childName(List<Child> children, String childId) {
    for (final child in children) {
      if (child.id == childId) return child.name;
    }
    return '未命名宝贝';
  }

  String _lessonStatusLabel(LessonStatus status) {
    switch (status) {
      case LessonStatus.scheduled:
        return '待上课';
      case LessonStatus.completed:
        return '已上课';
      case LessonStatus.leave:
        return '已请假';
      case LessonStatus.rescheduled:
        return '已调课';
      case LessonStatus.cancelled:
        return '已取消';
    }
  }

  Color _lessonStatusColor(LessonStatus status) {
    switch (status) {
      case LessonStatus.scheduled:
        return AppTheme.accent;
      case LessonStatus.completed:
        return AppTheme.sage;
      case LessonStatus.leave:
        return AppTheme.clay;
      case LessonStatus.rescheduled:
        return AppTheme.primary;
      case LessonStatus.cancelled:
        return AppTheme.error;
    }
  }
}

class _ClassesTab extends StatelessWidget {
  const _ClassesTab();

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();
    final children = context.watch<ChildProvider>().children;
    final classes = classProvider.filteredClasses;
    final courses = classProvider.uniqueCourses;
    final active = classes
        .where((cls) => cls.status == ClassStatus.active)
        .toList();
    final ended = classes.where((cls) => cls.status == ClassStatus.ended);
    final hasAnyClass = classProvider.classes.isNotEmpty;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 92),
        children: [
          _topTitle(context, '课时管家', '进行中的班级', Icons.calendar_month_rounded),
          const SizedBox(height: 10),
          Text(
            '共 ${active.length} 个进行中班级',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          _ChipScroller(
            children: [
              SoftChip(
                label: '全部宝贝',
                selected: classProvider.selectedChildId == null,
                onTap: () => context.read<ClassProvider>().setChildFilter(null),
              ),
              ...children.map(
                (child) => SoftChip(
                  label: child.name,
                  selected: classProvider.selectedChildId == child.id,
                  onTap: () =>
                      context.read<ClassProvider>().setChildFilter(child.id),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ChipScroller(
            children: [
              SoftChip(
                label: '全部科目',
                selected: classProvider.selectedCourse == null,
                onTap: () => context.read<ClassProvider>().clearCourseFilter(),
              ),
              ...courses.map(
                (course) => SoftChip(
                  label: course,
                  selected: classProvider.selectedCourse == course,
                  icon: _courseIcon(course),
                  onTap: () =>
                      context.read<ClassProvider>().setCourseFilter(course),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasAnyClass) _emptyClass(context),
          if (hasAnyClass && classes.isEmpty) _emptyFilterResult(context),
          ...active.map((cls) => _classCard(context, cls)),
          const SizedBox(height: 12),
          if (ended.isNotEmpty) const SectionTitle(title: '已结束'),
          ...ended.map((cls) => _classCard(context, cls)),
        ],
      ),
    );
  }

  Widget _emptyClass(BuildContext context) {
    return StickerCard(
      child: Column(
        children: [
          const StickerIcon(
            icon: Icons.local_library_rounded,
            backgroundColor: AppTheme.sage,
            size: 64,
          ),
          const SizedBox(height: 14),
          Text('还没有班级', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            '新建第一个培训班后，可以开始追踪课时和费用。',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/add_class'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('新建班级'),
          ),
        ],
      ),
    );
  }

  Widget _emptyFilterResult(BuildContext context) {
    return const StickerCard(child: Text('当前筛选条件下暂无班级'));
  }

  Widget _classCard(BuildContext context, TrainingClass cls) {
    final progress = cls.totalHours == 0 ? 0.0 : cls.usedHours / cls.totalHours;
    return StickerCard(
      margin: const EdgeInsets.only(bottom: 14),
      onTap: () =>
          Navigator.pushNamed(context, '/class_detail', arguments: cls),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StickerIcon(
                icon: _courseIcon(cls.courseName),
                backgroundColor: AppTheme.primary,
                size: 46,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cls.institutionName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      cls.className,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              _statusPill(
                '剩余 ${cls.remainingHours}',
                cls.remainingHours <= 3 ? AppTheme.error : AppTheme.sage,
              ),
            ],
          ),
          const SizedBox(height: 16),
          OrganicProgressBar(value: progress, color: AppTheme.primary),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '课程进度  ${cls.usedHours} / ${cls.totalHours} 节课',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '总费用 ${formatCurrency(cls.totalFee)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '客单价 ${formatCurrency(cls.feePerHour)}/课',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/class_detail',
                    arguments: cls,
                  ),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('打卡'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () => _showClassOptions(context, cls),
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showClassOptions(BuildContext context, TrainingClass cls) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      cls.className,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text('管理班级设置', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              _sheetItem(
                context,
                Icons.edit_note_rounded,
                '编辑班级',
                () => Navigator.pushNamed(
                  context,
                  '/add_class',
                  arguments: {'editClass': cls},
                ),
              ),
              _sheetItem(
                context,
                Icons.autorenew_rounded,
                '续费/续班',
                () => Navigator.pushNamed(
                  context,
                  '/add_class',
                  arguments: {'editClass': cls, 'renew': true},
                ),
              ),
              _sheetItem(
                context,
                Icons.pause_circle_rounded,
                '暂停课程',
                () => context.read<ClassProvider>().pauseClass(cls.id),
              ),
              _sheetItem(
                context,
                Icons.delete_outline_rounded,
                '删除班级',
                () => _confirmDelete(context, cls),
              ),
              const SizedBox(height: 8),
              Text(
                '续班或修改课时数可自动同步至课程计划',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsTab extends StatefulWidget {
  const _StatsTab();

  @override
  State<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab> {
  String? _selectedChildId;

  @override
  Widget build(BuildContext context) {
    final children = context.watch<ChildProvider>().children;
    final classes = context.watch<ClassProvider>().classes;
    final selectedChildExists = children.any(
      (child) => child.id == _selectedChildId,
    );
    if (!selectedChildExists) {
      _selectedChildId = null;
    }
    final filteredClasses = _selectedChildId == null
        ? classes
        : classes.where((cls) => cls.childId == _selectedChildId).toList();
    final totalFee = filteredClasses.fold<double>(
      0,
      (sum, cls) => sum + cls.totalFee,
    );
    final usedHours = filteredClasses.fold<int>(
      0,
      (sum, cls) => sum + cls.usedHours,
    );
    final totalHours = filteredClasses.fold<int>(
      0,
      (sum, cls) => sum + cls.totalHours,
    );
    final remainingHours = filteredClasses.fold<int>(
      0,
      (sum, cls) => sum + cls.remainingHours,
    );
    final consumedValue = filteredClasses.fold<double>(
      0,
      (sum, cls) => sum + cls.feePerHour * cls.usedHours,
    );
    final remainingValue = filteredClasses.fold<double>(
      0,
      (sum, cls) => sum + cls.feePerHour * cls.remainingHours,
    );
    final childNames = {for (final child in children) child.id: child.name};

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          _statsHeader(context),
          const SizedBox(height: 14),
          if (children.isNotEmpty) _childFilter(children),
          const SizedBox(height: 14),
          StickerCard(
            color: AppTheme.primary,
            child: Row(
              children: [
                const StickerIcon(
                  icon: Icons.workspace_premium_rounded,
                  backgroundColor: AppTheme.accent,
                  size: 62,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatCurrency(totalFee),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: AppTheme.textInverse),
                      ),
                      const Text(
                        '家庭累计培训缴费',
                        style: TextStyle(
                          color: AppTheme.textInverse,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle(title: '费用去向'),
          _CostDirectionCard(
            consumedValue: consumedValue,
            remainingValue: remainingValue,
            usedHours: usedHours,
            remainingHours: remainingHours,
            totalFee: totalFee,
          ),
          const SectionTitle(title: '班级费用明细'),
          if (filteredClasses.isEmpty)
            StickerCard(
              child: Text(
                '还没有可统计的班级费用',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...filteredClasses.map(
              (cls) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ClassCostCard(
                  cls: cls,
                  childName: childNames[cls.childId] ?? '宝贝',
                  totalHoursInScope: totalHours,
                ),
              ),
            ),
          const SizedBox(height: 72),
        ],
      ),
    );
  }

  Widget _statsHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('课时管家', style: Theme.of(context).textTheme.bodySmall),
              Text('培训开支统计', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.savings_rounded),
        ),
      ],
    );
  }

  Widget _childFilter(List<Child> children) {
    return _ChipScroller(
      children: [
        SoftChip(
          label: '全部宝贝',
          selected: _selectedChildId == null,
          onTap: () => setState(() => _selectedChildId = null),
        ),
        ...children.map(
          (child) => SoftChip(
            label: child.name,
            selected: _selectedChildId == child.id,
            onTap: () => setState(() => _selectedChildId = child.id),
          ),
        ),
      ],
    );
  }
}

class _ChipScroller extends StatelessWidget {
  final List<Widget> children;

  const _ChipScroller({required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chipMaxWidth = constraints.maxWidth.isFinite
              ? (constraints.maxWidth * 0.36).clamp(88.0, 132.0)
              : 112.0;
          return ListView(
            scrollDirection: Axis.horizontal,
            children: children.map((child) {
              if (child is SoftChip) {
                return SoftChip(
                  key: child.key,
                  label: child.label,
                  selected: child.selected,
                  icon: child.icon,
                  maxLabelWidth: chipMaxWidth,
                  onTap: child.onTap,
                  onLongPress: child.onLongPress,
                );
              }
              return child;
            }).toList(),
          );
        },
      ),
    );
  }
}

class _CostDirectionCard extends StatelessWidget {
  final double consumedValue;
  final double remainingValue;
  final int usedHours;
  final int remainingHours;
  final double totalFee;

  const _CostDirectionCard({
    required this.consumedValue,
    required this.remainingValue,
    required this.usedHours,
    required this.remainingHours,
    required this.totalFee,
  });

  @override
  Widget build(BuildContext context) {
    final accounted = consumedValue + remainingValue;
    final consumedRatio = accounted <= 0 ? 0.0 : consumedValue / accounted;
    return StickerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ValueColumn(
                  dotColor: AppTheme.primary,
                  title: '已消耗价值',
                  value: formatCurrency(consumedValue),
                  subtitle: '$usedHours 节已消耗',
                ),
              ),
              Container(width: 1, height: 72, color: AppTheme.oat),
              const SizedBox(width: 14),
              Expanded(
                child: _ValueColumn(
                  dotColor: AppTheme.sage,
                  title: '剩余课时价值',
                  value: formatCurrency(remainingValue),
                  subtitle: '$remainingHours 节待消耗',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 18,
              child: Row(
                children: [
                  Expanded(
                    flex: (consumedRatio * 1000).round().clamp(0, 1000),
                    child: Container(color: AppTheme.primary),
                  ),
                  Expanded(
                    flex: ((1 - consumedRatio) * 1000).round().clamp(0, 1000),
                    child: Container(color: AppTheme.sage),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '累计缴费 ${formatCurrency(totalFee)}，其中已消耗约 ${formatCurrency(consumedValue)}，剩余课时价值约 ${formatCurrency(remainingValue)}。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ValueColumn extends StatelessWidget {
  final Color dotColor;
  final String title;
  final String value;
  final String subtitle;

  const _ValueColumn({
    required this.dotColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
        const SizedBox(height: 6),
        FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: Text(value, style: Theme.of(context).textTheme.titleLarge),
        ),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ClassCostCard extends StatelessWidget {
  final TrainingClass cls;
  final String childName;
  final int totalHoursInScope;

  const _ClassCostCard({
    required this.cls,
    required this.childName,
    required this.totalHoursInScope,
  });

  @override
  Widget build(BuildContext context) {
    final consumedValue = cls.feePerHour * cls.usedHours;
    final remainingValue = cls.feePerHour * cls.remainingHours;
    final progress = cls.totalHours == 0 ? 0.0 : cls.usedHours / cls.totalHours;
    final share = totalHoursInScope == 0
        ? 0.0
        : cls.totalHours / totalHoursInScope;

    return StickerCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StickerIcon(
                icon: Icons.local_library_rounded,
                backgroundColor: AppTheme.sand,
                color: AppTheme.primaryDark,
                size: 48,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cls.className,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$childName · ${cls.courseName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatCurrency(cls.totalFee),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          OrganicProgressBar(
            value: progress,
            color: AppTheme.primary,
            height: 14,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '已消耗 ${formatCurrency(consumedValue)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '剩余 ${formatCurrency(remainingValue)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${cls.usedHours}/${cls.totalHours} 课时已消耗 · ${formatCurrency(cls.feePerHour)}/课',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          OrganicProgressBar(value: share, color: AppTheme.sage, height: 10),
        ],
      ),
    );
  }
}

class _MeTab extends StatefulWidget {
  const _MeTab();

  @override
  State<_MeTab> createState() => _MeTabState();
}

class _MeTabState extends State<_MeTab> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final children = context.watch<ChildProvider>().children;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Text('个人中心', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          StickerCard(
            color: AppTheme.sage,
            child: Row(
              children: [
                const StickerIcon(
                  icon: Icons.person_rounded,
                  backgroundColor: AppTheme.oat,
                  color: AppTheme.textPrimary,
                  size: 62,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.phone ?? '乐乐妈',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textInverse,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '家庭 ID: ${auth.familyId ?? '未登录'}',
                        style: const TextStyle(color: AppTheme.textInverse),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textInverse,
                ),
              ],
            ),
          ),
          const SectionTitle(title: '我的宝贝'),
          StickerCard(
            child: Column(
              children: [
                if (children.isEmpty)
                  Text(
                    '还没有添加宝贝',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ...children.map(
                  (child) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ChildAvatar(name: child.name),
                    title: Text(child.name),
                    subtitle: Text(
                      child.age == null ? '年龄未填写' : '${child.age}岁',
                    ),
                    trailing: IconButton(
                      tooltip: '删除宝贝',
                      onPressed: () => _confirmDeleteChild(context, child),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/add_child'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('添加宝贝'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StickerCard(
            child: Column(
              children: [
                _menuItem(
                  context,
                  Icons.family_restroom_rounded,
                  '家庭共享',
                  '邀请爸爸',
                  onTap: () => Navigator.pushNamed(context, '/family_sharing'),
                ),
                _menuItem(context, Icons.ios_share_rounded, '数据导出', 'CSV/PDF'),
                _menuItem(
                  context,
                  Icons.palette_rounded,
                  '主题与皮肤选择',
                  '经典大地贴纸',
                  onTap: () => Navigator.pushNamed(context, '/theme_selection'),
                ),
                _menuItem(
                  context,
                  Icons.notifications_active_rounded,
                  '上课提醒设置',
                  '提前 30 分钟',
                  onTap: () =>
                      Navigator.pushNamed(context, '/reminder_settings'),
                ),
                _menuItem(context, Icons.help_rounded, '帮助中心', '常见问题'),
                _menuItem(
                  context,
                  Icons.chat_bubble_rounded,
                  '问题反馈',
                  '告诉我们你的建议',
                ),
                _menuItem(
                  context,
                  Icons.info_rounded,
                  '关于 Lesson Butler',
                  'v1.0.0',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('退出登录'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteChild(BuildContext context, Child child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除宝贝'),
        content: Text('确认删除 ${child.name} 吗？关联的班级、课表和考勤记录也会一起删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final childProvider = context.read<ChildProvider>();
    final classProvider = context.read<ClassProvider>();
    final lessonProvider = context.read<LessonProvider>();
    final deleted = await childProvider.removeChild(child.id);
    if (!context.mounted) return;

    if (deleted) {
      if (classProvider.selectedChildId == child.id) {
        classProvider.setChildFilter(null);
      }
      await Future.wait([
        classProvider.loadClasses(),
        lessonProvider.loadLessons(),
      ]);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已删除 ${child.name}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(childProvider.error ?? '删除失败，请稍后重试')),
      );
    }
  }
}

Widget _topTitle(
  BuildContext context,
  String eyebrow,
  String title,
  IconData icon,
) {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eyebrow, style: Theme.of(context).textTheme.bodySmall),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      IconButton.filledTonal(onPressed: () {}, icon: Icon(icon)),
    ],
  );
}

Widget _meta(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.clay),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _statusPill(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color == AppTheme.accent ? AppTheme.primaryDark : color,
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

Widget _sheetItem(
  BuildContext context,
  IconData icon,
  String title,
  VoidCallback onTap,
) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: StickerIcon(icon: icon, backgroundColor: AppTheme.sage, size: 42),
    title: Text(title, style: Theme.of(context).textTheme.titleSmall),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: () {
      Navigator.pop(context);
      onTap();
    },
  );
}

Widget _menuItem(
  BuildContext context,
  IconData icon,
  String title,
  String subtitle, {
  VoidCallback? onTap,
}) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: StickerIcon(
      icon: icon,
      backgroundColor: AppTheme.sand,
      color: AppTheme.primaryDark,
      size: 42,
    ),
    title: Text(title, style: Theme.of(context).textTheme.titleSmall),
    subtitle: Text(subtitle),
    trailing: const Icon(
      Icons.chevron_right_rounded,
      color: AppTheme.textTertiary,
    ),
    onTap:
        onTap ??
        () => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title 功能开发中'))),
  );
}

void _confirmDelete(BuildContext context, TrainingClass cls) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(
        Icons.delete_forever_rounded,
        color: AppTheme.error,
        size: 42,
      ),
      title: const Text('确认删除该班级？'),
      content: Text('您正在尝试删除 ${cls.className}。删除后相关课程记录、考勤及剩余课时数据不可恢复。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('我再想想'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
          onPressed: () async {
            await context.read<ClassProvider>().deleteClass(cls.id);
            if (dialogContext.mounted) Navigator.pop(dialogContext);
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已成功移除班级')));
            }
          },
          child: const Text('确认删除'),
        ),
      ],
    ),
  );
}

IconData _courseIcon(String text) {
  if (text.contains('美术') || text.contains('艺术')) return Icons.palette_rounded;
  if (text.contains('游泳') || text.contains('体育')) return Icons.pool_rounded;
  if (text.contains('钢琴') || text.contains('音乐')) {
    return Icons.music_note_rounded;
  }
  if (text.contains('英语')) return Icons.auto_stories_rounded;
  return Icons.local_library_rounded;
}
