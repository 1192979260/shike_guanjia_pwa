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
      final lessonProvider = context.read<LessonProvider>();
      lessonProvider.loadLessons(classId: _cls.id);
      lessonProvider.loadLessonChangeHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final allLessons = lessonProvider.lessons;
    final classLessons = allLessons.where((l) => l.classId == _cls.id).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    final changeRecords = lessonProvider.getLessonChangeRecordsForClass(
      _cls.id,
    );
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
                      for (final lesson
                          in classLessons
                              .where(
                                (l) => l.status == LessonStatus.rescheduled,
                              )
                              .toList()
                              .take(1))
                        _recordRow(
                          Icons.swap_horiz_rounded,
                          '第 ${classLessons.indexOf(lesson) + 1} 课：已调课',
                          lesson.leaveReason ?? '已安排新时间',
                          AppTheme.primary,
                        ),
                    ],
                  ),
                ),
              ],
              const SectionTitle(title: '课次变更记录'),
              StickerCard(
                child: changeRecords.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '暂无课次变更记录',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : Column(
                        children: [
                          for (final record in changeRecords.take(5))
                            _changeRecordRow(record, classLessons),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showLessonChangeSheet,
                      icon: const Icon(Icons.edit_calendar_rounded),
                      label: const Text('课次变更'),
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

  Widget _changeRecordRow(
    LessonChangeRecord record,
    List<Lesson> classLessons,
  ) {
    final newLesson = _lessonById(classLessons, record.newLessonId);
    final isActive = record.status == LessonChangeStatus.active;
    final color = isActive ? AppTheme.primary : AppTheme.textTertiary;
    final newTime = newLesson == null ? '新课次已移除' : _lessonTimeRange(newLesson);
    final statusText = isActive ? '生效中' : '已撤销';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        record.type == LessonChangeType.leave
            ? Icons.event_busy_rounded
            : Icons.swap_horiz_rounded,
        color: color,
      ),
      title: Text(
        '${_changeTypeLabel(record.type)} · ${_changeSourceLabel(record.source)} · $statusText',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        '原：${formatDateChinese(record.originalStartAt)} ${formatTime(record.originalStartAt)}\n新：$newTime'
        '${record.reason == null || record.reason!.isEmpty ? '' : '\n原因：${record.reason}'}',
      ),
      trailing: isActive
          ? TextButton(
              onPressed: () => _confirmCancelLessonChange(record),
              child: const Text('撤销'),
            )
          : const Icon(Icons.check_circle_outline_rounded),
    );
  }

  Lesson? _lessonById(List<Lesson> lessons, String lessonId) {
    for (final lesson in lessons) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }

  String _lessonTimeRange(Lesson lesson) {
    final end =
        lesson.scheduledEndDate ??
        lesson.scheduledDate.add(const Duration(hours: 1));
    return '${formatDateChinese(lesson.scheduledDate)} ${formatTime(lesson.scheduledDate)}-${formatTime(end)}';
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

  Future<void> _confirmCancelLessonChange(LessonChangeRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('撤销课次变更？'),
        content: Text(
          '撤销后原课次会恢复为待上课，${_changeTypeLabel(record.type)}生成的新课次会被移除。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('先不撤销'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认撤销'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final lessonProvider = context.read<LessonProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await lessonProvider.cancelLessonChange(record.id);
    if (!mounted) return;
    if (!success) {
      messenger.showSnackBar(
        SnackBar(content: Text(lessonProvider.error ?? '撤销课次变更失败')),
      );
      return;
    }
    await lessonProvider.loadLessons(classId: _cls.id);
    await lessonProvider.loadLessonChangeHistory();
    if (!mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('已撤销课次变更')));
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

  void _showLessonChangeSheet() {
    final lessonProvider = context.read<LessonProvider>();
    final classLessons =
        lessonProvider.lessons
            .where(
              (lesson) =>
                  lesson.classId == _cls.id &&
                  lesson.status == LessonStatus.scheduled,
            )
            .toList()
          ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    final initialLesson = _nextScheduledLesson(classLessons);
    if (initialLesson == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('暂无可变更的待上课课次')));
      return;
    }

    Lesson selectedLesson = initialLesson;
    Duration lessonDuration(Lesson lesson) {
      final end = lesson.scheduledEndDate;
      if (end == null || !end.isAfter(lesson.scheduledDate)) {
        return const Duration(hours: 1);
      }
      return end.difference(lesson.scheduledDate);
    }

    var type = LessonChangeType.leave;
    var source = LessonChangeSource.student;
    var reason = '';
    var newStart = selectedLesson.scheduledDate.add(const Duration(days: 7));
    var newEnd = newStart.add(lessonDuration(selectedLesson));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> pickDate() async {
            final date = await showDatePicker(
              context: context,
              initialDate: newStart,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 540)),
            );
            if (date == null || !context.mounted) return;
            setSheetState(() {
              newStart = DateTime(
                date.year,
                date.month,
                date.day,
                newStart.hour,
                newStart.minute,
              );
              newEnd = DateTime(
                date.year,
                date.month,
                date.day,
                newEnd.hour,
                newEnd.minute,
              );
            });
          }

          Future<void> pickStartTime() async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(newStart),
            );
            if (time == null) return;
            final duration = newEnd.isAfter(newStart)
                ? newEnd.difference(newStart)
                : lessonDuration(selectedLesson);
            setSheetState(() {
              newStart = DateTime(
                newStart.year,
                newStart.month,
                newStart.day,
                time.hour,
                time.minute,
              );
              newEnd = newStart.add(duration);
            });
          }

          Future<void> pickEndTime() async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(newEnd),
            );
            if (time == null) return;
            setSheetState(() {
              newEnd = DateTime(
                newStart.year,
                newStart.month,
                newStart.day,
                time.hour,
                time.minute,
              );
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
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
                              '课次变更',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '请假或临时调课后，新课次会参与提醒和打卡。',
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
                            '${_cls.className}\n原课次：${_lessonTimeRange(selectedLesson)}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('选择原课次', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedLesson.id,
                    items: [
                      for (final lesson in classLessons)
                        DropdownMenuItem(
                          value: lesson.id,
                          child: Text(
                            '${formatDateChinese(lesson.scheduledDate)} ${formatTime(lesson.scheduledDate)}',
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      final next = classLessons.firstWhere(
                        (lesson) => lesson.id == value,
                      );
                      setSheetState(() {
                        selectedLesson = next;
                        newStart = next.scheduledDate.add(
                          const Duration(days: 7),
                        );
                        newEnd = newStart.add(lessonDuration(next));
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('变更类型', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: LessonChangeType.values
                        .map(
                          (item) => SoftChip(
                            label: _changeTypeLabel(item),
                            selected: type == item,
                            onTap: () => setSheetState(() => type = item),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('原因归因', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: LessonChangeSource.values
                        .map(
                          (item) => SoftChip(
                            label: _changeSourceLabel(item),
                            selected: source == item,
                            onTap: () => setSheetState(() => source = item),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('新上课时段', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: pickDate,
                        icon: const Icon(Icons.calendar_month_rounded),
                        label: Text(formatDateChinese(newStart)),
                      ),
                      OutlinedButton.icon(
                        onPressed: pickStartTime,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(formatTime(newStart)),
                      ),
                      OutlinedButton.icon(
                        onPressed: pickEndTime,
                        icon: const Icon(Icons.stop_rounded),
                        label: Text(formatTime(newEnd)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '原因说明（可选）',
                      hintText: '例如：老师临时有事、孩子身体不适',
                    ),
                    onChanged: (value) => reason = value.trim(),
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
                            final navigator = Navigator.of(sheetContext);
                            final messenger = ScaffoldMessenger.of(context);
                            if (!newEnd.isAfter(newStart)) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('结束时间必须晚于开始时间')),
                              );
                              return;
                            }
                            final success = await lessonProvider.changeLesson(
                              lessonId: selectedLesson.id,
                              type: type,
                              source: source,
                              newScheduledDate: newStart,
                              newScheduledEndDate: newEnd,
                              reason: reason.isEmpty ? null : reason,
                            );
                            if (!mounted) return;
                            if (!success) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    lessonProvider.error ?? '课次变更失败',
                                  ),
                                ),
                              );
                              return;
                            }
                            await lessonProvider.loadLessons(classId: _cls.id);
                            await lessonProvider.loadLessonChangeHistory();
                            if (!mounted) return;
                            navigator.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('${_changeTypeLabel(type)}成功'),
                              ),
                            );
                          },
                          child: const Text('确认变更'),
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

  String _changeTypeLabel(LessonChangeType type) {
    switch (type) {
      case LessonChangeType.leave:
        return '孩子请假';
      case LessonChangeType.reschedule:
        return '临时调课';
    }
  }

  String _changeSourceLabel(LessonChangeSource source) {
    switch (source) {
      case LessonChangeSource.student:
        return '孩子原因';
      case LessonChangeSource.teacher:
        return '老师原因';
      case LessonChangeSource.institution:
        return '机构调课';
      case LessonChangeSource.holiday:
        return '节假日';
      case LessonChangeSource.other:
        return '其他';
    }
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
