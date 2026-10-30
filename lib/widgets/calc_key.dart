import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class CalcKey extends StatefulWidget {
  const CalcKey({
    super.key,
    required this.keyId,
    required this.semanticLabel,
    required this.onPressed,
    this.label,
    this.icon,
    this.isOperator = false,
    this.isEquals = false,
    this.enabled = true,
    this.selected = false,
    this.muted = false,
    this.fontSize = CalcText.key,
    this.onLongPress,
  });

  final String keyId;
  final String semanticLabel;
  final String? label;
  final IconData? icon;
  final bool isOperator;
  final bool isEquals;
  final bool enabled;
  final bool selected;
  final bool muted;
  final double fontSize;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  State<CalcKey> createState() => _CalcKeyState();
}

class _CalcKeyState extends State<CalcKey> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = widget.enabled
        ? (widget.isEquals
              ? (_pressed ? CalcColors.orangePressed : CalcColors.orange)
              : widget.selected
              ? (_pressed
                    ? CalcColors.keyPressed(context)
                    : CalcColors.keyPressed(context))
              : (_pressed
                    ? CalcColors.keyPressed(context)
                    : CalcColors.keyBackground(context)))
        : CalcColors.keyBackground(context);
    final foreground = !widget.enabled
        ? CalcColors.tertiaryText(context)
        : widget.isEquals
        ? Colors.white
        : widget.isOperator
        ? CalcColors.orange
        : widget.muted
        ? (isDark ? CalcColors.darkSecondary : CalcColors.lightSecondary)
        : (isDark ? CalcColors.darkText : CalcColors.lightText);

    return Semantics(
      container: true,
      button: true,
      enabled: widget.enabled,
      selected: widget.selected,
      excludeSemantics: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        key: Key(widget.keyId),
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
        onTapUp: widget.enabled
            ? (_) {
                _setPressed(false);
                widget.onPressed();
              }
            : null,
        onTapCancel: widget.enabled ? () => _setPressed(false) : null,
        onLongPress: widget.enabled && widget.onLongPress != null
            ? () {
                _setPressed(false);
                widget.onLongPress!();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 80),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: widget.icon != null
                ? Icon(
                    widget.icon,
                    size: widget.fontSize + 2,
                    color: foreground,
                  )
                : Text(
                    widget.label ?? '',
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      height: 1,
                      color: foreground,
                      fontWeight: FontWeight.w400,
                      fontFeatures: CalcText.tabular,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
