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
      context.read<ChildProvider>().loadChildren();
      context.read<ClassProvider>().loadClasses();
      context.read<LessonProvider>().loadLessons();
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

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final classes = context.watch<ClassProvider>().activeClasses;
    final children = context.watch<ChildProvider>().children;
    final totalRemaining = classes.fold<int>(
      0,
      (sum, cls) => sum + cls.remainingHours,
    );
    final monthCost = classes.fold<double>(
      0,
      (sum, cls) =>
          sum +
          cls.feePerHour * (cls.usedHours == 0 ? 1 : cls.usedHours.clamp(1, 4)),
    );
    final firstClass = classes.isNotEmpty ? classes.first : null;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<ChildProvider>().loadChildren();
          context.read<ClassProvider>().loadClasses();
          context.read<LessonProvider>().loadLessons();
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
                        children.isNotEmpty
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
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SoftChip(label: '全部宝贝', selected: true),
                  ...children.map((child) => SoftChip(label: child.name)),
                  SoftChip(
                    label: '添加',
                    icon: Icons.add_rounded,
                    onTap: () => Navigator.pushNamed(context, '/home'),
                  ),
                ],
              ),
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
                          firstClass?.courseName ?? '今日无课',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppTheme.textInverse),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          firstClass == null
                              ? '可以安排一次复盘或休息'
                              : '${_ruleString(firstClass.recurringRule)} · 剩余 ${firstClass.remainingHours} 课时',
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
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _metric(
                    context,
                    Icons.auto_stories_rounded,
                    '剩余课时',
                    '$totalRemaining',
                    AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metric(
                    context,
                    Icons.payments_rounded,
                    '本月消费',
                    formatCurrency(monthCost),
                    AppTheme.accent,
                  ),
                ),
              ],
            ),
            const SectionTitle(title: '未来 3 天'),
            ..._upcomingRows(context, classes),
          ],
        ),
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return StickerCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StickerIcon(icon: icon, backgroundColor: color, size: 42),
          const SizedBox(height: 14),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  List<Widget> _upcomingRows(
    BuildContext context,
    List<TrainingClass> classes,
  ) {
    if (classes.isEmpty) {
      return [const StickerCard(child: Text('还没有课程，先新建一个班级吧。'))];
    }
    return classes.take(3).map((cls) {
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
                    '${_ruleString(cls.recurringRule)} • ${cls.institutionName}',
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

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab();

  @override
  Widget build(BuildContext context) {
    final classes = context.watch<ClassProvider>().activeClasses;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          _topTitle(context, '课时管家', '2024年九月', Icons.calendar_month_rounded),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                SoftChip(label: '全部宝贝', selected: true),
                SoftChip(label: '乐乐'),
                SoftChip(label: '朵朵'),
              ],
            ),
          ),
          const SectionTitle(title: '今日课程', trailing: '3 节课'),
          if (classes.isEmpty) const StickerCard(child: Text('今日暂无课程')),
          ...classes.map((cls) => _lessonCard(context, cls)),
        ],
      ),
    );
  }

  Widget _lessonCard(BuildContext context, TrainingClass cls) {
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
                child: Text(
                  cls.courseName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _statusPill('待上课', AppTheme.accent),
            ],
          ),
          const SizedBox(height: 14),
          _meta(Icons.schedule_rounded, '09:30 AM - 10:30 AM'),
          _meta(Icons.location_on_rounded, cls.institutionName),
        ],
      ),
    );
  }
}

class _ClassesTab extends StatelessWidget {
  const _ClassesTab();

  @override
  Widget build(BuildContext context) {
    final classes = context.watch<ClassProvider>().classes;
    final active = classes
        .where((cls) => cls.status == ClassStatus.active)
        .toList();
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
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                SoftChip(label: '全部科目', selected: true),
                SoftChip(label: '美术'),
                SoftChip(label: '体育'),
                SoftChip(label: '音乐'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (classes.isEmpty) _emptyClass(context),
          ...active.map((cls) => _classCard(context, cls)),
          const SizedBox(height: 12),
          if (classes.any((cls) => cls.status == ClassStatus.ended))
            const SectionTitle(title: '已结束'),
          ...classes
              .where((cls) => cls.status == ClassStatus.ended)
              .map((cls) => _classCard(context, cls)),
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
          Text(
            '课程进度  ${cls.usedHours} / ${cls.totalHours} 节课',
            style: Theme.of(context).textTheme.bodySmall,
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

class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    final classes = context.watch<ClassProvider>().classes;
    final completed = classes.fold<int>(0, (sum, cls) => sum + cls.usedHours);
    final totalFee = classes.fold<double>(0, (sum, cls) => sum + cls.totalFee);
    final remaining = classes.fold<int>(
      0,
      (sum, cls) => sum + cls.remainingHours,
    );
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          _topTitle(context, '课时管家', '本月成长足迹', Icons.calendar_month_rounded),
          const SizedBox(height: 18),
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
                        '你表现得太棒了！',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textInverse,
                        ),
                      ),
                      Text(
                        '本月已完成 $completed 节课',
                        style: const TextStyle(
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _reportMetric(
                  context,
                  '出勤之星',
                  '$completed',
                  '/ ${completed + 2} 节课',
                  Icons.stars_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _reportMetric(
                  context,
                  '记账统计',
                  formatCurrency(totalFee),
                  '累计缴费',
                  Icons.savings_rounded,
                ),
              ),
            ],
          ),
          const SectionTitle(title: '课时剩余趋势'),
          StickerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final height = 40.0 + (index % 4) * 18;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            Container(
                              height: height,
                              decoration: BoxDecoration(
                                color: index == 5
                                    ? AppTheme.primary
                                    : AppTheme.oat,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][index],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                Text(
                  '本周你已经完成了 ${completed.clamp(0, 4)} 节课，剩余 $remaining 课时。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SectionTitle(title: '本月勋章'),
          Row(
            children: const [
              Expanded(
                child: _Medal(label: '准时家长', icon: Icons.emoji_events_rounded),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _Medal(label: '坚持之星', icon: Icons.auto_fix_high_rounded),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _Medal(label: '爱学习', icon: Icons.favorite_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reportMetric(
    BuildContext context,
    String title,
    String value,
    String sub,
    IconData icon,
  ) {
    return StickerCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StickerIcon(icon: icon, backgroundColor: AppTheme.sage, size: 42),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(sub, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _MeTab extends StatefulWidget {
  const _MeTab();
  @override
  State<_MeTab> createState() => _MeTabState();
  void _confirmDeleteChild(BuildContext context, Child child) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除宝贝「${child.name}」吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ChildProvider>().removeChild(child.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已删除宝贝「${child.name}」')),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('添加成员'),
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
                ),
                _menuItem(context, Icons.ios_share_rounded, '数据导出', 'CSV/PDF'),
                _menuItem(context, Icons.palette_rounded, '主题与皮肤选择', '经典大地贴纸'),
                _menuItem(
                  context,
                  Icons.notifications_active_rounded,
                  '上课提醒设置',
                  '提前 30 分钟',
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
}

class _Medal extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Medal({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return StickerCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          StickerIcon(icon: icon, backgroundColor: AppTheme.accent, size: 42),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
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
  String subtitle,
) {
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
    onTap: () => ScaffoldMessenger.of(
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

String _ruleString(RecurringRule rule) {
  if (rule.type == RecurringRuleType.weekly && rule.daysOfWeek.isNotEmpty) {
    const labels = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    if (rule.timeSlots.isNotEmpty) {
      final slots = [...rule.timeSlots]
        ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
      return slots
          .map(
            (slot) =>
                '${labels[slot.dayOfWeek]} ${_clock(slot.startHour, slot.startMinute)}-${_clock(slot.endHour, slot.endMinute)}',
          )
          .join('、');
    }
    return '每周${rule.daysOfWeek.map((day) => labels[day]).join('、')}';
  }
  if (rule.type == RecurringRuleType.monthly) return '每月固定上课';
  return '自定义周期';
}

String _clock(int hour, int minute) {
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
