import 'package:flutter/material.dart';

abstract final class CalcColors {
  static const orange = Color(0xFFFF6A00);
  static const orangePressed = Color(0xFFE65F00);

  static const lightBg = Color(0xFFF5F5F5);
  static const lightDisplayBg = Color(0xFFF7F7F7);
  static const lightKey = Color(0xFFFFFFFF);
  static const lightKeyPressed = Color(0xFFE8E8E8);
  static const lightText = Color(0xFF111111);
  static const lightSecondary = Color(0xFF8C8C8C);
  static const lightDivider = Color(0xFFE6E6E6);

  static const darkBg = Color(0xFF111111);
  static const darkDisplayBg = Color(0xFF151515);
  static const darkKey = Color(0xFF1F1F1F);
  static const darkKeyPressed = Color(0xFF2C2C2C);
  static const darkText = Color(0xFFF5F5F5);
  static const darkSecondary = Color(0xFF8E8E8E);
  static const darkDivider = Color(0xFF2A2A2A);

  static const error = Color(0xFFE5484D);

  static Color keyBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkKey : lightKey;

  static Color keyPressed(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkKeyPressed
      : lightKeyPressed;

  static Color secondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkSecondary
      : lightSecondary;

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkDivider
      : lightDivider;

  static Color displayBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkDisplayBg
      : lightDisplayBg;
}

abstract final class CalcSpacing {
  static const double page = 16;
  static const double keyGap = 8;
  static const double topBarHeight = 56;
  static const double contentMaxWidth = 600;
}

abstract final class CalcRadius {
  static const double key = 22;
  static const double card = 18;
  static const double pill = 999;
}

abstract final class CalcText {
  static const displayLarge = 64.0;
  static const displayMin = 28.0;
  static const expression = 30.0;
  static const key = 28.0;
  static const keySmall = 20.0;
  static const history = 14.0;
  static const preview = 22.0;

  static const tabular = [FontFeature.tabularFigures()];
}
