import '../models/diary_entry.dart';
import '../services/storage_service.dart';

class DiaryRepository {
  DiaryRepository(this._storage);

  final StorageService _storage;

  Future<void> addEntry(DiaryEntry entry) => _storage.saveEntry(entry);
  Future<void> updateEntry(DiaryEntry entry) => _storage.saveEntry(entry);
  Future<void> addOrUpdateEntry(DiaryEntry entry) => _storage.saveEntry(entry);
  Future<void> deleteEntry(String id) => _storage.deleteEntry(id);
  Future<DiaryEntry?> getEntry(String id) => _storage.getEntry(id);
  Future<List<DiaryEntry>> getAllEntries() => _storage.getAllEntries();
  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) =>
      _storage.getEntriesForDate(date);
  Future<Set<DateTime>> getDatesWithEntries() =>
      _storage.getDatesWithEntries();
}
