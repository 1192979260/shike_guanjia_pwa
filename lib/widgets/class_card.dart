import "package:shike_guanjia/models/models.dart";
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'child_avatar.dart';

/// Card widget for a training class
class ClassCard extends StatelessWidget {
  final TrainingClass cls;
  final VoidCallback onTap;
  final String? childName;

  const ClassCard({
    super.key,
    required this.cls,
    required this.onTap,
    this.childName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = cls.totalHours > 0 ? cls.usedHours / cls.totalHours : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: childName != null
            ? ChildAvatar(name: childName!)
            : const Icon(Icons.school, color: AppTheme.primary, size: 24),
        title: Text(
          cls.className,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${cls.institutionName} · ${cls.courseName}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            _buildProgress(theme, progress),
            const SizedBox(height: 4),
            Text(
              '剩余 ${cls.remainingHours}/${cls.totalHours} 课时 · ¥${cls.feePerHour.toStringAsFixed(0)}/课时',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cls.remainingHours <= 3
                    ? AppTheme.error
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        trailing: _buildStatusChip(theme),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProgress(ThemeData theme, double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: AppTheme.surfaceAlt,
        valueColor: AlwaysStoppedAnimation<Color>(
          progress >= 1.0 ? AppTheme.textTertiary : AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    String label = '';
    Color bgColor = Colors.grey;
    Color textColor = Colors.white;

    switch (cls.status) {
      case ClassStatus.active:
        label = '进行中';
        bgColor = const Color(0xFFE8F5E9);
        textColor = AppTheme.success;
        break;
      case ClassStatus.paused:
        label = '已暂停';
        bgColor = const Color(0xFFFFF3E0);
        textColor = AppTheme.warning;
        break;
      case ClassStatus.ended:
        label = '已结束';
        bgColor = const Color(0xFFF5F5F5);
        textColor = AppTheme.textTertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
