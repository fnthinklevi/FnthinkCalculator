import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/page_header.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _sections = <(String, String)>[
    ('一、适用范围', '本政策适用于幻念计算器 Android 应用。使用本应用前，请阅读并理解本政策。'),
    (
      '二、我们收集的信息',
      '本应用不要求注册账号，不收集姓名、手机号、通讯录、位置、相机、麦克风、设备标识符或使用统计；不包含广告或第三方统计 SDK。',
    ),
    ('三、本地数据', '计算历史、设置和汇率缓存保存在应用私有存储中。卸载应用或清除应用数据会删除这些内容，我们无法远程访问或恢复。'),
    (
      '四、联网说明',
      '仅汇率换算会访问公开汇率接口（open.er-api.com，失败时回退 api.frankfurter.dev），请求只包含基础货币代码，不包含个人身份信息。其余计算、语音和历史功能均可离线使用。',
    ),
    ('五、语音播报', '按键与结果语音为构建期生成并随安装包分发的离线短音频。运行时不录音、不上传音频，也不调用系统 TTS。'),
    ('六、第三方服务', '除公开汇率接口外，本应用不集成第三方分析、广告或账号 SDK。公开汇率接口的请求处理受其自身隐私政策约束。'),
    (
      '七、您的权利',
      '您可以在设置中清空历史记录、修改设置，或卸载应用以停止使用并删除本地数据。由于本应用不建立账号，我们无法按账号检索或删除数据，因为不存在可供检索的账号数据。',
    ),
    ('八、未成年人', '本应用不面向未成年人收集个人信息；如未成年人使用，建议在监护人指导下阅读本政策。'),
    ('九、政策更新', '功能或数据处理方式发生变化时，我们会更新本政策并在版本记录中说明；重大变化会在应用内提示。'),
    ('十、联系我们', '如对本政策有疑问，可通过项目仓库的 Issue 反馈。'),
    ('十一、同意', '首次启动时点击“同意”即表示您已阅读并同意本政策。您可以在设置页底部随时查看本政策；如不同意，请停止使用并退出应用。'),
  ];

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Scaffold(
      key: const Key('privacy-policy-page'),
      backgroundColor: CalcColors.displayBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: '隐私政策',
              titleKey: const Key('privacy-policy-title'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                key: const Key('privacy-policy-content'),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                children: [
                  Text(
                    '幻念计算器隐私政策',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '更新日期：2026-10-31 · 生效日期：2026-10-31',
                    style: TextStyle(fontSize: 13, color: secondary),
                  ),
                  const SizedBox(height: 18),
                  for (final (title, body) in _sections) ...[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: secondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
