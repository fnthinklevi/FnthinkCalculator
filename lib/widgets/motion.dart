import 'package:flutter/material.dart';

import '../theme/motion.dart';

class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.trigger,
    this.duration = CalcMotion.standard,
    this.curve = CalcMotion.enter,
    this.offset = Offset.zero,
    this.scale = 1,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final Object? trigger;
  final Duration duration;
  final Curve curve;
  final Offset offset;
  final double scale;
  final Alignment alignment;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didUpdateWidget(FadeSlideIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.trigger != widget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    final animation = _controller.drive(CurveTween(curve: widget.curve));
    Widget result = AnimatedBuilder(
      animation: animation,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        alwaysIncludeSemantics: true,
        child: child,
      ),
    );
    if (widget.scale != 1) {
      result = ScaleTransition(
        scale: animation.drive(Tween<double>(begin: widget.scale, end: 1)),
        alignment: widget.alignment,
        child: result,
      );
    }
    if (widget.offset != Offset.zero) {
      result = SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: widget.offset, end: Offset.zero),
        ),
        child: result,
      );
    }
    return result;
  }
}
