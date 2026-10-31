abstract final class VoiceClips {
  static const _digits = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
  ];

  static const _semantic = <String, String>{
    '加': 'plus',
    '减': 'minus',
    '乘': 'multiply',
    '除': 'divide',
    '百分号': 'percent',
    '清空': 'clear',
    '退格': 'backspace',
    '小数点': 'point',
    '科学计算': 'switch',
    '标准计算': 'switch',
    '切换科学计算': 'switch',
    '切换标准计算': 'switch',
    '正负号': 'sign',
    '左括号': 'left_paren',
    '右括号': 'right_paren',
    '正弦': 'sin',
    '余弦': 'cos',
    '正切': 'tan',
    '反正弦': 'asin',
    '反余弦': 'acos',
    '反正切': 'atan',
    '自然对数': 'ln',
    '常用对数': 'log',
    '十的幂': 'power',
    '自然指数': 'e',
    '平方根': 'sqrt',
    '平方': 'power',
    '乘方': 'power',
    '阶乘': 'factorial',
    '倒数': 'reciprocal',
    '圆周率': 'pi',
    '自然常数': 'e',
    '第二功能': 'second',
    '角度单位': 'angle',
  };

  static List<String> forSemantic(String semantic) {
    if (semantic.length == 1 &&
        semantic.codeUnitAt(0) >= 48 &&
        semantic.codeUnitAt(0) <= 57) {
      return [_digits[semantic.codeUnitAt(0) - 48]];
    }
    final clip = _semantic[semantic];
    return clip == null ? const [] : [clip];
  }

  static List<String> forResult(String text, {bool approximate = false}) {
    final clips = <String>['equals'];
    if (approximate) clips.add('approximate');
    clips.addAll(number(text));
    return clips;
  }

  static List<String> number(String raw) {
    var text = raw.replaceAll(',', '').replaceAll('≈', '').trim();
    if (text.isEmpty) return const ['zero'];
    final clips = <String>[];
    if (text.startsWith('-')) {
      clips.add('negative');
      text = text.substring(1);
    }
    if (text.contains(RegExp(r'[eE]'))) {
      for (final char in text.split('')) {
        final code = char.codeUnitAt(0);
        if (code >= 48 && code <= 57) {
          clips.add(_digits[code - 48]);
        } else if (char == '.') {
          clips.add('point');
        } else if (char == '-') {
          clips.add('negative');
        }
      }
      if (clips.isEmpty) clips.add('result');
      return clips;
    }
    final parts = text.split('.');
    clips.addAll(_integer(parts.first));
    if (parts.length > 1) {
      clips.add('point');
      for (final char in parts[1].split('')) {
        final code = char.codeUnitAt(0);
        if (code >= 48 && code <= 57) clips.add(_digits[code - 48]);
      }
    }
    return clips;
  }

  static List<String> _integer(String digits) {
    final trimmed = digits.replaceFirst(RegExp(r'^0+'), '');
    if (trimmed.isEmpty) return const ['zero'];
    if (trimmed.length > 12) {
      return [
        for (final char in trimmed.split('')) _digits[char.codeUnitAt(0) - 48],
      ];
    }
    final groups = <String>[];
    for (var end = trimmed.length; end > 0; end -= 4) {
      final start = end - 4 < 0 ? 0 : end - 4;
      groups.add(trimmed.substring(start, end));
    }
    final clips = <String>[];
    var zeroPending = false;
    for (var index = groups.length - 1; index >= 0; index--) {
      final group = int.parse(groups[index]);
      if (group == 0) {
        if (clips.isNotEmpty) zeroPending = true;
        continue;
      }
      if (clips.isNotEmpty && (zeroPending || group < 1000)) {
        clips.add('zero');
      }
      clips.addAll(_group(group));
      if (index == 1) clips.add('ten_thousand');
      if (index == 2) clips.add('hundred_million');
      zeroPending = false;
    }
    return clips;
  }

  static List<String> _group(int group) {
    final digits = group.toString().padLeft(4, '0');
    const units = ['thousand', 'hundred', 'ten', ''];
    final clips = <String>[];
    var zeroPending = false;
    for (var index = 0; index < 4; index++) {
      final digit = digits.codeUnitAt(index) - 48;
      if (digit == 0) {
        if (clips.isNotEmpty) zeroPending = true;
        continue;
      }
      if (zeroPending) {
        clips.add('zero');
        zeroPending = false;
      }
      clips.add(_digits[digit]);
      if (units[index].isNotEmpty) clips.add(units[index]);
    }
    return clips;
  }
}
