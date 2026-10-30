import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../calculator_controller.dart';
import '../history_entry.dart';

class CalcDisplay extends StatelessWidget {
  const CalcDisplay({
    super.key,
    required this.controller,
    required this.onLongPressMain,
  });

  final CalculatorController controller;
  final ValueChanged<Offset> onLongPressMain;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);

    return GestureDetector(
      key: const Key('calc-display'),
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) => onLongPressMain(details.globalPosition),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final entry in controller.recentHistory)
              _HistoryLine(entry: entry),
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
                    fontSize: CalcText.preview,
                    color: secondary,
                    fontFeatures: CalcText.tabular,
                  ),
                ),
              ),
            if (controller.uppercaseVisible &&
                controller.uppercaseText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  controller.uppercaseText,
                  key: const Key('calc-uppercase-text'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: CalcText.resultSecondary,
                    height: 1.25,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        ),
      ),
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
        ),
      );
    }

    final isError = controller.isErrorMode;
    final secondary = CalcColors.secondaryText(context);
    final expression = controller.committedExpression;
    final style = TextStyle(
      fontSize: isError ? 52 : CalcText.displayLarge,
      height: 1.08,
      fontWeight: FontWeight.w400,
      color: color,
      fontFeatures: CalcText.tabular,
    );

    return Semantics(
      liveRegion: true,
      label: isError
          ? '错误 ${controller.errorMessage}'
          : '结果 ${controller.mainText}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (expression.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                expression,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 24,
                  height: 1.2,
                  color: secondary,
                  fontFeatures: CalcText.tabular,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    isError ? '= ' : (controller.mainApproximate ? '≈ ' : '= '),
                    style: style.copyWith(
                      fontSize: isError ? 44 : 44,
                      color: secondary,
                    ),
                  ),
                  Text(
                    isError ? controller.errorMessage : controller.mainText,
                    key: isError
                        ? const Key('calc-error-text')
                        : const Key('calc-result-text'),
                    maxLines: 1,
                    style: style,
                  ),
                ],
              ),
            ),
          ),
        ],
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
        fontSize: CalcText.history,
        color: CalcColors.tertiaryText(context),
        height: 1.45,
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
    this.textKey,
  });

  final String text;
  final int caret;
  final ValueChanged<int> onCaretChanged;
  final Color color;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    final display = text.isEmpty ? '0' : text;
    final baseStyle = TextStyle(
      fontSize: CalcText.expression,
      height: 1.08,
      fontWeight: FontWeight.w400,
      color: color,
      fontFeatures: CalcText.tabular,
    );

    final textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        var fontSize = CalcText.expression;
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
            CalcText.expression,
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
                    constraints.maxWidth - 4,
                  ),
                  top: caretOffset.dy + fontSize * 0.06,
                  child: Container(
                    width: 4,
                    height: fontSize * 0.94,
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
