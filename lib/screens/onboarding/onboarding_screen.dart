import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../themes/app_theme.dart';
import '../../widgets/design/sticker_widgets.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish({bool addChild = false}) async {
    final childProvider = context.read<ChildProvider>();
    final authProvider = context.read<AuthProvider>();
    if (addChild && _nameCtrl.text.trim().isNotEmpty) {
      await childProvider.addChild(
        _nameCtrl.text.trim(),
        int.tryParse(_ageCtrl.text.trim()),
        null,
      );
    }
    await authProvider.setOnboardingDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrganicBackground(
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _page == 0 ? _intro(context) : _addChild(context),
          ),
        ),
      ),
    );
  }

  Widget _intro(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      key: const ValueKey('intro'),
      padding: const EdgeInsets.fromLTRB(24, 42, 24, 28),
      children: [
        Text('欢迎来到 Lesson Butler', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 22),
        _introCard(Icons.auto_stories_rounded, '多娃排课不再乱', '告别混乱的手写日程，轻松管理每个宝贝的兴趣班。'),
        _introCard(Icons.verified_rounded, '剩余课时一眼看', '可视化的进度条提醒，精准掌控剩余课时。'),
        _introCard(Icons.favorite_rounded, '把时间留给陪伴', 'Lesson Butler 帮您打理琐事，您只需享受与孩子共度的时光。'),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: () => setState(() => _page = 1),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('继续探索'),
        ),
        TextButton(onPressed: () => _finish(), child: const Text('跳过引导')),
      ],
    );
  }

  Widget _introCard(IconData icon, String title, String body) {
    return StickerCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StickerIcon(icon: icon, backgroundColor: title.startsWith('多娃') ? AppTheme.sage : title.startsWith('剩余') ? AppTheme.accent : AppTheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addChild(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      key: const ValueKey('child'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      children: [
        IconButton(alignment: Alignment.centerLeft, onPressed: () => setState(() => _page = 0), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        const SizedBox(height: 10),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const StickerIcon(icon: Icons.add_a_photo_rounded, backgroundColor: AppTheme.sage, size: 88),
              Positioned(
                right: -4,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_rounded, size: 16, color: AppTheme.textInverse),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('添加宝贝', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text('添加成功后，就可以为宝贝规划精彩的课程进度。', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 28),
        StickerCard(
          child: Column(
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: '宝贝姓名', hintText: '例如：乐乐', prefixIcon: Icon(Icons.face_rounded)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '宝贝年龄', hintText: '岁', prefixIcon: Icon(Icons.cake_rounded)),
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Expanded(child: SoftChip(label: '小王子', icon: Icons.boy_rounded)),
                  Expanded(child: SoftChip(label: '小公主', icon: Icons.girl_rounded)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        ElevatedButton.icon(
          onPressed: () => _finish(addChild: true),
          icon: const Icon(Icons.check_circle_rounded),
          label: const Text('保存'),
        ),
        TextButton(onPressed: () => _finish(), child: const Text('稍后添加')),
      ],
    );
  }
}
