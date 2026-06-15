import 'package:csv/csv.dart';

/// Export class data to CSV string
String exportClassesToCSV(List<Map<String, dynamic>> classes) {
  final columns = [
    '机构名称',
    '班级名称',
    '课程名称',
    '孩子ID',
    '总课时',
    '已上课时',
    '剩余课时',
    '总费用',
    '单次成本',
    '开始日期',
    '状态',
  ];

  final rows = classes.map((c) {
    final totalHours = c['totalHours'] as int;
    final totalFee = c['totalFee'] as double;
    final feePerHour = totalHours > 0 ? totalFee / totalHours : 0.0;

    return [
      c['institutionName'] as String,
      c['className'] as String,
      c['courseName'] as String,
      c['childId'] as String,
      totalHours,
      c['usedHours'] as int,
      c['remainingHours'] as int,
      '¥${feePerHour.toStringAsFixed(0)}',
      '¥${feePerHour.toStringAsFixed(1)}/课时',
      c['startTime'] as String,
      c['status'] as String,
    ];
  }).toList();

  return const ListToCsvConverter().convert([columns, ...rows]);
}

/// Export lesson data to CSV string
String exportLessonsToCSV(List<Map<String, dynamic>> lessons) {
  final columns = [
    '课次ID',
    '班级ID',
    '计划日期',
    '状态',
    '实际日期',
    '打卡时间',
    '补录',
    '课后笔记',
    '请假原因',
  ];

  final rows = lessons.map((l) {
    return [
      l['id'] as String,
      l['classId'] as String,
      l['scheduledDate'] as String,
      l['status'] as String,
      l['actualDate'] as String? ?? '',
      l['checkinTime'] as String? ?? '',
      l['isMakeup'] as bool? ?? false,
      l['notes'] as String? ?? '',
      l['leaveReason'] as String? ?? '',
    ];
  }).toList();

  return const ListToCsvConverter().convert([columns, ...rows]);
}
