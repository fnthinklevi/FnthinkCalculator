class HistoryEntry {
  const HistoryEntry({
    required this.expression,
    required this.resultText,
    required this.rawResult,
    required this.approximate,
    required this.createdAt,
  });

  final String expression;
  final String resultText;
  final String rawResult;
  final bool approximate;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {
      'expression': expression,
      'resultText': resultText,
      'rawResult': rawResult,
      'approximate': approximate,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HistoryEntry.fromJson(Map<String, Object?> json) {
    return HistoryEntry(
      expression: json['expression'] as String? ?? '',
      resultText: json['resultText'] as String? ?? '0',
      rawResult: json['rawResult'] as String? ?? '0',
      approximate: json['approximate'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
