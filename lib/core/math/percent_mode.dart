enum PercentMode {
  /// 100 + 50% = 100.5（将百分数换算为小数后参与运算）
  value,

  /// 100 + 50% = 150（百分数与前序结果相乘）
  proportion,
}
