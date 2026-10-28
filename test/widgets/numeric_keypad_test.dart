import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/theme/app_theme.dart';
import 'package:fnthink_calculator/widgets/numeric_keypad.dart';

void main() {
  group('applyNumericKey', () {
    test('digits and leading zeros', () {
      expect(
        applyNumericKey('', '1', allowDecimal: true, allowNegative: true),
        '1',
      );
      expect(
        applyNumericKey('1', '0', allowDecimal: true, allowNegative: true),
        '10',
      );
      expect(
        applyNumericKey('0', '5', allowDecimal: true, allowNegative: true),
        '5',
      );
      expect(
        applyNumericKey('-0', '5', allowDecimal: true, allowNegative: true),
        '-5',
      );
      expect(
        applyNumericKey('', '00', allowDecimal: true, allowNegative: true),
        '0',
      );
      expect(
        applyNumericKey('1', '00', allowDecimal: true, allowNegative: true),
        '100',
      );
    });

    test('decimal and sign', () {
      expect(
        applyNumericKey('', '.', allowDecimal: true, allowNegative: true),
        '0.',
      );
      expect(
        applyNumericKey('0.', '5', allowDecimal: true, allowNegative: true),
        '0.5',
      );
      expect(
        applyNumericKey('1.5', '.', allowDecimal: true, allowNegative: true),
        '1.5',
      );
      expect(
        applyNumericKey('1', '.', allowDecimal: false, allowNegative: true),
        '1',
      );
      expect(
        applyNumericKey('5', 'sign', allowDecimal: true, allowNegative: true),
        '-5',
      );
      expect(
        applyNumericKey('-5', 'sign', allowDecimal: true, allowNegative: true),
        '5',
      );
      expect(
        applyNumericKey('', 'sign', allowDecimal: true, allowNegative: true),
        '-0',
      );
      expect(
        applyNumericKey('5', 'sign', allowDecimal: true, allowNegative: false),
        '5',
      );
    });

    test('backspace and clear', () {
      expect(
        applyNumericKey(
          '123',
          'backspace',
          allowDecimal: true,
          allowNegative: true,
        ),
        '12',
      );
      expect(
        applyNumericKey(
          '1',
          'backspace',
          allowDecimal: true,
          allowNegative: true,
        ),
        '',
      );
      expect(
        applyNumericKey(
          '-0',
          'backspace',
          allowDecimal: true,
          allowNegative: true,
        ),
        '',
      );
      expect(
        applyNumericKey(
          '123',
          'clear',
          allowDecimal: true,
          allowNegative: true,
        ),
        '',
      );
    });

    test('digit limit', () {
      const fifteen = '123456789012345';
      expect(
        applyNumericKey(fifteen, '6', allowDecimal: true, allowNegative: true),
        fifteen,
      );
    });
  });

  testWidgets('数字键盘可回调并禁用不允许的键', (tester) async {
    final keys = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
          body: NumericKeypad(
            onKey: keys.add,
            allowDecimal: false,
            allowNegative: false,
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('numeric-key-7')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('numeric-key-dot')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('numeric-key-sign')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('numeric-key-00')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('numeric-key-undo')));
    await tester.pump();
    expect(keys, ['7', '00', 'backspace']);
    expect(find.byType(TextField), findsNothing);
  });
}
