import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shike_guanjia/models/models.dart';
import 'package:shike_guanjia/providers/providers.dart';
import 'package:shike_guanjia/widgets/design/sticker_widgets.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('主题与皮肤')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                provider.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          for (final skin in ThemeSkin.values) ...[
            _ThemeCard(
              skin: skin,
              selected: provider.skin == skin,
              saving: provider.isSaving && provider.skin == skin,
              onTap: () => context.read<ThemeProvider>().setSkin(skin),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.skin,
    required this.selected,
    required this.saving,
    required this.onTap,
  });

  final ThemeSkin skin;
  final bool selected;
  final bool saving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(skin);
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: StickerCard(
        child: Row(
          children: [
            _Swatches(colors: colors),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skin.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(_subtitleFor(skin)),
                ],
              ),
            ),
            if (saving)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (selected)
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  List<Color> _colorsFor(ThemeSkin skin) {
    switch (skin) {
      case ThemeSkin.warm:
        return const [Color(0xFFC66B3D), Color(0xFF8B9D83), Color(0xFFF9F1E3)];
      case ThemeSkin.fresh:
        return const [Color(0xFF2F8F83), Color(0xFF5B9BD5), Color(0xFFFFFFFF)];
      case ThemeSkin.classic:
        return const [Color(0xFF4D5C7A), Color(0xFF8A6F4D), Color(0xFFF4F5F7)];
    }
  }

  String _subtitleFor(ThemeSkin skin) {
    switch (skin) {
      case ThemeSkin.warm:
        return '当前默认暖色主题';
      case ThemeSkin.fresh:
        return '清爽、轻亮、对比更柔和';
      case ThemeSkin.classic:
        return '稳重、克制、适合高频记录';
    }
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 44,
      child: Stack(
        children: [
          for (var i = 0; i < colors.length; i++)
            Positioned(
              left: i * 18,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
