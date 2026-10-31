import 'package:flutter/material.dart';

const double kAppMaxWidth = 900;

class AppWideLayout extends StatelessWidget {
  const AppWideLayout({
    super.key,
    required this.child,
    this.maxWidth = kAppMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width <= maxWidth) return child;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          key: const Key('app-width-cap'),
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: child,
          ),
        ),
      ),
    );
  }
}
