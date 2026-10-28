import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: CalcColors.orange,
        brightness: brightness,
        surface: isDark ? CalcColors.darkBg : CalcColors.lightBg,
      ).copyWith(
        primary: CalcColors.orange,
        secondary: CalcColors.orange,
        error: CalcColors.error,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: isDark ? CalcColors.darkBg : CalcColors.lightBg,
    canvasColor: isDark ? CalcColors.darkBg : CalcColors.lightBg,
    dividerColor: isDark ? CalcColors.darkDivider : CalcColors.lightDivider,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: isDark ? CalcColors.darkText : CalcColors.lightText,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: CalcColors.orange,
      selectionColor: Color(0x33FF6A00),
      selectionHandleColor: CalcColors.orange,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: isDark ? CalcColors.darkKey : Colors.white,
      textStyle: TextStyle(
        color: isDark ? CalcColors.darkText : CalcColors.lightText,
        fontSize: 15,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CalcRadius.card),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? CalcColors.darkKey : const Color(0xFF222222),
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: DividerThemeData(
      color: isDark ? CalcColors.darkDivider : CalcColors.lightDivider,
      thickness: 1,
      space: 1,
    ),
  );
}
