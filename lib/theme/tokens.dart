import 'package:flutter/material.dart';

abstract final class CalcColors {
  static const orange = Color(0xFFFF6900);
  static const orangePressed = Color(0xFFE65F00);

  static const lightBg = Color(0xFFF3F3F3);
  static const lightDisplayBg = Color(0xFFF3F3F3);
  static const lightKey = Color(0xFFFFFFFF);
  static const lightKeyPressed = Color(0xFFEDEDED);
  static const lightText = Color(0xFF000000);
  static const lightSecondary = Color(0xFF8C8C8C);
  static const lightTertiary = Color(0xFFC4C4C4);
  static const lightDivider = Color(0xFFE6E6E6);
  static const lightTrack = Color(0xFFFFFFFF);
  static const lightTrackSelected = Color(0xFFF0F0F0);

  static const darkBg = Color(0xFF000000);
  static const darkDisplayBg = Color(0xFF000000);
  static const darkKey = Color(0xFF1C1C1C);
  static const darkKeyPressed = Color(0xFF2C2C2C);
  static const darkText = Color(0xFFFFFFFF);
  static const darkSecondary = Color(0xFF8E8E8E);
  static const darkTertiary = Color(0xFF4A4A4A);
  static const darkDivider = Color(0xFF2A2A2A);
  static const darkTrack = Color(0xFF1C1C1C);
  static const darkTrackSelected = Color(0xFF333333);

  static const blue = Color(0xFF3478F6);
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

  static Color tertiaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTertiary
      : lightTertiary;

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkDivider
      : lightDivider;

  static Color displayBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkDisplayBg
      : lightDisplayBg;

  static Color track(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTrack : lightTrack;

  static Color trackSelected(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTrackSelected
      : lightTrackSelected;
}

abstract final class CalcSpacing {
  static const double page = 16;
  static const double keyGap = 13;
  static const double keyMargin = 30.5;
  static const double topBarHeight = 56;
  static const double contentMaxWidth = 600;
}

abstract final class CalcRadius {
  static const double key = 22;
  static const double card = 18;
  static const double pill = 999;
}

abstract final class CalcText {
  static const displayLarge = 60.0;
  static const displayMin = 26.0;
  static const expression = 56.0;
  static const resultSecondary = 24.0;
  static const key = 30.0;
  static const keySmall = 20.0;
  static const history = 18.0;
  static const preview = 24.0;

  static const tabular = [FontFeature.tabularFigures()];
}
