import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../calculator_controller.dart';
import '../history_entry.dart';

class CalcDisplay extends StatelessWidget {
  const CalcDisplay({
    super.key,
    required this.controller,
    required this.onHistory,
    required this.onCopy,
    required this.onUppercase,
    required this.onClearHistory,
    required this.onLongPressMain,
  });

  final CalculatorController controller;
  final VoidCallback onHistory;
  final VoidCallback onCopy;
  final VoidCallback onUppercase;
  final VoidCallback onClearHistory;
  final VoidCallback onLongPressMain;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 4,
          child: IconButton(
            key: const Key('calc-history'),
            tooltip: '历史记录',
            icon: Icon(Icons.history, size: 22, color: secondary),
            onPressed: onHistory,
          ),
        ),
        Positioned(
          top: 0,
          right: 4,
          child: PopupMenuButton<String>(
            key: const Key('calc-menu'),
            tooltip: '更多',
            icon: Icon(Icons.more_horiz, size: 22, color: secondary),
            onSelected: (value) {
              if (value == 'copy') {
                onCopy();
              } else if (value == 'uppercase') {
                onUppercase();
              } else if (value == 'clear-history') {
                onClearHistory();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'copy',
                enabled: controller.copyText.isNotEmpty,
                child: const Text('复制结果'),
              ),
              PopupMenuItem(
                value: 'uppercase',
                enabled: controller.canConvertToUppercase,
                child: const Text('转中文大写'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'clear-history', child: Text('清空历史')),
            ],
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final entry in controller.recentHistory)
                  _HistoryLine(entry: entry),
                if (controller.isResultMode &&
                    controller.committedExpression.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      controller.committedExpression,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        color: secondary,
                        fontFeatures: CalcText.tabular,
                      ),
                    ),
                  ),
                _buildMainLine(context),
                if (controller.showPreview)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${controller.previewApproximate ? '≈' : '='} ${controller.previewText}',
                      key: const Key('calc-preview-text'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 21,
                        color: secondary,
                        fontFeatures: CalcText.tabular,
                      ),
                    ),
                  ),
                if (controller.isErrorMode)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      controller.errorMessage,
                      key: const Key('calc-error-text'),
                      maxLines: 2,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 15,
                        color: CalcColors.error,
                        height: 1.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainLine(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    if (controller.isInputMode) {
      return Semantics(
        liveRegion: true,
        label:
            '算式 ${controller.expression.isEmpty ? '0' : controller.expression}',
        child: CaretText(
          text: controller.expression,
          caret: controller.caret,
          color: color,
          textKey: const Key('calc-input-text'),
          onCaretChanged: controller.setCaret,
          onLongPress: onLongPressMain,
        ),
      );
    }

    final isError = controller.isErrorMode;
    final text = isError
        ? (controller.expression.isEmpty ? '0' : controller.expression)
        : '${controller.mainApproximate ? '≈ ' : ''}${controller.mainText}';
    final style = TextStyle(
      fontSize: CalcText.displayLarge,
      height: 1.05,
      fontWeight: FontWeight.w400,
      color: color,
      fontFeatures: CalcText.tabular,
    );

    return Semantics(
      liveRegion: true,
      label: isError
          ? '错误 ${controller.errorMessage}'
          : '结果 ${controller.mainText}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: onLongPressMain,
        child: SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              text,
              key: isError
                  ? const Key('calc-error-expression')
                  : const Key('calc-result-text'),
              maxLines: 1,
              style: style,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryLine extends StatelessWidget {
  const _HistoryLine({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${entry.expression} ${entry.approximate ? '≈' : '='} ${entry.resultText}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 13,
        color: CalcColors.secondaryText(context),
        height: 1.5,
        fontFeatures: CalcText.tabular,
      ),
    );
  }
}

class CaretText extends StatelessWidget {
  const CaretText({
    super.key,
    required this.text,
    required this.caret,
    required this.onCaretChanged,
    required this.color,
    this.onLongPress,
    this.textKey,
  });

  final String text;
  final int caret;
  final ValueChanged<int> onCaretChanged;
  final Color color;
  final VoidCallback? onLongPress;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    final display = text.isEmpty ? '0' : text;
    final baseStyle = TextStyle(
      fontSize: CalcText.displayLarge,
      height: 1.05,
      fontWeight: FontWeight.w400,
      color: color,
      fontFeatures: CalcText.tabular,
    );

    final textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        var fontSize = CalcText.displayLarge;
        late TextPainter painter;
        while (true) {
          painter = TextPainter(
            text: TextSpan(
              text: display,
              style: baseStyle.copyWith(fontSize: fontSize),
            ),
            textDirection: TextDirection.ltr,
            maxLines: 1,
            textScaler: textScaler,
          )..layout();
          if (painter.width <= constraints.maxWidth ||
              fontSize <= CalcText.displayMin) {
            break;
          }
          fontSize = (fontSize - 2).clamp(
            CalcText.displayMin,
            CalcText.displayLarge,
          );
        }

        final style = baseStyle.copyWith(fontSize: fontSize);
        final textWidth = painter.width;
        final left = constraints.maxWidth - textWidth;
        final caretIndex = text.isEmpty
            ? display.length
            : caret.clamp(0, display.length);
        final caretOffset = painter.getOffsetForCaret(
          TextPosition(offset: caretIndex),
          Rect.zero,
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: onLongPress,
          onTapDown: (details) {
            final dx = (details.localPosition.dx - left).clamp(0.0, textWidth);
            final position = painter.getPositionForOffset(
              Offset(dx, details.localPosition.dy),
            );
            onCaretChanged(position.offset.clamp(0, text.length));
          },
          child: SizedBox(
            width: constraints.maxWidth,
            height: painter.height,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: left,
                  top: 0,
                  child: Text(
                    display,
                    key: textKey,
                    maxLines: 1,
                    softWrap: false,
                    style: style,
                  ),
                ),
                Positioned(
                  left: (left + caretOffset.dx).clamp(
                    0.0,
                    constraints.maxWidth - 2,
                  ),
                  top: caretOffset.dy + fontSize * 0.08,
                  child: Container(
                    width: 2,
                    height: fontSize * 0.9,
                    color: CalcColors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
