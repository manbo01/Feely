import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5728309026398735/3016837383'; // Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5728309026398735/5024620875'; // iOS
    }
    throw UnsupportedError("Unsupported platform");
  }

  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }
}
