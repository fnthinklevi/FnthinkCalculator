import 'package:flutter/material.dart';

import '../../../theme/motion.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/motion.dart';
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
              FadeSlideIn(
                key: ValueKey(entry.createdAt),
                duration: CalcMotion.standard,
                offset: const Offset(0, 0.4),
                child: _HistoryLine(entry: entry),
              ),
            FadeSlideIn(
              key: const ValueKey('display-main'),
              trigger: controller.mode,
              duration: CalcMotion.standard,
              offset: const Offset(0, 0.06),
              scale: 0.98,
              child: _buildMainLine(context),
            ),
            if (controller.showPreview)
              FadeSlideIn(
                key: const ValueKey('display-preview'),
                duration: CalcMotion.standard,
                offset: const Offset(0, 0.25),
                scale: 0.98,
                child: Padding(
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
              ),
            if (controller.uppercaseVisible &&
                controller.uppercaseText.isNotEmpty)
              FadeSlideIn(
                key: const ValueKey('display-uppercase'),
                duration: CalcMotion.slow,
                offset: const Offset(0, 0.2),
                child: Padding(
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
          blink: controller.caretBlinking,
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
              child: _CommittedExpressionLine(
                expression: expression,
                style: TextStyle(
                  fontSize: 24,
                  height: 1.2,
                  color: secondary,
                  fontFeatures: CalcText.tabular,
                ),
                onTapIndex: isError
                    ? null
                    : (index) =>
                          controller.editCommittedExpression(caret: index),
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

class _CommittedExpressionLine extends StatelessWidget {
  const _CommittedExpressionLine({
    required this.expression,
    required this.style,
    required this.onTapIndex,
  });

  final String expression;
  final TextStyle style;
  final ValueChanged<int>? onTapIndex;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final callback = onTapIndex;
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: expression, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '…',
          textScaler: textScaler,
        )..layout(maxWidth: constraints.maxWidth);
        final left = constraints.maxWidth - painter.width;
        final text = SizedBox(
          width: constraints.maxWidth,
          height: painter.height,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              expression,
              key: const Key('calc-committed-expression'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        );
        if (callback == null) return text;
        return Semantics(
          button: true,
          label: '编辑算式 $expression',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final dx = (details.localPosition.dx - left).clamp(
                0.0,
                painter.width,
              );
              final position = painter.getPositionForOffset(
                Offset(dx, details.localPosition.dy),
              );
              callback(position.offset.clamp(0, expression.length));
            },
            child: text,
          ),
        );
      },
    );
  }
}

class CaretText extends StatefulWidget {
  const CaretText({
    super.key,
    required this.text,
    required this.caret,
    required this.onCaretChanged,
    required this.color,
    this.textKey,
    this.blink = false,
  });

  final String text;
  final int caret;
  final ValueChanged<int> onCaretChanged;
  final Color color;
  final Key? textKey;
  final bool blink;

  @override
  State<CaretText> createState() => _CaretTextState();
}

class _CaretTextState extends State<CaretText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.blink) {
      _blinkController.repeat();
    }
  }

  @override
  void didUpdateWidget(CaretText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blink == oldWidget.blink) return;
    if (widget.blink) {
      _blinkController.repeat();
    } else {
      _blinkController.stop();
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final display = widget.text.isEmpty ? '0' : widget.text;
    final baseStyle = TextStyle(
      fontSize: CalcText.expression,
      height: 1.08,
      fontWeight: FontWeight.w400,
      color: widget.color,
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
        final caretIndex = widget.text.isEmpty
            ? display.length
            : widget.caret.clamp(0, display.length);
        final caretOffset = painter.getOffsetForCaret(
          TextPosition(offset: caretIndex),
          Rect.zero,
        );

        Widget caret = Container(
          width: 4,
          height: fontSize * 0.94,
          color: CalcColors.orange,
        );
        if (widget.blink) {
          caret = AnimatedBuilder(
            animation: _blinkController,
            builder: (context, child) => Opacity(
              opacity: _blinkController.value < 0.5 ? 1 : 0,
              child: child,
            ),
            child: caret,
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final dx = (details.localPosition.dx - left).clamp(0.0, textWidth);
            final position = painter.getPositionForOffset(
              Offset(dx, details.localPosition.dy),
            );
            widget.onCaretChanged(position.offset.clamp(0, widget.text.length));
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
                    key: widget.textKey,
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
                  child: caret,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
