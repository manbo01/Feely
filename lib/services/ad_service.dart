import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android 테스트 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 ID
    }
    throw UnsupportedError("Unsupported platform");
  }

  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }
}
