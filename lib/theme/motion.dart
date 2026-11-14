import 'package:flutter/material.dart';

abstract final class CalcMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration standard = Duration(milliseconds: 180);
  static const Duration slow = Duration(milliseconds: 260);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve move = Curves.easeInOutCubic;

  static Duration resolve(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

class CalcPageTransitionsBuilder extends PageTransitionsBuilder {
  const CalcPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final position = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: CalcMotion.enter)).animate(animation);
    final opacity = Tween<double>(
      begin: 0.92,
      end: 1,
    ).chain(CurveTween(curve: CalcMotion.enter)).animate(animation);
    final previousPosition = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.18, 0),
    ).chain(CurveTween(curve: CalcMotion.enter)).animate(secondaryAnimation);
    return SlideTransition(
      position: position,
      child: FadeTransition(
        opacity: opacity,
        child: SlideTransition(position: previousPosition, child: child),
      ),
    );
  }
}
