import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/class_provider.dart';
import '../../../providers/lesson_provider.dart';
import '../../../themes/app_theme.dart';

/// Home dashboard: today's lessons, upcoming 3 days, monthly cost, remaining hours overview
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final classes = context.watch<ClassProvider>().classes;
    final lessons = context.watch<LessonProvider>().lessons;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ClassProvider>().loadClasses();
        context.read<LessonProvider>().loadLessons();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _todayCard(context, classes, lessons),
                  const SizedBox(height: 16),
                  _upcomingCard(context, classes, lessons),
                  const SizedBox(height: 16),
                  _monthlySummary(context, classes, lessons),
                  const SizedBox(height: 16),
                  _remainingHoursOverview(context, classes),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _todayCard(BuildContext context, List<dynamic> classes, List<dynamic> lessons) {
    final now = DateTime.now();
    final todayLessons = lessons.where((l) {
      return l.scheduledDate.year == now.year &&
          l.scheduledDate.month == now.month &&
          l.scheduledDate.day == now.day;
    }).toList();

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '今日课次',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (todayLessons.isEmpty)
            Text(
              '今天没有排课，享受悠闲时光 ☀️',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            )
          else
            ...todayLessons.map((l) {
              // Find the class name
              final cls = classes.firstWhere(
                (c) => c.id == l.classId,
                orElse: () => classes.first,
              );
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${cls.className} · ${l.scheduledDate.hour}:${l.scheduledDate.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _upcomingCard(BuildContext context, List<dynamic> classes, List<dynamic> lessons) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final endAt = now.add(const Duration(days: 3));

    final upcoming = lessons.where((l) {
      return !l.scheduledDate.isBefore(now) && !l.scheduledDate.isAfter(endAt);
    }).toList()..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return _SectionCard(
      title: '未来3天',
      children: upcoming.isEmpty
          ? [Text('最近几天没有排课', style: theme.textTheme.bodySmall)]
          : upcoming.take(5).map((l) {
              final cls = classes.firstWhere(
                (c) => c.id == l.classId,
                orElse: () => classes.first,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '${l.scheduledDate.month}月${l.scheduledDate.day}日',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cls.className,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppTheme.textTertiary,
                    ),
                  ],
                ),
              );
            }).toList(),
    );
  }

  Widget _monthlySummary(BuildContext context, List classes, List lessons) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);

    final monthLessons = lessons.where((l) {
      return !l.scheduledDate.isBefore(start) && !l.scheduledDate.isAfter(end);
    }).toList();

    final completed = monthLessons.where((l) => l.status.name == 'completed').length;
    final leaves = monthLessons.where((l) => l.status.name == 'leave').length;

    double totalFee = 0;
    for (final c in classes) {
      if (c.remainingHours > 0) {
        final hoursUsed = c.usedHours;
        totalFee += c.totalFee > 0 && c.totalHours > 0
            ? (c.totalFee / c.totalHours) * hoursUsed
            : 0;
      }
    }

    return _SectionCard(
      title: '本月摘要',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem('已上课时', '$completed', Icons.check_circle, AppTheme.success),
            _StatItem('请假', '$leaves', Icons.cancel, AppTheme.warning),
            _StatItem('已消费', '¥${totalFee.toStringAsFixed(0)}', Icons.payments, AppTheme.primary),
          ],
        ),
      ],
    );
  }

  Widget _remainingHoursOverview(BuildContext context, List classes) {
    final activeClasses = classes.where((c) => c.remainingHours > 0).toList();

    return _SectionCard(
      title: '剩余课时总览',
      children: activeClasses.isEmpty
          ? [Text('暂无进行中的班级', style: Theme.of(context).textTheme.bodySmall)]
          : activeClasses.map((c) {
              final progress = c.totalHours > 0 ? c.usedHours / c.totalHours : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.className,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${c.remainingHours}/${c.totalHours}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.remainingHours <= 3
                            ? AppTheme.error
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceAlt,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (1 - progress).toDouble(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: c.remainingHours <= 3
                                ? AppTheme.error
                                : AppTheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
