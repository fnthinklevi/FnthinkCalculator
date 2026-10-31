import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/voice/voice_clips.dart';

void main() {
  test('按键语义映射到短音频', () {
    expect(VoiceClips.forSemantic('7'), ['seven']);
    expect(VoiceClips.forSemantic('加'), ['plus']);
    expect(VoiceClips.forSemantic('乘'), ['multiply']);
    expect(VoiceClips.forSemantic('退格'), ['backspace']);
    expect(VoiceClips.forSemantic('等于'), isEmpty);
  });

  test('结果按中文读法拆分音频', () {
    expect(VoiceClips.number('123'), ['one', 'hundred', 'two', 'ten', 'three']);
    expect(VoiceClips.number('1005'), ['one', 'thousand', 'zero', 'five']);
    expect(VoiceClips.number('-40'), ['negative', 'four', 'ten']);
    expect(VoiceClips.number('1.05'), ['one', 'point', 'zero', 'five']);
  });

  test('等号结果带等于/约前缀', () {
    expect(VoiceClips.forResult('3'), ['equals', 'three']);
    expect(VoiceClips.forResult('3', approximate: true), [
      'equals',
      'approximate',
      'three',
    ]);
  });
}
