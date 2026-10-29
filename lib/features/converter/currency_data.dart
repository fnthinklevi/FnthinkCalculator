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
  static const aud = CurrencyDef(code: 'AUD', name: '澳元', symbol: r'A$');
  static const cad = CurrencyDef(code: 'CAD', name: '加元', symbol: r'C$');
  static const sgd = CurrencyDef(code: 'SGD', name: '新加坡元', symbol: r'S$');
  static const chf = CurrencyDef(code: 'CHF', name: '瑞士法郎', symbol: 'CHF');
  static const thb = CurrencyDef(code: 'THB', name: '泰铢', symbol: '฿');
  static const twd = CurrencyDef(code: 'TWD', name: '新台币', symbol: r'NT$');
  static const mop = CurrencyDef(code: 'MOP', name: '澳门元', symbol: r'MOP$');
  static const myr = CurrencyDef(code: 'MYR', name: '马来西亚林吉特', symbol: 'RM');
  static const nzd = CurrencyDef(code: 'NZD', name: '新西兰元', symbol: r'NZ$');
  static const vnd = CurrencyDef(code: 'VND', name: '越南盾', symbol: '₫');
  static const php = CurrencyDef(code: 'PHP', name: '菲律宾比索', symbol: '₱');
  static const idr = CurrencyDef(code: 'IDR', name: '印尼盾', symbol: 'Rp');
  static const inr = CurrencyDef(code: 'INR', name: '印度卢比', symbol: '₹');
  static const rub = CurrencyDef(code: 'RUB', name: '俄罗斯卢布', symbol: '₽');
  static const aed = CurrencyDef(code: 'AED', name: '阿联酋迪拉姆', symbol: 'AED');
  static const sar = CurrencyDef(code: 'SAR', name: '沙特里亚尔', symbol: 'SAR');
  static const brl = CurrencyDef(code: 'BRL', name: '巴西雷亚尔', symbol: r'R$');
  static const mxn = CurrencyDef(code: 'MXN', name: '墨西哥比索', symbol: r'MX$');
  static const tryLira = CurrencyDef(code: 'TRY', name: '土耳其里拉', symbol: '₺');
  static const zar = CurrencyDef(code: 'ZAR', name: '南非兰特', symbol: 'R');
  static const sek = CurrencyDef(code: 'SEK', name: '瑞典克朗', symbol: 'kr');
  static const nok = CurrencyDef(code: 'NOK', name: '挪威克朗', symbol: 'kr');
  static const dkk = CurrencyDef(code: 'DKK', name: '丹麦克朗', symbol: 'kr');
  static const pln = CurrencyDef(code: 'PLN', name: '波兰兹罗提', symbol: 'zł');

  static const common = <CurrencyDef>[cny, usd, eur, jpy, hkd, gbp, krw];

  static const all = <CurrencyDef>[
    cny,
    usd,
    eur,
    jpy,
    hkd,
    gbp,
    krw,
    aud,
    cad,
    sgd,
    chf,
    thb,
    twd,
    mop,
    myr,
    nzd,
    vnd,
    php,
    idr,
    inr,
    rub,
    aed,
    sar,
    brl,
    mxn,
    tryLira,
    zar,
    sek,
    nok,
    dkk,
    pln,
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
