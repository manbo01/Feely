import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'config/naver_map_config.dart';
import 'services/storage_service.dart';
import 'src/naver_map_platform_io.dart' if (dart.library.html) 'src/naver_map_platform_stub.dart' as naver_platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('ko', null);
  } catch (_) {}
  if (naver_platform.isNaverMapSupported) {
    try {
      await FlutterNaverMap().init(
        clientId: naverMapClientId,
        onAuthFailed: (ex) {
          debugPrint('Naver Map 인증 실패: $ex');
        },
      );
    } catch (e, st) {
      debugPrint('Naver Map 초기화 실패: $e');
      debugPrintStack(stackTrace: st);
    }
  }
  try {
    final storage = StorageService();
    await storage.init();
  } catch (_) {
    // 웹 등에서 Hive 초기화 실패 시에도 앱은 실행 (프로바이더에서 기본값 사용)
  }
  runApp(const FeelyApp());
}
