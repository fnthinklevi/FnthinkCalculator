class ProvinceSocialBase {
  const ProvinceSocialBase({
    required this.name,
    required this.averageYuan,
    required this.lowerYuan,
    required this.upperYuan,
  });

  final String name;
  final double averageYuan;
  final double lowerYuan;
  final double upperYuan;

  String get rangeLabel => '基数 ${_group(lowerYuan)}–${_group(upperYuan)} 元';
}

// 2025 社保年度（基于 2024 社平工资），数据来源：人社通公开汇总。
// 个人费率按养老 8% + 医疗 2% + 失业 0.5% 估算，不含公积金。
const provinceSocialBases = <ProvinceSocialBase>[
  ProvinceSocialBase(
    name: '北京',
    averageYuan: 11937,
    lowerYuan: 7162,
    upperYuan: 35811,
  ),
  ProvinceSocialBase(
    name: '天津',
    averageYuan: 8540,
    lowerYuan: 5124,
    upperYuan: 25620,
  ),
  ProvinceSocialBase(
    name: '河北',
    averageYuan: 6678,
    lowerYuan: 4007,
    upperYuan: 20034,
  ),
  ProvinceSocialBase(
    name: '山西',
    averageYuan: 6997,
    lowerYuan: 4198,
    upperYuan: 20991,
  ),
  ProvinceSocialBase(
    name: '内蒙古',
    averageYuan: 8179,
    lowerYuan: 4907,
    upperYuan: 24537,
  ),
  ProvinceSocialBase(
    name: '辽宁',
    averageYuan: 7264,
    lowerYuan: 4359,
    upperYuan: 21792,
  ),
  ProvinceSocialBase(
    name: '吉林',
    averageYuan: 7322,
    lowerYuan: 4393.2,
    upperYuan: 21966,
  ),
  ProvinceSocialBase(
    name: '黑龙江',
    averageYuan: 7570,
    lowerYuan: 4542,
    upperYuan: 22710,
  ),
  ProvinceSocialBase(
    name: '上海',
    averageYuan: 12434,
    lowerYuan: 7460,
    upperYuan: 37302,
  ),
  ProvinceSocialBase(
    name: '江苏',
    averageYuan: 8254,
    lowerYuan: 4952,
    upperYuan: 24762,
  ),
  ProvinceSocialBase(
    name: '浙江',
    averageYuan: 8433,
    lowerYuan: 4986,
    upperYuan: 25299,
  ),
  ProvinceSocialBase(
    name: '安徽',
    averageYuan: 7185,
    lowerYuan: 4311,
    upperYuan: 21556,
  ),
  ProvinceSocialBase(
    name: '福建',
    averageYuan: 7535,
    lowerYuan: 4043,
    upperYuan: 22607,
  ),
  ProvinceSocialBase(
    name: '江西',
    averageYuan: 6525,
    lowerYuan: 3915,
    upperYuan: 19575,
  ),
  ProvinceSocialBase(
    name: '山东',
    averageYuan: 7506,
    lowerYuan: 4504,
    upperYuan: 22518,
  ),
  ProvinceSocialBase(
    name: '河南',
    averageYuan: 6385,
    lowerYuan: 3831,
    upperYuan: 19155,
  ),
  ProvinceSocialBase(
    name: '湖北',
    averageYuan: 7496,
    lowerYuan: 4498,
    upperYuan: 22488,
  ),
  ProvinceSocialBase(
    name: '湖南',
    averageYuan: 6787,
    lowerYuan: 4072,
    upperYuan: 20361,
  ),
  ProvinceSocialBase(
    name: '广东',
    averageYuan: 9183,
    lowerYuan: 4775,
    upperYuan: 27549,
  ),
  ProvinceSocialBase(
    name: '广西',
    averageYuan: 6905,
    lowerYuan: 4143,
    upperYuan: 20715,
  ),
  ProvinceSocialBase(
    name: '海南',
    averageYuan: 8188,
    lowerYuan: 4912.8,
    upperYuan: 24564,
  ),
  ProvinceSocialBase(
    name: '重庆',
    averageYuan: 7339,
    lowerYuan: 4404,
    upperYuan: 22017,
  ),
  ProvinceSocialBase(
    name: '四川',
    averageYuan: 7646,
    lowerYuan: 4588,
    upperYuan: 22938,
  ),
  ProvinceSocialBase(
    name: '贵州',
    averageYuan: 7324.5,
    lowerYuan: 4394.7,
    upperYuan: 21973.5,
  ),
  ProvinceSocialBase(
    name: '云南',
    averageYuan: 7263,
    lowerYuan: 4357,
    upperYuan: 21789,
  ),
  ProvinceSocialBase(
    name: '西藏',
    averageYuan: 11777,
    lowerYuan: 7066.2,
    upperYuan: 35331,
  ),
  ProvinceSocialBase(
    name: '陕西',
    averageYuan: 7750,
    lowerYuan: 4650,
    upperYuan: 23250,
  ),
  ProvinceSocialBase(
    name: '甘肃',
    averageYuan: 7338,
    lowerYuan: 4403,
    upperYuan: 22014,
  ),
  ProvinceSocialBase(
    name: '青海',
    averageYuan: 8816,
    lowerYuan: 5289.6,
    upperYuan: 26448,
  ),
  ProvinceSocialBase(
    name: '宁夏',
    averageYuan: 8258,
    lowerYuan: 4955,
    upperYuan: 24774,
  ),
  ProvinceSocialBase(
    name: '新疆',
    averageYuan: 8448,
    lowerYuan: 5069,
    upperYuan: 25344,
  ),
];

const personalInsuranceRate = 0.105;

ProvinceSocialBase? provinceByName(String? name) {
  if (name == null) return null;
  for (final province in provinceSocialBases) {
    if (province.name == name) return province;
  }
  return null;
}

int estimatePersonalInsuranceCents(ProvinceSocialBase province) {
  return ((province.averageYuan * 100 * personalInsuranceRate) + 0.5).floor();
}

double estimatePersonalInsuranceYuan(ProvinceSocialBase province) {
  return estimatePersonalInsuranceCents(province) / 100;
}

String _group(double value) {
  final text = value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  final parts = text.split('.');
  final digits = parts.first;
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  return parts.length > 1 ? '$buffer.${parts[1]}' : buffer.toString();
}
