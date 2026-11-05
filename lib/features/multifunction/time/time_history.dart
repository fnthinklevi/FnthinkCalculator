import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TimeHistoryEntry {
  const TimeHistoryEntry({
    required this.expression,
    required this.resultText,
    required this.createdAt,
  });

  final String expression;
  final String resultText;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {
      'expression': expression,
      'resultText': resultText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TimeHistoryEntry.fromJson(Map<String, Object?> json) {
    return TimeHistoryEntry(
      expression: json['expression'] as String? ?? '',
      resultText: json['resultText'] as String? ?? '0',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

abstract interface class TimeHistoryStore {
  List<TimeHistoryEntry> load();

  Future<void> save(List<TimeHistoryEntry> entries);
}

class TimeHistoryRepository implements TimeHistoryStore {
  TimeHistoryRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'timeHistory.v1';
  static const _limit = 100;

  @override
  List<TimeHistoryEntry> load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final entries = <TimeHistoryEntry>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final entry = TimeHistoryEntry.fromJson(
          Map<String, Object?>.from(item),
        );
        if (entry.expression.isEmpty) continue;
        entries.add(entry);
        if (entries.length >= _limit) break;
      }
      return entries;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(List<TimeHistoryEntry> entries) async {
    final data = jsonEncode(
      entries.take(_limit).map((entry) => entry.toJson()).toList(),
    );
    await _prefs.setString(_key, data);
  }
}

class MemoryTimeHistoryStore implements TimeHistoryStore {
  final List<TimeHistoryEntry> _entries = [];

  @override
  List<TimeHistoryEntry> load() => List<TimeHistoryEntry>.of(_entries);

  @override
  Future<void> save(List<TimeHistoryEntry> entries) async {
    _entries
      ..clear()
      ..addAll(entries.take(100));
  }
}

Future<TimeHistoryStore> defaultTimeHistoryStore() async {
  try {
    return TimeHistoryRepository(await SharedPreferences.getInstance());
  } catch (_) {
    return MemoryTimeHistoryStore();
  }
}
