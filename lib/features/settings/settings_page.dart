import 'package:flutter/material.dart';

import '../../app/settings_controller.dart';
import '../../theme/tokens.dart';
import 'privacy_policy_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return Scaffold(
          key: const Key('settings-page'),
          backgroundColor: CalcColors.displayBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                _Header(onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                    children: [
                      _sectionTitle(context, '百分数加减算法'),
                      const SizedBox(height: 8),
                      _PercentPreview(mode: settings.percentMode),
                      const SizedBox(height: 10),
                      _ChoiceCard(
                        key: const Key('settings-percent-value'),
                        title: '按数值计算',
                        subtitle: '将百分数换算为小数，进行加减计算',
                        selected: settings.percentMode == PercentMode.value,
                        onTap: () => settings.percentMode = PercentMode.value,
                      ),
                      const SizedBox(height: 10),
                      _ChoiceCard(
                        key: const Key('settings-percent-proportion'),
                        title: '按比例计算',
                        subtitle: '将百分数与前序计算结果相乘后，再进行加减计算，常用于折扣优惠的计算',
                        selected:
                            settings.percentMode == PercentMode.proportion,
                        onTap: () =>
                            settings.percentMode = PercentMode.proportion,
                      ),
                      const SizedBox(height: 26),
                      _sectionTitle(context, '设置'),
                      const SizedBox(height: 4),
                      SwitchListTile(
                        key: const Key('settings-angle-switch'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('使用角度'),
                        subtitle: const Text('科学计算器中使用角度替换弧度计算三角函数'),
                        value: settings.angleUnit == AngleUnit.degrees,
                        activeThumbColor: Colors.white,
                        activeTrackColor: CalcColors.blue,
                        onChanged: (value) => settings.angleUnit = value
                            ? AngleUnit.degrees
                            : AngleUnit.radians,
                      ),
                      SwitchListTile(
                        key: const Key('settings-voice'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('语音播报'),
                        subtitle: const Text('按键与结果离线播报（内置短音频）'),
                        value: settings.voice,
                        activeThumbColor: Colors.white,
                        activeTrackColor: CalcColors.blue,
                        onChanged: (value) => settings.voice = value,
                      ),
                      SwitchListTile(
                        key: const Key('settings-haptics'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('按键震动'),
                        subtitle: const Text('按下按键时触发轻震动'),
                        value: settings.haptics,
                        activeThumbColor: Colors.white,
                        activeTrackColor: CalcColors.blue,
                        onChanged: (value) => settings.haptics = value,
                      ),
                      const SizedBox(height: 10),
                      _sectionTitle(context, '深色模式'),
                      _ChoiceRow(
                        key: const Key('settings-theme-system'),
                        title: '跟随系统',
                        selected: settings.themeMode == ThemeMode.system,
                        onTap: () => settings.themeMode = ThemeMode.system,
                      ),
                      _ChoiceRow(
                        key: const Key('settings-theme-light'),
                        title: '浅色',
                        selected: settings.themeMode == ThemeMode.light,
                        onTap: () => settings.themeMode = ThemeMode.light,
                      ),
                      _ChoiceRow(
                        key: const Key('settings-theme-dark'),
                        title: '深色',
                        selected: settings.themeMode == ThemeMode.dark,
                        onTap: () => settings.themeMode = ThemeMode.dark,
                      ),
                      const SizedBox(height: 26),
                      _sectionTitle(context, '关于'),
                      _InfoRow(
                        key: const Key('settings-privacy'),
                        title: '隐私设置',
                        subtitle: '不收集数据；汇率仅用于换算',
                        onTap: () => _showPrivacy(context),
                      ),
                      _InfoRow(
                        title: '版本',
                        trailing: Text(
                          '0.2.01',
                          style: TextStyle(
                            fontSize: 15,
                            color: CalcColors.secondaryText(context),
                          ),
                        ),
                      ),
                      _InfoRow(
                        key: const Key('settings-privacy-policy'),
                        title: '隐私政策',
                        subtitle: '查看完整隐私政策',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PrivacyPolicyPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 15, color: CalcColors.secondaryText(context)),
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('隐私设置'),
        content: const Text(
          '本应用不收集、不上传任何个人数据。\n'
          '历史记录与设置仅保存在本机。\n'
          '汇率换算需要联网，仅向公开汇率接口发送币种代码。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 4,
            child: IconButton(
              key: const Key('settings-back'),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          const Text(
            '计算器',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _PercentPreview extends StatelessWidget {
  const _PercentPreview({required this.mode});

  final PercentMode mode;

  @override
  Widget build(BuildContext context) {
    final result = mode == PercentMode.value ? '100.5' : '150';
    final secondary = CalcColors.secondaryText(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '100+50%',
          style: TextStyle(
            fontSize: 28,
            color: secondary,
            fontFeatures: CalcText.tabular,
          ),
        ),
        Text(
          '= $result',
          key: const Key('settings-percent-preview'),
          style: TextStyle(
            fontSize: 40,
            color: Theme.of(context).colorScheme.onSurface,
            fontFeatures: CalcText.tabular,
          ),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleColor = selected
        ? CalcColors.blue
        : Theme.of(context).colorScheme.onSurface;
    return Material(
      color: CalcColors.keyPressed(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 19,
                        height: 1.3,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check, size: 22, color: CalcColors.blue),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 17))),
            if (selected)
              const Icon(Icons.check, size: 20, color: CalcColors.blue),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: CalcColors.secondaryText(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: CalcColors.secondaryText(context),
              ),
          ],
        ),
      ),
    );
  }
}
