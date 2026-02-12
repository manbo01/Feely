import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings.dart';
import '../models/diary_entry.dart';

class StorageService {
  static const String _entriesBox = 'diary_entries';
  static const String _settingsBox = 'settings';
  static const String _customTagsKey = 'custom_emotion_tags';
  static const String _hiddenDefaultTagsKey = 'hidden_default_emotion_tags';
  static const String _settingsKey = 'app_settings';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_entriesBox);
    await Hive.openBox<dynamic>(_settingsBox);
  }

  Box<dynamic> get _entries => Hive.box<dynamic>(_entriesBox);
  Box<dynamic> get _settings => Hive.box<dynamic>(_settingsBox);

  // ----- Diary entries -----
  Future<void> saveEntry(DiaryEntry entry) async {
    await _entries.put(entry.id, jsonEncode(entry.toJson()));
  }

  Future<void> deleteEntry(String id) async {
    await _entries.delete(id);
  }

  Future<DiaryEntry?> getEntry(String id) async {
    final raw = _entries.get(id);
    if (raw == null) return null;
    return DiaryEntry.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw as String) as Map),
    );
  }

  Future<List<DiaryEntry>> getAllEntries() async {
    final list = <DiaryEntry>[];
    for (final key in _entries.keys) {
      final raw = _entries.get(key);
      if (raw != null) {
        try {
          list.add(DiaryEntry.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw as String) as Map),
          ));
        } catch (_) {}
      }
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) async {
    final all = await getAllEntries();
    final day = DateTime(date.year, date.month, date.day);
    return all.where((e) {
      final eDay = DateTime(e.date.year, e.date.month, e.date.day);
      return eDay == day;
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<Set<DateTime>> getDatesWithEntries() async {
    final all = await getAllEntries();
    return all.map((e) => DateTime(e.date.year, e.date.month, e.date.day)).toSet();
  }

  // ----- Custom emotion tags -----
  Future<List<String>> getCustomEmotionTags() async {
    final raw = _settings.get(_customTagsKey);
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw as String) as List);
  }

  Future<void> setCustomEmotionTags(List<String> tags) async {
    await _settings.put(_customTagsKey, jsonEncode(tags));
  }

  Future<List<String>> getHiddenDefaultEmotionTags() async {
    final raw = _settings.get(_hiddenDefaultTagsKey);
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw as String) as List);
  }

  Future<void> setHiddenDefaultEmotionTags(List<String> tags) async {
    await _settings.put(_hiddenDefaultTagsKey, jsonEncode(tags));
  }

  // ----- App settings -----
  Future<AppSettings> getSettings() async {
    final raw = _settings.get(_settingsKey);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw as String) as Map),
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settings.put(_settingsKey, jsonEncode(settings.toJson()));
  }
}
