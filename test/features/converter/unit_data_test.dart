import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/math/calc_value.dart';
import 'package:fnthink_calculator/core/math/formatter.dart';
import 'package:fnthink_calculator/core/math/rational.dart';
import 'package:fnthink_calculator/features/converter/unit_data.dart';

void main() {
  UnitDef unit(UnitCategory category, String id) {
    return category.units.firstWhere((unit) => unit.id == id);
  }

  BigRational convert(
    UnitCategory category,
    String value,
    String from,
    String to,
  ) {
    return category.convert(
      BigRational.parse(value),
      unit(category, from),
      unit(category, to),
    );
  }

  String display(BigRational value) {
    return const NumberFormatter().format(RationalValue(value)).text;
  }

  test('长度换算', () {
    expect(display(convert(UnitData.length, '1', 'm', 'cm')), '100');
    expect(display(convert(UnitData.length, '1', 'inch', 'cm')), '2.54');
    expect(display(convert(UnitData.length, '1', 'mile', 'km')), '1.609344');
    expect(display(convert(UnitData.length, '1', 'm', 'mm')), '1,000');
  });

  test('面积与体积换算', () {
    final mu = convert(UnitData.area, '1', 'mu', 'm2');
    final formatted = const NumberFormatter().format(RationalValue(mu));
    expect(formatted.text, '666.666666667');
    expect(formatted.approximate, isTrue);

    expect(display(convert(UnitData.volume, '1', 'l', 'ml')), '1,000');
    expect(display(convert(UnitData.volume, '1', 'm3', 'l')), '1,000');
  });

  test('温度仿射换算', () {
    expect(display(convert(UnitData.temperature, '100', 'c', 'f')), '212');
    expect(display(convert(UnitData.temperature, '32', 'f', 'c')), '0');
    expect(display(convert(UnitData.temperature, '-40', 'c', 'f')), '-40');
    expect(display(convert(UnitData.temperature, '0', 'c', 'k')), '273.15');
    expect(display(convert(UnitData.temperature, '0', 'k', 'c')), '-273.15');
  });

  test('速度、时间与重量换算', () {
    expect(display(convert(UnitData.speed, '36', 'kmh', 'mps')), '10');
    expect(display(convert(UnitData.time, '1', 'h', 'min')), '60');
    expect(display(convert(UnitData.time, '1', 'year', 'd')), '365');
    expect(display(convert(UnitData.weight, '1', 'kg', 'jin')), '2');
    expect(display(convert(UnitData.weight, '1', 'lb', 'kg')), '0.45359237');
  });

  test('所有类别往返换算保持精确', () {
    final value = BigRational.parse('123.456');
    for (final category in UnitData.categories) {
      final from = category.units[category.defaultFromIndex];
      final to = category.units[category.defaultToIndex];
      final converted = category.convert(value, from, to);
      final roundTrip = category.convert(converted, to, from);
      expect(roundTrip, value, reason: category.name);
    }
  });

  test('单位数据包含 7 个类别', () {
    expect(UnitData.categories, hasLength(7));
    expect(UnitData.byId('length').name, '长度');
    expect(UnitData.byId('temperature').note, contains('摄氏度'));
  });
}
