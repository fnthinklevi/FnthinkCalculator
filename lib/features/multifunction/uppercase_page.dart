import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/chinese_upper.dart';
import '../../theme/tokens.dart';
import '../../widgets/numeric_keypad.dart';

class UppercasePage extends StatefulWidget {
  const UppercasePage({super.key});

  @override
  State<UppercasePage> createState() => _UppercasePageState();
}

class _UppercasePageState extends State<UppercasePage> {
  String _input = '1234.56';
  String? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _convert(_input);
  }

  void _onNumericKey(String key) {
    _input = applyNumericKey(
      _input,
      key,
      allowDecimal: true,
      allowNegative: true,
    );
    _convert(_input);
  }

  void _convert(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      setState(() {
        _result = null;
        _error = null;
      });
      return;
    }
    try {
      final converted = ChineseUpper.toRmb(text);
      setState(() {
        _result = converted;
        _error = null;
      });
    } catch (error) {
      setState(() {
        _result = null;
        _error = ChineseUpper.errorMessage(error);
      });
    }
  }

  Future<void> _copy() async {
    final text = _result;
    if (text == null) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('已复制')));
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Scaffold(
      key: const Key('uppercase-page'),
      appBar: AppBar(
        title: const Text('大写数字'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CalcColors.keyBackground(context),
                      borderRadius: BorderRadius.circular(CalcRadius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '金额 / 数字',
                          style: TextStyle(fontSize: 13, color: secondary),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              _input.isEmpty ? '0' : _input,
                              key: const Key('uppercase-input'),
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 30,
                                fontFeatures: CalcText.tabular,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CalcColors.keyBackground(context),
                      borderRadius: BorderRadius.circular(CalcRadius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(
                              '人民币大写',
                              style: TextStyle(fontSize: 13, color: secondary),
                            ),
                            const Spacer(),
                            IconButton(
                              key: const Key('uppercase-copy'),
                              tooltip: '复制',
                              onPressed: _result == null ? null : _copy,
                              icon: Icon(
                                Icons.copy_outlined,
                                size: 18,
                                color: secondary,
                              ),
                            ),
                          ],
                        ),
                        if (_error != null)
                          Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: CalcColors.error,
                            ),
                          )
                        else
                          SelectableText(
                            _result ?? '—',
                            key: const Key('uppercase-result'),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 22,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '使用内置键盘输入；支持负数与小数。金额四舍五入到分，整数部分最多 15 位。',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: secondary,
                    ),
                  ),
                ],
              ),
            ),
            NumericKeypad(onKey: _onNumericKey),
          ],
        ),
      ),
    );
  }
}
