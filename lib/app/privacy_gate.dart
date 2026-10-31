import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/settings/privacy_policy_page.dart';
import '../theme/tokens.dart';
import 'app_scope.dart';

class PrivacyGate extends StatefulWidget {
  const PrivacyGate({super.key, required this.child});

  final Widget child;

  @override
  State<PrivacyGate> createState() => _PrivacyGateState();
}

class _PrivacyGateState extends State<PrivacyGate> {
  bool _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checked) return;
    _checked = true;
    final settings = AppScope.of(context);
    if (settings.privacyAccepted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final accepted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PrivacyConsentDialog(
          onViewPolicy: () {
            Navigator.of(dialogContext).push(
              MaterialPageRoute<void>(
                builder: (_) => const PrivacyPolicyPage(),
              ),
            );
          },
          onAgree: () => Navigator.of(dialogContext).pop(true),
          onDisagree: () => Navigator.of(dialogContext).pop(false),
        ),
      );
      if (!mounted) return;
      if (accepted == true) {
        settings.privacyAccepted = true;
      } else if (accepted == false) {
        SystemNavigator.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class PrivacyConsentDialog extends StatelessWidget {
  const PrivacyConsentDialog({
    super.key,
    required this.onViewPolicy,
    required this.onAgree,
    required this.onDisagree,
  });

  final VoidCallback onViewPolicy;
  final VoidCallback onAgree;
  final VoidCallback onDisagree;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.74;
    return PopScope(
      canPop: false,
      child: Dialog(
        key: const Key('privacy-consent-dialog'),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420, maxHeight: maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '隐私政策',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      '欢迎使用幻念计算器！\n\n'
                      '本应用提供标准/科学计算、单位与汇率换算、时间工具及生活计算功能。\n\n'
                      '我们重视您的个人信息保护：本应用不收集、不上传您的个人信息；'
                      '历史记录与设置仅保存在本机；语音播报完全离线；'
                      '仅汇率换算在联网时向公开汇率接口发送币种代码。\n\n'
                      '请阅读并同意《隐私政策》后使用本应用。如不同意，将退出应用。',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: CalcColors.secondaryText(context),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const Key('privacy-view-policy'),
                    onPressed: onViewPolicy,
                    child: const Text('查看完整《隐私政策》'),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('privacy-disagree'),
                        onPressed: onDisagree,
                        child: const Text('不同意'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: const Key('privacy-agree'),
                        onPressed: onAgree,
                        style: FilledButton.styleFrom(
                          backgroundColor: CalcColors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('同意'),
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
}
