import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../core/utils/chinese_upper.dart';
import 'calculator_controller.dart';
import 'widgets/calc_display.dart';
import 'widgets/calc_keypad.dart';
import 'widgets/history_sheet.dart';
import 'widgets/scientific_panel.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key, this.controller});

  final CalculatorController? controller;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  late final CalculatorController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CalculatorController();
    _ownsController = widget.controller == null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.setAngleUnit(AppScope.of(context).angleUnit);
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _copy() async {
    final text = _controller.copyText;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('已复制')));
  }

  void _showUppercase() {
    final formatted = _controller.activeFormatted;
    if (formatted == null) return;
    final String text;
    try {
      text = ChineseUpper.toRmb(formatted.rawText);
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ChineseUpper.errorMessage(error))));
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('人民币大写'),
          content: SelectableText(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('关闭'),
            ),
            FilledButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: text));
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('已复制')));
              },
              child: const Text('复制'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmClearHistory() async {
    if (_controller.history.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('清空历史记录'),
          content: const Text('确定要清空全部历史记录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('清空'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      _controller.clearHistory();
    }
  }

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.65,
          child: HistorySheet(
            controller: _controller,
            onClearHistory: _confirmClearHistory,
          ),
        );
      },
    );
  }

  void _showActions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('复制结果'),
                enabled: _controller.copyText.isNotEmpty,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _copy();
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('转中文大写'),
                enabled: _controller.canConvertToUppercase,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showUppercase();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const Key('calculator-page'),
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth > 600
              ? 600.0
              : constraints.maxWidth;
          return Center(
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 4,
                        child: CalcDisplay(
                          controller: _controller,
                          onHistory: _showHistory,
                          onCopy: _copy,
                          onUppercase: _showUppercase,
                          onClearHistory: _confirmClearHistory,
                          onLongPressMain: _showActions,
                        ),
                      ),
                      if (_controller.scientificVisible)
                        ScientificPanel(controller: _controller),
                      Expanded(
                        flex: 6,
                        child: CalcKeypad(
                          controller: _controller,
                          clearLabel: _controller.clearLabel,
                          onClearLongPress: _confirmClearHistory,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
