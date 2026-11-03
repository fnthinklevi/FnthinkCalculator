import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/utils/kinship.dart';

List<String> chain(String value) => value.split('');

void main() {
  test('扩展直系、姻亲与堂表亲称呼', () {
    const cases = <String, String>{
      '夫父兄': '伯公',
      '夫父弟': '叔公',
      '夫父姐': '姑婆',
      '夫母姐': '姨婆',
      '夫兄': '大伯子',
      '夫妹': '小姑子',
      '妻兄': '大舅子',
      '妻妹': '小姨子',
      '夫兄妻': '大嫂',
      '妻姐父': '连襟',
      '夫姐子': '外甥',
      '妻妹女': '外甥女',
      '妻兄子': '侄子',
      '父兄妻': '伯母',
      '父弟妻': '婶婶',
      '父姐父': '姑父',
      '母妹夫': '姨父',
      '父兄子': '堂兄/堂弟',
      '父姐女': '表姐/表妹',
      '母妹子': '表兄/表弟',
      '子妻': '儿媳',
      '女夫': '女婿',
      '子妻父': '亲家公',
      '女夫母': '亲家母',
      '父父兄': '伯公',
      '父母妹': '姨婆',
      '兄子子': '侄孙',
      '弟子女': '侄孙女',
    };
    cases.forEach((path, expected) {
      expect(Kinship.direct(chain(path)), expected, reason: path);
    });
  });

  test('扩展反向称呼', () {
    const cases = <String, String>{
      '夫父兄': '侄媳',
      '夫母姐': '外甥媳',
      '夫兄': '弟媳',
      '夫弟': '嫂子',
      '妻弟': '姐夫',
      '妻妹': '姐夫',
      '夫姐子': '舅妈',
      '妻兄子': '姑父',
      '妻姐子': '姨父',
      '父兄妻': '侄子/侄女',
      '母妹夫': '外甥/外甥女',
      '子妻': '公公/婆婆',
      '女夫': '岳父/岳母',
      '子妻父': '亲家公/亲家母',
      '父父兄': '侄孙/侄孙女',
      '父母妹': '外甥孙/外甥孙女',
    };
    cases.forEach((path, expected) {
      expect(Kinship.reciprocal(chain(path)), expected, reason: path);
    });
  });

  test('已知路径保持原有称呼', () {
    expect(Kinship.direct(chain('父父')), '爷爷');
    expect(Kinship.direct(chain('父兄')), '伯父');
    expect(Kinship.direct(chain('兄妻')), '嫂子');
    expect(Kinship.reciprocal(chain('父父')), '孙女/孙子');
    expect(Kinship.direct(chain('父父父')), '曾祖父');
  });
}
