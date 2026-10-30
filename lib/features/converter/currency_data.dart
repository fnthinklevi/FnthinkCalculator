class CurrencyDef {
  const CurrencyDef({
    required this.code,
    required this.name,
    required this.symbol,
  });

  final String code;
  final String name;
  final String symbol;
}

abstract final class CurrencyData {
  static const cny = CurrencyDef(code: 'CNY', name: '人民币', symbol: '¥');
  static const usd = CurrencyDef(code: 'USD', name: '美元', symbol: r'$');
  static const eur = CurrencyDef(code: 'EUR', name: '欧元', symbol: '€');
  static const jpy = CurrencyDef(code: 'JPY', name: '日元', symbol: '¥');
  static const hkd = CurrencyDef(code: 'HKD', name: '港币', symbol: r'HK$');
  static const gbp = CurrencyDef(code: 'GBP', name: '英镑', symbol: '£');
  static const krw = CurrencyDef(code: 'KRW', name: '韩元', symbol: '₩');
  static const aud = CurrencyDef(code: 'AUD', name: '澳大利亚元', symbol: r'A$');
  static const cad = CurrencyDef(code: 'CAD', name: '加拿大元', symbol: r'C$');
  static const sgd = CurrencyDef(code: 'SGD', name: '新加坡元', symbol: r'S$');
  static const chf = CurrencyDef(code: 'CHF', name: '瑞士法郎', symbol: 'CHF');
  static const thb = CurrencyDef(code: 'THB', name: '泰铢', symbol: '฿');
  static const twd = CurrencyDef(code: 'TWD', name: '新台币', symbol: r'NT$');
  static const mop = CurrencyDef(code: 'MOP', name: '澳门元', symbol: r'MOP$');
  static const myr = CurrencyDef(code: 'MYR', name: '马来西亚林吉特', symbol: 'RM');

  static const common = <CurrencyDef>[cny, usd, eur, jpy, hkd, gbp, krw];

  static final all = <CurrencyDef>[
    CurrencyDef(code: 'CNY', name: '人民币', symbol: '¥'),
    CurrencyDef(code: 'USD', name: '美元', symbol: r'$'),
    CurrencyDef(code: 'EUR', name: '欧元', symbol: '€'),
    CurrencyDef(code: 'JPY', name: '日元', symbol: '¥'),
    CurrencyDef(code: 'HKD', name: '港币', symbol: r'HK$'),
    CurrencyDef(code: 'KRW', name: '韩元', symbol: '₩'),
    CurrencyDef(code: 'GBP', name: '英镑', symbol: '£'),
    CurrencyDef(code: 'THB', name: '泰铢', symbol: '฿'),
    CurrencyDef(code: 'BTN', name: '不丹努尔特鲁姆', symbol: 'BTN'),
    CurrencyDef(code: 'DKK', name: '丹麦克朗', symbol: 'kr'),
    CurrencyDef(code: 'UAH', name: '乌克兰格里夫纳', symbol: 'UAH'),
    CurrencyDef(code: 'UZS', name: '乌兹别克斯坦索姆', symbol: 'UZS'),
    CurrencyDef(code: 'UGX', name: '乌干达先令', symbol: 'UGX'),
    CurrencyDef(code: 'UYU', name: '乌拉圭比索', symbol: 'UYU'),
    CurrencyDef(code: 'YER', name: '也门里亚尔', symbol: 'YER'),
    CurrencyDef(code: 'ILS', name: '以色列新谢克尔', symbol: 'ILS'),
    CurrencyDef(code: 'IQD', name: '伊拉克第纳尔', symbol: 'IQD'),
    CurrencyDef(code: 'IRR', name: '伊朗里亚尔', symbol: 'IRR'),
    CurrencyDef(code: 'RUB', name: '俄罗斯卢布', symbol: '₽'),
    CurrencyDef(code: 'BGN', name: '保加利亚新列弗', symbol: 'BGN'),
    CurrencyDef(code: 'HRK', name: '克罗地亚库纳', symbol: 'HRK'),
    CurrencyDef(code: 'ISK', name: '冰岛克朗', symbol: 'ISK'),
    CurrencyDef(code: 'GNF', name: '几内亚法郎', symbol: 'GNF'),
    CurrencyDef(code: 'CDF', name: '刚果法郎', symbol: 'CDF'),
    CurrencyDef(code: 'LYD', name: '利比亚第纳尔', symbol: 'LYD'),
    CurrencyDef(code: 'LRD', name: '利比里亚元', symbol: 'LRD'),
    CurrencyDef(code: 'CAD', name: '加拿大元', symbol: r'C$'),
    CurrencyDef(code: 'GHS', name: '加纳塞地', symbol: 'GHS'),
    CurrencyDef(code: 'HUF', name: '匈牙利福林', symbol: 'HUF'),
    CurrencyDef(code: 'ZAR', name: '南非兰特', symbol: 'R'),
    CurrencyDef(code: 'BWP', name: '博茨瓦纳普拉', symbol: 'BWP'),
    CurrencyDef(code: 'QAR', name: '卡塔尔里亚尔', symbol: 'QAR'),
    CurrencyDef(code: 'INR', name: '印度卢比', symbol: '₹'),
    CurrencyDef(code: 'IDR', name: '印度尼西亚盾', symbol: 'Rp'),
    CurrencyDef(code: 'SYP', name: '叙利亚镑', symbol: 'SYP'),
    CurrencyDef(code: 'CUP', name: '古巴比索', symbol: 'CUP'),
    CurrencyDef(code: 'KGS', name: '吉尔吉斯斯坦索姆', symbol: 'KGS'),
    CurrencyDef(code: 'KZT', name: '哈萨克斯坦坚戈', symbol: 'KZT'),
    CurrencyDef(code: 'COP', name: '哥伦比亚比索', symbol: 'COP'),
    CurrencyDef(code: 'CRC', name: '哥斯达黎加科朗', symbol: 'CRC'),
    CurrencyDef(code: 'TMT', name: '土库曼斯坦马纳特', symbol: 'TMT'),
    CurrencyDef(code: 'TRY', name: '土耳其里拉', symbol: '₺'),
    CurrencyDef(code: 'TZS', name: '坦桑尼亚先令', symbol: 'TZS'),
    CurrencyDef(code: 'EGP', name: '埃及镑', symbol: 'EGP'),
    CurrencyDef(code: 'ETB', name: '埃塞俄比亚比尔', symbol: 'ETB'),
    CurrencyDef(code: 'RSD', name: '塞尔维亚第纳尔', symbol: 'RSD'),
    CurrencyDef(code: 'SCR', name: '塞舌尔卢比', symbol: 'SCR'),
    CurrencyDef(code: 'MXN', name: '墨西哥比索', symbol: r'MX$'),
    CurrencyDef(code: 'VES', name: '委内瑞拉玻利瓦尔', symbol: 'VES'),
    CurrencyDef(code: 'BDT', name: '孟加拉塔卡', symbol: 'BDT'),
    CurrencyDef(code: 'NGN', name: '尼日利亚奈拉', symbol: 'NGN'),
    CurrencyDef(code: 'NPR', name: '尼泊尔卢比', symbol: 'NPR'),
    CurrencyDef(code: 'BSD', name: '巴哈马元', symbol: 'BSD'),
    CurrencyDef(code: 'PKR', name: '巴基斯坦卢比', symbol: 'PKR'),
    CurrencyDef(code: 'BBD', name: '巴巴多斯元', symbol: 'BBD'),
    CurrencyDef(code: 'PYG', name: '巴拉圭瓜拉尼', symbol: 'PYG'),
    CurrencyDef(code: 'BHD', name: '巴林第纳尔', symbol: 'BHD'),
    CurrencyDef(code: 'BRL', name: '巴西雷亚尔', symbol: r'R$'),
    CurrencyDef(code: 'NOK', name: '挪威克朗', symbol: 'kr'),
    CurrencyDef(code: 'CZK', name: '捷克克郎', symbol: 'CZK'),
    CurrencyDef(code: 'MDL', name: '摩尔多瓦列伊', symbol: 'MDL'),
    CurrencyDef(code: 'MAD', name: '摩洛哥迪拉姆', symbol: 'MAD'),
    CurrencyDef(code: 'BND', name: '文莱元', symbol: 'BND'),
    CurrencyDef(code: 'FJD', name: '斐济元', symbol: 'FJD'),
    CurrencyDef(code: 'LKR', name: '斯里兰卡卢比', symbol: 'LKR'),
    CurrencyDef(code: 'SGD', name: '新加坡元', symbol: r'S$'),
    CurrencyDef(code: 'TWD', name: '新台币', symbol: r'NT$'),
    CurrencyDef(code: 'NZD', name: '新西兰元', symbol: r'NZ$'),
    CurrencyDef(code: 'CLP', name: '智利比索', symbol: 'CLP'),
    CurrencyDef(code: 'KPW', name: '朝鲜元', symbol: 'KPW'),
    CurrencyDef(code: 'KHR', name: '柬埔寨瑞尔', symbol: 'KHR'),
    CurrencyDef(code: 'GEL', name: '格鲁吉亚拉里', symbol: 'GEL'),
    CurrencyDef(code: 'MRU', name: '毛里塔尼亚乌吉亚', symbol: 'MRU'),
    CurrencyDef(code: 'MUR', name: '毛里求斯卢比', symbol: 'MUR'),
    CurrencyDef(code: 'SAR', name: '沙特里亚尔', symbol: 'SAR'),
    CurrencyDef(code: 'PLN', name: '波兰兹罗提', symbol: 'zł'),
    CurrencyDef(code: 'JEP', name: '泽西镑', symbol: 'JEP'),
    CurrencyDef(code: 'AUD', name: '澳大利亚元', symbol: r'A$'),
    CurrencyDef(code: 'MOP', name: '澳门元', symbol: r'MOP$'),
    CurrencyDef(code: 'JMD', name: '牙买加元', symbol: 'JMD'),
    CurrencyDef(code: 'BOB', name: '玻利维亚诺', symbol: 'BOB'),
    CurrencyDef(code: 'SEK', name: '瑞典克朗', symbol: 'kr'),
    CurrencyDef(code: 'CHF', name: '瑞士法郎', symbol: 'CHF'),
    CurrencyDef(code: 'BYN', name: '白俄罗斯卢布', symbol: 'BYN'),
    CurrencyDef(code: 'BMD', name: '百慕大元', symbol: 'BMD'),
    CurrencyDef(code: 'CNH', name: '离岸人民币', symbol: 'CNH'),
    CurrencyDef(code: 'KWD', name: '科威特第纳尔', symbol: 'KWD'),
    CurrencyDef(code: 'PEN', name: '秘鲁索尔', symbol: 'PEN'),
    CurrencyDef(code: 'TND', name: '突尼斯第纳尔', symbol: 'TND'),
    CurrencyDef(code: 'JOD', name: '约旦第纳尔', symbol: 'JOD'),
    CurrencyDef(code: 'NAD', name: '纳米比亚元', symbol: 'NAD'),
    CurrencyDef(code: 'MMK', name: '缅甸元', symbol: 'MMK'),
    CurrencyDef(code: 'RON', name: '罗马尼亚列伊', symbol: 'RON'),
    CurrencyDef(code: 'LAK', name: '老挝基普', symbol: 'LAK'),
    CurrencyDef(code: 'KES', name: '肯尼亚先令', symbol: 'KES'),
    CurrencyDef(code: 'SDG', name: '苏丹镑', symbol: 'SDG'),
    CurrencyDef(code: 'PHP', name: '菲律宾比索', symbol: '₱'),
    CurrencyDef(code: 'MNT', name: '蒙古图格里克', symbol: 'MNT'),
    CurrencyDef(code: 'ZMW', name: '赞比亚克瓦查', symbol: 'ZMW'),
    CurrencyDef(code: 'VND', name: '越南盾', symbol: '₫'),
    CurrencyDef(code: 'AZN', name: '阿塞拜疆马纳特', symbol: 'AZN'),
    CurrencyDef(code: 'AFN', name: '阿富汗尼', symbol: 'AFN'),
    CurrencyDef(code: 'DZD', name: '阿尔及利亚第纳尔', symbol: 'DZD'),
    CurrencyDef(code: 'OMR', name: '阿曼里亚尔', symbol: 'OMR'),
    CurrencyDef(code: 'ARS', name: '阿根廷比索', symbol: 'ARS'),
    CurrencyDef(code: 'AED', name: '阿联酋迪拉姆', symbol: 'AED'),
    CurrencyDef(code: 'MVR', name: '马尔代夫拉菲亚', symbol: 'MVR'),
    CurrencyDef(code: 'MYR', name: '马来西亚林吉特', symbol: 'RM'),
    CurrencyDef(code: 'LBP', name: '黎巴嫩镑', symbol: 'LBP'),
  ];

  static final Map<String, CurrencyDef> byCode = {
    for (final currency in all) currency.code: currency,
  };

  static const commonCodes = <String>{
    'CNY',
    'USD',
    'EUR',
    'JPY',
    'HKD',
    'GBP',
    'KRW',
  };
}
