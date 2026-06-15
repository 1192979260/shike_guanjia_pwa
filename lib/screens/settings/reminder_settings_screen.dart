import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/providers/providers.dart';
import 'package:shike_guanjia/services/reminder_service.dart';
import 'package:shike_guanjia/widgets/design/sticker_widgets.dart';

class ReminderSettingsScreen extends StatelessWidget {
  const ReminderSettingsScreen({super.key});

  static const advanceOptions = [15, 30, 60, 120, 1440];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();
    final settings = provider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('上课提醒')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          if (provider.error != null)
            _InlineNotice(
              icon: Icons.info_rounded,
              text: provider.error!,
              color: Theme.of(context).colorScheme.error,
            ),
          StickerCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('开启上课提醒'),
                  subtitle: const Text('根据课表在上课前提醒'),
                  value: settings.enabled,
                  onChanged: (value) =>
                      _update(context, settings.copyWith(enabled: value)),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('提醒今日课次'),
                  value: settings.includeTodayLessons,
                  onChanged: settings.enabled
                      ? (value) => _update(
                          context,
                          settings.copyWith(includeTodayLessons: value),
                        )
                      : null,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('提醒补课课次'),
                  value: settings.includeMakeupLessons,
                  onChanged: settings.enabled
                      ? (value) => _update(
                          context,
                          settings.copyWith(includeMakeupLessons: value),
                        )
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('提前时间', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final minutes in advanceOptions)
                ChoiceChip(
                  label: Text(_advanceLabel(minutes)),
                  selected: settings.advanceMinutes == minutes,
                  onSelected: settings.enabled
                      ? (_) => _update(
                          context,
                          settings.copyWith(advanceMinutes: minutes),
                        )
                      : null,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _PermissionCard(provider: provider),
          if (provider.isSaving || provider.isLoading) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Future<void> _update(BuildContext context, ReminderSettings settings) async {
    await context.read<ReminderProvider>().updateSettings(settings);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('提醒设置已保存')));
    }
  }

  String _advanceLabel(int minutes) {
    switch (minutes) {
      case 15:
        return '15 分钟';
      case 30:
        return '30 分钟';
      case 60:
        return '1 小时';
      case 120:
        return '2 小时';
      case 1440:
        return '1 天';
      default:
        return '$minutes 分钟';
    }
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.provider});

  final ReminderProvider provider;

  @override
  Widget build(BuildContext context) {
    final granted =
        provider.permissionStatus == NotificationPermissionStatus.granted;
    final unknown =
        provider.permissionStatus == NotificationPermissionStatus.unknown;
    return StickerCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          granted
              ? Icons.notifications_active_rounded
              : Icons.notifications_off_rounded,
          color: granted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
        title: Text(granted ? '通知权限已开启' : '通知权限未开启'),
        subtitle: Text(unknown ? '当前平台暂无法读取权限状态' : '权限不影响保存设置'),
        trailing: TextButton(
          onPressed: () => provider.requestPermission(),
          child: Text(granted ? '刷新' : '去开启'),
        ),
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
