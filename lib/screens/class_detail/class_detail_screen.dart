import "package:shike_guanjia/models/models.dart";
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../themes/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../widgets/design/sticker_widgets.dart';

class ClassDetailScreen extends StatefulWidget {
  final TrainingClass cls;
  const ClassDetailScreen({super.key, required this.cls});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  late TrainingClass _cls;

  @override
  void initState() {
    super.initState();
    _cls = widget.cls;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().loadLessons(classId: _cls.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allLessons = context.watch<LessonProvider>().lessons;
    final classLessons = allLessons.where((l) => l.classId == _cls.id).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    final nextLesson = _nextScheduledLesson(classLessons);
    final progress = _cls.totalHours == 0
        ? 0.0
        : _cls.usedHours / _cls.totalHours;
    final remainValue = _cls.feePerHour * _cls.remainingHours;

    return Scaffold(
      body: OrganicBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Text(
                      _cls.className,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: _showOptions,
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StickerCard(
                color: AppTheme.sage,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const StickerIcon(
                          icon: Icons.palette_rounded,
                          backgroundColor: AppTheme.accent,
                          size: 58,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '课时进度',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textInverse.withValues(
                                        alpha: 0.85,
                                      ),
                                    ),
                              ),
                              Text(
                                '${_cls.usedHours} / ${_cls.totalHours} 课时',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: AppTheme.textInverse),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    OrganicProgressBar(
                      value: progress,
                      color: AppTheme.accent,
                      height: 12,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '剩余 ${_cls.remainingHours} 课时',
                      style: const TextStyle(
                        color: AppTheme.textInverse,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              StickerCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow(
                      Icons.event_available_rounded,
                      '下次上课时间',
                      nextLesson == null
                          ? '暂无待上课课次'
                          : '${formatTime(nextLesson.scheduledDate)} - ${formatTime(nextLesson.scheduledEndDate ?? nextLesson.scheduledDate.add(const Duration(hours: 1)))}\n${formatDateChinese(nextLesson.scheduledDate)}',
                    ),
                    const Divider(color: AppTheme.oat),
                    _detailRow(
                      Icons.location_on_rounded,
                      '上课地点',
                      _cls.institutionName,
                    ),
                    if (_cls.teacherName != null) ...[
                      const Divider(color: AppTheme.oat),
                      _detailRow(
                        Icons.person_rounded,
                        _cls.teacherName!,
                        '主要授课老师',
                      ),
                    ],
                  ],
                ),
              ),
              const SectionTitle(title: '费用信息摘要'),
              StickerCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _feeBlock(
                        context,
                        '剩余课时价值',
                        formatCurrency(remainValue),
                      ),
                    ),
                    Container(width: 1, height: 52, color: AppTheme.oat),
                    Expanded(
                      child: _feeBlock(
                        context,
                        '已缴总费',
                        '${formatCurrency(_cls.totalFee)} (${_cls.totalHours}课)',
                      ),
                    ),
                  ],
                ),
              ),
              if (_cls.usedHours > 0) ...[
                const SectionTitle(title: '近期上课记录', trailing: '查看全部'),
                StickerCard(
                  child: Column(
                    children: [
                      for (final lesson
                          in classLessons
                              .where((l) => l.status == LessonStatus.completed)
                              .toList()
                              .reversed
                              .take(3))
                        _recordRow(
                          Icons.check_circle_rounded,
                          '第 ${classLessons.indexOf(lesson) + 1} 课：${_cls.courseName}',
                          '${formatDateChinese(lesson.scheduledDate)} ${formatTime(lesson.scheduledDate)}',
                          AppTheme.sage,
                          onCancelCheckIn: () => _confirmCancelCheckIn(lesson),
                        ),
                      for (final lesson
                          in classLessons
                              .where((l) => l.status == LessonStatus.leave)
                              .toList()
                              .take(1))
                        _recordRow(
                          Icons.event_busy_rounded,
                          '第 ${classLessons.indexOf(lesson) + 1} 课：请假',
                          lesson.leaveReason ?? '已顺延',
                          AppTheme.warning,
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showLeaveSheet,
                      icon: const Icon(Icons.edit_calendar_rounded),
                      label: const Text('我要请假'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showCheckinDialog,
                      icon: const Icon(Icons.verified_rounded),
                      label: const Text('上课打卡'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: StickerIcon(
        icon: icon,
        backgroundColor: AppTheme.sand,
        color: AppTheme.primaryDark,
        size: 44,
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(subtitle),
      trailing: title == '上课地点'
          ? TextButton(onPressed: () {}, child: const Text('在地图中查看'))
          : null,
    );
  }

  Widget _feeBlock(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _recordRow(
    IconData icon,
    String title,
    String subtitle,
    Color color, {
    VoidCallback? onCancelCheckIn,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(subtitle),
      trailing: onCancelCheckIn == null
          ? const Icon(Icons.chevron_right_rounded)
          : TextButton(onPressed: onCancelCheckIn, child: const Text('取消打卡')),
    );
  }

  Future<void> _confirmCancelCheckIn(Lesson lesson) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('取消打卡？'),
        content: const Text('取消后这节课会恢复为待上课，并返还已消耗的课时。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('先不取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认取消'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final lessonProvider = context.read<LessonProvider>();
    final classProvider = context.read<ClassProvider>();
    final messenger = ScaffoldMessenger.of(context);
    await lessonProvider.cancelCheckIn(lesson.id);
    await lessonProvider.loadLessons(classId: _cls.id);
    await classProvider.loadClasses();
    if (!mounted) return;
    TrainingClass? updatedClass;
    for (final item in classProvider.classes) {
      if (item.id == _cls.id) {
        updatedClass = item;
        break;
      }
    }
    final nextClass = updatedClass;
    if (nextClass != null) {
      setState(() => _cls = nextClass);
    }
    messenger.showSnackBar(const SnackBar(content: Text('已取消打卡')));
  }

  Lesson? _nextScheduledLesson(List<Lesson> lessons) {
    final now = DateTime.now();
    for (final lesson in lessons) {
      if (lesson.status == LessonStatus.scheduled &&
          !lesson.scheduledDate.isBefore(now)) {
        return lesson;
      }
    }
    return null;
  }

  void _showCheckinDialog() {
    final lessonProvider = context.read<LessonProvider>();
    final classLessons =
        lessonProvider.lessons
            .where((lesson) => lesson.classId == _cls.id)
            .toList()
          ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    final lesson = _nextScheduledLesson(classLessons);
    if (lesson == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('暂无可打卡的待上课课次')));
      return;
    }
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const StickerIcon(
          icon: Icons.stars_rounded,
          backgroundColor: AppTheme.accent,
          size: 62,
        ),
        title: const Text('确认上课打卡？'),
        content: Text(
          '${formatDateChinese(lesson.scheduledDate)} ${formatTime(lesson.scheduledDate)}\n确认后将记录为已上课。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final classProvider = context.read<ClassProvider>();
              final navigator = Navigator.of(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              final success = await lessonProvider.checkinLesson(lesson.id);
              if (!success) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text(lessonProvider.error ?? '打卡失败')),
                );
                return;
              }
              await lessonProvider.loadLessons(classId: _cls.id);
              await classProvider.loadClasses();
              if (!mounted) return;
              TrainingClass? updatedClass;
              for (final item in classProvider.classes) {
                if (item.id == _cls.id) {
                  updatedClass = item;
                  break;
                }
              }
              final nextClass = updatedClass;
              if (nextClass != null) {
                setState(() => _cls = nextClass);
              }
              navigator.pop();
              messenger.showSnackBar(const SnackBar(content: Text('打卡成功')));
            },
            child: const Text('确认打卡'),
          ),
        ],
      ),
    );
  }

  void _showLeaveSheet() {
    var reason = '身体不适';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const StickerIcon(
                        icon: Icons.event_busy_rounded,
                        backgroundColor: AppTheme.warning,
                        size: 48,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '申请请假',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '没关系，成长偶尔也需要休息。',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  StickerCard(
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.sand,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.palette_rounded,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${_cls.className}\n${formatDateChinese(DateTime.now())} 18:30',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('请假原因', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    children: ['身体不适', '家庭出游', '临时有事']
                        .map(
                          (item) => SoftChip(
                            label: item,
                            selected: reason == item,
                            onTap: () => setSheetState(() => reason = item),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '温馨提示：请假申请通过后，本节课时将自动顺延至课程结束后的下个周期，不会损失课时费。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final lessonProvider = context
                                .read<LessonProvider>();
                            final navigator = Navigator.of(sheetContext);
                            final messenger = ScaffoldMessenger.of(context);
                            await lessonProvider.createLesson(
                              classId: _cls.id,
                              scheduledDate: DateTime.now(),
                            );
                            if (!mounted) return;
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(content: Text('请假申请成功，课时已自动顺延')),
                            );
                          },
                          child: const Text('确认请假'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  _cls.className,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: const Text('管理班级设置'),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              _option(Icons.edit_note_rounded, '编辑班级', () => _openClassForm()),
              _option(
                Icons.autorenew_rounded,
                '续费/续班',
                () => _openClassForm(renew: true),
              ),
              _option(
                _cls.status == ClassStatus.paused
                    ? Icons.play_circle_rounded
                    : Icons.pause_circle_rounded,
                _cls.status == ClassStatus.paused ? '恢复课程' : '暂停课程',
                _togglePause,
              ),
              _option(Icons.delete_outline_rounded, '删除班级', _confirmDelete),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openClassForm({bool renew = false}) async {
    final result = await Navigator.pushNamed(
      context,
      '/add_class',
      arguments: {'editClass': _cls, if (renew) 'renew': true},
    );
    if (!mounted) return;

    final classProvider = context.read<ClassProvider>();
    final lessonProvider = context.read<LessonProvider>();
    await classProvider.loadClasses();
    await lessonProvider.loadLessons(classId: _cls.id);
    if (!mounted) return;

    final returnedClass = result is TrainingClass && result.id == _cls.id
        ? result
        : null;
    final latestClass = returnedClass ?? _findCurrentClass(classProvider);
    if (latestClass != null) {
      setState(() => _cls = latestClass);
    }
  }

  TrainingClass? _findCurrentClass(ClassProvider provider) {
    for (final item in provider.classes) {
      if (item.id == _cls.id) return item;
    }
    return null;
  }

  Widget _option(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: StickerIcon(
        icon: icon,
        backgroundColor: AppTheme.sage,
        size: 42,
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _togglePause() async {
    final provider = context.read<ClassProvider>();
    if (_cls.status == ClassStatus.paused) {
      await provider.resumeClass(_cls.id);
      setState(() => _cls = _cls.copyWith(status: ClassStatus.active));
    } else {
      await provider.pauseClass(_cls.id);
      setState(() => _cls = _cls.copyWith(status: ClassStatus.paused));
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.delete_forever_rounded,
          color: AppTheme.error,
          size: 44,
        ),
        title: const Text('确认删除该班级？'),
        content: Text('您正在尝试删除 ${_cls.className}。删除后相关课程记录、考勤及剩余课时数据不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('我再想想'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              await context.read<ClassProvider>().deleteClass(_cls.id);
              if (!mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已成功移除班级')));
            },
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
  }
}
