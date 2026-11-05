import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final appTime = File('lib/features/multifunction/time/duration_view.dart')
      .readAsStringSync();
  final appCalculator = File('lib/features/calculator/widgets/calc_keypad.dart')
      .readAsStringSync();
  final widgetProvider = File(
    'android/app/src/main/kotlin/com/fnthink/FnthinkCalculator/widget/CalculatorWidgetProvider.kt',
  ).readAsStringSync();
  final widgetMath = File(
    'android/app/src/main/kotlin/com/fnthink/FnthinkCalculator/widget/WidgetMath.kt',
  ).readAsStringSync();
  final settingsRepository = File('lib/app/settings_repository.dart')
      .readAsStringSync();

  test('时间计算：应用与组件都提供加减乘除与等号', () {
    for (final id in const [
      'duration-key-add',
      'duration-key-subtract',
      'duration-key-multiply',
      'duration-key-divide',
      'duration-key-equals',
    ]) {
      expect(appTime, contains(id), reason: '应用时间键盘缺少 $id');
    }
    for (final token in const [
      'key("+", "+"',
      'key("−", "−"',
      'key("×", "×"',
      'key("÷", "÷"',
      'key("=", "="',
    ]) {
      expect(widgetProvider, contains(token), reason: '组件时间键盘缺少 $token');
    }
  });

  test('科学计算：应用核心函数在组件中都有对应键', () {
    for (final id in const [
      'sci-sin',
      'sci-cos',
      'sci-tan',
      'sci-log',
      'sci-ln',
      'sci-left-paren',
      'sci-right-paren',
      'sci-sqrt',
      'sci-power',
      'sci-pi',
      'sci-e',
      'key-percent',
      'sci-factorial',
      'sci-reciprocal',
    ]) {
      expect(appCalculator, contains(id), reason: '应用科学键盘缺少 $id');
    }
    for (final token in const [
      'key("sin"',
      'key("cos"',
      'key("tan"',
      'key("ln"',
      'key("lg"',
      'key("√"',
      'key("x²"',
      'key("^"',
      'key("π"',
      'key("e"',
      'key("("',
      'key(")"',
      'key("%"',
      'key("1/x"',
      'key("x!"',
    ]) {
      expect(widgetProvider, contains(token), reason: '组件科学键盘缺少 $token');
    }
    for (final operator in const ["'×'", "'÷'", "'%'", "'!'"]) {
      expect(widgetMath, contains(operator), reason: '组件求值引擎缺少 $operator');
    }
  });

  test('角度单位：应用设置与组件读取同一个键', () {
    expect(settingsRepository, contains('settings.angleUnit.v1'));
    expect(widgetProvider, contains('flutter.settings.angleUnit.v1'));
  });
}
