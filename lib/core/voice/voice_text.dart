abstract final class VoiceText {
  static const _semantic = <String, String>{
    '加': '加',
    '减': '减',
    '乘': '乘',
    '除': '除',
    '百分号': '百分号',
    '清空': '清空',
    '退格': '退格',
    '小数点': '点',
    '科学计算': '切换',
    '标准计算': '切换',
    '切换科学计算': '切换',
    '切换标准计算': '切换',
    '正负号': '正负号',
    '左括号': '左括号',
    '右括号': '右括号',
    '正弦': '正弦',
    '余弦': '余弦',
    '正切': '正切',
    '反正弦': '反正弦',
    '反余弦': '反余弦',
    '反正切': '反正切',
    '自然对数': '自然对数',
    '常用对数': '常用对数',
    '十的幂': '十的幂',
    '自然指数': 'e 的幂',
    '平方根': '平方根',
    '平方': '平方',
    '乘方': '乘方',
    '阶乘': '阶乘',
    '倒数': '倒数',
    '圆周率': '圆周率',
    '自然常数': '自然常数',
    '第二功能': '第二功能',
    '角度单位': '角度',
  };

  static String? forSemantic(String semantic) {
    if (semantic.length == 1) {
      final code = semantic.codeUnitAt(0);
      if (code >= 48 && code <= 57) return semantic;
    }
    return _semantic[semantic];
  }

  static String forResult(String text, {bool approximate = false}) {
    final value = text.replaceAll(',', '').replaceAll('≈', '').trim();
    return '${approximate ? '约等于' : '等于'} $value';
  }

  static const error = '错误';
}
