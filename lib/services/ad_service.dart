import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4076454443271072/5400113712'; // Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4076454443271072/7324762419'; // iOS
    }
    throw UnsupportedError("Unsupported platform");
  }

  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }
}
