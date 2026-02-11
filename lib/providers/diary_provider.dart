import 'package:flutter/foundation.dart';

import '../constants/emotions.dart';
import '../models/diary_entry.dart';
import '../repositories/diary_repository.dart';
import '../services/storage_service.dart';

class DiaryProvider with ChangeNotifier {
  DiaryProvider() : _repo = DiaryRepository(StorageService()) {
    _load();
  }

  final DiaryRepository _repo;
  List<DiaryEntry> _allEntries = [];
  List<String> _customTags = [];
  bool _loaded = false;

  List<DiaryEntry> get allEntries => List.unmodifiable(_allEntries);
  bool get loaded => _loaded;

  List<String> get allEmotionTags => [...defaultEmotionTags, ..._customTags];

  Future<void> _load() async {
    try {
      final storage = StorageService();
      _allEntries = await _repo.getAllEntries();
      _customTags = await storage.getCustomEmotionTags();
    } catch (_) {
      _allEntries = [];
      _customTags = [];
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> addOrUpdateEntry(DiaryEntry entry) async {
    await _repo.addOrUpdateEntry(entry);
    await _load();
  }

  Future<void> saveEntry(DiaryEntry entry) async {
    await _repo.addOrUpdateEntry(entry);
    await _load();
  }

  Future<void> deleteEntry(String id) async {
    await _repo.deleteEntry(id);
    await _load();
  }

  Future<DiaryEntry?> getEntry(String id) => _repo.getEntry(id);

  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) =>
      _repo.getEntriesForDate(date);

  Future<Set<DateTime>> getDatesWithEntries() =>
      _repo.getDatesWithEntries();

  Future<void> setCustomEmotionTags(List<String> tags) async {
    final storage = StorageService();
    await storage.init();
    await storage.setCustomEmotionTags(tags);
    _customTags = tags;
    notifyListeners();
  }
}
