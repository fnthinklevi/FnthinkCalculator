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
  static UnitDef _u(String id, String name, String symbol, String factor) {
    return UnitDef.linear(
      id: id,
      name: name,
      symbol: symbol,
      factor: BigRational.parse(factor),
    );
  }

  static UnitDef _r(
    String id,
    String name,
    String symbol,
    int numerator,
    int denominator,
  ) {
    return UnitDef.linear(
      id: id,
      name: name,
      symbol: symbol,
      factor: BigRational.fromInt(numerator, denominator),
    );
  }

  static final length = UnitCategory(
    id: 'length',
    name: '长度',
    icon: Icons.straighten,
    defaultFromIndex: 2,
    defaultToIndex: 4,
    units: [
      _u('km', '千米', 'km', '1000'),
      _u('gongli', '公里', 'gongli', '1000'),
      _u('m', '米', 'm', '1'),
      _u('dm', '分米', 'dm', '0.1'),
      _u('cm', '厘米', 'cm', '0.01'),
      _u('mm', '毫米', 'mm', '0.001'),
      _u('um', '微米', 'μm', '0.000001'),
      _u('nm', '纳米', 'nm', '1e-9'),
      _u('pm', '皮米', 'pm', '1e-12'),
      _u('li', '里', 'li', '500'),
      _r('zhang', '丈', 'zhang', 10, 3),
      _r('chi', '尺', 'chi', 1, 3),
      _r('cun', '寸', 'cun', 1, 30),
      _r('fen', '分', 'fen', 1, 300),
      _r('lii', '厘', 'lii', 1, 3000),
      _r('hao', '毫', 'hao', 1, 30000),
      _u('nmi', '海里', 'nmi', '1852'),
      _u('mile', '英里', 'mi', '1609.344'),
      _u('yd', '码', 'yd', '0.9144'),
      _u('ft', '英尺', 'ft', '0.3048'),
      _u('inch', '英寸', 'in', '0.0254'),
      _u('ftm', '英寻', 'ftm', '1.8288'),
      _u('fur', '弗隆', 'fur', '201.168'),
      _u('ly', '光年', 'ly', '9.4607304725808e15'),
      _u('au', '天文单位', '⊙', '1.495978707e11'),
      _u('pc', '秒差距', 'pc', '3.0856775814913673e16'),
      _u('ld', '月球距离', 'ld', '384400000'),
    ],
  );

  static final area = UnitCategory(
    id: 'area',
    name: '面积',
    icon: Icons.crop_square,
    defaultFromIndex: 4,
    defaultToIndex: 6,
    note: '亩按 1 亩 = 2000/3 平方米换算。',
    units: [
      _u('km2', '平方千米', 'km²', '1000000'),
      _u('gongli2', '平方公里', 'gongli²', '1000000'),
      _u('ha', '公顷', 'ha', '10000'),
      _u('are', '公亩', 'a', '100'),
      _u('m2', '平方米', 'm²', '1'),
      _u('dm2', '平方分米', 'dm²', '0.01'),
      _u('cm2', '平方厘米', 'cm²', '0.0001'),
      _u('mm2', '平方毫米', 'mm²', '0.000001'),
      _u('um2', '平方微米', 'μm²', '1e-12'),
      _r('mu', '亩', 'mu', 2000, 3),
      _r('qing', '顷', 'qing', 200000, 3),
      _u('acre', '英亩', 'ac', '4046.8564224'),
      _u('mi2', '平方英里', 'mile²', '2589988.110336'),
      _u('yd2', '平方码', 'yd²', '0.83612736'),
      _u('ft2', '平方英尺', 'ft²', '0.09290304'),
      _u('in2', '平方英寸', 'in²', '0.00064516'),
      _r('chi2', '平方尺', 'chi²', 1, 9),
      _r('cun2', '平方寸', 'cun²', 1, 900),
      _u('rd2', '平方竿', 'rd²', '25.29285264'),
    ],
  );

  static final volume = UnitCategory(
    id: 'volume',
    name: '体积',
    icon: Icons.view_in_ar,
    defaultFromIndex: 0,
    defaultToIndex: 6,
    note: '美制与英制加仑分别按各自标准定义。',
    units: [
      _u('m3', '立方米', 'm³', '1'),
      _u('dm3', '立方分米', 'dm³', '0.001'),
      _u('l', '升', 'l', '0.001'),
      _u('dl', '分升', 'dl', '0.0001'),
      _u('cl', '厘升', 'cl', '0.00001'),
      _u('ml', '毫升', 'ml', '0.000001'),
      _u('cm3', '立方厘米', 'cm³', '0.000001'),
      _u('mm3', '立方毫米', 'mm³', '1e-9'),
      _u('um3', '立方微米', 'μm³', '1e-18'),
      _u('hl', '公石', 'hl', '0.1'),
      _u('acft', '亩英尺', 'ac⋅ft', '1233.48183754752'),
      _u('ft3', '立方英尺', 'ft³', '0.028316846592'),
      _u('in3', '立方英寸', 'in³', '0.000016387064'),
      _u('yd3', '立方码', 'yd³', '0.764554857984'),
    ],
  );

  static UnitCategory _temperature() {
    final fahrenheitOffset = BigRational.fromInt(32);
    final kelvinOffset = BigRational.parse('273.15');
    final rankineOffset = BigRational.parse('491.67');
    final fiveNinths = BigRational.fromInt(5, 9);
    final nineFifths = BigRational.fromInt(9, 5);
    final fiveQuarters = BigRational.fromInt(5, 4);
    final fourFifths = BigRational.fromInt(4, 5);

    return UnitCategory(
      id: 'temperature',
      name: '温度',
      icon: Icons.thermostat,
      defaultFromIndex: 0,
      defaultToIndex: 1,
      note: '温度按摄氏度、华氏度、开尔文、兰氏度、列氏度标准定义换算。',
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
        UnitDef(
          id: 're',
          name: '列氏度',
          symbol: '°Re',
          toBase: (value) => value * fiveQuarters,
          fromBase: (value) => value * fourFifths,
        ),
      ],
    );
  }

  static final temperature = _temperature();

  static final speed = UnitCategory(
    id: 'speed',
    name: '速度',
    icon: Icons.speed,
    defaultFromIndex: 0,
    defaultToIndex: 1,
    units: [
      _u('mps', '米/秒', 'm/s', '1'),
      _u('kmps', '千米/秒', 'km/s', '1000'),
      _u('kmh', '千米/小时', 'km/h', '0.277777777777777778'),
      _u('mph', '英里/小时', 'mph', '0.44704'),
      _u('fps', '英尺/秒', 'fps', '0.3048'),
      _u('ips', '英寸/秒', 'ips', '0.0254'),
      _u('knot', '海里/小时', 'kn', '0.514444444444444444'),
      _u('mach', '马赫', 'Ma', '340.3'),
      _u('c', '光速', 'c', '299792458'),
    ],
  );

  static final time = UnitCategory(
    id: 'time',
    name: '时间',
    icon: Icons.schedule,
    defaultFromIndex: 4,
    defaultToIndex: 5,
    note: '1 年按 365 天计算。',
    units: [
      _u('year', '年', 'yr', '31536000'),
      _u('week', '周', 'wk', '604800'),
      _u('d', '天', 'd', '86400'),
      _u('h', '小时', 'hr', '3600'),
      _u('min', '分钟', 'min', '60'),
      _u('s', '秒', 's', '1'),
      _u('ms', '毫秒', 'ms', '0.001'),
      _u('us', '微秒', 'μs', '0.000001'),
      _u('ps', '皮秒', 'ps', '1e-12'),
    ],
  );

  static final weight = UnitCategory(
    id: 'weight',
    name: '重量',
    icon: Icons.monitor_weight_outlined,
    defaultFromIndex: 3,
    defaultToIndex: 7,
    units: [
      _u('t', '吨', 't', '1000'),
      _u('q', '公担', 'q', '100'),
      _u('dan', '担', 'dan', '50'),
      _u('kg', '千克', 'kg', '1'),
      _u('jin', '斤', 'jin', '0.5'),
      _u('liang', '两', 'liang', '0.05'),
      _u('qian', '钱', 'qian', '0.005'),
      _u('g', '克', 'g', '0.001'),
      _u('mg', '毫克', 'mg', '0.000001'),
      _u('ug', '微克', 'μg', '1e-9'),
      _u('ct', '克拉', 'ct', '0.0002'),
      _u('gr', '格令', 'gr', '0.00006479891'),
      _u('dr', '打兰', 'dr', '0.0017718451953125'),
      _u('oz', '盎司', 'oz', '0.028349523125'),
      _u('lb', '磅', 'lb', '0.45359237'),
      _u('st', '英石', 'st', '6.35029318'),
      _u('lt', '长吨', 'l.t', '1016.0469088'),
      _u('st_short', '短吨', 'sh.t', '907.18474'),
      _u('cwt_uk', '英担', 'cwt', '50.80234544'),
      _u('cwt_us', '美担', 'cwt', '45.359237'),
      _u('taijin', '斤(台湾)', 'jin (Taiwan)', '0.6'),
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
