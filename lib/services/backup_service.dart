import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../models/diary_entry.dart';
import 'storage_service.dart';

class BackupService {
  final StorageService _storage = StorageService();

  /// 모든 데이터를 JSON 파일로 내보내고 공유 시트를 띄운다.
  Future<void> exportData() async {
    final entries = await _storage.getAllEntries();
    final customTags = await _storage.getCustomEmotionTags();
    final hiddenTags = await _storage.getHiddenDefaultEmotionTags();
    final settings = await _storage.getSettings();

    final backup = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'customEmotionTags': customTags,
      'hiddenDefaultEmotionTags': hiddenTags,
      'settings': settings.toJson(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(backup);

    final dir = await getTemporaryDirectory();
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/feely_backup_$dateStr.json');
    await file.writeAsString(jsonStr);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Feely 백업 데이터',
    );
  }

  /// JSON 파일을 선택해 데이터를 복원한다.
  /// 반환값: 복원된 일기 수, null이면 취소됨.
  Future<int?> importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    final jsonStr = await file.readAsString();
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    // 일기 데이터 복원
    final entriesJson = data['entries'] as List?;
    int count = 0;
    if (entriesJson != null) {
      for (final e in entriesJson) {
        final entry = DiaryEntry.fromJson(Map<String, dynamic>.from(e as Map));
        await _storage.saveEntry(entry);
        count++;
      }
    }

    // 커스텀 감정 태그 복원
    final customTags = data['customEmotionTags'] as List?;
    if (customTags != null) {
      await _storage.setCustomEmotionTags(List<String>.from(customTags));
    }

    // 숨긴 기본 태그 복원
    final hiddenTags = data['hiddenDefaultEmotionTags'] as List?;
    if (hiddenTags != null) {
      await _storage.setHiddenDefaultEmotionTags(List<String>.from(hiddenTags));
    }

    return count;
  }
}
