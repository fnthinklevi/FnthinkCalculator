import 'package:flutter/material.dart';

import '../../app/settings_controller.dart';
import '../../theme/tokens.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('设置'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _sectionTitle(context, '外观'),
              _ChoiceTile(
                key: const Key('settings-theme-system'),
                title: '跟随系统',
                subtitle: '根据系统深浅色自动切换',
                selected: settings.themeMode == ThemeMode.system,
                onTap: () => settings.themeMode = ThemeMode.system,
              ),
              _ChoiceTile(
                key: const Key('settings-theme-light'),
                title: '浅色',
                selected: settings.themeMode == ThemeMode.light,
                onTap: () => settings.themeMode = ThemeMode.light,
              ),
              _ChoiceTile(
                key: const Key('settings-theme-dark'),
                title: '深色',
                selected: settings.themeMode == ThemeMode.dark,
                onTap: () => settings.themeMode = ThemeMode.dark,
              ),
              const SizedBox(height: 12),
              _sectionTitle(context, '按键'),
              SwitchListTile(
                key: const Key('settings-haptics'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: const Text('按键震动'),
                subtitle: const Text('按下按键时触发轻震动'),
                value: settings.haptics,
                onChanged: (value) => settings.haptics = value,
              ),
              const SizedBox(height: 12),
              _sectionTitle(context, '计算'),
              _ChoiceTile(
                key: const Key('settings-angle-degrees'),
                title: '角度制',
                subtitle: '三角函数按角度计算',
                selected: settings.angleUnit == AngleUnit.degrees,
                onTap: () => settings.angleUnit = AngleUnit.degrees,
              ),
              _ChoiceTile(
                key: const Key('settings-angle-radians'),
                title: '弧度制',
                subtitle: '三角函数按弧度计算',
                selected: settings.angleUnit == AngleUnit.radians,
                onTap: () => settings.angleUnit = AngleUnit.radians,
              ),
              const SizedBox(height: 24),
              Divider(color: CalcColors.divider(context)),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: const Text('版本'),
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(color: CalcColors.secondaryText(context)),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: const Text('数据保存'),
                subtitle: const Text('历史记录与设置仅保存在本机'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: CalcColors.secondaryText(context),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: selected
          ? const Icon(Icons.check, color: CalcColors.orange, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
