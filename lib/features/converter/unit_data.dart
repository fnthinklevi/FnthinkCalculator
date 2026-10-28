import 'package:flutter/material.dart';

import '../../core/math/rational.dart';

class UnitDef {
  UnitDef({
    required this.id,
    required this.name,
    required this.symbol,
    required this.toBase,
    required this.fromBase,
  });

  factory UnitDef.linear({
    required String id,
    required String name,
    required String symbol,
    required BigRational factor,
  }) {
    return UnitDef(
      id: id,
      name: name,
      symbol: symbol,
      toBase: (value) => value * factor,
      fromBase: (value) => value / factor,
    );
  }

  final String id;
  final String name;
  final String symbol;
  final BigRational Function(BigRational value) toBase;
  final BigRational Function(BigRational value) fromBase;
}

class UnitCategory {
  UnitCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.units,
    required this.defaultFromIndex,
    required this.defaultToIndex,
    this.note,
  });

  final String id;
  final String name;
  final IconData icon;
  final List<UnitDef> units;
  final int defaultFromIndex;
  final int defaultToIndex;
  final String? note;

  BigRational convert(BigRational value, UnitDef from, UnitDef to) {
    return to.fromBase(from.toBase(value));
  }
}

abstract final class UnitData {
  static UnitDef _u(String id, String name, String symbol, BigRational factor) {
    return UnitDef.linear(id: id, name: name, symbol: symbol, factor: factor);
  }

  static final length = UnitCategory(
    id: 'length',
    name: '长度',
    icon: Icons.straighten,
    defaultFromIndex: 1,
    defaultToIndex: 3,
    units: [
      _u('km', '千米', 'km', BigRational.fromInt(1000)),
      _u('m', '米', 'm', BigRational.one),
      _u('dm', '分米', 'dm', BigRational.fromInt(1, 10)),
      _u('cm', '厘米', 'cm', BigRational.fromInt(1, 100)),
      _u('mm', '毫米', 'mm', BigRational.fromInt(1, 1000)),
      _u('um', '微米', 'μm', BigRational.fromInt(1, 1000000)),
      _u('li', '里', '里', BigRational.fromInt(500)),
      _u('zhang', '丈', '丈', BigRational.fromInt(10, 3)),
      _u('chi', '尺', '尺', BigRational.fromInt(1, 3)),
      _u('cun', '寸', '寸', BigRational.fromInt(1, 30)),
      _u('mile', '英里', 'mi', BigRational.parse('1609.344')),
      _u('yard', '码', 'yd', BigRational.parse('0.9144')),
      _u('foot', '英尺', 'ft', BigRational.parse('0.3048')),
      _u('inch', '英寸', 'in', BigRational.parse('0.0254')),
      _u('nautical', '海里', 'nmi', BigRational.fromInt(1852)),
    ],
  );

  static final area = UnitCategory(
    id: 'area',
    name: '面积',
    icon: Icons.crop_square,
    defaultFromIndex: 2,
    defaultToIndex: 4,
    note: '亩按 1 亩 = 2000/3 平方米换算。',
    units: [
      _u('km2', '平方千米', 'km²', BigRational.fromInt(1000000)),
      _u('ha', '公顷', 'ha', BigRational.fromInt(10000)),
      _u('m2', '平方米', 'm²', BigRational.one),
      _u('dm2', '平方分米', 'dm²', BigRational.fromInt(1, 100)),
      _u('cm2', '平方厘米', 'cm²', BigRational.fromInt(1, 10000)),
      _u('mm2', '平方毫米', 'mm²', BigRational.fromInt(1, 1000000)),
      _u('mu', '亩', '亩', BigRational.fromInt(2000, 3)),
      _u('acre', '英亩', 'ac', BigRational.parse('4046.8564224')),
      _u('mile2', '平方英里', 'mi²', BigRational.parse('2589988.110336')),
      _u('foot2', '平方英尺', 'ft²', BigRational.parse('0.09290304')),
      _u('inch2', '平方英寸', 'in²', BigRational.parse('0.00064516')),
      _u('yard2', '平方码', 'yd²', BigRational.parse('0.83612736')),
    ],
  );

  static final volume = UnitCategory(
    id: 'volume',
    name: '体积',
    icon: Icons.view_in_ar,
    defaultFromIndex: 1,
    defaultToIndex: 2,
    note: '美制与英制加仑分别按各自标准定义。',
    units: [
      _u('m3', '立方米', 'm³', BigRational.one),
      _u('l', '升', 'L', BigRational.fromInt(1, 1000)),
      _u('ml', '毫升', 'mL', BigRational.fromInt(1, 1000000)),
      _u('cm3', '立方厘米', 'cm³', BigRational.fromInt(1, 1000000)),
      _u('dm3', '立方分米', 'dm³', BigRational.fromInt(1, 1000)),
      _u('gal_us', '加仑（美）', 'gal(US)', BigRational.parse('0.003785411784')),
      _u('gal_uk', '加仑（英）', 'gal(UK)', BigRational.parse('0.00454609')),
      _u('ft3', '立方英尺', 'ft³', BigRational.parse('0.028316846592')),
      _u('in3', '立方英寸', 'in³', BigRational.parse('0.000016387064')),
    ],
  );

  static UnitCategory _temperature() {
    final fahrenheitOffset = BigRational.fromInt(32);
    final kelvinOffset = BigRational.parse('273.15');
    final rankineOffset = BigRational.parse('491.67');
    final fiveNinths = BigRational.fromInt(5, 9);
    final nineFifths = BigRational.fromInt(9, 5);

    return UnitCategory(
      id: 'temperature',
      name: '温度',
      icon: Icons.thermostat,
      defaultFromIndex: 0,
      defaultToIndex: 1,
      note: '温度按摄氏度、华氏度、开尔文、兰氏度标准定义换算。',
      units: [
        UnitDef(
          id: 'c',
          name: '摄氏度',
          symbol: '°C',
          toBase: (value) => value,
          fromBase: (value) => value,
        ),
        UnitDef(
          id: 'f',
          name: '华氏度',
          symbol: '°F',
          toBase: (value) => (value - fahrenheitOffset) * fiveNinths,
          fromBase: (value) => value * nineFifths + fahrenheitOffset,
        ),
        UnitDef(
          id: 'k',
          name: '开尔文',
          symbol: 'K',
          toBase: (value) => value - kelvinOffset,
          fromBase: (value) => value + kelvinOffset,
        ),
        UnitDef(
          id: 'r',
          name: '兰氏度',
          symbol: '°R',
          toBase: (value) => (value - rankineOffset) * fiveNinths,
          fromBase: (value) => (value + kelvinOffset) * nineFifths,
        ),
      ],
    );
  }

  static final temperature = _temperature();

  static final speed = UnitCategory(
    id: 'speed',
    name: '速度',
    icon: Icons.speed,
    defaultFromIndex: 1,
    defaultToIndex: 0,
    units: [
      _u('mps', '米/秒', 'm/s', BigRational.one),
      _u('kmh', '千米/小时', 'km/h', BigRational.fromInt(5, 18)),
      _u('mph', '英里/小时', 'mph', BigRational.parse('0.44704')),
      _u('knot', '节', 'kn', BigRational.fromInt(463, 900)),
      _u('fps', '英尺/秒', 'ft/s', BigRational.parse('0.3048')),
    ],
  );

  static final time = UnitCategory(
    id: 'time',
    name: '时间',
    icon: Icons.schedule,
    defaultFromIndex: 5,
    defaultToIndex: 4,
    note: '时间换算按 1 月 = 30 天、1 年 = 365 天计算。',
    units: [
      _u('ns', '纳秒', 'ns', BigRational.fromInt(1, 1000000000)),
      _u('us', '微秒', 'μs', BigRational.fromInt(1, 1000000)),
      _u('ms', '毫秒', 'ms', BigRational.fromInt(1, 1000)),
      _u('s', '秒', 's', BigRational.one),
      _u('min', '分钟', 'min', BigRational.fromInt(60)),
      _u('h', '小时', 'h', BigRational.fromInt(3600)),
      _u('d', '天', 'd', BigRational.fromInt(86400)),
      _u('week', '周', 'wk', BigRational.fromInt(604800)),
      _u('month', '月', 'mo', BigRational.fromInt(2592000)),
      _u('year', '年', 'yr', BigRational.fromInt(31536000)),
    ],
  );

  static final weight = UnitCategory(
    id: 'weight',
    name: '重量',
    icon: Icons.monitor_weight_outlined,
    defaultFromIndex: 1,
    defaultToIndex: 5,
    units: [
      _u('t', '吨', 't', BigRational.fromInt(1000)),
      _u('kg', '千克', 'kg', BigRational.one),
      _u('g', '克', 'g', BigRational.fromInt(1, 1000)),
      _u('mg', '毫克', 'mg', BigRational.fromInt(1, 1000000)),
      _u('ug', '微克', 'μg', BigRational.fromInt(1, 1000000000)),
      _u('jin', '斤', '斤', BigRational.fromInt(1, 2)),
      _u('liang', '两', '两', BigRational.fromInt(1, 20)),
      _u('lb', '磅', 'lb', BigRational.parse('0.45359237')),
      _u('oz', '盎司', 'oz', BigRational.parse('0.028349523125')),
      _u('stone', '英石', 'st', BigRational.parse('6.35029318')),
    ],
  );

  static final categories = [
    length,
    area,
    volume,
    temperature,
    speed,
    time,
    weight,
  ];

  static UnitCategory byId(String id) {
    return categories.firstWhere((category) => category.id == id);
  }
}
