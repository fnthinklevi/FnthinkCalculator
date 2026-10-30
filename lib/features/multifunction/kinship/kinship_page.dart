import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../core/utils/kinship.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/calc_key.dart';
import '../../../widgets/page_header.dart';

class KinshipPage extends StatefulWidget {
  const KinshipPage({super.key});

  @override
  State<KinshipPage> createState() => _KinshipPageState();
}

class _KinshipPageState extends State<KinshipPage> {
  final List<String> _chain = [];
  bool _reverse = false;
  bool _committed = false;

  String get _description => Kinship.describe(_chain);

  String? get _title =>
      _reverse ? Kinship.reciprocal(_chain) : Kinship.direct(_chain);

  void _append(String token) {
    if (_chain.length >= 8) return;
    setState(() {
      _chain.add(token);
      _committed = false;
    });
  }

  void _clear() {
    setState(() {
      _chain.clear();
      _reverse = false;
      _committed = false;
    });
  }

  void _backspace() {
    if (_chain.isEmpty) return;
    setState(() {
      _chain.removeLast();
      _committed = false;
    });
  }

  void _reverseMode() {
    if (_chain.isEmpty) return;
    setState(() {
      _reverse = !_reverse;
      _committed = true;
    });
  }

  void _commit() {
    if (_chain.isEmpty) return;
    setState(() => _committed = true);
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    final title = _title ?? '暂时无法识别';
    return Scaffold(
      key: const Key('kinship-page'),
      backgroundColor: CalcColors.displayBackground(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: '亲戚称呼计算',
              titleKey: const Key('kinship-title'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _committed
                          ? _description
                          : (_chain.isEmpty ? '我' : _description),
                      key: const Key('kinship-description'),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: _committed ? 24 : 40,
                        height: 1.25,
                        color: _committed
                            ? secondary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (!_committed && _chain.isNotEmpty)
                      Text(
                        title,
                        key: const Key('kinship-preview'),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 24, color: secondary),
                      ),
                    if (_committed) ...[
                      if (_reverse)
                        Text(
                          'TA称呼我',
                          style: TextStyle(fontSize: 15, color: secondary),
                        ),
                      Text(
                        title,
                        key: const Key('kinship-result'),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 44,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _KinshipKeypad(
              reverseEnabled: _chain.isNotEmpty,
              onToken: _append,
              onClear: _clear,
              onBackspace: _backspace,
              onReverse: _reverseMode,
              onEquals: _commit,
            ),
          ],
        ),
      ),
    );
  }
}

class _KinshipKeypad extends StatelessWidget {
  const _KinshipKeypad({
    required this.reverseEnabled,
    required this.onToken,
    required this.onClear,
    required this.onBackspace,
    required this.onReverse,
    required this.onEquals,
  });

  final bool reverseEnabled;
  final ValueChanged<String> onToken;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onReverse;
  final VoidCallback onEquals;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.maybeOf(context);
    void press(VoidCallback action) {
      if (settings?.haptics ?? true) HapticFeedback.lightImpact();
      action();
    }

    Widget key({
      required String id,
      required String semantic,
      String? label,
      IconData? icon,
      bool operator = false,
      bool equals = false,
      required VoidCallback onPressed,
    }) {
      return CalcKey(
        keyId: id,
        semanticLabel: semantic,
        label: label,
        icon: icon,
        isOperator: operator,
        isEquals: equals,
        fontSize: 26,
        onPressed: () => press(onPressed),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 10.0;
          final diameter = math
              .min(
                (constraints.maxWidth - 56 - gap * 3) / 4,
                (constraints.maxHeight - gap * 3) / 4,
              )
              .clamp(36.0, 82.0);
          Widget row(List<Widget> keys) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < keys.length; index++) ...[
                  SizedBox.square(dimension: diameter, child: keys[index]),
                  if (index != keys.length - 1) const SizedBox(width: gap),
                ],
              ],
            );
          }

          final reverseWidth = diameter * 3 + gap * 2;
          return Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                row([
                  key(
                    id: 'kinship-key-夫',
                    semantic: '夫',
                    label: '夫',
                    onPressed: () => onToken('夫'),
                  ),
                  key(
                    id: 'kinship-key-妻',
                    semantic: '妻',
                    label: '妻',
                    onPressed: () => onToken('妻'),
                  ),
                  key(
                    id: 'kinship-clear',
                    semantic: '清空',
                    label: 'C',
                    operator: true,
                    onPressed: onClear,
                  ),
                  key(
                    id: 'kinship-backspace',
                    semantic: '退格',
                    icon: Icons.backspace_outlined,
                    operator: true,
                    onPressed: onBackspace,
                  ),
                ]),
                const SizedBox(height: gap),
                row([
                  key(
                    id: 'kinship-key-父',
                    semantic: '父',
                    label: '父',
                    onPressed: () => onToken('父'),
                  ),
                  key(
                    id: 'kinship-key-母',
                    semantic: '母',
                    label: '母',
                    onPressed: () => onToken('母'),
                  ),
                  key(
                    id: 'kinship-key-子',
                    semantic: '子',
                    label: '子',
                    onPressed: () => onToken('子'),
                  ),
                  key(
                    id: 'kinship-key-女',
                    semantic: '女',
                    label: '女',
                    onPressed: () => onToken('女'),
                  ),
                ]),
                const SizedBox(height: gap),
                row([
                  key(
                    id: 'kinship-key-兄',
                    semantic: '兄',
                    label: '兄',
                    onPressed: () => onToken('兄'),
                  ),
                  key(
                    id: 'kinship-key-弟',
                    semantic: '弟',
                    label: '弟',
                    onPressed: () => onToken('弟'),
                  ),
                  key(
                    id: 'kinship-key-姐',
                    semantic: '姐',
                    label: '姐',
                    onPressed: () => onToken('姐'),
                  ),
                  key(
                    id: 'kinship-key-妹',
                    semantic: '妹',
                    label: '妹',
                    onPressed: () => onToken('妹'),
                  ),
                ]),
                const SizedBox(height: gap),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: reverseWidth,
                      height: diameter,
                      child: Semantics(
                        button: true,
                        enabled: reverseEnabled,
                        label: '互查',
                        excludeSemantics: true,
                        child: GestureDetector(
                          key: const Key('kinship-reverse'),
                          behavior: HitTestBehavior.opaque,
                          onTap: reverseEnabled ? () => press(onReverse) : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: CalcColors.keyBackground(context),
                              borderRadius: BorderRadius.circular(diameter / 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '互查',
                              style: TextStyle(
                                fontSize: 22,
                                color: reverseEnabled
                                    ? CalcColors.orange
                                    : CalcColors.tertiaryText(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: gap),
                    SizedBox.square(
                      dimension: diameter,
                      child: key(
                        id: 'kinship-equals',
                        semantic: '等于',
                        label: '=',
                        equals: true,
                        onPressed: onEquals,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
