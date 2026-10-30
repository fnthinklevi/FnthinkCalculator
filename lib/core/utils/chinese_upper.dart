import '../math/math_error.dart';
import '../math/rational.dart';

class ChineseUpper {
  const ChineseUpper._();

  static const _digits = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖'];

  static const _groupUnits = ['', '万', '亿', '万亿'];
  static const _positionUnits = ['仟', '佰', '拾', ''];

  static String toRmb(String rawText) {
    final value = BigRational.parse(rawText);
    if (value.isZero) {
      return '零圆整';
    }
    final negative = value.isNegative;
    final absolute = value.abs;
    final cents = _roundToCents(absolute);
    if (cents == BigInt.zero) {
      return '零圆整';
    }
    final integerPart = cents ~/ BigInt.from(100);
    final fraction = (cents % BigInt.from(100)).toInt();
    if (integerPart.toString().length > 15) {
      throw const FormatException('数值过大，暂不支持人民币大写');
    }

    final jiao = fraction ~/ 10;
    final fen = fraction % 10;
    final buffer = StringBuffer();
    if (integerPart > BigInt.zero) {
      buffer.write('${_integerToChinese(integerPart)}圆');
    }
    if (jiao == 0 && fen == 0) {
      buffer.write('整');
    } else {
      if (integerPart > BigInt.zero && jiao == 0 && fen > 0) {
        buffer.write('零');
      }
      if (jiao > 0) {
        buffer.write('${_digits[jiao]}角');
      }
      if (fen > 0) {
        buffer.write('${_digits[fen]}分');
      }
    }
    final text = buffer.toString();
    return negative ? '负$text' : text;
  }

  static BigInt _roundToCents(BigRational value) {
    final scaled = value.n * BigInt.from(100);
    return (scaled * BigInt.two + value.d) ~/ (value.d * BigInt.two);
  }

  static String _integerToChinese(BigInt value) {
    if (value == BigInt.zero) {
      return '';
    }
    final groups = <int>[];
    var remaining = value;
    final tenThousand = BigInt.from(10000);
    while (remaining > BigInt.zero) {
      groups.add((remaining % tenThousand).toInt());
      remaining ~/= tenThousand;
    }
    if (groups.length > _groupUnits.length) {
      throw const FormatException('数值过大，暂不支持人民币大写');
    }

    final buffer = StringBuffer();
    var zeroPending = false;
    for (var index = groups.length - 1; index >= 0; index--) {
      final group = groups[index];
      if (group == 0) {
        if (buffer.isNotEmpty) {
          zeroPending = true;
        }
        continue;
      }
      if (buffer.isNotEmpty && (zeroPending || group < 1000)) {
        buffer.write('零');
      }
      zeroPending = false;
      buffer.write(_groupToChinese(group));
      buffer.write(_groupUnits[index]);
    }
    return buffer.toString();
  }

  static String _groupToChinese(int group) {
    final digits = group.toString().padLeft(4, '0');
    final buffer = StringBuffer();
    var zeroPending = false;
    for (var index = 0; index < 4; index++) {
      final digit = digits.codeUnitAt(index) - 48;
      if (digit == 0) {
        if (buffer.isNotEmpty) {
          zeroPending = true;
        }
        continue;
      }
      if (zeroPending) {
        buffer.write('零');
        zeroPending = false;
      }
      buffer.write('${_digits[digit]}${_positionUnits[index]}');
    }
    return buffer.toString();
  }

  static String errorMessage(Object error) {
    if (error is MathException) {
      return error.message;
    }
    if (error is FormatException) {
      return error.message;
    }
    return '该结果暂不支持人民币大写';
  }
}
