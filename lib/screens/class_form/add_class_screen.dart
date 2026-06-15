import "package:shike_guanjia/models/models.dart";
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/class_provider.dart';
import '../../themes/app_theme.dart';
import '../../widgets/design/sticker_widgets.dart';

class AddClassScreen extends StatefulWidget {
  final TrainingClass? editClass;
  final bool renew;

  const AddClassScreen({super.key, this.editClass, this.renew = false});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _institutionCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  final _teacherCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '20');
  final _usedHoursCtrl = TextEditingController(text: '0');
  final _feeCtrl = TextEditingController();
  DateTime _startDate = DateTime.now();
  final Set<int> _daysOfWeek = {6};
  final Map<int, LessonTimeSlot> _timeSlots = {
    6: const LessonTimeSlot(
      dayOfWeek: 6,
      startHour: 10,
      startMinute: 30,
      endHour: 12,
      endMinute: 0,
    ),
  };
  String? _childId;

  @override
  void initState() {
    super.initState();
    final cls = widget.editClass;
    if (cls != null) {
      _institutionCtrl.text = cls.institutionName;
      _classCtrl.text = widget.renew ? '${cls.className} 续班' : cls.className;
      _courseCtrl.text = cls.courseName;
      _teacherCtrl.text = cls.teacherName ?? '';
      _phoneCtrl.text = cls.teacherPhone ?? '';
      _hoursCtrl.text = cls.totalHours.toString();
      _usedHoursCtrl.text = widget.renew ? '0' : cls.usedHours.toString();
      _feeCtrl.text = cls.totalFee.toStringAsFixed(0);
      _startDate = cls.startTime;
      _daysOfWeek
        ..clear()
        ..addAll(
          cls.recurringRule.daysOfWeek.isNotEmpty
              ? cls.recurringRule.daysOfWeek
              : [6],
        );
      _timeSlots
        ..clear()
        ..addEntries(
          _buildInitialTimeSlots(
            cls,
          ).map((slot) => MapEntry(slot.dayOfWeek, slot)),
        );
      _childId = cls.childId;
    }
  }

  @override
  void dispose() {
    _institutionCtrl.dispose();
    _classCtrl.dispose();
    _courseCtrl.dispose();
    _teacherCtrl.dispose();
    _phoneCtrl.dispose();
    _hoursCtrl.dispose();
    _usedHoursCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final children = context.read<ChildProvider>().children;
    final childId =
        _childId ?? (children.isNotEmpty ? children.first.id : null);
    if (childId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先添加宝贝')));
      return;
    }

    final provider = context.read<ClassProvider>();
    final totalHours = int.tryParse(_hoursCtrl.text.trim()) ?? 0;
    final usedHours = int.tryParse(_usedHoursCtrl.text.trim()) ?? 0;
    final totalFee = double.tryParse(_feeCtrl.text.trim()) ?? 0;
    if (usedHours < 0 || usedHours > totalHours) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('历史已消耗课时必须在 0 到总课时之间')));
      return;
    }
    if (_daysOfWeek.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请至少选择一个每周上课日')));
      return;
    }
    final daysOfWeek = _daysOfWeek.toList()..sort();
    final timeSlots = [
      for (final day in daysOfWeek) _timeSlots[day] ?? _defaultTimeSlot(day),
    ];
    for (final slot in timeSlots) {
      if (slot.endMinutes <= slot.startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_weekdayLabel(slot.dayOfWeek)}结束时间必须晚于开始时间'),
          ),
        );
        return;
      }
    }
    final rule = RecurringRule(
      type: RecurringRuleType.weekly,
      daysOfWeek: daysOfWeek,
      timeSlots: timeSlots,
    );
    final startTime = _firstMatchingLessonTime(_startDate, timeSlots);

    final edit = widget.editClass;
    TrainingClass? savedClass;
    try {
      if (edit != null && !widget.renew) {
        savedClass = await provider.updateClass(
          edit.copyWith(
            childId: childId,
            institutionName: _institutionCtrl.text.trim(),
            className: _classCtrl.text.trim(),
            courseName: _courseCtrl.text.trim(),
            teacherName: _teacherCtrl.text.trim().isEmpty
                ? null
                : _teacherCtrl.text.trim(),
            teacherPhone: _phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim(),
            totalHours: totalHours,
            usedHours: usedHours,
            remainingHours: totalHours - usedHours,
            totalFee: totalFee,
            startTime: startTime,
            recurringRule: rule,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        savedClass = await provider.addClass(
          childId: childId,
          institutionName: _institutionCtrl.text.trim(),
          className: _classCtrl.text.trim(),
          courseName: _courseCtrl.text.trim(),
          totalFee: totalFee,
          totalHours: totalHours,
          usedHours: usedHours,
          startTime: startTime,
          recurringRule: rule,
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败：$error')));
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('太棒了！课程已开启')));
    Navigator.pop(context, savedClass);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date != null) setState(() => _startDate = date);
  }

  Future<void> _pickSlotTime(int dayOfWeek, {required bool pickStart}) async {
    final slot = _timeSlots[dayOfWeek] ?? _defaultTimeSlot(dayOfWeek);
    final initialTime = pickStart
        ? TimeOfDay(hour: slot.startHour, minute: slot.startMinute)
        : TimeOfDay(hour: slot.endHour, minute: slot.endMinute);
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (time == null) return;

    setState(() {
      _timeSlots[dayOfWeek] = pickStart
          ? slot.copyWith(startHour: time.hour, startMinute: time.minute)
          : slot.copyWith(endHour: time.hour, endMinute: time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final children = context.watch<ChildProvider>().children;
    if (_childId == null && children.isNotEmpty) _childId = children.first.id;
    final theme = Theme.of(context);

    return Scaffold(
      body: OrganicBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        widget.editClass == null || widget.renew
                            ? '新建班级'
                            : '编辑班级',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StickerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.school_rounded, '基本信息'),
                      if (children.isNotEmpty) ...[
                        DropdownButtonFormField<String>(
                          initialValue: _childId,
                          decoration: const InputDecoration(
                            labelText: '所属宝贝',
                            prefixIcon: Icon(Icons.child_care_rounded),
                          ),
                          items: children
                              .map(
                                (child) => DropdownMenuItem(
                                  value: child.id,
                                  child: Text(child.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _childId = value),
                        ),
                        const SizedBox(height: 14),
                      ],
                      _field(_institutionCtrl, '机构名称', Icons.apartment_rounded),
                      _field(_classCtrl, '班级名称', Icons.groups_rounded),
                      _field(_courseCtrl, '课程名称', Icons.palette_rounded),
                      _field(
                        _teacherCtrl,
                        '老师姓名（选填）',
                        Icons.person_rounded,
                        required: false,
                      ),
                      _field(
                        _phoneCtrl,
                        '老师电话（选填）',
                        Icons.call_rounded,
                        required: false,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StickerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.payments_rounded, '课时与费用'),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              _hoursCtrl,
                              '总课时',
                              Icons.timelapse_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              _feeCtrl,
                              '总费用',
                              Icons.currency_yen_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _field(
                        _usedHoursCtrl,
                        '历史已消耗课时',
                        Icons.history_edu_rounded,
                        required: false,
                        keyboardType: TextInputType.number,
                      ),
                      Text(
                        '仅用于初始化剩余课时，不生成本月课次，也不计入本月消费。补打卡请按实际上课日期录入。',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StickerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.event_repeat_rounded, '开课与排课'),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const StickerIcon(
                          icon: Icons.calendar_today_rounded,
                          backgroundColor: AppTheme.sage,
                          size: 42,
                        ),
                        title: const Text('第一节课日期'),
                        subtitle: Text(
                          '${_startDate.year}年${_startDate.month}月${_startDate.day}日',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        children: List.generate(7, (index) {
                          final day = index == 0 ? 0 : index;
                          const labels = [
                            '周日',
                            '周一',
                            '周二',
                            '周三',
                            '周四',
                            '周五',
                            '周六',
                          ];
                          return SoftChip(
                            label: labels[day],
                            selected: _daysOfWeek.contains(day),
                            onTap: () => setState(() {
                              if (_daysOfWeek.contains(day)) {
                                _daysOfWeek.remove(day);
                                _timeSlots.remove(day);
                              } else {
                                _daysOfWeek.add(day);
                                _timeSlots.putIfAbsent(
                                  day,
                                  () => _defaultTimeSlot(day),
                                );
                              }
                            }),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      ...(_daysOfWeek.toList()..sort()).map(
                        (day) => _timeSlotTile(
                          _timeSlots[day] ?? _defaultTimeSlot(day),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _addNextWeekdaySlot,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('添加上课时间点'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: context.watch<ClassProvider>().isLoading
                      ? null
                      : _save,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('完成并开启课程'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: AppTheme.sage,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '开启后，系统将自动为课程计划预留日历入口',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          StickerIcon(icon: icon, backgroundColor: AppTheme.primary, size: 42),
          const SizedBox(width: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _timeSlotTile(LessonTimeSlot slot) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.oat),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _weekdayLabel(slot.dayOfWeek),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _pickSlotTime(slot.dayOfWeek, pickStart: true),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text('开始 ${_slotStartText(slot)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _pickSlotTime(slot.dayOfWeek, pickStart: false),
                    icon: const Icon(Icons.stop_rounded),
                    label: Text('结束 ${_slotEndText(slot)}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addNextWeekdaySlot() {
    for (var day = 0; day < 7; day++) {
      if (!_daysOfWeek.contains(day)) {
        setState(() {
          _daysOfWeek.add(day);
          _timeSlots[day] = _defaultTimeSlot(day);
        });
        return;
      }
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('一周 7 天都已经添加了')));
  }

  List<LessonTimeSlot> _buildInitialTimeSlots(TrainingClass cls) {
    if (cls.recurringRule.timeSlots.isNotEmpty) {
      return cls.recurringRule.timeSlots;
    }
    final days = cls.recurringRule.daysOfWeek.isNotEmpty
        ? cls.recurringRule.daysOfWeek
        : [6];
    return [
      for (final day in days)
        LessonTimeSlot(
          dayOfWeek: day,
          startHour: cls.startTime.hour,
          startMinute: cls.startTime.minute,
          endHour: cls.startTime.add(const Duration(hours: 1)).hour,
          endMinute: cls.startTime.add(const Duration(hours: 1)).minute,
        ),
    ];
  }

  LessonTimeSlot _defaultTimeSlot(int dayOfWeek) {
    return LessonTimeSlot(
      dayOfWeek: dayOfWeek,
      startHour: 10,
      startMinute: 30,
      endHour: 12,
      endMinute: 0,
    );
  }

  DateTime _combineDateAndSlot(DateTime date, LessonTimeSlot slot) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      slot.startHour,
      slot.startMinute,
    );
  }

  DateTime _firstMatchingLessonTime(DateTime date, List<LessonTimeSlot> slots) {
    final sortedSlots = [...slots]
      ..sort((a, b) {
        final dayCompare = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (dayCompare != 0) return dayCompare;
        return a.startMinutes.compareTo(b.startMinutes);
      });
    final startDay = DateTime(date.year, date.month, date.day);
    for (var offset = 0; offset < 7; offset++) {
      final candidate = startDay.add(Duration(days: offset));
      final dayOfWeek = candidate.weekday == DateTime.sunday
          ? 0
          : candidate.weekday;
      for (final slot in sortedSlots) {
        if (slot.dayOfWeek == dayOfWeek) {
          return _combineDateAndSlot(candidate, slot);
        }
      }
    }
    return _combineDateAndSlot(startDay, sortedSlots.first);
  }

  String _weekdayLabel(int dayOfWeek) {
    const labels = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return labels[dayOfWeek];
  }

  String _slotStartText(LessonTimeSlot slot) =>
      _formatClock(slot.startHour, slot.startMinute);

  String _slotEndText(LessonTimeSlot slot) =>
      _formatClock(slot.endHour, slot.endMinute);

  String _formatClock(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: required
            ? (value) =>
                  value == null || value.trim().isEmpty ? '请填写$label' : null
            : null,
      ),
    );
  }
}
