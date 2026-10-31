import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/voice/voice_text.dart';

void main() {
  test('按键语义映射到系统语音文本', () {
    expect(VoiceText.forSemantic('7'), '7');
    expect(VoiceText.forSemantic('加'), '加');
    expect(VoiceText.forSemantic('乘'), '乘');
    expect(VoiceText.forSemantic('退格'), '退格');
    expect(VoiceText.forSemantic('等于'), isNull);
  });

  test('结果与错误播报文本', () {
    expect(VoiceText.forResult('1,234.5'), '等于 1234.5');
    expect(VoiceText.forResult('3', approximate: true), '约等于 3');
    expect(VoiceText.error, '错误');
  });
}
