import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'history_entry.dart';

abstract interface class HistoryStore {
  List<HistoryEntry> load();

  Future<void> save(List<HistoryEntry> entries);
}

class HistoryRepository implements HistoryStore {
  HistoryRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'history.v1';
  static const _limit = 200;

  @override
  List<HistoryEntry> load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }
      final entries = <HistoryEntry>[];
      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }
        final entry = HistoryEntry.fromJson(Map<String, Object?>.from(item));
        if (entry.expression.isEmpty) {
          continue;
        }
        entries.add(entry);
        if (entries.length >= _limit) {
          break;
        }
      }
      return entries;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(List<HistoryEntry> entries) async {
    final data = jsonEncode(
      entries.take(_limit).map((entry) => entry.toJson()).toList(),
    );
    await _prefs.setString(_key, data);
  }
}
