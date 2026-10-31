import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../core/voice/voice_clips.dart';
import '../../core/voice/voice_service.dart';
import 'calculator_controller.dart';
import 'widgets/calc_display.dart';
import 'widgets/calc_keypad.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key, this.controller});

  final CalculatorController? controller;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  late final CalculatorController _controller;
  late final bool _ownsController;
  final VoiceService _voice = VoiceService();
  late CalculatorMode _lastMode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CalculatorController();
    _ownsController = widget.controller == null;
    _lastMode = _controller.mode;
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = AppScope.of(context);
    _controller.setAngleUnit(settings.angleUnit);
    _controller.setPercentMode(settings.percentMode);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _voice.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  bool get _voiceEnabled => AppScope.maybeOf(context)?.voice ?? false;

  void _onControllerChanged() {
    final mode = _controller.mode;
    if (mode != _lastMode && _voiceEnabled) {
      if (mode == CalculatorMode.result) {
        _voice.speak(
          VoiceClips.forResult(
            _controller.mainText,
            approximate: _controller.mainApproximate,
          ),
        );
      } else if (mode == CalculatorMode.error) {
        _voice.speak(const ['error']);
      }
    }
    _lastMode = mode;
  }

  void _onAnnounce(String semantic) {
    if (!_voiceEnabled) return;
    final clips = VoiceClips.forSemantic(semantic);
    if (clips.isNotEmpty) _voice.speak(clips);
  }

  Future<void> _copy() async {
    final text = _controller.copyText;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('已复制')));
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

  Future<void> _showDisplayMenu(Offset globalPosition) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<String>(
          key: const Key('display-menu-copy'),
          value: 'copy',
          enabled: _controller.copyText.isNotEmpty,
          child: const Text('复制'),
        ),
        PopupMenuItem<String>(
          key: const Key('display-menu-uppercase'),
          value: 'uppercase',
          enabled: _controller.canConvertToUppercase,
          child: const Text('转换为大写数字'),
        ),
      ],
    );
    if (selected == 'copy') {
      await _copy();
    } else if (selected == 'uppercase') {
      _controller.showUppercase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const Key('calculator-page'),
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final landscape = constraints.maxWidth > constraints.maxHeight;
          final maxWidth = landscape ? 960.0 : 600.0;
          final width = constraints.maxWidth > maxWidth
              ? maxWidth
              : constraints.maxWidth;
          return Center(
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final display = CalcDisplay(
                    controller: _controller,
                    onLongPressMain: _showDisplayMenu,
                  );
                  final keypad = CalcKeypad(
                    controller: _controller,
                    clearLabel: _controller.clearLabel,
                    onClearLongPress: _confirmClearHistory,
                    onAnnounce: _onAnnounce,
                  );

                  if (landscape) {
                    return Row(
                      key: const Key('landscape-layout'),
                      children: [
                        Expanded(flex: 5, child: display),
                        const VerticalDivider(width: 1),
                        Expanded(flex: 5, child: keypad),
                      ],
                    );
                  }

                  return Column(
                    key: const Key('portrait-layout'),
                    children: [
                      Expanded(flex: 4, child: display),
                      Expanded(flex: 6, child: keypad),
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
